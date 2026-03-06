const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const Evidence = require('../models/Evidence');

// ─── Upload Evidence ───────────────────────────────────────────
exports.uploadEvidence = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Evidence file is required',
      });
    }

    const { case_id, lat, lng, gps_text, description, duration_seconds } = req.body;

    // Compute SHA-256 hash for tamper-evidence
    const filePath = req.file.path;
    const fileBuffer = fs.readFileSync(filePath);
    const fileHash = crypto.createHash('sha256').update(fileBuffer).digest('hex');

    // Determine file type
    const ext = path.extname(req.file.originalname).toLowerCase();
    const videoExtensions = ['.mp4', '.mov', '.avi', '.mkv'];
    const fileType = videoExtensions.includes(ext) ? 'video' : 'photo';

    const evidence = await Evidence.create({
      uploader_id: req.user._id,
      case_id: case_id || null,
      file_url: `/uploads/evidence/${req.file.filename}`,
      file_type: fileType,
      file_hash: fileHash,
      file_size: req.file.size,
      duration_seconds: parseInt(duration_seconds) || 0,
      gps: {
        type: 'Point',
        coordinates: [parseFloat(lng) || 0, parseFloat(lat) || 0],
      },
      gps_text: gps_text || '',
      description: description || '',
      status: 'uploaded',
    });

    res.status(201).json({
      success: true,
      message: 'Evidence uploaded successfully',
      evidence: {
        id: evidence._id,
        file_url: evidence.file_url,
        file_type: evidence.file_type,
        file_hash: evidence.file_hash,
        file_size: evidence.file_size,
        gps_text: evidence.gps_text,
        status: evidence.status,
        createdAt: evidence.createdAt,
      },
    });
  } catch (error) {
    console.error('uploadEvidence error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─── Get My Uploads ────────────────────────────────────────────
exports.getMyUploads = async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const [evidence, total] = await Promise.all([
      Evidence.find({ uploader_id: req.user._id })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .populate('case_id', 'name status')
        .lean(),
      Evidence.countDocuments({ uploader_id: req.user._id }),
    ]);

    res.status(200).json({
      success: true,
      evidence,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit)),
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─── Delete Evidence ───────────────────────────────────────────
exports.deleteEvidence = async (req, res) => {
  try {
    const evidence = await Evidence.findOne({
      _id: req.params.id,
      uploader_id: req.user._id,
    });

    if (!evidence) {
      return res.status(404).json({ success: false, message: 'Evidence not found' });
    }

    // Delete file from disk
    const filePath = path.join(__dirname, '../../', evidence.file_url);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }

    await Evidence.findByIdAndDelete(req.params.id);

    res.status(200).json({
      success: true,
      message: 'Evidence deleted',
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};
