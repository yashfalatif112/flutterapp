const functions = require('firebase-functions');
const { RtcTokenBuilder, RtcRole } = require('agora-access-token');
const cors = require('cors')({ origin: true });

// Your Agora credentials
const appID = '5d2a2254ac774f13bf57006c2df53a5b'; // Your Agora App ID
const appCertificate = '105bb31fe1ff40c29c02feae1e940e37'; // Replace with your Agora App Certificate

exports.generateAgoraToken = functions.https.onRequest((request, response) => {
  return cors(request, response, () => {
    // Check request method
    if (request.method !== 'POST') {
      return response.status(405).json({ error: 'Method not allowed' });
    }

    
    try {
      const { channelName, uid, role } = request.body;
      
      if (!channelName) {
        return response.status(400).json({ error: 'Channel name is required' });
      }

      // Convert string uid to number if needed
      const userId = parseInt(uid) || 0;
      
      // Set role
      const roleType = role === 'publisher' ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER;
      
      // Set expiration time - 1 hour from now
      const expirationTimeInSeconds = 3600;
      const currentTimestamp = Math.floor(Date.now() / 1000);
      const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;
      
      // Build the token
      const token = RtcTokenBuilder.buildTokenWithUid(
        appID,
        appCertificate,
        channelName,
        userId,
        roleType,
        privilegeExpiredTs
      );
      
      // Return the token
      return response.status(200).json({ token });
    } catch (error) {
      console.error('Error generating token:', error);
      return response.status(500).json({ error: 'Failed to generate token' });
    }
  });
});