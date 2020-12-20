//import firebase functions modules
import { config, database } from 'firebase-functions';
//import admin module
import { initializeApp } from 'firebase-admin';
initializeApp(config().firebase);

export const pushNotification = database.ref('Weeks/{weekId}').onCreate((change, context) => {
});

export const pushNotification = database.ref('Weeks/{weekId}').onDelete((change, context) => {
   console.log("it's working");
   console.log('Push notification event triggered');

   //  Get the current value of what was written to the Realtime Database.
   const valueObject = change.after.val();

   // Create a notification
   const payload = {
      notification: {
         title: "Baliz foti",
         body: "La2",
      }
   };

   //Create an options object that contains the time to live for the notification and the priority
   /*  const options = {
       priority: "high",
       timeToLive: 60 * 60 * 24
    };
  */
   return admin.messaging().sendToTopic("pushNotifications", payload);
});

