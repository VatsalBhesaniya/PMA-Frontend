import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/project.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'create_project_state.dart';
part 'create_project_event.dart';
part 'create_project_bloc.freezed.dart';

class CreateProjectBloc extends Bloc<CreateProjectEvent, CreateProjectState> {
  CreateProjectBloc() : super(const CreateProjectState.initial()) {
    on<_CreateProject>(_onCreateProject);
  }

  FutureOr<void> _onCreateProject(
      _CreateProject event, Emitter<CreateProjectState> emit) {}
}
