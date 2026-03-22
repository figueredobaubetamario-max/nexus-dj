import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';

class MixerWidget extends StatelessWidget {
  const MixerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DJAppState>();
    return Container(
      color: kBg2,
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        const Text('M I X E R  /  E Q', style: TextStyle(
          fontFamily: 'Orbitron', fontSize: 8, color: kTextDim, letterSpacing: 5)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _ChannelEQ(deck: state.deckA, color: kAccentA)),
          const SizedBox(width: 8),
          _VUMeter(state: state),
          const SizedBox(width: 8),
          Expanded(child: _ChannelEQ(deck: state.deckB, color: kAccentB)),
        ]),
      ]),
    );
  }
}

class _ChannelEQ extends StatelessWidget {
  final DeckState deck;
  final Color color;
  const _ChannelEQ({required this.deck, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _eq(context, 'HI', deck.eqHi, (v) { deck.eqHi = v; deck.notifyListeners(); }),
      _eq(context, 'MID', deck.eqMid, (v) { deck.eqMid = v; deck.notifyListeners(); }),
      _eq(context, 'LOW', deck.eqLow, (v) { deck.eqLow = v; deck.notifyListeners(); }),
      const SizedBox(height: 6),
      Row(children: [
        const Text('VOL', style: TextStyle(fontSize: 8, color: kTextDim)),
        const SizedBox(width: 4),
        Expanded(child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 5, activeTrackColor: color,
            inactiveTrackColor: kBg3, thumbColor: color,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8)),
          child: Slider(value: deck.volume, min: 0, max: 1.3,
            onChanged: (v) => deck.setVolume(v)),
        )),
      ]),
    ]);
  }

  Widget _eq(BuildContext context, String label, double val, ValueChanged<double> onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        SizedBox(width: 24, child: Text(label, style: const TextStyle(fontSize: 8, color: kTextDim))),
        Expanded(child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3, activeTrackColor: color,
            inactiveTrackColor: kBg3, thumbColor: color,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: SliderComponentShape.noOverlay),
          child: Slider(value: val, min: -1, max: 1, onChanged: onChange),
        )),
        SizedBox(width: 28, child: Text(
          '${val >= 0 ? '+' : ''}${(val * 12).toStringAsFixed(0)}',
          style: TextStyle(fontSize: 7, color: color), textAlign: TextAlign.right)),
      ]),
    );
  }
}

class _VUMeter extends StatefulWidget {
  final DJAppState state;
  const _VUMeter({required this.state});
  @override
  State<_VUMeter> createState() => _VUMeterState();
}

class _VUMeterState extends State<_VUMeter> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  double _level = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 80))
      ..addListener(() {
        setState(() {
          final active = widget.state.deckA.isPlaying || widget.state.deckB.isPlaying;
          _level = (_level + (active ? 0.1 : -0.1)).clamp(0, 1);
        });
      })..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    const segs = 12;
    final active = (_level * segs).toInt().clamp(0, segs);
    return Column(children: List.generate(segs, (i) {
      final idx = segs - 1 - i;
      Color c = idx >= segs * 0.85 ? kAccentB : idx >= segs * 0.6 ? const Color(0xFFFFCC00) : kAccentG;
      return Container(width: 14, height: 4, margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(color: idx < active ? c : kBg3, borderRadius: BorderRadius.circular(1)));
    }));
  }
}