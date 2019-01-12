import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/colors.dart';

class KaliumSheets {
  //Kalium Ninty Height Sheet
  static Future<T> showKaliumHeightNineSheet<T>(
      {@required BuildContext context,
      @required WidgetBuilder builder,
      Color color = KaliumColors.backgroundDark,
      double radius = 30.0,
      Color bgColor = KaliumColors.overlay70,
      int animationDurationMs = 200,
      bool removeUntilHome = false,
      bool closeOnTap = false,
      Function onDisposed}) {
    assert(context != null);
    assert(builder != null);
    assert(radius != null && radius > 0.0);
    assert(color != null && color != Colors.transparent);
    var route = _KaliumHeightNineModalRoute<T>(
        builder: builder,
        color: color,
        radius: radius,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        bgColor: bgColor,
        animationDurationMs: animationDurationMs,
        closeOnTap: closeOnTap,
        onDisposed: onDisposed);
    if (removeUntilHome) {
      return Navigator.pushAndRemoveUntil<T>(
          context, route, ModalRoute.withName('/home'));
    }
    return Navigator.push<T>(context, route);
  }

  //Kalium Height Eigth Sheet
  static Future<T> showKaliumHeightEightSheet<T>(
      {@required BuildContext context,
      @required WidgetBuilder builder,
      Color color = KaliumColors.backgroundDark,
      double radius = 30.0,
      Color bgColor = KaliumColors.overlay70,
      int animationDurationMs = 200}) {
    assert(context != null);
    assert(builder != null);
    assert(radius != null && radius > 0.0);
    assert(color != null && color != Colors.transparent);
    return Navigator.push<T>(
        context,
        _KaliumHeightEightModalRoute<T>(
            builder: builder,
            color: color,
            radius: radius,
            barrierLabel:
                MaterialLocalizations.of(context).modalBarrierDismissLabel,
            bgColor: bgColor,
            animationDurationMs: animationDurationMs));
  }
}

class _KaliumHeightNineSheetLayout extends SingleChildLayoutDelegate {
  _KaliumHeightNineSheetLayout(this.progress);

  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    if (constraints.maxHeight < 667)
      return BoxConstraints(
          minWidth: constraints.maxWidth,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight * 0.95);
    else
      return BoxConstraints(
          minWidth: constraints.maxWidth,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight * 0.9);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_KaliumHeightNineSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _KaliumHeightNineModalRoute<T> extends PopupRoute<T> {
  _KaliumHeightNineModalRoute(
      {this.builder,
      this.barrierLabel,
      this.color,
      this.radius,
      RouteSettings settings,
      this.bgColor,
      this.animationDurationMs,
      this.closeOnTap,
      this.onDisposed})
      : super(settings: settings);

  final WidgetBuilder builder;
  final double radius;
  final Color color;
  final Color bgColor;
  final int animationDurationMs;
  final bool closeOnTap;
  final Function onDisposed;

  @override
  Color get barrierColor => bgColor;

  @override
  bool get barrierDismissible => true;

  @override
  String barrierLabel;

  @override
  void didComplete(T result) {
    if (onDisposed != null) {
      onDisposed();
    }
    super.didComplete(result);
  }

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: GestureDetector(
        onTap: () {
          if (closeOnTap) {
            // Close when tapped anywhere
            Navigator.of(context).pop();
          }
        },
        child: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) => CustomSingleChildLayout(
                  delegate: _KaliumHeightNineSheetLayout(animation.value),
                  child: BottomSheet(
                    animationController: _animationController,
                    onClosing: () => Navigator.pop(context),
                    builder: (context) => Container(
                          decoration: BoxDecoration(
                            color: this.color,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(this.radius),
                              topRight: Radius.circular(this.radius),
                            ),
                          ),
                          child: Builder(builder: this.builder),
                        ),
                  ),
                ),
          ),
        ),
      ),
    );
  }

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration =>
      Duration(milliseconds: animationDurationMs);
}
//Kalium Height Nine Sheet End

class _KaliumHeightEightSheetLayout extends SingleChildLayoutDelegate {
  _KaliumHeightEightSheetLayout(this.progress);

  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    if (constraints.maxHeight / constraints.maxWidth > 1.9)
      return BoxConstraints(
          minWidth: constraints.maxWidth,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight * 0.7);
    if (constraints.maxHeight < 667)
      return BoxConstraints(
          minWidth: constraints.maxWidth,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight * 0.9);
    else
      return BoxConstraints(
          minWidth: constraints.maxWidth,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight * 0.8);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_KaliumHeightEightSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _KaliumHeightEightModalRoute<T> extends PopupRoute<T> {
  _KaliumHeightEightModalRoute(
      {this.builder,
      this.barrierLabel,
      this.color,
      this.radius,
      RouteSettings settings,
      this.bgColor,
      this.animationDurationMs})
      : super(settings: settings);

  final WidgetBuilder builder;
  final double radius;
  final Color color;
  final Color bgColor;
  final int animationDurationMs;

  @override
  Color get barrierColor => bgColor;

  @override
  bool get barrierDismissible => true;

  @override
  String barrierLabel;

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) => CustomSingleChildLayout(
                delegate: _KaliumHeightEightSheetLayout(animation.value),
                child: BottomSheet(
                  animationController: _animationController,
                  onClosing: () => Navigator.pop(context),
                  builder: (context) => Container(
                        decoration: BoxDecoration(
                          color: this.color,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(this.radius),
                            topRight: Radius.circular(this.radius),
                          ),
                        ),
                        child: Builder(builder: this.builder),
                      ),
                ),
              ),
        ),
      ),
    );
  }

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration =>
      Duration(milliseconds: animationDurationMs);
}
//Kalium HeightEight Sheet End
