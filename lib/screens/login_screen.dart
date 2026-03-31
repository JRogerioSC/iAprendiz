import 'dart:math';
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

  bool mostrarSenha = false;
  bool carregando = false;

  void entrar() async {
    if (usuario.isEmpty || senha.isEmpty) return;

    setState(() {
      carregando = true;
    });

    final id = await ApiService.login(usuario, senha);

    setState(() {
      carregando = false;
    });

    if (id != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("usuarioId", id);
      widget.onLogin(id);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Login inválido")));
    }
  }

  // 🔥 NOVO: Entrar como visitante (SEM alterar sua lógica existente)
  void entrarComoVisitante() async {
    final prefs = await SharedPreferences.getInstance();

    // gera um id único de visitante
    final random = Random();
    final guestId = "guest_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}";

    await prefs.setString("usuarioId", guestId);

    widget.onLogin(guestId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Ao colocar o nome de usuário e senha, você estará realizando seu cadastro, ou entrando na sua conta caso já tenha uma.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                const Text("🔐 Login",
                    style: TextStyle(color: Colors.white)),

                TextField(
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  onChanged: (v) => usuario = v,
                  decoration: const InputDecoration(
                    hintText: "Usuário",
                    hintStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),

                TextField(
                  obscureText: !mostrarSenha,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  onChanged: (v) => senha = v,
                  decoration: InputDecoration(
                    hintText: "Senha",
                    hintStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        mostrarSenha
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          mostrarSenha = !mostrarSenha;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: carregando ? null : entrar,
                  child: const Text("Entrar"),
                ),

                const SizedBox(height: 10),

                // 🔥 NOVO BOTÃO (visitante)
                TextButton(
                  onPressed: entrarComoVisitante,
                  child: const Text(
                    "Entrar como visitante",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),

          if (carregando)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "CARREGANDO...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}