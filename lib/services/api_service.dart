import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';

class ApiService {
  // Endpoint pencarian TheMealDB. Query s=a mengembalikan banyak resep.
  static const String _endpoint =
      'https://www.themealdb.com/api/json/v1/1/search.php';

  Future<List<RecipeModel>> fetchRecipes() async {
    try {
      final response = await http
          .get(Uri.parse('$_endpoint?s=a'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Gagal memuat resep (kode ${response.statusCode}).');
      }

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final meals = decoded['meals'];
      if (meals == null) return []; // API mengembalikan null jika kosong

      return (meals as List)
          .map((item) => RecipeModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw Exception('Koneksi terlalu lama (timeout). Coba lagi.');
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    } on http.ClientException {
      throw Exception('Tidak ada koneksi internet.');
    } on FormatException {
      throw Exception('Format data dari server tidak valid.');
    }
  }
}
