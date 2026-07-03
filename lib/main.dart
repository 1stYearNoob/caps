import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/home_screen.dart';
import 'pages/terms_of_service_page.dart';
import 'services/auth_service.dart';
import 'services/translation_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hide navigation bar and status bar, make them swipe-to-reveal (immersive sticky mode)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await TranslationService.initialize();
  bool isLoggedIn = await AuthService().checkLoginStatus();
  bool hasAcceptedTos = false;
  if (isLoggedIn) {
    hasAcceptedTos = await AuthService().checkTosStatus();
  }
  runApp(MyApp(isLoggedIn: isLoggedIn, hasAcceptedTos: hasAcceptedTos));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final bool hasAcceptedTos;
  const MyApp({super.key, this.isLoggedIn = false, this.hasAcceptedTos = false});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<bool> _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = AuthService().authStateChanges.listen((loggedIn) {
      if (!loggedIn) {
        // If the user gets logged out (e.g. account deleted), kick them to MainScreen
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: TranslationService.languageNotifier,
      builder: (context, lang, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Agri:Scan',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
          home: widget.isLoggedIn
              ? (widget.hasAcceptedTos ? const HomeScreen() : const TermsOfServicePage())
              : const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/agriscanLOGO2nd.png',
              width: 500,
              height: 500,
            ),
            const SizedBox(height: 100),
            // Let's Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                padding: const EdgeInsets.only(top: 3, left: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: const Border(
                    bottom: BorderSide(color: Colors.black),
                    top: BorderSide(color: Colors.black),
                    left: BorderSide(color: Colors.black),
                    right: BorderSide(color: Colors.black),
                  ),
                ),
                child: MaterialButton(
                  minWidth: double.infinity,
                  height: 60,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  color: const Color(0xff0095FF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text(
                    "Let's Get Started",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
        
