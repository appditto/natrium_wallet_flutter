/// Used when coming from a deep link to post to the UI we're ready to handle a uni link
class DeepLinkAction {
  bool insufficientBalance;
  bool invalidDestination;
  String sendAmount;
  String sendDestination;

  DeepLinkAction({this.insufficientBalance = false, this.invalidDestination = false, this.sendAmount, this.sendDestination});
}