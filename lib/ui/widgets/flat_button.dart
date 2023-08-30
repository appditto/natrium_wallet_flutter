import 'package:flutter/material.dart';

class FlatButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final VoidCallback onLongPress;
  final ValueChanged<bool> onHighlightChanged;
  final MouseCursor mouseCursor;
  final ButtonTextTheme textTheme;
  final Color textColor;
  final Color disabledTextColor;
  final Color color;
  final Color disabledColor;
  final Color focusColor;
  final Color hoverColor;
  final Color highlightColor;
  final Color splashColor;
  final Brightness colorBrightness;
  final EdgeInsetsGeometry padding;
  final VisualDensity visualDensity;
  final ShapeBorder shape;
  final Clip clipBehavior;
  final FocusNode focusNode;
  final bool autofocus;
  final MaterialTapTargetSize materialTapTargetSize;
  final double height;
  final double minWidth;

  FlatButton({
    Key key,
    @required this.onPressed,
    @required this.child,
    this.onLongPress,
    this.onHighlightChanged,
    this.mouseCursor,
    this.textTheme,
    this.textColor,
    this.disabledTextColor,
    this.color,
    this.disabledColor,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.colorBrightness,
    this.padding,
    this.visualDensity,
    this.shape,
    this.clipBehavior = Clip.none,
    this.focusNode,
    this.autofocus = false,
    this.materialTapTargetSize,
    this.height,
    this.minWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert FlatButton properties to TextButton properties.
    final ButtonStyle style = ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) return disabledColor;
          return color;
        },
      ),
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) return disabledTextColor;
          return textColor;
        },
      ),
      overlayColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) return splashColor;
          if (states.contains(MaterialState.hovered)) return hoverColor;
          if (states.contains(MaterialState.focused)) return focusColor;
          return null;
        },
      ),
      mouseCursor:
          mouseCursor != null ? MaterialStateProperty.all(mouseCursor) : null,
      shape: shape != null
          ? MaterialStateProperty.all(shape)
          : MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
      padding: MaterialStateProperty.all(padding),
      visualDensity: visualDensity,
      tapTargetSize: materialTapTargetSize ?? MaterialTapTargetSize.padded,
      minimumSize: (height != null || minWidth != null)
          ? MaterialStateProperty.all(Size(minWidth ?? 0, height ?? 0))
          : null,
    );

    return TextButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: style,
      child: child,
      clipBehavior: clipBehavior,
      autofocus: autofocus,
      focusNode: focusNode,
    );
  }
}
