const mongoose = require('mongoose');

const rewardSchema = new mongoose.Schema(
  {
    user_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    points: {
      type: Number,
      required: true,
    },
    reason: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      enum: ['earned', 'redeemed', 'bonus'],
      default: 'earned',
    },
    case_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Case',
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Reward', rewardSchema);
