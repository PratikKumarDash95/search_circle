const router = require('express').Router();
const { getAlerts, markRead } = require('../controllers/alertController');
const { protect } = require('../middleware/auth');

router.use(protect);

router.get('/', getAlerts);
router.post('/mark-read', markRead);

module.exports = router;
