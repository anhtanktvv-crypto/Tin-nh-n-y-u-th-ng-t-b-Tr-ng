import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB3a5Yjs2knhSsk1sK4oB8sfUPqzi66b1g",
      authDomain: "meove-53c46.firebaseapp.com",
      databaseURL:
          "https://meove-53c46-default-rtdb.asia-southeast1.firebasedatabase.app",
      projectId: "meove-53c46",
      storageBucket: "meove-53c46.firebasestorage.app",
      messagingSenderId: "977041101576",
      appId: "1:977041101576:web:4b7a33894f5a0b17ff92bd",
    ),
  );
  runApp(const LoveStationApp());
}

class LoveStationApp extends StatelessWidget {
  const LoveStationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '💖 Love Station - Trạm Sạc Tình Yêu',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'NotoSans',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.light,
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}