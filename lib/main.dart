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
import 'package:mobile_app/features/service/notification_service.dart';
import 'package:mobile_app/features/service/websocket_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Notification Service
  await NotificationService.initialize();

  // 2. Load Environment Variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }

  // 3. Initialize API Service
  ApiService.init();

  runApp(
    MultiProvider(
      providers: [
        // Provide WebSocketService across the app
        Provider<WebSocketService>(
          create: (_) => WebSocketService(),
          dispose: (_, service) => service.disconnect(),
        ),
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

    // Handle global session invalidation (e.g. 401 Unauthorized / token expired)
    ApiService.onSessionInvalidated = () {
      if (!mounted) return;
      
      // Disconnect WebSocket on session expiry
      context.read<WebSocketService>().disconnect();

      // Clear cached providers
      context.read<MrnProvider>().clear();
      context.read<SiteProvider>().clear();
      context.read<StockProvider>().clear();
    };
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wsService = context.read<WebSocketService>();

    // Manage WebSocket connection based on authentication state
    if (auth.isAuthenticated) {
      if (!wsService.isConnected) {
        // Pass JWT token if required, or simply call connect()
        wsService.connect(jwtToken: auth.token); 
      }
    } else {
      if (wsService.isConnected) {
        wsService.disconnect();
      }
    }

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