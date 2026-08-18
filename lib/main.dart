import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_app/features/provider/auth_provider.dart';
import 'package:mobile_app/features/provider/mrn_provider.dart';
import 'package:mobile_app/features/provider/site_provider.dart';
import 'package:mobile_app/features/provider/stock_provider.dart';
import 'package:mobile_app/features/screens/bottom_three.dart';
import 'package:mobile_app/features/screens/login_screen.dart';
import 'package:mobile_app/features/screens/splash_screen.dart';
import 'package:mobile_app/features/service/api_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }

  ApiService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => MrnProvider()),
        ChangeNotifierProvider(create: (_) => SiteProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
      ],
      child: const KanishkaApp(),
    ),
  );
}

class KanishkaApp extends StatefulWidget {
  const KanishkaApp({super.key});

  @override
  State<KanishkaApp> createState() => _KanishkaaAppState();
}

class _KanishkaaAppState extends State<KanishkaApp> {
  bool _sessionHookBound = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_sessionHookBound) return;
    _sessionHookBound = true;

    ApiService.onSessionInvalidated = () {
      if (!mounted) return;
      context.read<MrnProvider>().clear();
      context.read<SiteProvider>().clear();
      context.read<StockProvider>().clear();
    };
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return MaterialApp(
      title: 'Kanishkaa MRN App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
      ),
      home: auth.isInitializing
          ? const SplashScreen()
          : auth.isAuthenticated
              ? const BottomThree()
              : const LoginScreen(),
    );
  }
}