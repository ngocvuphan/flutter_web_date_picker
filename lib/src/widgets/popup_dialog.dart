///
/// Reference: flutter/lib/src/material/popup_menu.dart
///
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const Duration _kPopupTransitionDuration = Duration(milliseconds: 400);
const double _kPopupCloseIntervalEnd = 2.0 / 3.0;
const double _kPopupScreenPadding = 8.0;

Future<T?> showPopupDialog<T>(
  BuildContext context,
  WidgetBuilder builder, {
  bool useRootNavigator = false,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  Offset offset = Offset.zero,
  bool asDropDown = false,
  bool useTargetWidth = false,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final renderBox = context.findRenderObject()! as RenderBox;
  final overlayRenderBox =
      navigator.overlay!.context.findRenderObject()! as RenderBox;

  final position = RelativeRect.fromRect(
    Rect.fromPoints(
      renderBox.localToGlobal(renderBox.size.topLeft(Offset.zero),
          ancestor: overlayRenderBox),
      renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero),
          ancestor: overlayRenderBox),
    ),
    Offset.zero & overlayRenderBox.size,
  );

  return navigator.push(_PopupDialogRoute<T>(
    asDropDown: asDropDown,
    position: position,
    capturedThemes:
        InheritedTheme.capture(from: context, to: navigator.context),
    dialogWidth: useTargetWidth ? renderBox.size.width : double.infinity,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    child: builder(context),
  ));
}

class _PopupDialogRoute<T> extends PopupRoute<T> {
  _PopupDialogRoute({
    required this.asDropDown,
    required this.position,
    required this.capturedThemes,
    required this.dialogWidth,
    required this.barrierDismissible,
    this.barrierColor,
    this.barrierLabel,
    required this.child,
  });

  final bool asDropDown;
  final RelativeRect position;
  final CapturedThemes capturedThemes;
  final double dialogWidth;
  @override
  final bool barrierDismissible;
  @override
  Color? barrierColor;
  @override
  String? barrierLabel;
  final Widget child;

  @override
  Duration get transitionDuration => _kPopupTransitionDuration;

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(
      parent: super.createAnimation(),
      curve: Curves.linear,
      reverseCurve: const Interval(0.0, _kPopupCloseIntervalEnd),
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final dialog = _Dialog(
        animation: animation,
        asDropDown: asDropDown,
        width: dialogWidth,
        child: child);
    return CustomSingleChildLayout(
      delegate: _PopupDialogLayoutDelegate(
        position: position,
        avoidBounds: _avoidBounds(mediaQuery),
        asDropDown: asDropDown,
      ),
      child: capturedThemes.wrap(dialog),
    );
  }

  Set<Rect> _avoidBounds(MediaQueryData mediaQuery) {
    return DisplayFeatureSubScreen.avoidBounds(mediaQuery).toSet();
  }
}

class _PopupDialogLayoutDelegate extends SingleChildLayoutDelegate {
  _PopupDialogLayoutDelegate({
    required this.position,
    required this.avoidBounds,
    required this.asDropDown,
  });

  final RelativeRect position;
  final Set<Rect> avoidBounds;
  final bool asDropDown;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest)
        .deflate(const EdgeInsets.all(_kPopupScreenPadding));
  }

  @override
  Offset getPositionForChild(Size overlaySize, Size menuSize) {
    final targetWidth = overlaySize.width - position.left - position.right;
    final targetHeight = overlaySize.height - position.top - position.bottom;
    double x, y;
    if (position.left > position.right) {
      x = asDropDown ? position.left : position.left - menuSize.width;
    } else {
      x = asDropDown ? position.left : position.left + targetWidth;
    }

    // if (position.top > position.bottom) {
    //   y = asDropDown ? position.top - menuSize.height : position.top;
    // } else {
    //   y = asDropDown ? position.top + targetHeight : position.top;
    // }
    y = position.top + targetHeight;

    final Offset wantedPosition = Offset(x, y);
    final Offset originCenter =
        position.toRect(Offset.zero & overlaySize).center;
    final Iterable<Rect> subScreens =
        DisplayFeatureSubScreen.subScreensInBounds(
            Offset.zero & overlaySize, avoidBounds);
    final Rect subScreen = _closestScreen(subScreens, originCenter);
    return _fitInsideScreen(subScreen, menuSize, wantedPosition);
  }

  @override
  bool shouldRelayout(covariant _PopupDialogLayoutDelegate oldDelegate) {
    return position != oldDelegate.position ||
        !setEquals(avoidBounds, oldDelegate.avoidBounds) ||
        asDropDown != oldDelegate.asDropDown;
  }

  Rect _closestScreen(Iterable<Rect> screens, Offset point) {
    Rect closest = screens.first;
    for (final Rect screen in screens) {
      if ((screen.center - point).distance <
          (closest.center - point).distance) {
        closest = screen;
      }
    }
    return closest;
  }

  Offset _fitInsideScreen(Rect screen, Size menuSize, Offset wantedPosition) {
    double x = wantedPosition.dx;
    double y = wantedPosition.dy;
    if (x < screen.left + _kPopupScreenPadding) {
      x = screen.left + _kPopupScreenPadding;
    } else if (x + menuSize.width > screen.right - _kPopupScreenPadding) {
      x = screen.right - menuSize.width - _kPopupScreenPadding;
    }
    if (y < screen.top + _kPopupScreenPadding) {
      y = _kPopupScreenPadding;
    } else if (y + menuSize.height > screen.bottom - _kPopupScreenPadding) {
      y = screen.bottom - menuSize.height - _kPopupScreenPadding;
    }

    return Offset(x, y);
  }
}

class _Dialog extends StatelessWidget {
  const _Dialog({
    required this.animation,
    required this.asDropDown,
    required this.width,
    required this.child,
  });

  final Animation<double> animation;
  final bool asDropDown;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sizeAnimation = CurveTween(curve: const Interval(0.0, 1.0 / 2.5));
    final opacityAnimation = CurveTween(curve: const Interval(0.0, 1.0 / 3.0));
    Widget dialog = SingleChildScrollView(child: child);

    if (!width.isInfinite) {
      dialog = SizedBox(width: width, child: dialog);
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: opacityAnimation.animate(animation),
          child: ClipRect(
            clipBehavior: Clip.antiAlias,
            child: Align(
              widthFactor: asDropDown ? 1.0 : sizeAnimation.evaluate(animation),
              heightFactor:
                  asDropDown ? sizeAnimation.evaluate(animation) : 1.0,
              child: child,
            ),
          ),
        );
      },
      child: dialog,
    );
  }
}
