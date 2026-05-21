import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioService {
  static final AudioService _instance = AudioService._();
  factory AudioService() => _instance;
  AudioService._();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _notiPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _clickPlayer = AudioPlayer();

  int _currentSongIndex = -1;
  bool _isPlaying = false;

  int get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;

  Stream<PlayerState> get onMusicStateChange => _musicPlayer.onPlayerStateChanged;
  Stream<void> get onMusicComplete => _musicPlayer.onPlayerComplete;

  Future<void> playNotification(String sound) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('music/$sound'));
    } catch (e) {
      debugPrint("Lỗi phát notification: $e");
    }
  }

  Future<void> playNotificationSound() async {
    try {
      await _notiPlayer.play(AssetSource('music/notification.mp3'));
    } catch (e) {
      debugPrint("Lỗi phát sound: $e");
    }
  }

  Future<void> playSong(String file) async {
    try {
      await _musicPlayer.stop();
      await _musicPlayer.setSource(AssetSource('music/$file'));
      await _musicPlayer.resume();
      _isPlaying = true;
    } catch (e) {
      debugPrint("Lỗi phát nhạc: $e");
    }
  }

  Future<void> pauseResume() async {
    if (_currentSongIndex == -1) return;
    if (_isPlaying) {
      await _musicPlayer.pause();
      _isPlaying = false;
    } else {
      await _musicPlayer.resume();
      _isPlaying = true;
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
    _isPlaying = false;
    _currentSongIndex = -1;
  }

  Future<void> playClick() async {
    try {
      await _clickPlayer.stop();
      await _clickPlayer.play(AssetSource('music/click.mp3'));
    } catch (e) {
      // ignore click sound errors
    }
  }

  void setCurrentSong(int index) {
    _currentSongIndex = index;
  }

  void setIsPlaying(bool playing) {
    _isPlaying = playing;
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
    await _notiPlayer.dispose();
    await _musicPlayer.dispose();
    await _clickPlayer.dispose();
  }
}