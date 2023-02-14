import 'dart:math' as math;
import 'package:flutter/rendering.dart';

typedef UniformGridSizeChangedCallback = void Function(
    Size size, Size cellSize);

class _ParentData extends ContainerBoxParentData<RenderBox> {}

class RenderUniformGrid extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _ParentData> {
  RenderUniformGrid({
    required int columnCount,
    BorderSide borderSide = BorderSide.none,
    bool squareCell = false,
    bool withHeader = true,
    UniformGridSizeChangedCallback? onSizeChanged,
    Size? fixedSize,
  })  : _columnCount = columnCount,
        _borderSide = borderSide,
        _squareCell = squareCell,
        _withHeader = withHeader,
        _onSizeChanged = onSizeChanged,
        _fixedSize = fixedSize;

  int get columnCount => _columnCount;
  int _columnCount;
  set columnCount(int value) {
    if (_columnCount == value) {
      return;
    }
    _columnCount = value;
    markNeedsLayout();
  }

  BorderSide get borderSide => _borderSide;
  BorderSide _borderSide;
  set borderSide(BorderSide value) {
    if (_borderSide == value) {
      return;
    }
    _borderSide = value;
    markNeedsPaint();
  }

  bool get squareCell => _squareCell;
  bool _squareCell;
  set squareCell(bool value) {
    if (_squareCell == value) {
      return;
    }
    _squareCell = value;
    markNeedsLayout();
  }

  bool get withHeader => _withHeader;
  bool _withHeader;
  set withHeader(bool value) {
    if (_withHeader == value) {
      return;
    }
    _withHeader = value;
    markNeedsLayout();
  }

  UniformGridSizeChangedCallback? _onSizeChanged;
  set onSizeChanged(UniformGridSizeChangedCallback? value) {
    if (_onSizeChanged == value) {
      return;
    }
    _onSizeChanged = value;
  }

  Size? get fixedSize => _fixedSize;
  Size? _fixedSize;
  set fixedSize(Size? value) {
    if (_fixedSize == value) {
      return;
    }
    _fixedSize = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _ParentData) {
      child.parentData = _ParentData();
    }
  }

  @override
  void performLayout() {
    final width = _fixedSize?.width ?? constraints.maxWidth;
    final height = _fixedSize?.height ?? constraints.maxHeight;
    final delta = _borderSide == BorderSide.none ? 0 : _borderSide.width / 2;
    final childWidth = (width - delta * 2) / columnCount;
    double headerHeight = 0;
    int index = 0;
    RenderBox? child = firstChild;

    /// layout headers
    if (_withHeader) {
      while (child != null) {
        final childParentData = child.parentData as _ParentData;
        child.layout(BoxConstraints.tightFor(width: childWidth),
            parentUsesSize: true);
        childParentData.offset = Offset(delta + childWidth * index, 0);
        headerHeight = math.max(headerHeight, child.size.height);
        child = childParentData.nextSibling;
        if (++index == columnCount) {
          break;
        }
      }
    }

    /// layout cells
    final rowCount = _withHeader
        ? ((childCount - columnCount) / columnCount).floor()
        : (childCount / columnCount).floor();
    final childHeight =
        _squareCell ? childWidth : (height - headerHeight - delta) / rowCount;
    while (child != null) {
      final childParentData = child.parentData as _ParentData;
      final rowIndex =
          _withHeader ? index ~/ columnCount - 1 : index ~/ columnCount;
      child.layout(
          BoxConstraints.tightFor(width: childWidth, height: childHeight),
          parentUsesSize: true);
      childParentData.offset = Offset(
          delta + childWidth * (index % columnCount),
          headerHeight + childHeight * rowIndex);
      child = childParentData.nextSibling;
      index++;
    }

    size = constraints.constrain(Size(width,
        height.isInfinite ? headerHeight + childHeight * rowCount : height));
    _onSizeChanged?.call(size, Size(childWidth, childHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as _ParentData;
      context.paintChild(child, childParentData.offset + offset);
      child = childParentData.nextSibling;
    }

    if (_borderSide != BorderSide.none) {
      _paintBorder(context.canvas, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = lastChild;
    while (child != null) {
      final childParentData = child.parentData as _ParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
      child = childParentData.previousSibling;
    }
    return false;
  }

  void _paintBorder(Canvas canvas, Offset offset) {
    final delta = _borderSide == BorderSide.none ? 0.0 : _borderSide.width / 2;
    if (_withHeader) {
      offset = offset.translate(delta, firstChild!.size.height);
    }
    final width = size.width - delta * 2;
    final height = _withHeader
        ? size.height - delta - firstChild!.size.height
        : size.height - delta;
    final Paint paint = Paint()
      ..color = _borderSide.color
      ..strokeWidth = _borderSide.width
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..moveTo(offset.dx, offset.dy)
      ..lineTo(offset.dx + width, offset.dy)
      ..lineTo(offset.dx + width, offset.dy + height)
      ..lineTo(offset.dx, offset.dy + height)
      ..lineTo(offset.dx, offset.dy);

    final childWidth = firstChild!.size.width;
    for (int i = _withHeader ? 1 : 0; i < columnCount; i++) {
      path
        ..moveTo(offset.dx + i * childWidth, offset.dy)
        ..lineTo(offset.dx + i * childWidth, offset.dy + height);
    }

    final rowCount =
        ((childCount - (_withHeader ? columnCount : 0)) / columnCount).floor();
    final childHeight = height / rowCount;
    for (int i = _withHeader ? 1 : 0; i < rowCount; i++) {
      path
        ..moveTo(offset.dx, offset.dy + i * childHeight)
        ..lineTo(offset.dx + width, offset.dy + i * childHeight);
    }
    canvas.drawPath(path, paint);
  }
}
