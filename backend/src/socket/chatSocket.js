const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Message = require('../models/Message');
const ChatRoom = require('../models/ChatRoom');

const initSocket = (io) => {
  // ─── Authentication middleware for Socket.IO ────────────────────
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token || socket.handshake.query.token;

      if (!token) {
        return next(new Error('Authentication required'));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.id).select('name avatar_url role');

      if (!user) {
        return next(new Error('User not found'));
      }

      socket.user = user;
      next();
    } catch (error) {
      next(new Error('Invalid token'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`🔌 Socket connected: ${socket.user.name || socket.user._id} (${socket.id})`);

    // ── Join a chat room ──────────────────────────────────────────
    socket.on('join_room', async (data) => {
      try {
        const { room_id } = data;

        // Verify room exists and user is participant
        const room = await ChatRoom.findById(room_id);
        if (!room) {
          socket.emit('error', { message: 'Room not found' });
          return;
        }

        // Add user to participants if not already
        if (!room.participants.map(String).includes(String(socket.user._id))) {
          room.participants.push(socket.user._id);
          await room.save();
        }

        socket.join(`room_${room_id}`);
        console.log(`📌 ${socket.user.name || socket.user._id} joined room ${room_id}`);

        // Notify others
        socket.to(`room_${room_id}`).emit('user_joined', {
          user_id: socket.user._id,
          name: socket.user.name,
          avatar_url: socket.user.avatar_url,
        });
      } catch (error) {
        console.error('join_room error:', error.message);
        socket.emit('error', { message: 'Failed to join room' });
      }
    });

    // ── Leave a chat room ─────────────────────────────────────────
    socket.on('leave_room', (data) => {
      const { room_id } = data;
      socket.leave(`room_${room_id}`);
      console.log(`📌 ${socket.user.name || socket.user._id} left room ${room_id}`);
    });

    // ── Send a message ────────────────────────────────────────────
    socket.on('send_message', async (data) => {
      try {
        const { room_id, text, message_type, attachment_url } = data;

        if (!room_id || !text) {
          socket.emit('error', { message: 'room_id and text are required' });
          return;
        }

        // Save message to DB
        const message = await Message.create({
          room_id,
          sender_id: socket.user._id,
          text,
          message_type: message_type || 'text',
          attachment_url: attachment_url || '',
          read_by: [socket.user._id],
        });

        // Update room's last message
        await ChatRoom.findByIdAndUpdate(room_id, {
          last_message: text,
          last_message_at: new Date(),
        });

        // Populate sender info
        const populatedMessage = await Message.findById(message._id)
          .populate('sender_id', 'name avatar_url role')
          .lean();

        // Broadcast to room
        io.to(`room_${room_id}`).emit('new_message', populatedMessage);
      } catch (error) {
        console.error('send_message error:', error.message);
        socket.emit('error', { message: 'Failed to send message' });
      }
    });

    // ── Typing indicator ──────────────────────────────────────────
    socket.on('typing', (data) => {
      const { room_id, is_typing } = data;
      socket.to(`room_${room_id}`).emit('typing', {
        user_id: socket.user._id,
        name: socket.user.name,
        is_typing,
      });
    });

    // ── Read receipt ──────────────────────────────────────────────
    socket.on('read_receipt', async (data) => {
      try {
        const { message_id } = data;

        await Message.findByIdAndUpdate(message_id, {
          $addToSet: { read_by: socket.user._id },
        });

        const msg = await Message.findById(message_id).select('room_id');
        if (msg) {
          socket.to(`room_${msg.room_id}`).emit('message_read', {
            message_id,
            reader_id: socket.user._id,
            reader_name: socket.user.name,
          });
        }
      } catch (error) {
        console.error('read_receipt error:', error.message);
      }
    });

    // ── Share location via chat ───────────────────────────────────
    socket.on('share_location', async (data) => {
      try {
        const { room_id, lat, lng } = data;

        const message = await Message.create({
          room_id,
          sender_id: socket.user._id,
          text: `📍 Shared location: ${lat}, ${lng}`,
          message_type: 'location',
          read_by: [socket.user._id],
        });

        const populatedMessage = await Message.findById(message._id)
          .populate('sender_id', 'name avatar_url role')
          .lean();

        io.to(`room_${room_id}`).emit('new_message', populatedMessage);
      } catch (error) {
        console.error('share_location error:', error.message);
      }
    });

    // ── Disconnect ────────────────────────────────────────────────
    socket.on('disconnect', () => {
      console.log(`🔌 Socket disconnected: ${socket.user.name || socket.user._id} (${socket.id})`);
    });
  });
};

module.exports = initSocket;
