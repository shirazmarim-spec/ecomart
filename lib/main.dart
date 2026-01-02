import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/screens.dart';
import 'providers/providers.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.messageId}');
}

const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyDa7BT21BLo4K1g9UUAbgofJE0N3mivpZI",
  authDomain: "test2-a1f71.firebaseapp.com",
  projectId: "test2-a1f71",
  storageBucket: "test2-a1f71.firebasestorage.app",
  messagingSenderId: "874619078267",
  appId: "1:874619078267:web:bf4f1c982aefc53ac644de",
  measurementId: "G-DB7G7MBCGL",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()..loadLocale()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()..checkAdmin()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      locale: localeProvider.locale,
      debugShowCheckedModeBanner: false,
      title: 'ecomart',
      theme: themeProvider.themeData,
      builder: (context, child) {
        return Directionality(
          textDirection: localeProvider.locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },
      home: LoginScreen(),
    );
  }
}
