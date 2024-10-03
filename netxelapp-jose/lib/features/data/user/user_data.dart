class UserData {
  static final UserData _instance = UserData._internal();
  static String? userName;

  factory UserData() {
    return _instance;
  }

  UserData._internal();
}
