import 'package:flutter/widgets.dart';
import 'package:pscommunitymobileapp/core/lifecycle/app_lifecycle_observer.dart';
import 'package:pscommunitymobileapp/core/utils/diagnostic_logger.dart';

/// A platform-agnostic interface for any media player.
/// This prevents tight coupling to `media_kit`, `video_player`, or other specific packages.
abstract class ManagedPlayer {
  String get id;
  bool get isPlaying;
  
  void pause();
  void play();
  void dispose();
}

/// Centralized manager for tracking active media players.
/// Ensures only one player is active at a time (if desired), handles app lifecycle pauses,
/// and prevents zombie decoders from leaking memory.
class MediaLifecycleManager {
  MediaLifecycleManager._internal();
  static final MediaLifecycleManager _instance = MediaLifecycleManager._internal();
  static MediaLifecycleManager get instance => _instance;

  final Map<String, ManagedPlayer> _activePlayers = {};
  
  /// The player that was actively playing before the app went to the background.
  ManagedPlayer? _playerToResume;

  bool _isInitialized = false;

  void init() {
    if (_isInitialized) return;
    AppLifecycleObserver.instance.addListener(_onAppLifecycleChanged);
    _isInitialized = true;
    DiagnosticLogger.logLifecycle('MediaLifecycleManager', 'Initialized');
  }

  void dispose() {
    AppLifecycleObserver.instance.removeListener(_onAppLifecycleChanged);
    _disposeAllPlayers();
    _isInitialized = false;
    DiagnosticLogger.logLifecycle('MediaLifecycleManager', 'Disposed');
  }

  void _onAppLifecycleChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _pauseAllForBackground();
    } else if (state == AppLifecycleState.resumed) {
      _resumeAfterForeground();
    }
  }

  /// Registers a newly created player.
  void registerPlayer(ManagedPlayer player) {
    if (_activePlayers.containsKey(player.id)) {
      DiagnosticLogger.log('Player ${player.id} is already registered. Disposing old instance.', tag: 'MediaManager');
      _activePlayers[player.id]?.dispose();
    }
    _activePlayers[player.id] = player;
    DiagnosticLogger.logLifecycle('MediaManager', 'Registered player ${player.id}');
  }

  /// Disposes and unregisters a player.
  void unregisterPlayer(String id) {
    final player = _activePlayers.remove(id);
    player?.dispose();
    if (_playerToResume?.id == id) {
      _playerToResume = null;
    }
    DiagnosticLogger.logLifecycle('MediaManager', 'Unregistered player $id');
  }

  /// Used to ensure only one player plays at once (e.g. in a feed).
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
        DiagnosticLogger.log('Auto-paused player ${player.id} for background', tag: 'MediaManager');
        break;
      }
    }
  }

  void _resumeAfterForeground() {
    if (_playerToResume != null) {
      DiagnosticLogger.log('Auto-resuming player ${_playerToResume!.id} after foreground', tag: 'MediaManager');
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
