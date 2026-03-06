const mongoose = require('mongoose');

const evidenceSchema = new mongoose.Schema(
  {
    uploader_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    case_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Case',
      default: null,
    },
    file_url: {
      type: String,
      required: true,
    },
    file_type: {
      type: String,
      enum: ['video', 'photo'],
      required: true,
    },
    file_hash: {
      type: String,
      default: '',
    },
    file_size: {
      type: Number,
      default: 0,
    },
    duration_seconds: {
      type: Number,
      default: 0,
    },
    gps: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point',
      },
      coordinates: {
        type: [Number],
        default: [0, 0],
      },
    },
    gps_text: {
      type: String,
      default: '',
    },
    description: {
      type: String,
      default: '',
    },
    status: {
      type: String,
      enum: ['uploading', 'uploaded', 'verified', 'rejected'],
      default: 'uploaded',
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Evidence', evidenceSchema);
