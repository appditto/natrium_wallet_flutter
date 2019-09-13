import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/styles.dart';

enum AddressTextType { PRIMARY60, PRIMARY, SUCCESS }

class OneOrThreeLineAddressText extends StatelessWidget {
  String address;
  String contactName;
  AddressTextType type;

  OneOrThreeLineAddressText({@required this.address, @required this.type, this.contactName});

  @override
  Widget build(BuildContext context) {
    // One line for small displays
    if (MediaQuery.of(context).size.height < 667) {
      String stringPartOne = address.substring(0, 12);
      String stringPartFive = address.substring(59);
      switch (type) {
        case AddressTextType.PRIMARY60:
          return Column(
            children: <Widget>[
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: '',
                  children: [
                    TextSpan(
                      text: stringPartOne,
                      style: AppStyles.textStyleAddressPrimary60(context),
                    ),
                    TextSpan(
                      text: "...",
                      style: AppStyles.textStyleAddressText60(context),
                    ),
                    TextSpan(
                      text: stringPartFive,
                      style: AppStyles.textStyleAddressPrimary60(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        case AddressTextType.PRIMARY:
          return Column(
            children: <Widget>[
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: '',
                  children: [
                    TextSpan(
                      text: stringPartOne,
                      style: AppStyles.textStyleAddressPrimary(context),
                    ),
                    TextSpan(
                      text: "...",
                      style: AppStyles.textStyleAddressText90(context),
                    ),
                    TextSpan(
                      text: stringPartFive,
                      style: AppStyles.textStyleAddressPrimary(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        case AddressTextType.SUCCESS:
          return Column(
            children: <Widget>[
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: '',
                  children: [
                    TextSpan(
                      text: stringPartOne,
                      style: AppStyles.textStyleAddressSuccess(context),
                    ),
                    TextSpan(
                      text: "...",
                      style: AppStyles.textStyleAddressText90(context),
                    ),
                    TextSpan(
                      text: stringPartFive,
                      style: AppStyles.textStyleAddressSuccess(context),
                    ),
                  ],
                ),
              ),
            ],
          );      
      }
    }
    // Three line
    String stringPartOne = address.substring(0, 12);
    String stringPartTwo = address.substring(12, 22);
    String stringPartThree = address.substring(22, 44);
    String stringPartFour = address.substring(44, 59);
    String stringPartFive = address.substring(59);
    switch (type) {
      case AddressTextType.PRIMARY60:
        return Column(
          children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartOne,
                    style: AppStyles.textStyleAddressPrimary60(context),
                  ),
                  TextSpan(
                    text: stringPartTwo,
                    style: AppStyles.textStyleAddressText60(context),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartThree,
                    style: AppStyles.textStyleAddressText60(context),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartFour,
                    style: AppStyles.textStyleAddressText60(context),
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: AppStyles.textStyleAddressPrimary60(context)
                  ),
                ],
              ),
            )
          ],
        );
      case AddressTextType.PRIMARY:
        Widget contactWidget = contactName != null
            ? RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: contactName,
                    style: AppStyles.textStyleAddressPrimary(context)))
            : SizedBox();
        return Column(
          children: <Widget>[
            contactWidget,
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartOne,
                    style: AppStyles.textStyleAddressPrimary(context),
                  ),
                  TextSpan(
                    text: stringPartTwo,
                    style: AppStyles.textStyleAddressText90(context),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartThree,
                    style: AppStyles.textStyleAddressText90(context),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartFour,
                    style: AppStyles.textStyleAddressText90(context),
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: AppStyles.textStyleAddressPrimary(context),
                  ),
                ],
              ),
            )
          ],
        );
      case AddressTextType.SUCCESS:
        Widget contactWidget = contactName != null
            ? RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: contactName,
                    style: AppStyles.textStyleAddressSuccess(context)))
            : SizedBox();
        return Column(
          children: <Widget>[
            contactWidget,
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartOne,
                    style: AppStyles.textStyleAddressSuccess(context),
                  ),
                  TextSpan(
                    text: stringPartTwo,
                    style: AppStyles.textStyleAddressText90(context),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartThree,
                    style: AppStyles.textStyleAddressText90(context),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartFour,
                    style: AppStyles.textStyleAddressText90(context),
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: AppStyles.textStyleAddressSuccess(context),
                  ),
                ],
              ),
            )
          ],
        );
    }
  }
}