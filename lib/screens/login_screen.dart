import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  final Function(String) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String usuario = "";
  String senha = "";

  void entrar() async {
    if (usuario.isEmpty || senha.isEmpty) return;

    final id = await ApiService.login(usuario, senha);

    if (id != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("usuarioId", id);
      widget.onLogin(id);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Login inválido")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🔐 Login", style: TextStyle(color: Colors.white)),

            TextField(
              style: const TextStyle(color: Colors.white), // ✅ TEXTO DIGITADO
              cursorColor: Colors.white, // cursor branco
              onChanged: (v) => usuario = v,
              decoration: const InputDecoration(
                hintText: "Usuário",
                hintStyle: TextStyle(color: Colors.white54), // hint visível
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),

            TextField(
              obscureText: true,
              style: const TextStyle(color: Colors.white), // ✅ TEXTO DIGITADO
              cursorColor: Colors.white,
              onChanged: (v) => senha = v,
              decoration: const InputDecoration(
                hintText: "Senha",
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),

            ElevatedButton(
              onPressed: entrar,
              child: const Text("Entrar"),
            )
          ],
        ),
      ),
    );
  }
}