import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class DeckState extends ChangeNotifier {
  final String id;
  final AudioPlayer player = AudioPlayer();
  String? trackName;
  double bpm = 128.0;
  double pitch = 0.0;
  double volume = 1.0;
  double eqHi = 0.0;
  double eqMid = 0.0;
  double eqLow = 0.0;
  bool syncEnabled = false;
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  List<double?> hotCues = [null, null, null, null];
  double? cuePoint;
  bool loopActive = false;
  Duration? loopStart;
  Duration? loopEnd;
  double loopBars = 0;
  List<double> waveformData = [];

  DeckState(this.id) {
    player.positionStream.listen((pos) {
      position = pos;
      if (loopActive && loopEnd != null && pos >= loopEnd!) {
        player.seek(loopStart ?? Duration.zero);
      }
      notifyListeners();
    });
    player.playerStateStream.listen((state) {
      isPlaying = state.playing;
      notifyListeners();
    });
    player.durationStream.listen((dur) {
      if (dur != null) duration = dur;
      notifyListeners();
    });
  }

  double get playbackRate => syncEnabled ? 1.0 : (1.0 + pitch / 100.0);
  double get effectiveBpm => bpm * playbackRate;

  Future<void> loadFile(String path, String name) async {
    await player.setFilePath(path);
    trackName = name;
    bpm = 100.0 + (name.hashCode.abs() % 60).toDouble();
    waveformData = List.generate(200, (_) => 0.1 + Random(name.hashCode).nextDouble() * 0.9);
    notifyListeners();
  }

  Future<void> togglePlay() async {
    if (isPlaying) { await player.pause(); }
    else { await player.setSpeed(playbackRate); await player.play(); }
    notifyListeners();
  }

  Future<void> setCue() async { cuePoint = position.inMilliseconds.toDouble(); notifyListeners(); }
  Future<void> jumpToCue() async {
    if (cuePoint != null) await player.seek(Duration(milliseconds: cuePoint!.toInt()));
    notifyListeners();
  }

  Future<void> triggerHotCue(int i) async {
    if (hotCues[i] != null) {
      await player.seek(Duration(milliseconds: hotCues[i]!.toInt()));
      if (!isPlaying) await player.play();
    } else { hotCues[i] = position.inMilliseconds.toDouble(); }
    notifyListeners();
  }

  void clearHotCue(int i) { hotCues[i] = null; notifyListeners(); }

  Future<void> setLoop(double bars) async {
    if (loopActive && loopBars == bars) { loopActive = false; loopBars = 0; notifyListeners(); return; }
    final loopLen = bars * (60.0 / bpm) * 4;
    loopStart = position;
    loopEnd = position + Duration(milliseconds: (loopLen * 1000).toInt());
    loopActive = true; loopBars = bars;
    notifyListeners();
  }

  void setPitch(double val) { pitch = val; if (!syncEnabled) player.setSpeed(playbackRate.clamp(0.1, 3.0)); notifyListeners(); }
  void setVolume(double val) { volume = val; player.setVolume(val); notifyListeners(); }
  void syncTo(double masterBpm) { if (syncEnabled && bpm > 0) player.setSpeed((masterBpm / bpm).clamp(0.1, 3.0)); }

  @override
  void dispose() { player.dispose(); super.dispose(); }
}

enum ActiveFx { none, reverb, delay, flanger, filter, echo, phaser, bitcr, gate }

class DJAppState extends ChangeNotifier {
  final DeckState deckA = DeckState('A');
  final DeckState deckB = DeckState('B');
  double crossfader = 0.5;
  ActiveFx activeFx = ActiveFx.none;
  double fxWet = 0.3;
  double fxRate = 0.5;
  double fxDepth = 0.5;
  String fxDeck = 'A';

  DJAppState() {
    deckA.addListener(_onChange);
    deckB.addListener(_onChange);
  }

  void _onChange() { _applyCrossfade(); notifyListeners(); }

  double get masterBpm {
    if (deckA.isPlaying) return deckA.effectiveBpm;
    if (deckB.isPlaying) return deckB.effectiveBpm;
    return 128.0;
  }

  void setCrossfader(double val) { crossfader = val; _applyCrossfade(); notifyListeners(); }

  void _applyCrossfade() {
    deckA.player.setVolume((cos(crossfader * pi / 2) * deckA.volume).clamp(0.0, 1.0));
    deckB.player.setVolume((cos((1.0 - crossfader) * pi / 2) * deckB.volume).clamp(0.0, 1.0));
  }

  void toggleFx(ActiveFx fx) { activeFx = activeFx == fx ? ActiveFx.none : fx; notifyListeners(); }
  void setFxWet(double v) { fxWet = v; notifyListeners(); }
  void setFxRate(double v) { fxRate = v; notifyListeners(); }
  void setFxDepth(double v) { fxDepth = v; notifyListeners(); }
  void setFxDeck(String d) { fxDeck = d; notifyListeners(); }

  @override
  void dispose() { deckA.dispose(); deckB.dispose(); super.dispose(); }
}