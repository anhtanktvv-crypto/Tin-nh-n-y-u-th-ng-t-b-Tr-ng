// Firebase Cloud Messaging Service Worker
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyB3a5Yjs2knhSsk1sK4oB8sfUPqzi66b1g",
  authDomain: "meove-53c46.firebaseapp.com",
  databaseURL: "https://meove-53c46-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "meove-53c46",
  storageBucket: "meove-53c46.firebasestorage.app",
  messagingSenderId: "977041101576",
  appId: "1:977041101576:web:4b7a33894f5a0b17ff92bd"
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('Received background message:', payload);
  
  const notificationTitle = payload.notification?.title || payload.data?.title || '💖 Love Station';
  const notificationBody = payload.notification?.body || payload.data?.body || 'Có tin nhắn mới!';
  const notificationIcon = payload.notification?.icon || '/assets/lulu_icon.png';
  
  self.registration.showNotification(notificationTitle, {
    body: notificationBody,
    icon: notificationIcon,
    badge: '/assets/lulu_icon.png',
    vibrate: [200, 100, 200],
    requireInteraction: true,
    tag: 'love_station',
    data: {
      url: payload.data?.url || '/',
    },
  });
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      if (clientList.length > 0) {
        let client = clientList[0];
        for (let i = 0; i < clientList.length; i++) {
          if (clientList[i].focused) {
            client = clientList[i];
          }
        }
        return client.focus();
      }
      return clients.openWindow('/');
    })
  );
});

// Handle push events directly (for iOS fallback)
self.addEventListener('push', (event) => {
  let data = { title: '💖 Love Station', body: 'Có tin nhắn mới!' };
  if (event.data) {
    try {
      data = event.data.json();
    } catch (e) {
      data = { title: event.data.text(), body: '' };
    }
  }
  
  event.waitUntil(
    self.registration.showNotification(data.title || '💖 Love Station', {
      body: data.body || 'Có tin nhắn mới!',
      icon: '/assets/lulu_icon.png',
      badge: '/assets/lulu_icon.png',
      vibrate: [200, 100, 200],
      requireInteraction: true,
    })
  );
});