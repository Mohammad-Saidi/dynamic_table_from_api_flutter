import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_generation_flutter_project/ui/table_generation/view_models/table_generation_viewmodel.dart';
import 'package:table_generation_flutter_project/ui/table_generation/widgets/dynamic_table_screen.dart';

import 'data/repositories/table_generation/table_repository.dart';

void main() {
  final repository = TableRepository();
  runApp(
    ChangeNotifierProvider(
      create: (_) => TableViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Builder(
          builder: (context) {
            final viewModel =
                Provider.of<TableViewModel>(context, listen: false);
            repository.fetchTableHtml().then((htmlResponse) {
              viewModel.parseApiResponse(htmlResponse);
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error fetching data:')),
              );
            });
            return DynamicTableScreen(repository: repository);
          },
        ),
      ),
    ),
  );
}
