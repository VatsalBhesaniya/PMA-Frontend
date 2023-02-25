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

extension MemberStatusExtension on MemberStatus {
  String get title {
    switch (this) {
      case MemberStatus.accepted:
        return 'Accepted';
      case MemberStatus.invited:
        return 'Invited';
    }
  }
}

extension TaskStatusExtension on TaskStatus {
  String get title {
    switch (this) {
      case TaskStatus.todo:
        return 'Todo';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.qa:
        return 'QA';
    }
  }
}
