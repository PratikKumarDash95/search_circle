const Reward = require('../models/Reward');
const User = require('../models/User');

// ─── Get Wallet ────────────────────────────────────────────────
exports.getWallet = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('rewards_points');

    // Get summary stats
    const [totalEarned, totalRedeemed] = await Promise.all([
      Reward.aggregate([
        { $match: { user_id: req.user._id, type: 'earned' } },
        { $group: { _id: null, total: { $sum: '$points' } } },
      ]),
      Reward.aggregate([
        { $match: { user_id: req.user._id, type: 'redeemed' } },
        { $group: { _id: null, total: { $sum: '$points' } } },
      ]),
    ]);

    res.status(200).json({
      success: true,
      wallet: {
        balance: user.rewards_points,
        total_earned: totalEarned[0]?.total || 0,
        total_redeemed: totalRedeemed[0]?.total || 0,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─── Get Reward History ────────────────────────────────────────
exports.getHistory = async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const [rewards, total] = await Promise.all([
      Reward.find({ user_id: req.user._id })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .populate('case_id', 'name')
        .lean(),
      Reward.countDocuments({ user_id: req.user._id }),
    ]);

    res.status(200).json({
      success: true,
      rewards,
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
