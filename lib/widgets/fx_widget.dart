import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';

class FxWidget extends StatelessWidget {
  const FxWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DJAppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        const Text('E F E C T O S   F X', style: TextStyle(
          fontFamily: 'Orbitron', fontSize: 9, color: kTextDim, letterSpacing: 5)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('APLICAR A: ', style: TextStyle(fontSize: 9, color: kTextDim)),
          _deckBtn(context, state, 'A'),
          const SizedBox(width: 8),
          _deckBtn(context, state, 'B'),
        ]),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 8, mainAxisSpacing: 8,
          childAspectRatio: 1.8,
          children: [
            _fxBtn(context, state, ActiveFx.reverb, 'REVERB'),
            _fxBtn(context, state, ActiveFx.delay, 'DELAY'),
            _fxBtn(context, state, ActiveFx.flanger, 'FLANGER'),
            _fxBtn(context, state, ActiveFx.filter, 'FILTER'),
            _fxBtn(context, state, ActiveFx.echo, 'ECHO'),
            _fxBtn(context, state, ActiveFx.phaser, 'PHASER'),
            _fxBtn(context, state, ActiveFx.bitcr, 'BITCR'),
            _fxBtn(context, state, ActiveFx.gate, 'GATE'),
          ],
        ),
        const SizedBox(height: 20),
        const Align(alignment: Alignment.centerLeft,
          child: Text('PARÁMETROS', style: TextStyle(
            fontFamily: 'Orbitron', fontSize: 9, color: kTextDim, letterSpacing: 3))),
        const SizedBox(height: 12),
        _param(context, 'WET', state.fxWet, (v) => state.setFxWet(v)),
        _param(context, 'RATE', state.fxRate, (v) => state.setFxRate(v)),
        _param(context, 'DEPTH', state.fxDepth, (v) => state.setFxDepth(v)),
        if (state.activeFx != ActiveFx.none) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kAccentC.withOpacity(0.1),
              border: Border.all(color: kAccentC),
              borderRadius: BorderRadius.circular(6)),
            child: Row(children: [
              const Icon(Icons.equalizer, color: kAccentC, size: 16),
              const SizedBox(width: 8),
              Text('FX: ${state.activeFx.name.toUpperCase()} → DECK ${state.fxDeck}',
                style: const TextStyle(fontFamily: 'Orbitron', fontSize: 9, color: kAccentC)),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _deckBtn(BuildContext context, DJAppState state, String deck) {
    final active = state.fxDeck == deck;
    final color = deck == 'A' ? kAccentA : kAccentB;
    return GestureDetector(
      onTap: () => state.setFxDeck(deck),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : kBg3,
          border: Border.all(color: active ? color : kBorder),
          borderRadius: BorderRadius.circular(4)),
        child: Text('DECK $deck', style: TextStyle(
          fontFamily: 'Orbitron', fontSize: 9,
          color: active ? color : kTextDim, letterSpacing: 1)),
      ),
    );
  }

  Widget _fxBtn(BuildContext context, DJAppState state, ActiveFx fx, String label) {
    final active = state.activeFx == fx;
    return GestureDetector(
      onTap: () => state.toggleFx(fx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: active ? kAccentC.withOpacity(0.15) : const Color(0xFF0D0D1A),
          border: Border.all(color: active ? kAccentC : kBorder),
          borderRadius: BorderRadius.circular(4)),
        child: Center(child: Text(label, style: TextStyle(
          fontSize: 9, fontFamily: 'Orbitron',
          color: active ? kAccentC : kTextDim))),
      ),
    );
  }

  Widget _param(BuildContext context, String label, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(width: 48, child: Text(label,
          style: const TextStyle(fontSize: 9, color: kTextDim, letterSpacing: 1))),
        Expanded(child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3, activeTrackColor: kAccentC,
            inactiveTrackColor: kBg3, thumbColor: kAccentC,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: SliderComponentShape.noOverlay),
          child: Slider(value: value, onChanged: onChanged),
        )),
        SizedBox(width: 32, child: Text('${(value * 100).toInt()}%',
          style: const TextStyle(fontSize: 8, color: kAccentC), textAlign: TextAlign.right)),
      ]),
    );
  }
}