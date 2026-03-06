const router = require('express').Router();
const { uploadId, uploadSelfie, getStatus } = require('../controllers/kycController');
const { protect } = require('../middleware/auth');
const { kycUpload } = require('../middleware/upload');

// All KYC routes require authentication
router.use(protect);

router.post(
  '/upload-id',
  kycUpload.fields([
    { name: 'front', maxCount: 1 },
    { name: 'back', maxCount: 1 },
  ]),
  uploadId
);

router.post('/selfie', kycUpload.single('selfie'), uploadSelfie);
router.get('/status', getStatus);

module.exports = router;
