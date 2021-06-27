import 'package:better_print/better_print.dart';
import 'package:flutter/cupertino.dart';

enum Restack { top, up, down, bottom }

class CanvasItem {
  final String key;
  final String rootKey;
  String _label;
  int focusCount = 0;
  String _sizeProfile;
  Offset _offset;
  Size _size;
  bool _rotate;
  final Widget? child;
  CanvasItem(this.key, this.rootKey, this._label, this.child,
      [this._size = const Size(360, 640),
      this._sizeProfile = 'Android',
      this._rotate = false,
      this._offset = Offset.zero]);
  String get label => _label;
  Offset get offset => _offset;
  Size get size => _size;
  bool get rotate => _rotate;
  String get sizeProfile => _sizeProfile;

  changeLabel(String value) {
    this._label = value;
  }

  setOffset(Offset offset) {
    this._offset = offset;
  }

  rotateSize() {
    _rotate = !_rotate;
    _size = _size.flipped;
  }

  setSize(String profile, Size size) {
    _sizeProfile = profile;
    this._size = size;
  }

  Map get asMap => {
        'key': key,
        'label': _label,
        'root': this.rootKey,
        'size': {'width': size.width, 'height': size.height},
        'sizeProfile': _sizeProfile,
        'rotate': _rotate,
        'offset': {'x': offset.dx, 'y': offset.dy},
      };
}

class CanvasController {
  final List<CanvasItem> children;
  double _zoom = 1;
  final void Function([bool notify]) notifier;
  CanvasController({
    this.children: const [],
    required this.notifier,
  });

  double get zoom => _zoom;

  setZoom(double zoom) {
    _zoom = zoom;
  }

  List<CanvasItem> restack(CanvasItem item, [Restack mode = Restack.top]) {
    final i = children.indexWhere((el) => el.key == item.key);
    children.removeAt(i);
    switch (mode) {
      case Restack.top:
        children.add(item);
        break;
      case Restack.up:
        children.insert(i + 1, item);
        break;
      case Restack.down:
        children.insert(i == 0 ? 0 : i - 1, item);
        break;
      case Restack.bottom:
        children.insert(0, item);
        break;
    }
    return children;
  }

  List<Map> get asMap => children.map((e) => e.asMap).toList();
}
