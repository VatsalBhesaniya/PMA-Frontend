import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pma/constants/route_constants.dart';
import 'package:pma/models/document.dart';
import 'package:pma/module/Document/bloc/documents_bloc.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentsBloc, DocumentsState>(
      builder: (BuildContext context, DocumentsState state) {
        return state.when(
          initial: () {
            context.read<DocumentsBloc>().add(
                  const DocumentsEvent.fetchDocuments(),
                );
            return const CircularProgressIndicator();
          },
          loadInProgress: () {
            return const CircularProgressIndicator();
          },
          fetchDocumentsSuccess: (List<Document> documents) {
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                final Document document = documents[index];
                return ListTile(
                  onTap: () {
                    context.goNamed(
                      RouteConstants.document,
                      params: <String, String>{
                        'id': document.id.toString(),
                      },
                    );
                  },
                  title: Text(document.title),
                );
              },
            );
          },
          fetchDocumentsFailure: () {
            return const Center(
              child: Text('Something went wrong.'),
            );
          },
        );
      },
    );
  }
}
