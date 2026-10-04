import { initializeApp, getApps } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';

// Config from GoogleService-Info.plist / google-services.json
const firebaseConfig = {
  apiKey: 'AIzaSyAlPEB-ms0FzDKOZbvC6EO2MIL8AUwH00s',
  projectId: 'sheguard-8e01b',
  storageBucket: 'sheguard-8e01b.firebasestorage.app',
  messagingSenderId: '711928108969',
  appId: '1:711928108969:ios:bd845e65c18008d40d56b8',
};

// Prevent duplicate app initialization on hot reload
const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0];
const firestore = getFirestore(app);

export { firestore };
