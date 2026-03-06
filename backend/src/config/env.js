// Validate required environment variables
const requiredEnvVars = ['MONGODB_URI', 'JWT_SECRET'];

const validateEnv = () => {
  const missing = requiredEnvVars.filter((key) => !process.env[key]);
  if (missing.length > 0) {
    console.error(`❌ Missing required environment variables: ${missing.join(', ')}`);
    console.error('   Copy .env.example to .env and fill in the values.');
    process.exit(1);
  }

  // Warn about Twilio if not in dev mode
  if (process.env.DEV_MODE_OTP !== 'true') {
    const twilioVars = ['TWILIO_ACCOUNT_SID', 'TWILIO_AUTH_TOKEN', 'TWILIO_VERIFY_SERVICE_SID'];
    const missingTwilio = twilioVars.filter((key) => !process.env[key]);
    if (missingTwilio.length > 0) {
      console.warn(`⚠️  Twilio not configured (${missingTwilio.join(', ')}). Set DEV_MODE_OTP=true for dev mode.`);
    }
  } else {
    console.log('🔧 DEV MODE: OTP code is always', process.env.DEV_OTP_CODE || '1234');
  }
};

module.exports = validateEnv;
