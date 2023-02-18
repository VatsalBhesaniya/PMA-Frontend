import 'package:pma/constants/enum.dart';

extension TextFieldHeightExtension on InputFieldHeight {
  double get verticalPadding {
    switch (this) {
      case InputFieldHeight.small:
        return 12;
      case InputFieldHeight.large:
        return 16;
    }
  }
}

extension MemberRoleExtension on MemberRole {
  String get title {
    switch (this) {
      case MemberRole.owner:
        return 'Owner';
      case MemberRole.admin:
        return 'Admin';
      case MemberRole.member:
        return 'Member';
      case MemberRole.guest:
        return 'Guest';
    }
  }
}
