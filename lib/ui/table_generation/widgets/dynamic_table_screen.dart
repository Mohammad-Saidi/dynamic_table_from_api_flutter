
import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/table_generation/table_repository.dart';
import '../view_models/table_generation_viewmodel.dart';

class DynamicTableScreen extends StatefulWidget {
  final TableRepository repository;

  const DynamicTableScreen({super.key, required this.repository});

  @override
  State<DynamicTableScreen> createState() => _DynamicTableScreenState();
}

class _DynamicTableScreenState extends State<DynamicTableScreen> {

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TableViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Dynamic Table')),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          children: [
            if (viewModel.hasValidationErrors())
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: viewModel.errorMessages.entries.map((entry) {
                    return Text(
                      'Cell [${entry.key}]: ${entry.value}',
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                ),
              ),
            if (viewModel.latestSum != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Sum: ${viewModel.latestSum}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            viewModel.tableData.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children:
                          viewModel.tableData.asMap().entries.map((rowEntry) {
                        final rowIndex = rowEntry.key;
                        final row = rowEntry.value;
                        return Row(
                          children: row.asMap().entries.map((cellEntry) {
                            final colIndex = cellEntry.key;
                            final cell = cellEntry.value;
                            final cellKey = "$rowIndex-$colIndex";
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: cell.isEditable
                                    ? TextFormField(
                                        initialValue: cell.value,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          errorText:
                                              viewModel.errorMessages[cellKey],
                                        ),
                                        onChanged: (value) {
                                          viewModel.updateCell(
                                              rowIndex, colIndex, value);
                                        },
                                      )
                                    : Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: Text(cell.value),
                                      ),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: Colors.grey,
              ),
              onPressed: () {
                if (viewModel.hasValidationErrors()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Validation error exists. Please fix all errors.')),
                  );
                } else {
                  final sum = viewModel.calculateSum();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sum: $sum')),
                  );
                }
              },
              child: const Text(
                'Sum',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
