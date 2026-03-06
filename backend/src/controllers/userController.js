const User = require('../models/User');

// ─── Get Profile ───────────────────────────────────────────────
exports.getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user._id)
      .select('-__v -kyc_front_url -kyc_back_url -selfie_url');

    res.status(200).json({
      success: true,
      user,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─── Update Profile ────────────────────────────────────────────
exports.updateProfile = async (req, res) => {
  try {
    const allowedFields = ['name', 'fcm_token'];
    const updates = {};

    allowedFields.forEach((field) => {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    });

    // Handle avatar upload
    if (req.file) {
      updates.avatar_url = `/uploads/avatars/${req.file.filename}`;
    }

    const user = await User.findByIdAndUpdate(req.user._id, updates, {
      new: true,
    }).select('-__v -kyc_front_url -kyc_back_url -selfie_url');

    res.status(200).json({
      success: true,
      message: 'Profile updated',
      user,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─── Get Public Profile ────────────────────────────────────────
exports.getPublicProfile = async (req, res) => {
  try {
    const user = await User.findById(req.params.id)
      .select('name avatar_url role rewards_points createdAt');

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.status(200).json({
      success: true,
      user,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─── Update Location ───────────────────────────────────────────
exports.updateLocation = async (req, res) => {
  try {
    const { lat, lng } = req.body;

    if (!lat || !lng) {
      return res.status(400).json({ success: false, message: 'lat and lng are required' });
    }

    await User.findByIdAndUpdate(req.user._id, {
      last_known_location: {
        type: 'Point',
        coordinates: [parseFloat(lng), parseFloat(lat)],
      },
    });

    res.status(200).json({
      success: true,
      message: 'Location updated',
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─── Get Settings ──────────────────────────────────────────────
exports.getSettings = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('settings');

    res.status(200).json({
      success: true,
      settings: user.settings,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─── Update Settings ───────────────────────────────────────────
exports.updateSettings = async (req, res) => {
  try {
    const allowedSettings = [
      'notifications_enabled',
      'location_sharing',
      'privacy_mode',
      'dark_mode',
    ];

    const updates = {};
    allowedSettings.forEach((key) => {
      if (req.body[key] !== undefined) {
        updates[`settings.${key}`] = req.body[key];
      }
    });

    const user = await User.findByIdAndUpdate(req.user._id, updates, {
      new: true,
    }).select('settings');

    res.status(200).json({
      success: true,
      message: 'Settings updated',
      settings: user.settings,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};
