require('dotenv').config();

const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');

// ─── Config ──────────────────────────────────────────────────────
const connectDB = require('./src/config/db');
const validateEnv = require('./src/config/env');

// Validate environment variables
validateEnv();

// ─── App Setup ───────────────────────────────────────────────────
const app = express();
const server = http.createServer(app);

// ─── Socket.IO Setup ─────────────────────────────────────────────
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
  transports: ['websocket', 'polling'],
});

// Share io instance with Express routes
app.set('io', io);

// ─── Middleware ───────────────────────────────────────────────────
app.use(cors({
  origin: '*',
  credentials: true,
}));
app.use(helmet({
  crossOriginResourcePolicy: { policy: 'cross-origin' },
}));
app.use(morgan('dev'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ─── Static Files (uploads) ─────────────────────────────────────
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ─── API Routes ──────────────────────────────────────────────────
app.use('/api/auth', require('./src/routes/auth'));
app.use('/api/kyc', require('./src/routes/kyc'));
app.use('/api/cases', require('./src/routes/cases'));
app.use('/api/evidence', require('./src/routes/evidence'));
app.use('/api/chat', require('./src/routes/chat'));
app.use('/api/alerts', require('./src/routes/alerts'));
app.use('/api/rewards', require('./src/routes/rewards'));
app.use('/api/users', require('./src/routes/users'));
app.use('/api/seed', require('./src/routes/seed'));

// ─── Health Check ────────────────────────────────────────────────
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'SearchCircle API is running',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    env: process.env.NODE_ENV,
  });
});

// ─── Root Route ──────────────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({
    app: 'SearchCircle Backend',
    version: '1.0.0',
    endpoints: {
      health: '/api/health',
      auth: '/api/auth',
      kyc: '/api/kyc',
      cases: '/api/cases',
      evidence: '/api/evidence',
      chat: '/api/chat',
      alerts: '/api/alerts',
      rewards: '/api/rewards',
      users: '/api/users',
    },
  });
});

// ─── 404 Handler ─────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found`,
  });
});

// ─── Global Error Handler ────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('❌ Error:', err.message);

  // Multer errors
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(400).json({
      success: false,
      message: 'File too large',
    });
  }

  if (err.message && err.message.includes('Only')) {
    return res.status(400).json({
      success: false,
      message: err.message,
    });
  }

  res.status(err.statusCode || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
  });
});

// ─── Initialize Socket.IO ────────────────────────────────────────
const initSocket = require('./src/socket/chatSocket');
initSocket(io);

// ─── Start Server ────────────────────────────────────────────────
const PORT = process.env.PORT || 5000;

const startServer = async () => {
  try {
    // Connect to MongoDB
    await connectDB();

    server.listen(PORT, '0.0.0.0', () => {
      console.log('');
      console.log('═══════════════════════════════════════════════════');
      console.log(`  🔍 SearchCircle Backend v1.0.0`);
      console.log(`  🚀 Server running on http://localhost:${PORT}`);
      console.log(`  🔌 Socket.IO ready on ws://localhost:${PORT}`);
      console.log(`  📡 Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log('═══════════════════════════════════════════════════');
      console.log('');
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error.message);
    process.exit(1);
  }
};

startServer();
