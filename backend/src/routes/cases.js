const router = require('express').Router();
const {
  getCases,
  getCaseById,
  createCase,
  updateCaseStatus,
  reportSighting,
  getMyReports,
} = require('../controllers/caseController');
const { protect, optionalAuth, authorize } = require('../middleware/auth');
const { evidenceUpload } = require('../middleware/upload');

// Public / optional auth
router.get('/', optionalAuth, getCases);
router.get('/my-reports', protect, getMyReports);
router.get('/:id', optionalAuth, getCaseById);

// Authenticated
router.post('/', protect, evidenceUpload.single('photo'), createCase);
router.post('/:id/sighting', protect, evidenceUpload.single('photo'), reportSighting);

// Officer/Admin only
router.put('/:id/status', protect, updateCaseStatus);

module.exports = router;
