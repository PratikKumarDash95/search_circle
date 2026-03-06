const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema(
  {
    room_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'ChatRoom',
      required: true,
      index: true,
    },
    sender_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    text: {
      type: String,
      required: true,
    },
    message_type: {
      type: String,
      enum: ['text', 'image', 'location', 'system'],
      default: 'text',
    },
    attachment_url: {
      type: String,
      default: '',
    },
    read_by: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
    ],
  },
  {
    timestamps: true,
  }
);

messageSchema.index({ room_id: 1, createdAt: -1 });

module.exports = mongoose.model('Message', messageSchema);
