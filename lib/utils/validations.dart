class Validations {
  final RegExp _emailRegEx = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );
  final RegExp _passwordRegEx =
      RegExp(r"^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[?:.,;'_*&|!@$#%^])");

  String? emailValidator({required String email}) {
    if (_emailRegEx.hasMatch(email)) {
      return null;
    }
    return 'This email address is invalid. Please try again.';
  }

  String? passwordValidator({required String password}) {
    if (_passwordRegEx.hasMatch(password)) {
      return null;
    }
    return '''Password must be a combination of 6 or more letters, numbers and punctuation marks.''';
  }
}
