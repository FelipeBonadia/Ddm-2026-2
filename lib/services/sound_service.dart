import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum AppSoundEffect {
  navigation,
  primaryAction,
  selection,
  toggle,
  control,
  back,
  help,
  success,
  warning,
  gameEvent,
}

class AppSoundService {
  AppSoundService({AudioPlayer? effectPlayer, AudioPlayer? musicPlayer})
    : _effectPlayer = effectPlayer ?? AudioPlayer(),
      _musicPlayer = musicPlayer ?? AudioPlayer();

  final AudioPlayer _effectPlayer;
  final AudioPlayer _musicPlayer;
  Uint8List? _musicWave;
  bool _musicEnabled = false;
  bool _musicStarted = false;

  void setSoundEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _musicStarted = false;
      unawaited(_stopMusic());
    }
  }

  void play(AppSoundEffect type, {required bool enabled}) {
    if (!enabled) {
      return;
    }

    _musicEnabled = true;
    unawaited(_startMusic());
    unawaited(_playEffect(_createWave(type)));
  }

  void playNavigation({required bool enabled}) =>
      play(AppSoundEffect.navigation, enabled: enabled);
  void playPrimaryAction({required bool enabled}) =>
      play(AppSoundEffect.primaryAction, enabled: enabled);
  void playSelection({required bool enabled}) =>
      play(AppSoundEffect.selection, enabled: enabled);
  void playToggle({required bool enabled}) =>
      play(AppSoundEffect.toggle, enabled: enabled);
  void playControl({required bool enabled}) =>
      play(AppSoundEffect.control, enabled: enabled);
  void playBack({required bool enabled}) =>
      play(AppSoundEffect.back, enabled: enabled);
  void playHelp({required bool enabled}) =>
      play(AppSoundEffect.help, enabled: enabled);
  void playSuccess({required bool enabled}) =>
      play(AppSoundEffect.success, enabled: enabled);
  void playWarning({required bool enabled}) =>
      play(AppSoundEffect.warning, enabled: enabled);
  void playGameEvent({required bool enabled}) =>
      play(AppSoundEffect.gameEvent, enabled: enabled);

  Future<void> dispose() async {
    await Future.wait([
      _disposePlayer(_effectPlayer),
      _disposePlayer(_musicPlayer),
    ]);
  }

  Future<void> _disposePlayer(AudioPlayer player) async {
    try {
      await player.dispose();
    } catch (error) {
      debugPrint('Unable to dispose audio player: $error');
    }
  }

  Future<void> _playEffect(Uint8List bytes) async {
    try {
      await _effectPlayer.play(BytesSource(bytes, mimeType: 'audio/wav'));
    } catch (error) {
      debugPrint('Unable to play sound effect: $error');
    }
  }

  Future<void> _startMusic() async {
    if (!_musicEnabled || _musicStarted) {
      return;
    }

    _musicStarted = true;
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(
        BytesSource(_musicWave ??= _createMusicWave(), mimeType: 'audio/wav'),
        volume: 0.12,
      );
    } catch (error) {
      _musicStarted = false;
      debugPrint('Unable to play background music: $error');
    }
  }

  Future<void> _stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (error) {
      debugPrint('Unable to stop background music: $error');
    }
  }

  Uint8List _createWave(AppSoundEffect type) {
    final tones = switch (type) {
      AppSoundEffect.navigation => [(523.25, 45), (659.25, 65)],
      AppSoundEffect.primaryAction => [(587.33, 55), (880.0, 90)],
      AppSoundEffect.selection => [(740.0, 48)],
      AppSoundEffect.toggle => [(440.0, 45), (698.46, 70)],
      AppSoundEffect.control => [(493.88, 55)],
      AppSoundEffect.back => [(698.46, 48), (440.0, 72)],
      AppSoundEffect.help => [(659.25, 50), (987.77, 80)],
      AppSoundEffect.success => [(659.25, 55), (880.0, 80), (1046.5, 120)],
      AppSoundEffect.warning => [(440.0, 75), (311.13, 135)],
      AppSoundEffect.gameEvent => [(523.25, 55), (783.99, 90)],
    };
    const gapMs = 10;
    final durationMs =
        tones.fold<int>(0, (total, tone) => total + tone.$2) +
        gapMs * (tones.length - 1);
    const sampleRate = 22050;
    final sampleCount = sampleRate * durationMs ~/ 1000;
    final dataSize = sampleCount * 2;
    final bytes = Uint8List(44 + dataSize);
    final wave = ByteData.sublistView(bytes);

    wave
      ..setUint32(0, 0x46464952, Endian.little)
      ..setUint32(4, bytes.length - 8, Endian.little)
      ..setUint32(8, 0x45564157, Endian.little)
      ..setUint32(12, 0x20746D66, Endian.little)
      ..setUint32(16, 16, Endian.little)
      ..setUint16(20, 1, Endian.little)
      ..setUint16(22, 1, Endian.little)
      ..setUint32(24, sampleRate, Endian.little)
      ..setUint32(28, sampleRate * 2, Endian.little)
      ..setUint16(32, 2, Endian.little)
      ..setUint16(34, 16, Endian.little)
      ..setUint32(36, 0x61746164, Endian.little)
      ..setUint32(40, dataSize, Endian.little);

    for (var index = 0; index < sampleCount; index++) {
      final elapsedMs = index * 1000 / sampleRate;
      var toneStartMs = 0.0;
      var sample = 0.0;
      for (final tone in tones) {
        final toneEndMs = toneStartMs + tone.$2;
        if (elapsedMs >= toneStartMs && elapsedMs < toneEndMs) {
          final tonePositionMs = elapsedMs - toneStartMs;
          final time = tonePositionMs / 1000;
          final attack = (tonePositionMs / 7).clamp(0.0, 1.0);
          final release = ((toneEndMs - elapsedMs) / 18).clamp(0.0, 1.0);
          sample = sin(2 * pi * tone.$1 * time) * min(attack, release) * 0.32;
          break;
        }
        toneStartMs = toneEndMs + gapMs;
      }
      wave.setInt16(44 + index * 2, (sample * 32767).round(), Endian.little);
    }

    return bytes;
  }

  Uint8List _createMusicWave() {
    const sampleRate = 22050;
    const barDuration = 2.0;
    const barCount = 4;
    const duration = barDuration * barCount;
    const chordNotes = [
      [48, 55, 60, 64, 67],
      [43, 50, 55, 59, 62],
      [45, 52, 57, 60, 64],
      [41, 48, 53, 57, 60],
    ];
    const arpeggioSteps = [3, 4, 2, 4];
    final sampleCount = (sampleRate * duration).round();
    final dataSize = sampleCount * 2;
    final bytes = Uint8List(44 + dataSize);
    final wave = ByteData.sublistView(bytes);

    wave
      ..setUint32(0, 0x46464952, Endian.little)
      ..setUint32(4, bytes.length - 8, Endian.little)
      ..setUint32(8, 0x45564157, Endian.little)
      ..setUint32(12, 0x20746D66, Endian.little)
      ..setUint32(16, 16, Endian.little)
      ..setUint16(20, 1, Endian.little)
      ..setUint16(22, 1, Endian.little)
      ..setUint32(24, sampleRate, Endian.little)
      ..setUint32(28, sampleRate * 2, Endian.little)
      ..setUint16(32, 2, Endian.little)
      ..setUint16(34, 16, Endian.little)
      ..setUint32(36, 0x61746164, Endian.little)
      ..setUint32(40, dataSize, Endian.little);

    for (var index = 0; index < sampleCount; index++) {
      final time = index / sampleRate;
      final chord = chordNotes[(time ~/ barDuration) % barCount];
      var sample = 0.0;

      for (final note in chord) {
        final frequency = 440 * pow(2, (note - 69) / 12);
        sample += sin(2 * pi * frequency * time) * 0.035;
      }

      final beatPosition = time % 0.5;
      final beat = (time / 0.5).floor();
      final noteIndex = arpeggioSteps[beat % arpeggioSteps.length];
      final arpFrequency = 440 * pow(2, (chord[noteIndex] + 12 - 69) / 12);
      final arpEnvelope = exp(-beatPosition * 7) * min(1, beatPosition / 0.015);
      sample += sin(2 * pi * arpFrequency * beatPosition) * arpEnvelope * 0.13;

      final edgeFade = min(1, min(time / 0.12, (duration - time) / 0.12));
      sample = (sample * edgeFade).clamp(-0.9, 0.9);
      wave.setInt16(44 + index * 2, (sample * 32767).round(), Endian.little);
    }

    return bytes;
  }
}
