const User = require('../models/User');
const Alert = require('../models/Alert');

// ─── Upload ID (front + back) ──────────────────────────────────
exports.uploadId = async (req, res) => {
  try {
    const { doc_type } = req.body;
    const files = req.files;

    if (!files || !files.front || !files.back) {
      return res.status(400).json({
        success: false,
        message: 'Both front and back ID images are required',
      });
    }

    const frontUrl = `/uploads/kyc/${files.front[0].filename}`;
    const backUrl = `/uploads/kyc/${files.back[0].filename}`;

    await User.findByIdAndUpdate(req.user._id, {
      kyc_doc_type: doc_type || 'national_id',
      kyc_front_url: frontUrl,
      kyc_back_url: backUrl,
      kyc_status: 'id_uploaded',
    });

    res.status(200).json({
      success: true,
      message: 'ID images uploaded successfully',
      kyc_status: 'id_uploaded',
      front_url: frontUrl,
      back_url: backUrl,
    });
  } catch (error) {
    console.error('uploadId error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─── Upload Selfie ─────────────────────────────────────────────
exports.uploadSelfie = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Selfie image is required',
      });
    }

    const selfieUrl = `/uploads/kyc/${req.file.filename}`;

    // Simulated face matching (in production, use AWS Rekognition or DeepFace)
    const matchScore = 85 + Math.random() * 15; // 85–100
    const isVerified = matchScore >= 80;

    const newStatus = isVerified ? 'verified' : 'selfie_uploaded';

    await User.findByIdAndUpdate(req.user._id, {
      selfie_url: selfieUrl,
      kyc_status: newStatus,
    });

    // Create verification alert
    if (isVerified) {
      await Alert.create({
        user_id: req.user._id,
        type: 'verification',
        title: 'Identity Verified ✓',
        body: 'Your identity has been successfully verified. You now have full access to SearchCircle.',
      });
    }

    res.status(200).json({
      success: true,
      message: isVerified ? 'Identity verified successfully' : 'Selfie uploaded — pending review',
      kyc_status: newStatus,
      match_score: Math.round(matchScore),
      selfie_url: selfieUrl,
    });
  } catch (error) {
    console.error('uploadSelfie error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─── Get KYC Status ────────────────────────────────────────────
exports.getStatus = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('kyc_status kyc_doc_type kyc_front_url kyc_back_url selfie_url');

    res.status(200).json({
      success: true,
      kyc_status: user.kyc_status,
      doc_type: user.kyc_doc_type,
      has_front: !!user.kyc_front_url,
      has_back: !!user.kyc_back_url,
      has_selfie: !!user.selfie_url,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};
