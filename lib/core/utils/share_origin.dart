import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Global rect of the widget behind [context].
///
/// iPad presents the share sheet as a popover and requires an anchor rect;
/// without one share_plus throws and Printing.sharePdf shows nothing. Pass
/// the context of the tapped button (wrap it in a Builder if needed).
Rect? shareOriginOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}
