const mongoose = require('mongoose');

const alertSchema = new mongoose.Schema(
  {
    user_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    type: {
      type: String,
      enum: ['case_nearby', 'case_update', 'sighting', 'chat', 'reward', 'system', 'verification'],
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    body: {
      type: String,
      default: '',
    },
    case_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Case',
      default: null,
    },
    read: {
      type: Boolean,
      default: false,
    },
    action_url: {
      type: String,
      default: '',
    },
  },
  {
    timestamps: true,
  }
);

alertSchema.index({ user_id: 1, read: 1, createdAt: -1 });

module.exports = mongoose.model('Alert', alertSchema);
