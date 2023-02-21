import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/create_project.dart';
import 'package:pma/models/project.dart';
import 'package:pma/module/home/projects_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'home_bloc.freezed.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required ProjectsRepository projectsRepository,
  })  : _projectsRepository = projectsRepository,
        super(const HomeState.initial()) {
    on<_FetchProjects>(_onFetchProjects);
    on<_CreateProject>(_onCreateProject);
  }

  final ProjectsRepository _projectsRepository;

  FutureOr<void> _onFetchProjects(
      _FetchProjects event, Emitter<HomeState> emit) async {
    emit(const _LoadInProgress());
    final ApiResult<List<Project>?> apiResult =
        await _projectsRepository.fetchProjects();
    apiResult.when(
      success: (List<Project>? data) {
        emit(
          _FetchProjectsSuccess(
            projects: data ?? <Project>[],
          ),
        );
      },
      failure: (NetworkExceptions error) {
        emit(const _FetchProjectsFailure());
      },
    );
  }

  FutureOr<void> _onCreateProject(
      _CreateProject event, Emitter<HomeState> emit) async {
    final ApiResult<bool> apiResult = await _projectsRepository.createProject(
      projectJson: event.project.toJson(),
    );
    apiResult.when(
      success: (bool isCreated) {
        if (isCreated) {
          emit(const _CreateProjectSuccess());
        } else {
          emit(
            const _CreateProjectFailure(
              error: NetworkExceptions.defaultError(),
            ),
          );
        }
      },
      failure: (NetworkExceptions error) {
        emit(_CreateProjectFailure(error: error));
      },
    );
  }
}
