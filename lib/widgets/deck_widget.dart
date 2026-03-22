import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';

class DeckWidget extends StatefulWidget {
  final String deckId;
  const DeckWidget({super.key, required this.deckId});
  @override
  State<DeckWidget> createState() => _DeckWidgetState();
}

class _DeckWidgetState extends State<DeckWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  double _angle = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..addListener(() => setState(() => _angle = _ctrl.value * 2 * pi));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color get color => widget.deckId == 'A' ? kAccentA : kAccentB;

  DeckState getDeck(BuildContext context) {
    final s = context.read<DJAppState>();
    return widget.deckId == 'A' ? s.deckA : s.deckB;
  }

  Future<void> _loadFile(BuildContext context) async {
    final r = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (r != null && r.files.single.path != null) {
      await getDeck(context).loadFile(r.files.single.path!, r.files.single.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DJAppState>();
    final dk = widget.deckId == 'A' ? state.deckA : state.deckB;
    if (dk.isPlaying && !_ctrl.isAnimating) _ctrl.repeat();
    if (!dk.isPlaying && _ctrl.isAnimating) _ctrl.stop();

    return Container(
      color: kPanel,
      padding: const EdgeInsets.all(8),
      child: Column(children: [
        _waveform(dk),
        const SizedBox(height: 6),
        _vinyl(dk),
        const SizedBox(height: 4),
        Text(dk.trackName ?? '— SIN PISTA —',
          style: const TextStyle(fontSize: 9, color: kText), overflow: TextOverflow.ellipsis),
        Text('${_fmt(dk.position)} / ${_fmt(dk.duration)}  •  ${dk.bpm.toStringAsFixed(1)} BPM',
          style: const TextStyle(fontSize: 8, color: kTextDim)),
        const SizedBox(height: 4),
        _pitch(dk),
        const SizedBox(height: 4),
        _loops(dk),
        const SizedBox(height: 4),
        _transport(context, dk),
        const SizedBox(height: 4),
        _hotcues(dk),
        const SizedBox(height: 4),
        _loadBtn(context),
      ]),
    );
  }

  Widget _waveform(DeckState dk) {
    return GestureDetector(
      onTapDown: (d) {
        final w = context.size?.width ?? 160;
        final pct = (d.localPosition.dx / w).clamp(0.0, 1.0);
        dk.player.seek(Duration(milliseconds: (pct * dk.duration.inMilliseconds).toInt()));
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(color: const Color(0xFF080810), borderRadius: BorderRadius.circular(4)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CustomPaint(
            painter: _WaveformPainter(
              data: dk.waveformData,
              progress: dk.duration.inMilliseconds > 0 ? dk.position.inMilliseconds / dk.duration.inMilliseconds : 0,
              color: color),
            child: const SizedBox.expand()),
        ),
      ),
    );
  }

  Widget _vinyl(DeckState dk) {
    return GestureDetector(
      onVerticalDragUpdate: (d) { if (dk.isPlaying) dk.player.setSpeed((dk.player.speed - d.delta.dy * 0.05).clamp(-3.0, 3.0)); },
      onVerticalDragEnd: (_) { if (dk.isPlaying) dk.player.setSpeed(dk.playbackRate.clamp(0.1, 3.0)); },
      child: SizedBox(width: 80, height: 80,
        child: CustomPaint(painter: _VinylPainter(angle: _angle, color: color))),
    );
  }

  Widget _pitch(DeckState dk) {
    return Row(children: [
      const Text('PITCH', style: TextStyle(fontSize: 8, color: kTextDim)),
      const SizedBox(width: 4),
      Expanded(child: SliderTheme(
        data: SliderTheme.of(context).copyWith(activeTrackColor: color, inactiveTrackColor: kBg3, thumbColor: color),
        child: Slider(value: dk.pitch, min: -10, max: 10, onChanged: (v) => dk.setPitch(v)),
      )),
      Text('${dk.pitch >= 0 ? '+' : ''}${dk.pitch.toStringAsFixed(1)}%', style: TextStyle(fontSize: 8, color: color)),
    ]);
  }

  Widget _loops(DeckState dk) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children:
      [0.5, 1.0, 2.0, 4.0, 8.0].map((b) {
        final active = dk.loopActive && dk.loopBars == b;
        return GestureDetector(
          onTap: () => dk.setLoop(b),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32, height: 24,
            decoration: BoxDecoration(
              color: active ? kAccentG.withOpacity(0.15) : const Color(0xFF0D0D1A),
              border: Border.all(color: active ? kAccentG : kBorder),
              borderRadius: BorderRadius.circular(2)),
            child: Center(child: Text(b == 0.5 ? '½' : b.toInt().toString(),
              style: TextStyle(fontSize: 9, color: active ? kAccentG : kTextDim))),
          ),
        );
      }).toList(),
    );
  }

  Widget _transport(BuildContext context, DeckState dk) {
    return Row(children: [
      _btn('CUE', kText, onTap: () => dk.isPlaying ? dk.setCue() : dk.jumpToCue()),
      const SizedBox(width: 6),
      Expanded(child: GestureDetector(
        onTap: () => dk.togglePlay(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: dk.isPlaying ? color.withOpacity(0.1) : const Color(0xFF0D0D1A),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(4)),
          child: Center(child: Text(dk.isPlaying ? '⏸' : '▶', style: TextStyle(fontSize: 18, color: color))),
        ),
      )),
      const SizedBox(width: 6),
      _btn('SYNC', kAccentG, active: dk.syncEnabled, onTap: () {
        dk.syncEnabled = !dk.syncEnabled;
        final master = context.read<DJAppState>().masterBpm;
        if (dk.syncEnabled) dk.syncTo(master);
        else dk.player.setSpeed(dk.playbackRate.clamp(0.1, 3.0));
        dk.notifyListeners();
      }),
    ]);
  }

  Widget _btn(String label, Color c, {bool active = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: active ? c.withOpacity(0.15) : const Color(0xFF0D0D1A),
          border: Border.all(color: active ? c : kBorder),
          borderRadius: BorderRadius.circular(4)),
        child: Text(label, style: TextStyle(fontSize: 9, color: active ? c : kText, letterSpacing: 1)),
      ),
    );
  }

  Widget _hotcues(DeckState dk) {
    return Row(children: List.generate(4, (i) => Expanded(child: Padding(
      padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
      child: GestureDetector(
        onTap: () => dk.triggerHotCue(i),
        onLongPress: () => dk.clearHotCue(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: dk.hotCues[i] != null ? kAccentC.withOpacity(0.15) : const Color(0xFF0D0D1A),
            border: Border.all(color: dk.hotCues[i] != null ? kAccentC : kBorder),
            borderRadius: BorderRadius.circular(3)),
          child: Center(child: Text('C${i+1}${dk.hotCues[i] != null ? '✓' : ''}',
            style: TextStyle(fontSize: 9, color: dk.hotCues[i] != null ? kAccentC : kTextDim))),
        ),
      ),
    ))));
  }

  Widget _loadBtn(BuildContext context) {
    return GestureDetector(
      onTap: () => _loadFile(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D1A),
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(3)),
        child: const Center(child: Text('⬆  CARGAR PISTA',
          style: TextStyle(fontSize: 9, color: kTextDim, letterSpacing: 2))),
      ),
    );
  }

  String _fmt(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}

class _WaveformPainter extends CustomPainter {
  final List<double> data;
  final double progress;
  final Color color;
  _WaveformPainter({required this.data, required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final bw = size.width / data.length;
    for (int i = 0; i < data.length; i++) {
      final bh = data[i] * size.height * 0.9;
      canvas.drawRect(
        Rect.fromLTWH(i * bw, (size.height - bh) / 2, max(1, bw - 1), bh),
        Paint()..color = i / data.length < progress ? color : color.withOpacity(0.25));
    }
    canvas.drawRect(Rect.fromLTWH(progress * size.width - 1, 0, 2, size.height),
      Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_WaveformPainter o) => o.progress != progress;
}

class _VinylPainter extends CustomPainter {
  final double angle;
  final Color color;
  _VinylPainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    canvas.translate(-c.dx, -c.dy);
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF0D0D1A));
    for (int i = 3; i < 9; i++) {
      canvas.drawCircle(c, r * i / 9, Paint()..color = Colors.white.withOpacity(0.04)..style = PaintingStyle.stroke..strokeWidth = 1);
    }
    canvas.drawCircle(c, r - 2, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawCircle(c, r * 0.28, Paint()..color = const Color(0xFF151525));
    canvas.drawCircle(c, 4, Paint()..color = const Color(0xFF0A0A0F));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_VinylPainter o) => o.angle != angle;
}