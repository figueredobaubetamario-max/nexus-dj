import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';

class CrossfaderWidget extends StatelessWidget {
  const CrossfaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DJAppState>();
    return Container(
      color: kBg2,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(children: [
        const Text('C R O S S F A D E R', style: TextStyle(
          fontFamily: 'Orbitron', fontSize: 8, color: kTextDim, letterSpacing: 5)),
        const SizedBox(height: 6),
        Row(children: [
          const Text('A', style: TextStyle(fontFamily: 'Orbitron', fontSize: 11,
            color: kAccentA, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: kAccentA,
              inactiveTrackColor: kAccentB,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: state.crossfader,
              min: 0, max: 1,
              onChanged: (v) => state.setCrossfader(v),
            ),
          )),
          const SizedBox(width: 10),
          const Text('B', style: TextStyle(fontFamily: 'Orbitron', fontSize: 11,
            color: kAccentB, fontWeight: FontWeight.bold)),
        ]),
      ]),
    );
  }
}