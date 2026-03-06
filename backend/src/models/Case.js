const mongoose = require('mongoose');

const caseSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    age: { type: Number, default: 0 },
    gender: {
      type: String,
      enum: ['male', 'female', 'other', 'unknown'],
      default: 'unknown',
    },
    description: {
      type: String,
      required: true,
    },
    photo_url: {
      type: String,
      default: '',
    },
    last_seen_location: {
      type: String,
      default: '',
    },
    last_seen_date: {
      type: Date,
      default: Date.now,
    },
    gps: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point',
      },
      coordinates: {
        type: [Number], // [lng, lat]
        default: [0, 0],
      },
    },
    status: {
      type: String,
      enum: ['active', 'urgent', 'found', 'closed'],
      default: 'active',
    },
    reporter_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    assigned_officer_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },
    sightings_count: {
      type: Number,
      default: 0,
    },
    height: { type: String, default: '' },
    weight: { type: String, default: '' },
    distinguishing_features: { type: String, default: '' },
    contact_info: { type: String, default: '' },
  },
  {
    timestamps: true,
  }
);

// Geospatial index for "near me" queries
caseSchema.index({ gps: '2dsphere' });
caseSchema.index({ status: 1, createdAt: -1 });

module.exports = mongoose.model('Case', caseSchema);
