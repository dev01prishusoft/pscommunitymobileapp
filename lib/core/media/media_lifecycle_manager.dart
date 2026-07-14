import 'package:flutter/widgets.dart';
import 'package:pscommunitymobileapp/core/lifecycle/app_lifecycle_observer.dart';
abstract class ManagedPlayer {
  String get id;
  bool get isPlaying;
  
  void pause();
  void play();
  void dispose();
}
class MediaLifecycleManager {
  MediaLifecycleManager._internal();
  static final MediaLifecycleManager _instance = MediaLifecycleManager._internal();
  static MediaLifecycleManager get instance => _instance;

  final Map<String, ManagedPlayer> _activePlayers = {};
  ManagedPlayer? _playerToResume;

  bool _isInitialized = false;

  void init() {
    if (_isInitialized) return;
    AppLifecycleObserver.instance.addListener(_onAppLifecycleChanged);
    _isInitialized = true;
  }

  void dispose() {
    AppLifecycleObserver.instance.removeListener(_onAppLifecycleChanged);
    _disposeAllPlayers();
    _isInitialized = false;
  }

  void _onAppLifecycleChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _pauseAllForBackground();
    } else if (state == AppLifecycleState.resumed) {
      _resumeAfterForeground();
    }
  }
  void registerPlayer(ManagedPlayer player) {
    if (_activePlayers.containsKey(player.id)) {
      _activePlayers[player.id]?.dispose();
    }
    _activePlayers[player.id] = player;
  }
  void unregisterPlayer(String id) {
    final player = _activePlayers.remove(id);
    player?.dispose();
    if (_playerToResume?.id == id) {
      _playerToResume = null;
    }
  }
  void notifyPlaying(String playingId) {
    for (var player in _activePlayers.values) {
      if (player.id != playingId && player.isPlaying) {
        player.pause();
      }
    }
  }

  void _pauseAllForBackground() {
    for (var player in _activePlayers.values) {
      if (player.isPlaying) {
        _playerToResume = player;
        player.pause();
        break;
      }
    }
  }

  void _resumeAfterForeground() {
    if (_playerToResume != null) {
      _playerToResume!.play();
      _playerToResume = null;
    }
  }

  void _disposeAllPlayers() {
    for (var player in _activePlayers.values) {
      player.dispose();
    }
    _activePlayers.clear();
    _playerToResume = null;
  }
}
