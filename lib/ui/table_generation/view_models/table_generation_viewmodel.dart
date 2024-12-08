import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/cupertino.dart';

import '../../../domain/models/table_generation/table_generation_cell_model.dart';

class TableViewModel extends ChangeNotifier {
  List<List<TableCellModel>> tableData = [];
  Map<String, String> errorMessages = {};
  int? latestSum;



  void parseApiResponse(String htmlResponse) {
    tableData.clear();
    final rows = RegExp(r"<tr>(.*?)</tr>").allMatches(htmlResponse);

    for (final row in rows) {
      final cells = RegExp(r"<td>(.*?)</td>").allMatches(row.group(1) ?? '');
      final rowData = cells.map((cell) {
        final cellContent = cell.group(1) ?? '';
        final isEditable = cellContent.toLowerCase() == 'edittext';
        return TableCellModel(
          value: isEditable ? '' : cellContent,
          isEditable: isEditable,
        );
      }).toList();
      tableData.add(rowData);
    }
    calculateSum();
    notifyListeners();
  }

  bool validateNumber(String value) {
    if (value.isEmpty) return false;
    final number = int.tryParse(value);
    return number != null && number >= 100 && number <= 999;
  }

  bool isDuplicate(String value, int excludeRow, int excludeCol) {
    final allValues = tableData.asMap().entries.expand((rowEntry) {
      final rowIndex = rowEntry.key;
      return rowEntry.value.asMap().entries.where((cellEntry) {
        final colIndex = cellEntry.key;
        return !(rowIndex == excludeRow && colIndex == excludeCol);
      }).map((cellEntry) => cellEntry.value.value);
    });

    return allValues.where((val) => val == value).isNotEmpty;
  }

  void updateCell(int rowIndex, int colIndex, String value) {
    final cellKey = "$rowIndex-$colIndex";

    if (value.isEmpty) {
      // Clear the validation error if the cell is empty
      errorMessages.remove(cellKey);
      tableData[rowIndex][colIndex] =
          TableCellModel(value: '', isEditable: true);
    } else if (!validateNumber(value)) {
      errorMessages[cellKey] = 'Value must be between 100 and 999';
    } else if (isDuplicate(value, rowIndex, colIndex)) {
      errorMessages[cellKey] = 'Duplicate numbers are not allowed';
    } else {
      errorMessages.remove(cellKey);
      tableData[rowIndex][colIndex] =
          TableCellModel(value: value, isEditable: true);
    }

    notifyListeners();
  }

  bool hasValidationErrors() {
    return errorMessages.isNotEmpty;
  }

  int calculateSum() {
    final sum = tableData
        .expand((row) => row)
        .where((cell) => cell.value.isNotEmpty)
        .map((cell) => int.tryParse(cell.value) ?? 0)
        .fold(0, (sum, value) => sum + value);
    latestSum = sum;
    notifyListeners();
    return sum;
  }
}
