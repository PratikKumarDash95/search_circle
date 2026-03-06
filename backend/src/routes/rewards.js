const router = require('express').Router();
const { getWallet, getHistory } = require('../controllers/rewardController');
const { protect } = require('../middleware/auth');

router.use(protect);

router.get('/', getWallet);
router.get('/history', getHistory);

module.exports = router;
