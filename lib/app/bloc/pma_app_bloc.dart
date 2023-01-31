import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'pma_app_event.dart';
part 'pma_app_state.dart';

class PmaAppBloc extends Bloc<PmaAppEvent, PmaAppState> {
  PmaAppBloc() : super(PmaAppInitial()) {
    on<AppStarted>(_onAppStarted);
  }

  FutureOr<void> _onAppStarted(AppStarted event, Emitter<PmaAppState> emit) {
    // final String? token =
  }
}
