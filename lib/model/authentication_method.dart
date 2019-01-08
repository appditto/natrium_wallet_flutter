
enum AuthMethod { PIN, BIOMETRICS }

/// Represent the available authentication methods our app supports
class AuthenticationMethod {
  AuthMethod method;

  AuthenticationMethod(this.method);

  String getDisplayName() {
    switch (method) {
      case AuthMethod.BIOMETRICS:
        return "Biometrics";
      case AuthMethod.PIN:
        return "PIN";
      default:
        return "PIN";
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return method.index;
  }
}