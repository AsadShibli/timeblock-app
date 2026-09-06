import 'package:flutter/material.dart';

import '../domain/kalender_block.dart';

/// Colored time-block tile with web cursors + long-press delete affordance.
class EventBlockTile extends StatefulWidget {
  const EventBlockTile({
    super.key,
    required this.block,
    this.onLongPressDelete,
  });

  final KalenderBlock block;
  /// Touch-native delete (iOS PWA) — long-press confirms in parent.
  final VoidCallback? onLongPressDelete;

  @override
  State<EventBlockTile> createState() => _EventBlockTileState();
}

class _EventBlockTileState extends State<EventBlockTile> {
  // grab = move; resizeUpDown near top/bottom edges.
  MouseCursor _cursor = SystemMouseCursors.grab;

  void _updateCursor(Offset local, double height) {
    const edge = 10.0;
    final next = (local.dy <= edge || local.dy >= height - edge)
        ? SystemMouseCursors.resizeUpDown
        : SystemMouseCursors.grab;
    if (next != _cursor) setState(() => _cursor = next);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Short blocks can't fit title + duration — hide duration to avoid overflow.
        final showDuration = constraints.maxHeight >= 32;

        return MouseRegion(
          cursor: _cursor,
          onHover: (e) => _updateCursor(e.localPosition, constraints.maxHeight),
          onExit: (_) => setState(() => _cursor = SystemMouseCursors.grab),
          child: GestureDetector(
            onLongPress: widget.onLongPressDelete,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 3,
                      color: Color.lerp(
                        widget.block.color.color,
                        Colors.black,
                        0.35,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        // Less padding on short tiles so title still fits.
                        padding: EdgeInsets.all(constraints.maxHeight < 28 ? 2 : 4),
                        color: widget.block.color.color.withValues(alpha: 0.85),
                        alignment: Alignment.topLeft,
                        child: ClipRect(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.block.title,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.1,
                                ),
                              ),
                              if (showDuration)
                                Text(
                                  _formatDuration(
                                    widget.block.end.difference(widget.block.start),
                                  ),
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black87.withValues(alpha: 0.55),
                                    fontSize: 10,
                                    height: 1.1,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Formats a duration like "1h", "45m", or "1h 30m".
  static String _formatDuration(Duration diff) {
    final totalMinutes = diff.inMinutes.abs();
    if (totalMinutes <= 0) return '0m';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }
}
