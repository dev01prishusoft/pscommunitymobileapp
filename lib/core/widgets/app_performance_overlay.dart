import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/utils/diagnostic_logger.dart';

/// A lightweight diagnostic overlay only visible in debug/dev modes.
/// Wraps the root of the app to provide real-time observability.
class AppPerformanceOverlay extends StatefulWidget {
  const AppPerformanceOverlay({
    super.key,
    required this.child,
    this.enabled = kDebugMode,
  });

  final Widget child;
  final bool enabled;

  @override
  State<AppPerformanceOverlay> createState() => _AppPerformanceOverlayState();
}

class _AppPerformanceOverlayState extends State<AppPerformanceOverlay> {
  bool _isVisible = false;
  int _rebuildCount = 0;
  
  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _isVisible = true;
    }
  }

  void _toggleOverlay() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    _rebuildCount++;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          if (_isVisible)
            Positioned(
              top: 50,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.greenAccent, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🛠️ DEBUG MODE',
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      _buildStatRow('Active Requests', DiagnosticLogger.activeRequests.toString()),
                      _buildStatRow('Active Controllers', Get.isRegistered<dynamic>() ? '?' : '0'),
                      _buildStatRow('Overlay Rebuilds', _rebuildCount.toString()),
                      _buildStatRow('Current Route', Get.currentRoute),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            top: 50,
            right: 0,
            child: GestureDetector(
              onTap: _toggleOverlay,
              child: Container(
                width: 20,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Icon(
                  _isVisible ? Icons.chevron_right : Icons.chevron_left,
                  size: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
