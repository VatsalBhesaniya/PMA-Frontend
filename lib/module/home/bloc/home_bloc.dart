import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/project.dart';
import 'package:pma/module/home/projects_repository.dart';

part 'home_bloc.freezed.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required ProjectsRepository projectsRepository,
  })  : _projectsRepository = projectsRepository,
        super(const HomeState.initial()) {
    on<_FetchProjects>(_onFetchProjects);
  }

  final ProjectsRepository _projectsRepository;

  FutureOr<void> _onFetchProjects(
      _FetchProjects event, Emitter<HomeState> emit) async {
    emit(const _LoadInProgress());
    final List<Project>? result = await _projectsRepository.fetchProjects();
    if (result == null) {
      emit(const _FetchProjectsFailure());
    } else {
      emit(_FetchProjectsSuccess(projects: result));
    }
  }
}
