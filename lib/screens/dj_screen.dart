import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/deck_widget.dart';
import '../widgets/crossfader_widget.dart';
import '../widgets/mixer_widget.dart';
import '../widgets/fx_widget.dart';

class DJScreen extends StatefulWidget {
  const DJScreen({super.key});
  @override
  State<DJScreen> createState() => _DJScreenState();
}

class _DJScreenState extends State<DJScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DJAppState>();
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            _header(state),
            Expanded(
              child: _tab == 0
                ? SingleChildScrollView(child: Column(children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: DeckWidget(deckId: 'A')),
                      Container(width: 1, color: kBorder),
                      Expanded(child: DeckWidget(deckId: 'B')),
                    ]),
                    const CrossfaderWidget(),
                    const MixerWidget(),
                  ]))
                : _tab == 1 ? const FxWidget()
                : _info(),
            ),
            _nav(),
          ],
        ),
      ),
    );
  }

  Widget _header(DJAppState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: kBg2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [kAccentA, kAccentC, kAccentB]).createShader(b),
            child: const Text('NEXUS DJ', style: TextStyle(
              fontFamily: 'Orbitron', fontSize: 18, fontWeight: FontWeight.w900,
              letterSpacing: 6, color: Colors.white)),
          ),
          Column(children: [
            Text(state.masterBpm.toStringAsFixed(1), style: const TextStyle(
              fontFamily: 'Orbitron', fontSize: 20, color: kAccentG, fontWeight: FontWeight.bold)),
            const Text('BPM', style: TextStyle(fontSize: 8, color: kTextDim, letterSpacing: 3)),
          ]),
        ],
      ),
    );
  }

  Widget _info() => const Center(child: Text('NEXUS DJ v1.0',
    style: TextStyle(fontFamily: 'Orbitron', fontSize: 20, color: kAccentC)));

  Widget _nav() {
    return Container(
      color: kBg2,
      child: Row(children: [
        _navBtn(0, Icons.tune, 'DECKS'),
        _navBtn(1, Icons.speaker, 'FX'),
        _navBtn(2, Icons.info_outline, 'INFO'),
      ]),
    );
  }

  Widget _navBtn(int i, IconData icon, String label) {
    final active = _tab == i;
    return Expanded(child: InkWell(
      onTap: () => setState(() => _tab = i),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: active ? kAccentC : kTextDim, size: 20),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontFamily: 'Orbitron', fontSize: 8,
            color: active ? kAccentC : kTextDim, letterSpacing: 2)),
        ]),
      ),
    ));
  }
}