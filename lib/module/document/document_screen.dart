import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pma/models/document.dart';
import 'package:pma/module/document/bloc/document_bloc.dart';
import 'package:pma/module/document/document_repository.dart';
import 'package:pma/utils/dio_client.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({
    required this.documentId,
    super.key,
  });

  final String documentId;

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<DocumentBloc>(
      create: (BuildContext context) => DocumentBloc(
        documentRepository: DocumentRepository(
          dioClient: context.read<DioClient>(),
        ),
      ),
      child: BlocBuilder<DocumentBloc, DocumentState>(
        builder: (BuildContext context, DocumentState state) {
          return state.when(
            initial: () {
              context.read<DocumentBloc>().add(
                    DocumentEvent.fetchDocument(
                      documentId: int.parse(widget.documentId),
                    ),
                  );
              return const CircularProgressIndicator();
            },
            loadInProgress: () {
              return const CircularProgressIndicator();
            },
            fetchDocumentSuccess: (Document document) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(document.title),
                ),
                body: SafeArea(
                  child: Column(
                    children: <Widget>[
                      const Text('Created At'),
                      Text(document.createdAt),
                    ],
                  ),
                ),
              );
            },
            fetchDocumentFailure: () {
              return const Center(
                child: Text('Something went wrong.'),
              );
            },
          );
        },
      ),
    );
  }
}
