import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/ui/widgets/flat_button.dart';

/// TextField button
class TextFieldButton extends StatelessWidget {
  final IconData icon;
  final Function onPressed;

  TextFieldButton({@required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 48,
        width: 48,
        child: FlatButton(
          padding: EdgeInsets.all(14.0),
          highlightColor: StateContainer.of(context).curTheme.primary15,
          splashColor: StateContainer.of(context).curTheme.primary30,
          onPressed: () {
            onPressed != null ? onPressed() : null;
          },
          child: Icon(icon,
              size: 20, color: StateContainer.of(context).curTheme.primary),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200.0)),
        ));
  }
}

/// A widget for our custom textfields
class AppTextField extends StatefulWidget {
  final TextAlign textAlign;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Color cursorColor;
  final Brightness keyboardAppearance;
  final List<TextInputFormatter> inputFormatters;
  final TextInputAction textInputAction;
  final int maxLines;
  final bool autocorrect;
  final String hintText;
  final TextFieldButton prefixButton;
  final TextFieldButton suffixButton;
  final bool fadePrefixOnCondition;
  final bool prefixShowFirstCondition;
  final bool fadeSuffixOnCondition;
  final bool suffixShowFirstCondition;
  final EdgeInsetsGeometry padding;
  final Widget overrideTextFieldWidget;
  final int buttonFadeDurationMs;
  final TextInputType keyboardType;
  final Function onSubmitted;
  final Function onChanged;
  final double topMargin;
  final double leftMargin;
  final double rightMargin;
  final TextStyle style;
  final bool obscureText;
  final bool autofocus;

  AppTextField(
      {this.focusNode,
      this.controller,
      this.cursorColor,
      this.inputFormatters,
      this.textInputAction,
      this.hintText,
      this.prefixButton,
      this.suffixButton,
      this.fadePrefixOnCondition,
      this.prefixShowFirstCondition,
      this.fadeSuffixOnCondition,
      this.suffixShowFirstCondition,
      this.overrideTextFieldWidget,
      this.keyboardType,
      this.onSubmitted,
      this.onChanged,
      this.style,
      this.leftMargin,
      this.rightMargin,
      this.obscureText = false,
      this.textAlign = TextAlign.center,
      this.keyboardAppearance = Brightness.dark,
      this.autocorrect = true,
      this.maxLines = 1,
      this.padding = EdgeInsets.zero,
      this.buttonFadeDurationMs = 100,
      this.topMargin = 0,
      this.autofocus = false});

  _AppTextFieldState createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(
          left: widget.leftMargin ?? MediaQuery.of(context).size.width * 0.105,
          right:
              widget.rightMargin ?? MediaQuery.of(context).size.width * 0.105,
          top: widget.topMargin,
        ),
        padding: widget.padding,
        width: double.infinity,
        decoration: BoxDecoration(
          color: StateContainer.of(context).curTheme.backgroundDarkest,
          borderRadius: BorderRadius.circular(25),
        ),
        child: widget.overrideTextFieldWidget == null
            ? Stack(alignment: AlignmentDirectional.center, children: <Widget>[
                TextField(
                    // User defined fields
                    textAlign: widget.textAlign,
                    keyboardAppearance: widget.keyboardAppearance,
                    autocorrect: widget.autocorrect,
                    maxLines: widget.maxLines,
                    focusNode: widget.focusNode,
                    controller: widget.controller,
                    cursorColor: widget.cursorColor ??
                        StateContainer.of(context).curTheme.primary,
                    inputFormatters: widget.inputFormatters,
                    textInputAction: widget.textInputAction,
                    keyboardType: widget.keyboardType,
                    obscureText: widget.obscureText,
                    autofocus: widget.autofocus,
                    onSubmitted: widget.onSubmitted != null
                        ? widget.onSubmitted
                        : (text) {
                            if (widget.textInputAction ==
                                TextInputAction.done) {
                              FocusScope.of(context).unfocus();
                            }
                          },
                    onChanged: widget.onChanged,
                    // Style
                    style: widget.style,
                    // Input decoration
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        // Hint
                        hintText:
                            widget.hintText == null ? "" : widget.hintText,
                        hintStyle: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w100,
                          fontFamily: 'NunitoSans',
                          color: StateContainer.of(context).curTheme.text60,
                        ),
                        // First button
                        prefixIcon: widget.prefixButton == null
                            ? Container(width: 0, height: 0)
                            : Container(width: 48, height: 48),
                        suffixIcon: widget.suffixButton == null
                            ? Container(width: 0, height: 0)
                            : Container(width: 48, height: 48))),
                // Buttons
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          widget.fadePrefixOnCondition != null &&
                                  widget.prefixButton != null
                              ? AnimatedCrossFade(
                                  duration: Duration(
                                      milliseconds:
                                          widget.buttonFadeDurationMs),
                                  firstChild: widget.prefixButton,
                                  secondChild: SizedBox(height: 48, width: 48),
                                  crossFadeState:
                                      widget.prefixShowFirstCondition
                                          ? CrossFadeState.showFirst
                                          : CrossFadeState.showSecond,
                                )
                              : widget.prefixButton != null
                                  ? widget.prefixButton
                                  : SizedBox(),
                          // Second (suffix) button
                          widget.fadeSuffixOnCondition != null &&
                                  widget.suffixButton != null
                              ? AnimatedCrossFade(
                                  duration: Duration(
                                      milliseconds:
                                          widget.buttonFadeDurationMs),
                                  firstChild: widget.suffixButton,
                                  secondChild: SizedBox(height: 48, width: 48),
                                  crossFadeState:
                                      widget.suffixShowFirstCondition
                                          ? CrossFadeState.showFirst
                                          : CrossFadeState.showSecond,
                                )
                              : widget.suffixButton != null
                                  ? widget.suffixButton
                                  : SizedBox()
                        ])
                  ],
                )
              ])
            : widget.overrideTextFieldWidget);
  }
}
