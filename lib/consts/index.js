// const functions = require('firebase-functions');
// const admin = require('firebase-admin');
// admin.initializeApp();

// exports.sendCallNotification = functions.firestore
//     .document('notifications/{notificationId}')
//     .onCreate(async (snapshot, context) => {
//         const notificationData = snapshot.data();
        
//         if (!notificationData.message) {
//             console.error('No message data found');
//             return null;
//         }
        
//         try {
//             // Send FCM message
//             const response = await admin.messaging().send(notificationData.message);
//             console.log('Successfully sent message:', response);
            
//             // Delete notification document
//             return snapshot.ref.delete();
//         } catch (error) {
//             console.error('Error sending message:', error);
//             return null;
//         }
//     });