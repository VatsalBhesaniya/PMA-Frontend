import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pma/models/create_document.dart';
import 'package:pma/module/create_document/create_document_repository.dart';
import 'package:pma/utils/api_result.dart';
import 'package:pma/utils/network_exceptions.dart';

part 'create_document_state.dart';
part 'create_document_event.dart';
part 'create_document_bloc.freezed.dart';

class CreateDocumentBloc
    extends Bloc<CreateDocumentEvent, CreateDocumentState> {
  CreateDocumentBloc({
    required CreateDocumentRepository createDocumentRepository,
  })  : _createDocumentRepository = createDocumentRepository,
        super(const CreateDocumentState.initial()) {
    on<_CreateDocument>(_onCreateDocument);
  }

  final CreateDocumentRepository _createDocumentRepository;

  FutureOr<void> _onCreateDocument(
      _CreateDocument event, Emitter<CreateDocumentState> emit) async {
    final ApiResult<int?> apiResult =
        await _createDocumentRepository.createDocument(
      documentData: event.document.toJson(),
    );
    apiResult.when(
      success: (int? documentId) {
        if (documentId == null) {
          emit(const CreateDocumentState.createDocumentFailure(
            error: NetworkExceptions.defaultError(),
          ));
        } else {
          emit(
            CreateDocumentState.createDocumentSuccess(documentId: documentId),
          );
        }
      },
      failure: (NetworkExceptions error) {
        emit(
          const CreateDocumentState.createDocumentFailure(
            error: NetworkExceptions.defaultError(),
          ),
        );
      },
    );
  }
}
