const router = require('express').Router();
const { getMyRooms, getMessages, getOrCreateRoom } = require('../controllers/chatController');
const { protect } = require('../middleware/auth');

router.use(protect);

router.get('/rooms', getMyRooms);
router.get('/rooms/:id/messages', getMessages);
router.post('/rooms', getOrCreateRoom);

module.exports = router;
