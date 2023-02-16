import 'package:pma/constants/enum.dart';

extension TextFieldHeightExtendion on InputFieldHeight {
  double get verticalPadding {
    switch (this) {
      case InputFieldHeight.small:
        return 12;
      case InputFieldHeight.large:
        return 16;
    }
  }
}
