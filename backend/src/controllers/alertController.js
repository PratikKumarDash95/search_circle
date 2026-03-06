const Alert = require('../models/Alert');

// ─── Get My Alerts ─────────────────────────────────────────────
exports.getAlerts = async (req, res) => {
  try {
    const { page = 1, limit = 30 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const [alerts, total, unreadCount] = await Promise.all([
      Alert.find({ user_id: req.user._id })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .populate('case_id', 'name status')
        .lean(),
      Alert.countDocuments({ user_id: req.user._id }),
      Alert.countDocuments({ user_id: req.user._id, read: false }),
    ]);

    res.status(200).json({
      success: true,
      alerts,
      unread_count: unreadCount,
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

// ─── Mark Alerts as Read ───────────────────────────────────────
exports.markRead = async (req, res) => {
  try {
    const { alert_ids } = req.body;

    if (alert_ids && alert_ids.length > 0) {
      // Mark specific alerts
      await Alert.updateMany(
        { _id: { $in: alert_ids }, user_id: req.user._id },
        { read: true }
      );
    } else {
      // Mark all alerts as read
      await Alert.updateMany(
        { user_id: req.user._id, read: false },
        { read: true }
      );
    }

    res.status(200).json({
      success: true,
      message: 'Alerts marked as read',
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};
