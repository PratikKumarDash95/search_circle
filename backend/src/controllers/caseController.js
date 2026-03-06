const Case = require('../models/Case');
const Sighting = require('../models/Sighting');
const Alert = require('../models/Alert');
const User = require('../models/User');
const Reward = require('../models/Reward');
const ChatRoom = require('../models/ChatRoom');

// ─── Get Cases (with filters) ──────────────────────────────────
exports.getCases = async (req, res) => {
  try {
    const { filter, lat, lng, radius, page = 1, limit = 20, search } = req.query;

    let query = {};
    let sort = { createdAt: -1 };

    // Apply filters
    switch (filter) {
      case 'urgent':
        query.status = 'urgent';
        break;
      case 'recent':
        query.createdAt = { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) };
        break;
      case 'resolved':
        query.status = { $in: ['found', 'closed'] };
        break;
      case 'near_me':
        if (lat && lng) {
          query.gps = {
            $nearSphere: {
              $geometry: {
                type: 'Point',
                coordinates: [parseFloat(lng), parseFloat(lat)],
              },
              $maxDistance: (parseFloat(radius) || 10) * 1609.34, // miles to meters
            },
          };
        }
        break;
      default:
        query.status = { $in: ['active', 'urgent'] };
    }

    // Text search
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
      ];
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const [cases, total] = await Promise.all([
      Case.find(query)
        .sort(sort)
        .skip(skip)
        .limit(parseInt(limit))
        .populate('reporter_id', 'name avatar_url')
        .populate('assigned_officer_id', 'name avatar_url')
        .lean(),
      Case.countDocuments(query),
    ]);

    // Calculate distance if user coords provided
    const casesWithDistance = cases.map((c) => {
      let distance = null;
      if (lat && lng && c.gps && c.gps.coordinates) {
        distance = calculateDistance(
          parseFloat(lat),
          parseFloat(lng),
          c.gps.coordinates[1],
          c.gps.coordinates[0]
        );
      }
      return {
        ...c,
        distance: distance ? `${distance.toFixed(1)} miles away` : null,
        time_ago: getTimeAgo(c.createdAt),
      };
    });

    res.status(200).json({
      success: true,
      cases: casesWithDistance,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit)),
      },
    });
  } catch (error) {
    console.error('getCases error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─── Get Single Case ───────────────────────────────────────────
exports.getCaseById = async (req, res) => {
  try {
    const caseData = await Case.findById(req.params.id)
      .populate('reporter_id', 'name avatar_url phone')
      .populate('assigned_officer_id', 'name avatar_url')
      .lean();

    if (!caseData) {
      return res.status(404).json({ success: false, message: 'Case not found' });
    }

    // Get sightings for this case
    const sightings = await Sighting.find({ case_id: req.params.id })
      .populate('reporter_id', 'name avatar_url')
      .sort({ createdAt: -1 })
      .limit(20)
      .lean();

    res.status(200).json({
      success: true,
      case: {
        ...caseData,
        time_ago: getTimeAgo(caseData.createdAt),
        sightings,
      },
    });
  } catch (error) {
    console.error('getCaseById error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─── Create Case ───────────────────────────────────────────────
exports.createCase = async (req, res) => {
  try {
    const {
      name, age, gender, description, last_seen_location,
      last_seen_date, lat, lng, status, height, weight,
      distinguishing_features, contact_info,
    } = req.body;

    if (!name || !description) {
      return res.status(400).json({
        success: false,
        message: 'Name and description are required',
      });
    }

    const photoUrl = req.file ? `/uploads/evidence/${req.file.filename}` : '';

    const newCase = await Case.create({
      name,
      age: age || 0,
      gender: gender || 'unknown',
      description,
      photo_url: photoUrl,
      last_seen_location: last_seen_location || '',
      last_seen_date: last_seen_date || new Date(),
      gps: {
        type: 'Point',
        coordinates: [parseFloat(lng) || 0, parseFloat(lat) || 0],
      },
      status: status || 'active',
      reporter_id: req.user._id,
      height: height || '',
      weight: weight || '',
      distinguishing_features: distinguishing_features || '',
      contact_info: contact_info || '',
    });

    // Create a chat room for this case
    await ChatRoom.create({
      case_id: newCase._id,
      participants: [req.user._id],
    });

    // Award points to reporter
    await User.findByIdAndUpdate(req.user._id, {
      $inc: { rewards_points: 50 },
    });
    await Reward.create({
      user_id: req.user._id,
      points: 50,
      reason: 'Filed a missing person report',
      type: 'earned',
      case_id: newCase._id,
    });

    // Emit to Socket.IO (handled in server.js)
    const io = req.app.get('io');
    if (io) {
      io.emit('new_case', {
        id: newCase._id,
        name: newCase.name,
        status: newCase.status,
        description: newCase.description,
      });
    }

    res.status(201).json({
      success: true,
      message: 'Case created successfully',
      case: newCase,
    });
  } catch (error) {
    console.error('createCase error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─── Update Case Status ────────────────────────────────────────
exports.updateCaseStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const validStatuses = ['active', 'urgent', 'found', 'closed'];

    if (!validStatuses.includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid status' });
    }

    const updated = await Case.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );

    if (!updated) {
      return res.status(404).json({ success: false, message: 'Case not found' });
    }

    // Notify via Socket.IO
    const io = req.app.get('io');
    if (io) {
      io.emit('case_status_update', {
        case_id: updated._id,
        status: updated.status,
        name: updated.name,
      });
    }

    res.status(200).json({
      success: true,
      message: 'Case status updated',
      case: updated,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─── Report Sighting ───────────────────────────────────────────
exports.reportSighting = async (req, res) => {
  try {
    const { description, location_text, lat, lng } = req.body;
    const caseId = req.params.id;

    const existingCase = await Case.findById(caseId);
    if (!existingCase) {
      return res.status(404).json({ success: false, message: 'Case not found' });
    }

    const photoUrl = req.file ? `/uploads/evidence/${req.file.filename}` : '';

    const sighting = await Sighting.create({
      case_id: caseId,
      reporter_id: req.user._id,
      description: description || '',
      photo_url: photoUrl,
      location: {
        type: 'Point',
        coordinates: [parseFloat(lng) || 0, parseFloat(lat) || 0],
      },
      location_text: location_text || '',
    });

    // Increment sightings count
    await Case.findByIdAndUpdate(caseId, {
      $inc: { sightings_count: 1 },
    });

    // Award points
    await User.findByIdAndUpdate(req.user._id, {
      $inc: { rewards_points: 25 },
    });
    await Reward.create({
      user_id: req.user._id,
      points: 25,
      reason: `Reported sighting for ${existingCase.name}`,
      type: 'earned',
      case_id: caseId,
    });

    // Alert case reporter
    if (existingCase.reporter_id.toString() !== req.user._id.toString()) {
      await Alert.create({
        user_id: existingCase.reporter_id,
        type: 'sighting',
        title: 'New Sighting Reported',
        body: `Someone reported a sighting for ${existingCase.name}`,
        case_id: caseId,
      });
    }

    // Emit to Socket.IO
    const io = req.app.get('io');
    if (io) {
      io.to(`case_${caseId}`).emit('new_sighting', sighting);
    }

    res.status(201).json({
      success: true,
      message: 'Sighting reported successfully',
      sighting,
    });
  } catch (error) {
    console.error('reportSighting error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─── Get My Reports ────────────────────────────────────────────
exports.getMyReports = async (req, res) => {
  try {
    const cases = await Case.find({ reporter_id: req.user._id })
      .sort({ createdAt: -1 })
      .lean();

    const casesWithTime = cases.map((c) => ({
      ...c,
      time_ago: getTimeAgo(c.createdAt),
    }));

    res.status(200).json({
      success: true,
      cases: casesWithTime,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ═══════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════

function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 3959; // Earth's radius in miles
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function getTimeAgo(date) {
  const seconds = Math.floor((new Date() - new Date(date)) / 1000);
  if (seconds < 60) return 'just now';
  if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`;
  if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ago`;
  if (seconds < 604800) return `${Math.floor(seconds / 86400)}d ago`;
  return new Date(date).toLocaleDateString();
}
