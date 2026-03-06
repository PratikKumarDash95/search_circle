const router = require('express').Router();
const {
  getProfile,
  updateProfile,
  getPublicProfile,
  updateLocation,
  getSettings,
  updateSettings,
} = require('../controllers/userController');
const { protect } = require('../middleware/auth');
const { avatarUpload } = require('../middleware/upload');

router.use(protect);

// Profile
router.get('/me', getProfile);
router.put('/me', avatarUpload.single('avatar'), updateProfile);
router.get('/:id', getPublicProfile);

// Location
router.put('/location', updateLocation);

// Settings
router.get('/settings', getSettings);
router.put('/settings', updateSettings);

module.exports = router;
