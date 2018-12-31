class AppState {
  bool isLoggedIn = false;

  AppState({
    this.isLoggedIn = false
  });

  factory AppState.loggedIn() => new AppState(isLoggedIn: true);

  @override
  String toString() {
    return 'AppState{isLoggedIn: $isLoggedIn}';
  }
}