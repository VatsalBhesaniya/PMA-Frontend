import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/project.dart';
import 'package:pma/project/project_repository.dart';

part 'project_state.dart';
part 'project_event.dart';
part 'project_bloc.freezed.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc({
    required ProjectRepository projectRepository,
  })  : _projectRepository = projectRepository,
        super(const ProjectState.initial()) {
    on<_FetchProject>(_onFetchProject);
  }

  final ProjectRepository _projectRepository;

  FutureOr<void> _onFetchProject(
      _FetchProject event, Emitter<ProjectState> emit) async {
    emit(const _LoadInProgress());
    final Project? result =
        await _projectRepository.fetchProject(projectId: event.projectId);
    if (result == null) {
      emit(const _FetchProjectFailure());
    } else {
      emit(_FetchProjectSuccess(project: result));
    }
  }
}
