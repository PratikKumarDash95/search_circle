const mongoose = require('mongoose');
const User = require('./models/User');
const Case = require('./models/Case');
const ChatRoom = require('./models/ChatRoom');
const Message = require('./models/Message');
const Alert = require('./models/Alert');
const Reward = require('./models/Reward');
require('dotenv').config({ path: require('path').join(__dirname, '../.env') });

const seed = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Clear existing data
    await Promise.all([
      User.deleteMany({}),
      Case.deleteMany({}),
      ChatRoom.deleteMany({}),
      Message.deleteMany({}),
      Alert.deleteMany({}),
      Reward.deleteMany({}),
    ]);
    console.log('🗑️  Cleared existing data');

    // ── Create Users ──────────────────────────────────────────────
    const [user1, user2, officer1] = await User.insertMany([
      {
        phone: '+919876543210',
        name: 'Alex Kumar',
        role: 'user',
        kyc_status: 'verified',
        rewards_points: 150,
        last_known_location: { type: 'Point', coordinates: [-73.985, 40.748] },
      },
      {
        phone: '+919876543211',
        name: 'Priya Sharma',
        role: 'user',
        kyc_status: 'verified',
        rewards_points: 75,
        last_known_location: { type: 'Point', coordinates: [-73.990, 40.750] },
      },
      {
        phone: '+919876543212',
        name: 'Officer Miller',
        role: 'officer',
        kyc_status: 'verified',
        rewards_points: 0,
        last_known_location: { type: 'Point', coordinates: [-73.980, 40.745] },
      },
    ]);
    console.log('👤 Created users');

    // ── Create Cases ──────────────────────────────────────────────
    const [case1, case2, case3, case4] = await Case.insertMany([
      {
        name: 'Sarah Jenkins',
        age: 28,
        gender: 'female',
        description: 'Last seen wearing a red jacket near Central Park entrance. Height 5\'6", brown hair, green eyes.',
        last_seen_location: 'Central Park, New York',
        last_seen_date: new Date(Date.now() - 2 * 60 * 60 * 1000),
        gps: { type: 'Point', coordinates: [-73.9654, 40.7829] },
        status: 'urgent',
        reporter_id: user1._id,
        height: '5\'6"',
        weight: '130 lbs',
        distinguishing_features: 'Small butterfly tattoo on left wrist',
        contact_info: 'If found, please contact family at 555-0101',
      },
      {
        name: 'David Chen',
        age: 35,
        gender: 'male',
        description: 'Missing from downtown area. Height 5\'9", wearing glasses, dark jacket.',
        last_seen_location: 'Downtown Manhattan, New York',
        last_seen_date: new Date(Date.now() - 5 * 60 * 60 * 1000),
        gps: { type: 'Point', coordinates: [-74.0060, 40.7128] },
        status: 'active',
        reporter_id: user2._id,
        height: '5\'9"',
        weight: '165 lbs',
        distinguishing_features: 'Wears prescription glasses',
      },
      {
        name: 'Robert Miller',
        age: 72,
        gender: 'male',
        description: 'Suffers from dementia. May be confused and disoriented. Gray hair, wearing blue sweater.',
        last_seen_location: 'Brooklyn Heights, New York',
        last_seen_date: new Date(Date.now() - 1 * 60 * 60 * 1000),
        gps: { type: 'Point', coordinates: [-73.9936, 40.6960] },
        status: 'urgent',
        reporter_id: user1._id,
        height: '5\'11"',
        weight: '180 lbs',
        distinguishing_features: 'Walks with a slight limp',
      },
      {
        name: 'Maria Gonzalez',
        age: 22,
        gender: 'female',
        description: 'Located safe by community member. Thank you SearchCircle!',
        last_seen_location: 'Queens, New York',
        gps: { type: 'Point', coordinates: [-73.7949, 40.7282] },
        status: 'found',
        reporter_id: user2._id,
        sightings_count: 3,
      },
    ]);
    console.log('📋 Created cases');

    // ── Create Chat Rooms ─────────────────────────────────────────
    const room1 = await ChatRoom.create({
      case_id: case1._id,
      participants: [user1._id, officer1._id],
      last_message: 'I saw someone matching the description near the park.',
      last_message_at: new Date(),
    });

    // ── Create Messages ───────────────────────────────────────────
    await Message.insertMany([
      {
        room_id: room1._id,
        sender_id: officer1._id,
        text: 'This is Officer Miller. I\'m reviewing the sighting you reported. Can you provide more details about the location?',
        read_by: [officer1._id, user1._id],
      },
      {
        room_id: room1._id,
        sender_id: user1._id,
        text: 'I saw someone matching the description near the park entrance on 4th Ave.',
        read_by: [user1._id, officer1._id],
      },
      {
        room_id: room1._id,
        sender_id: officer1._id,
        text: 'Understood. Please stay safe. Are you still at that location? It would be helpful if you could share your current coordinates.',
        read_by: [officer1._id],
      },
      {
        room_id: room1._id,
        sender_id: user1._id,
        text: 'Yes, I\'m waiting in my car across the street.',
        read_by: [user1._id],
      },
    ]);
    console.log('💬 Created chat messages');

    // ── Create Alerts ─────────────────────────────────────────────
    await Alert.insertMany([
      {
        user_id: user1._id,
        type: 'case_nearby',
        title: 'Urgent Case Nearby',
        body: 'Sarah Jenkins was last seen 0.8 miles from your location',
        case_id: case1._id,
      },
      {
        user_id: user1._id,
        type: 'case_update',
        title: 'Case Update',
        body: 'Maria Gonzalez has been found safe!',
        case_id: case4._id,
        read: true,
      },
      {
        user_id: user1._id,
        type: 'reward',
        title: 'Points Earned!',
        body: 'You earned 50 points for filing a report',
      },
      {
        user_id: user2._id,
        type: 'sighting',
        title: 'New Sighting',
        body: 'Someone reported a sighting for David Chen',
        case_id: case2._id,
      },
    ]);
    console.log('🔔 Created alerts');

    // ── Create Rewards ────────────────────────────────────────────
    await Reward.insertMany([
      {
        user_id: user1._id,
        points: 50,
        reason: 'Filed a missing person report',
        type: 'earned',
        case_id: case1._id,
      },
      {
        user_id: user1._id,
        points: 50,
        reason: 'Filed a missing person report',
        type: 'earned',
        case_id: case3._id,
      },
      {
        user_id: user1._id,
        points: 25,
        reason: 'Reported a sighting for Maria Gonzalez',
        type: 'earned',
        case_id: case4._id,
      },
      {
        user_id: user1._id,
        points: 25,
        reason: 'Community contribution bonus',
        type: 'bonus',
      },
      {
        user_id: user2._id,
        points: 50,
        reason: 'Filed a missing person report',
        type: 'earned',
        case_id: case2._id,
      },
      {
        user_id: user2._id,
        points: 25,
        reason: 'Filed a missing person report',
        type: 'earned',
        case_id: case4._id,
      },
    ]);
    console.log('🎁 Created rewards');

    console.log('\n✅ Seed completed successfully!');
    console.log('────────────────────────────────────────');
    console.log('Test users:');
    console.log(`  📱 Alex Kumar:      +919876543210`);
    console.log(`  📱 Priya Sharma:    +919876543211`);
    console.log(`  👮 Officer Miller:  +919876543212`);
    console.log(`  🔑 DEV OTP code:    1234`);
    console.log('────────────────────────────────────────');

    process.exit(0);
  } catch (error) {
    console.error('❌ Seed error:', error);
    process.exit(1);
  }
};

seed();
