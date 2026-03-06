const router = require('express').Router();
const { sendOtp, verifyOtp, refreshToken, getMe } = require('../controllers/authController');
const { protect } = require('../middleware/auth');

// Public routes
router.post('/send-otp', sendOtp);
router.post('/verify-otp', verifyOtp);

// Protected routes
router.post('/refresh', protect, refreshToken);
router.get('/me', protect, getMe);

module.exports = router;
