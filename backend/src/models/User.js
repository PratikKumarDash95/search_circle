const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    phone: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    name: {
      type: String,
      default: '',
    },
    avatar_url: {
      type: String,
      default: '',
    },
    kyc_status: {
      type: String,
      enum: ['none', 'id_uploaded', 'selfie_uploaded', 'verified', 'rejected'],
      default: 'none',
    },
    kyc_doc_type: {
      type: String,
      enum: ['national_id', 'passport', 'driver_license', ''],
      default: '',
    },
    kyc_front_url: { type: String, default: '' },
    kyc_back_url: { type: String, default: '' },
    selfie_url: { type: String, default: '' },
    rewards_points: {
      type: Number,
      default: 0,
    },
    role: {
      type: String,
      enum: ['user', 'officer', 'admin'],
      default: 'user',
    },
    fcm_token: { type: String, default: '' },
    is_active: { type: Boolean, default: true },
    settings: {
      notifications_enabled: { type: Boolean, default: true },
      location_sharing: { type: Boolean, default: true },
      privacy_mode: { type: Boolean, default: false },
      dark_mode: { type: Boolean, default: false },
    },
    last_known_location: {
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
  },
  {
    timestamps: true,
  }
);

// Geospatial index for location queries
userSchema.index({ last_known_location: '2dsphere' });

module.exports = mongoose.model('User', userSchema);
