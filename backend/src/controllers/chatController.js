const ChatRoom = require('../models/ChatRoom');
const Message = require('../models/Message');

// ─── Get My Chat Rooms ─────────────────────────────────────────
exports.getMyRooms = async (req, res) => {
  try {
    const rooms = await ChatRoom.find({
      participants: req.user._id,
      is_active: true,
    })
      .populate('case_id', 'name status photo_url')
      .populate('participants', 'name avatar_url role')
      .sort({ last_message_at: -1 })
      .lean();

    // Get unread counts
    const roomsWithUnread = await Promise.all(
      rooms.map(async (room) => {
        const unreadCount = await Message.countDocuments({
          room_id: room._id,
          sender_id: { $ne: req.user._id },
          read_by: { $nin: [req.user._id] },
        });
        return { ...room, unread_count: unreadCount };
      })
    );

    res.status(200).json({
      success: true,
      rooms: roomsWithUnread,
    });
  } catch (error) {
    console.error('getMyRooms error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─── Get Messages for a Room ───────────────────────────────────
exports.getMessages = async (req, res) => {
  try {
    const { page = 1, limit = 50 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const room = await ChatRoom.findById(req.params.id);
    if (!room) {
      return res.status(404).json({ success: false, message: 'Chat room not found' });
    }

    // Verify user is a participant
    if (!room.participants.map(String).includes(String(req.user._id))) {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    }

    const messages = await Message.find({ room_id: req.params.id })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit))
      .populate('sender_id', 'name avatar_url role')
      .lean();

    // Mark messages as read
    await Message.updateMany(
      {
        room_id: req.params.id,
        sender_id: { $ne: req.user._id },
        read_by: { $nin: [req.user._id] },
      },
      { $addToSet: { read_by: req.user._id } }
    );

    res.status(200).json({
      success: true,
      messages: messages.reverse(), // oldest first
    });
  } catch (error) {
    console.error('getMessages error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─── Create/Get Room for a Case ────────────────────────────────
exports.getOrCreateRoom = async (req, res) => {
  try {
    const { case_id } = req.body;

    if (!case_id) {
      return res.status(400).json({ success: false, message: 'case_id is required' });
    }

    // Check if room already exists for this user + case
    let room = await ChatRoom.findOne({
      case_id,
      participants: req.user._id,
    }).populate('case_id', 'name status')
      .populate('participants', 'name avatar_url role');

    if (!room) {
      room = await ChatRoom.create({
        case_id,
        participants: [req.user._id],
      });
      room = await ChatRoom.findById(room._id)
        .populate('case_id', 'name status')
        .populate('participants', 'name avatar_url role');
    }

    res.status(200).json({
      success: true,
      room,
    });
  } catch (error) {
    console.error('getOrCreateRoom error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};
