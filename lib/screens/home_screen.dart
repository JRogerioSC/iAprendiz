import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/api_service.dart';
import '../widgets/avatar_widget.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final speech = SpeechToText();
  final tts = FlutterTts();

  bool ouvindo = false;
  bool falando = false;
  bool ensinando = false;

  String usuarioId = "";
  String nomeIA = "";

  // 🔥 INTERSTITIAL
  InterstitialAd? interstitialAd;

  @override
  void initState() {
    super.initState();
    init();
    carregarAd();
  }

  // 🔥 CARREGAR ANÚNCIO
  void carregarAd() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-4787541780243563/6723521753", // 🔥 TESTE OFICIAL
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;

          // 🔥 MOSTRAR ASSIM QUE CARREGAR
          interstitialAd!.show();

          // 🔥 DESCARTA DEPOIS DE USAR
          interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              interstitialAd = null;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              interstitialAd = null;
            },
          );
        },
        onAdFailedToLoad: (error) {
          print("❌ ERRO INTERSTITIAL: $error");
        },
      ),
    );
  }

  void init() async {
    final prefs = await SharedPreferences.getInstance();
    usuarioId = prefs.getString("usuarioId") ?? "";
    nomeIA = prefs.getString("nomeIA") ?? "";

    await speech.initialize(
      onStatus: (status) => print("STATUS: $status"),
      onError: (error) => print("ERRO: $error"),
    );
  }

  void ouvir() async {
    if (ouvindo || falando) return;

    bool available = await speech.initialize();

    if (!available) {
      print("Microfone não disponível");
      return;
    }

    setState(() => ouvindo = true);

    speech.listen(
      localeId: "pt_BR",
      onResult: (result) async {
        if (!result.finalResult) return;

        String texto = result.recognizedWords.toLowerCase();

        setState(() => ouvindo = false);

        // 🔥 COMANDO DE LIMPAR APRENDIZADO
        if (texto.contains("excluir todo aprendizado")) {
          String? resposta =
              await ApiService.limparAprendizado(usuarioId);

          if (resposta != null) {
            falar("Apaguei tudo que aprendi");
          } else {
            falar("Erro ao apagar aprendizado");
          }
          return;
        }

        String? resposta;

        if (ensinando) {
          resposta = await ApiService.ensinar(texto, usuarioId);
        } else {
          resposta = await ApiService.responder(texto, usuarioId);
        }

        if (resposta != null) {
          String r = resposta.toLowerCase();

          if (r.contains("qual") && r.contains("resposta")) {
            ensinando = true;
          }

          if (r.contains("aprendi") || r.contains("aprendido")) {
            ensinando = false;
          }

          falar(resposta);
        }
      },
    );
  }

  void falar(String texto) async {
    setState(() => falando = true);
    await tts.speak(texto);
    setState(() => falando = false);
  }

  void sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    widget.onLogout();
  }

  @override
  void dispose() {
    interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF083b08),

      // ❌ REMOVIDO BANNER COMPLETAMENTE

      body: SafeArea(
        child: Column(
          children: [
            // 🔥 AVISO NO TOPO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.black.withOpacity(0.3),
              child: const Text(
                'Para deletar todo o aprendizado, fale para a IA:\n🎤 "excluir todo aprendizado"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),

            // 🔥 CONTEÚDO ORIGINAL (inalterado)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AvatarWidget(falando: falando),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: ouvir,
                      child: Text(
                        ensinando
                            ? "🎓 Ensinar"
                            : ouvindo
                                ? "🎤 Ouvindo..."
                                : "Falar com IA",
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: sair,
                      child: const Text("Sair"),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}