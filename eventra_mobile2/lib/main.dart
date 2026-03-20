import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'View/Login.dart';
import 'View/home_screen.dart';

void main() async {
  // ต้องมีบรรทัดนี้เพื่อให้ Flutter รอการเชื่อมต่อกับ Native code
  WidgetsFlutterBinding.ensureInitialized();
  
  // เริ่มต้นการเชื่อมต้อ Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // รอการโหลด
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // ถ้า user ล็อกอินแล้ว ไปหน้า Home
          if (snapshot.hasData) {
            return const EventListScreen();
          }
          
          // ถ้าไม่ได้ล็อกอิน ไปหน้า Login
          return const LoginScreen();
        },
      ),
    );
  }
}