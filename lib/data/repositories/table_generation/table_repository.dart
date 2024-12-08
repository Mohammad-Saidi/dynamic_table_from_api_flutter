import 'package:http/http.dart' as http;

class TableRepository {
  Future<String> fetchTableHtml() async {
    final uri = Uri.parse(
        "https://budget-app-backend-8lel.onrender.com/table/interview");
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load table data');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }
}
