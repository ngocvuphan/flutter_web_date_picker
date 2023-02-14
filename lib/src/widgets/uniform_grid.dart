import 'package:flutter/widgets.dart';

import 'rendering/uniform_grid.dart';

export 'rendering/uniform_grid.dart' show UniformGridSizeChangedCallback;

class UniformGrid extends MultiChildRenderObjectWidget {
  UniformGrid({
    super.key,
    super.children,
    required this.columnCount,
    this.borderSide = BorderSide.none,
    this.squareCell = false,
    this.withHeader = true,
    this.onSizeChanged,
    this.fixedSize,
  });

  final int columnCount;
  final BorderSide borderSide;
  final bool squareCell;
  final bool withHeader;
  final UniformGridSizeChangedCallback? onSizeChanged;
  final Size? fixedSize;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderUniformGrid(
      columnCount: columnCount,
      borderSide: borderSide,
      squareCell: squareCell,
      withHeader: withHeader,
      onSizeChanged: onSizeChanged,
      fixedSize: fixedSize,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    (renderObject as RenderUniformGrid)
      ..columnCount = columnCount
      ..borderSide = borderSide
      ..squareCell = squareCell
      ..withHeader = withHeader
      ..onSizeChanged = onSizeChanged
      ..fixedSize = fixedSize;
  }
}
