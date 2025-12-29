import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Continue without Firebase for now
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DSA Chatbot',
      theme: ThemeData(
        primarySwatch:  Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Auth wrapper to handle authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('🔍 AuthWrapper build called');
    // Check if Firebase is initialized
    try {
      return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          print('🔍 Auth state: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, user: ${snapshot.data?.uid}');
          
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('⏳ Showing loading indicator');
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // User is logged in
          if (snapshot.hasData && snapshot.data != null) {
            print('✅ User logged in, navigating to ChatScreen with uid: ${snapshot.data!.uid}');
            return ChatScreen(userId: snapshot.data!.uid);
          }
          
          // User is not logged in
          print('❌ No user, showing LoginScreen');
          return const LoginScreen();
        },
      );
    } catch (e) {
      print('❌ Firebase error: $e');
      // Firebase not initialized, go directly to login
      return const LoginScreen();
    }
  }
}
