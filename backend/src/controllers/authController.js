const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Otp = require('../models/Otp');

// Generate JWT token
const generateToken = (userId) => {
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '30d',
  });
};

// Generate random 4-digit OTP
const generateOtp = () => {
  return Math.floor(1000 + Math.random() * 9000).toString();
};

exports.sendOtp = async (req, res) => {
  try {
    const { phone, country_code } = req.body;

    if (!phone) {
      return res.status(400).json({
        success: false,
        message: 'Phone number is required',
      });
    }

    const fullPhone = (country_code || '+91') + phone.replace(/\D/g, '');

    // Rate limit: max 5 OTPs per phone per hour
    const recentOtps = await Otp.countDocuments({
      phone: fullPhone,
      created_at: { $gte: new Date(Date.now() - 60 * 60 * 1000) },
    });

    if (recentOtps >= 5) {
      return res.status(429).json({
        success: false,
        message: 'Too many OTP requests. Try again in an hour.',
      });
    }

    // Send via Twilio (skip in dev mode)
    if (process.env.DEV_MODE_OTP !== 'true') {
      try {
        const twilio = require('twilio')(
          process.env.TWILIO_ACCOUNT_SID,
          process.env.TWILIO_AUTH_TOKEN
        );
        
        await twilio.verify.v2.services(process.env.TWILIO_VERIFY_SERVICE_SID)
          .verifications.create({ to: fullPhone, channel: 'sms' });

        // Record an OTP request in DB for rate-limiting purposes only
        await Otp.create({
          phone: fullPhone,
          otp_hash: 'twilio_verify',
          expires_at: new Date(Date.now() + 5 * 60 * 1000),
        });

      } catch (twilioErr) {
        console.error('Twilio error:', twilioErr.message);
        return res.status(500).json({
          success: false,
          message: 'Failed to send SMS. Please check your number and try again.',
        });
      }
    } else {
      // DEV MODE fallback
      const otpCode = process.env.DEV_OTP_CODE || '1234';
      const salt = await bcrypt.genSalt(10);
      const otpHash = await bcrypt.hash(otpCode, salt);
      await Otp.create({
        phone: fullPhone,
        otp_hash: otpHash,
        expires_at: new Date(Date.now() + 5 * 60 * 1000),
      });
      console.log(`📱 DEV OTP for ${fullPhone}: ${otpCode}`);
    }

    res.status(200).json({
      success: true,
      message: 'OTP sent successfully',
      phone: fullPhone,
      // Include OTP in dev mode for easy testing
      ...(process.env.DEV_MODE_OTP === 'true' && { dev_otp: process.env.DEV_OTP_CODE || '1234' }),
    });
  } catch (error) {
    console.error('sendOtp error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

exports.verifyOtp = async (req, res) => {
  try {
    const { phone, country_code, otp } = req.body;

    if (!phone || !otp) {
      return res.status(400).json({
        success: false,
        message: 'Phone and OTP are required',
      });
    }

    const fullPhone = (country_code || '+91') + phone.replace(/\D/g, '');

    if (process.env.DEV_MODE_OTP !== 'true') {
      // Verify via Twilio
      try {
        const twilio = require('twilio')(
          process.env.TWILIO_ACCOUNT_SID,
          process.env.TWILIO_AUTH_TOKEN
        );
        
        const verificationCheck = await twilio.verify.v2.services(process.env.TWILIO_VERIFY_SERVICE_SID)
          .verificationChecks.create({ to: fullPhone, code: otp });
          
        if (verificationCheck.status !== 'approved') {
          return res.status(400).json({
            success: false,
            message: 'Invalid OTP',
          });
        }
      } catch (twilioErr) {
        console.error('Twilio verify error:', twilioErr.message);
        return res.status(400).json({
          success: false,
          message: 'Invalid or expired OTP',
        });
      }
    } else {
      // DEV MODE Verification using local DB
      const otpRecord = await Otp.findOne({
        phone: fullPhone,
        used: false,
        expires_at: { $gt: new Date() },
      }).sort({ created_at: -1 });

      if (!otpRecord) {
        return res.status(400).json({
          success: false,
          message: 'OTP expired or not found. Please request a new one.',
        });
      }

      if (otpRecord.attempts >= 5) {
        otpRecord.used = true;
        await otpRecord.save();
        return res.status(400).json({
          success: false,
          message: 'Too many failed attempts. Please request a new OTP.',
        });
      }

      const isMatch = await bcrypt.compare(otp, otpRecord.otp_hash);

      if (!isMatch) {
        otpRecord.attempts += 1;
        await otpRecord.save();
        return res.status(400).json({
          success: false,
          message: 'Invalid OTP',
          attempts_remaining: 5 - otpRecord.attempts,
        });
      }

      otpRecord.used = true;
      await otpRecord.save();
    }

    // Find or create user
    let user = await User.findOne({ phone: fullPhone });
    let isNewUser = false;

    if (!user) {
      isNewUser = true;
      user = await User.create({
        phone: fullPhone,
        name: '',
      });
    }

    // Generate JWT
    const token = generateToken(user._id);

    res.status(200).json({
      success: true,
      message: isNewUser ? 'Account created successfully' : 'Login successful',
      token,
      is_new_user: isNewUser,
      user: {
        id: user._id,
        phone: user.phone,
        name: user.name,
        avatar_url: user.avatar_url,
        kyc_status: user.kyc_status,
        role: user.role,
        rewards_points: user.rewards_points,
      },
    });
  } catch (error) {
    console.error('verifyOtp error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

// ─── Refresh Token ─────────────────────────────────────────────
exports.refreshToken = async (req, res) => {
  try {
    const token = generateToken(req.user._id);
    res.status(200).json({
      success: true,
      token,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

// ─── Get Current User ──────────────────────────────────────────
exports.getMe = async (req, res) => {
  try {
    res.status(200).json({
      success: true,
      user: {
        id: req.user._id,
        phone: req.user.phone,
        name: req.user.name,
        avatar_url: req.user.avatar_url,
        kyc_status: req.user.kyc_status,
        role: req.user.role,
        rewards_points: req.user.rewards_points,
        settings: req.user.settings,
        createdAt: req.user.createdAt,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};
