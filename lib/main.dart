
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // The AuthWrapper will handle the sign-in process and then show the app
  runApp(const AuthWrapper());
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _signInAnonymously();
  }

  Future<void> _signInAnonymously() async {
    try {
      // Sign in if the user is not already signed in
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    } catch (e) {
      // Handle sign-in errors, maybe show a message to the user
      debugPrint("Failed to sign in anonymously: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the user is signed in, show the main app
        if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
          return const MyApp();
        }

        // While waiting for auth state, show a loading indicator
        return const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.teal;

    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
      labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold),
    );

    final ThemeData theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
      ),
       listTileTheme: ListTileThemeData(
        iconColor: primarySeedColor,
        titleTextStyle: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500),
        subtitleTextStyle: GoogleFonts.openSans(fontSize: 14, color: Colors.black54),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primarySeedColor, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        labelStyle: GoogleFonts.roboto(color: primarySeedColor),
      ),
    );

    return MaterialApp.router(
      routerConfig: router,
      title: 'ShakShak App',
      theme: theme,
      debugShowCheckedModeBanner: false,
    );
  }
}
