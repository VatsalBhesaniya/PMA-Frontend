import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/project.dart';
import 'package:pma/module/home/projects_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'invited_projects_bloc.freezed.dart';
part 'invited_projects_event.dart';
part 'invited_projects_state.dart';

class InvitedProjectsBloc
    extends Bloc<InvitedProjectsEvent, InvitedProjectsState> {
  InvitedProjectsBloc({
    required ProjectsRepository projectsRepository,
  })  : _projectsRepository = projectsRepository,
        super(const InvitedProjectsState.initial()) {
    on<_FetchInvitedProjects>(_onFetchProjects);
  }

  final ProjectsRepository _projectsRepository;

  FutureOr<void> _onFetchProjects(
      _FetchInvitedProjects event, Emitter<InvitedProjectsState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<List<Project>?> apiResult =
        await _projectsRepository.fetchInvitedProjects();
    apiResult.when(
      success: (List<Project>? data) {
        emit(
          _FetchInvitedProjectsSuccess(
            projects: data ?? <Project>[],
          ),
        );
      },
      failure: (NetworkExceptions error) {
        emit(const _FetchInvitedProjectsFailure());
      },
    );
  }
}
