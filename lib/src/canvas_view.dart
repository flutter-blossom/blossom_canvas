import 'package:better_print/better_print.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'controller.dart';

class CanvasView extends HookWidget {
  CanvasView(
      {Key? key,
      required this.controller,
      this.maxZoom = 2.0,
      this.minZoom = 0.5,
      this.enableControls = true,
      this.backgroundColor,
      this.borderColor = Colors.blue,
      required this.onSelect,
      required this.onDeviceChange,
      required this.onDrag,
      required this.onZoom,
      required this.onRemove,
      required this.onAdd,
      required this.onRotate,
      required this.onError})
      : super(key: key);
  final double maxZoom;
  final double minZoom;
  final bool enableControls;
  final CanvasController controller;
  final void Function(CanvasItem? item) onSelect;
  final void Function(CanvasItem item, Offset pos) onDeviceChange;
  final void Function(CanvasItem item) onRemove;
  final void Function(CanvasItem item) onAdd;
  final void Function(CanvasItem item) onRotate;
  final void Function(double zoom) onZoom;
  final void Function(FlutterErrorDetails details) onError;
  final void Function(
          bool value, Offset delta, CanvasItem? item, List<CanvasItem> overlaps)
      onDrag;
  final Color? backgroundColor;
  final Color borderColor;
  @override
  Widget build(BuildContext context) {
    List<CanvasItem> overlaps = [];
    final selectedItem = useState<CanvasItem?>(null);
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerSignal: enableControls
          ? (PointerSignalEvent event) {
              if (event is PointerScrollEvent) {
                if (event.scrollDelta.dy > 0) {
                  if (controller.zoom < maxZoom)
                    controller.setZoom(controller.zoom + 0.1);
                } else {
                  if (controller.zoom > minZoom + 0.1)
                    controller.setZoom(controller.zoom - 0.1);
                }
                this.onZoom(controller.zoom);
                controller.notifier();
              }
            }
          : null,
      onPointerDown: enableControls
          ? (_) {
              overlaps = [];
              selectedItem.value = null;
              Future.delayed(Duration(milliseconds: 0))
                  .then((value) => onSelect(selectedItem.value));
            }
          : null,
      onPointerMove: enableControls
          ? (event) {
              Future.delayed(Duration(milliseconds: 0)).then(
                  (value) => this.onDrag(true, event.delta, null, overlaps));
              if (selectedItem.value == null) {
                controller.children.forEach((e) =>
                    e.setOffset(event.delta / controller.zoom + e.offset));
                controller.notifier();
              }
            }
          : null,
      onPointerUp: (_) {
        this.onDrag(false, Offset.zero, null, overlaps);
      },
      child: FractionallySizedBox(
        widthFactor: 3,
        heightFactor: 3,
        child: Container(
          color: backgroundColor,
          child: Stack(
            children: controller.children
                .map((e) => Center(
                      child: Transform.scale(
                        scale: controller.zoom,
                        child: Transform.translate(
                          offset: e.offset +
                              Offset(0, MediaQuery.of(context).size.height),
                          child: Listener(
                            behavior: HitTestBehavior.translucent,
                            onPointerDown: enableControls
                                ? (_) {
                                    Future.delayed(Duration(milliseconds: 0))
                                        .then(
                                            (value) => selectedItem.value = e);
                                  }
                                : null,
                            onPointerMove: enableControls
                                ? (event) {
                                    overlaps = controller.children
                                        .where((el) =>
                                            el != e &&
                                            (el.offset & el.size)
                                                .overlaps(e.offset & e.size))
                                        .toList();
                                    this.onDrag(true, event.delta, e, overlaps);
                                    e.setOffset(event.delta / controller.zoom +
                                        e.offset);
                                    // controller.layoutCanvas(e, event.delta);
                                    controller.notifier(true);
                                  }
                                : null,
                            child: Column(
                              children: [
                                if (enableControls)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3.0,
                                    ),
                                    child: Container(
                                      width: e.size.width - 6,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                e.label,
                                                style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14),
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              InkWell(
                                                onTap: () => onAdd(e),
                                                child: Tooltip(
                                                  message: 'new',
                                                  child: Icon(
                                                    Icons.add,
                                                    color: Colors.black54,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  e.rotateSize();
                                                  onRotate(e);
                                                },
                                                child: Tooltip(
                                                  message: 'rotate',
                                                  child: Icon(
                                                    Icons.crop_rotate_outlined,
                                                    color: Colors.black54,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Listener(
                                                onPointerDown: (event) =>
                                                    onDeviceChange(
                                                        e, event.position),
                                                child: Text(
                                                  e.sizeProfile,
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 14),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              InkWell(
                                                onTap: () => onRemove(e),
                                                child: Tooltip(
                                                  message: 'close',
                                                  child: Icon(
                                                    Icons.cancel,
                                                    color: Colors.black54,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  SizedBox(
                                    height: 19,
                                  ),
                                WidgetsApp(
                                  color: Colors.blue,
                                  debugShowCheckedModeBanner: false,
                                  builder: (_, __) {
                                    ErrorWidget.builder =
                                        (FlutterErrorDetails errorDetails) {
                                      onError(errorDetails);
                                      return Center(
                                          child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.error,
                                              size: 20, color: Colors.red),
                                          Text(
                                            errorDetails.summary.toString() +
                                                ' !!',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ));
                                    };
                                    return Container(
                                      width: e.size.width,
                                      height: e.size.height,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: borderColor.withOpacity(
                                              selectedItem.value?.key ==
                                                          e.key &&
                                                      enableControls
                                                  ? 1
                                                  : 0),
                                          width: 2.5,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(0.5),
                                      child: ClipRRect(
                                        child: e.child,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
