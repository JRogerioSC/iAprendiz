import 'dart:math';
import 'package:flutter/material.dart';

class AvatarWidget extends StatefulWidget {
  final bool falando;

  const AvatarWidget({super.key, required this.falando});

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  double olhoX = 0;
  double olhoY = 0;
  double alvoX = 0;
  double alvoY = 0;

  double piscar = 1;
  double boca = 8;

  double respiracao = 1;

  final rnd = Random();
  double tempoPiscar = 0;

  // 🔥 SIMULAÇÃO DE ÁUDIO REAL
  double energiaAudio = 0;
  double alvoEnergia = 0;
  double tempoAudio = 0;

  // 🔥 NOVO: CONTROLE DE COR DA BOCA
  bool corToggle = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(update);

    controller.repeat();
  }

  void update() {
    // 👀 OLHOS
    if ((olhoX - alvoX).abs() < 0.5) {
      alvoX = (rnd.nextDouble() - 0.5) * 6;
    }
    if ((olhoY - alvoY).abs() < 0.5) {
      alvoY = (rnd.nextDouble() - 0.5) * 4;
    }

    olhoX += (alvoX - olhoX) * 0.05;
    olhoY += (alvoY - olhoY) * 0.05;

    // 👁️ PISCAR
    tempoPiscar += 0.016;

    if (tempoPiscar > 2 + rnd.nextDouble() * 3) {
      piscar = 0.05;
      tempoPiscar = 0;
    } else {
      piscar += (1 - piscar) * 0.2;
    }

    // 🔥 👄 SINCRONIZAÇÃO COM "ÁUDIO"
    if (widget.falando) {
      tempoAudio += 0.016;

      // gera “picos” tipo voz real (sílabas)
      if (rnd.nextDouble() < 0.25) {
        alvoEnergia = rnd.nextDouble();

        // 🔥 ALTERNA COR DA BOCA A CADA "SÍLABA"
        corToggle = !corToggle;
      }

      // suaviza
      energiaAudio += (alvoEnergia - energiaAudio) * 0.4;

      // pausas naturais
      double pausa = rnd.nextDouble() < 0.1 ? 0.3 : 1.0;

      double abertura = 8 + (energiaAudio * 35 * pausa);

      boca += (abertura - boca) * 0.6;
    } else {
      boca += (8 - boca) * 0.25;
      energiaAudio = 0;
    }

    // 🌬️ RESPIRAÇÃO
    respiracao =
        1 + sin(DateTime.now().millisecondsSinceEpoch / 800) * 0.02;

    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: respiracao,
      child: Container(
        width: 190,
        height: 190,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: widget.falando
                ? [Colors.blueAccent, Colors.blue.shade900]
                : [Colors.blue, Colors.blue.shade800],
          ),
          boxShadow: [
            BoxShadow(
              color: widget.falando
                  ? Colors.blueAccent.withOpacity(0.6)
                  : Colors.black26,
              blurRadius: 25,
              spreadRadius: 3,
            )
          ],
        ),
        child: Transform.rotate(
          angle:
              sin(DateTime.now().millisecondsSinceEpoch / 2000) * 0.03,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  olho(),
                  const SizedBox(width: 28),
                  olho(),
                ],
              ),
              const SizedBox(height: 18),

              // 🔥 BOCA COM DUAS CORES DINÂMICAS
              Container(
                width: 55,
                height: boca,
                decoration: BoxDecoration(
                  color: widget.falando
                      ? (corToggle ? Colors.redAccent : Colors.orangeAccent)
                      : Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget olho() {
    return Transform.scale(
      scaleY: piscar,
      child: Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Transform.translate(
            offset: Offset(olhoX, olhoY),
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}