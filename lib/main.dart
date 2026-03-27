import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 INICIALIZA ADMOB
  MobileAds.instance.initialize();

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String? usuarioId;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  void carregar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usuarioId = prefs.getString("usuarioId");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: usuarioId == null
          ? LoginScreen(onLogin: (id) {
              setState(() => usuarioId = id);
            })
          : HomeScreen(onLogout: () {
              setState(() => usuarioId = null);
            }),
    );
  }
}