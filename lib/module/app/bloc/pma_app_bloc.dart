import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'pma_app_event.dart';
part 'pma_app_state.dart';

class PmaAppBloc extends Bloc<PmaAppEvent, PmaAppState> {
  PmaAppBloc() : super(PmaAppInitial()) {
    on<AppStarted>(_onAppStarted);
  }

  FutureOr<void> _onAppStarted(AppStarted event, Emitter<PmaAppState> emit) {}
}
