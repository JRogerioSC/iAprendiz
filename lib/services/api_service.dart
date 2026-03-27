import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const base = "https://servidor-robo-ia.onrender.com";

  static Future<String?> login(String usuario, String senha) async {
    final res = await http.post(
      Uri.parse("$base/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"usuario": usuario, "senha": senha}),
    );

    final data = jsonDecode(res.body);
    return data["usuarioId"];
  }

  static Future<String?> responder(String texto, String usuarioId) async {
    final res = await http.post(
      Uri.parse("$base/responder"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"texto": texto, "usuarioId": usuarioId}),
    );

    final data = jsonDecode(res.body);
    return data["resposta"];
  }

  static Future<String?> ensinar(String resposta, String usuarioId) async {
    final res = await http.post(
      Uri.parse("$base/ensinar-audio"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"resposta": resposta, "usuarioId": usuarioId}),
    );

    final data = jsonDecode(res.body);
    return data["resposta"];
  }

  // 🔥 NOVO: limpar aprendizado
  static Future<String?> limparAprendizado(String usuarioId) async {
    try {
      final res = await http.post(
        Uri.parse("$base/limpar"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"usuarioId": usuarioId}),
      );

      final data = jsonDecode(res.body);
      return data["resposta"];
    } catch (e) {
      print(e);
      return null;
    }
  }
}