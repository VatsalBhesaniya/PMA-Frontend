part of 'pma_app_bloc.dart';

@immutable
abstract class PmaAppEvent extends Equatable {}

class AppStarted extends PmaAppEvent {
  @override
  List<Object?> get props => <Object>[];
}
