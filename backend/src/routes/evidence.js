const router = require('express').Router();
const { uploadEvidence, getMyUploads, deleteEvidence } = require('../controllers/evidenceController');
const { protect } = require('../middleware/auth');
const { evidenceUpload } = require('../middleware/upload');

router.use(protect);

router.post('/upload', evidenceUpload.single('file'), uploadEvidence);
router.get('/mine', getMyUploads);
router.delete('/:id', deleteEvidence);

module.exports = router;
