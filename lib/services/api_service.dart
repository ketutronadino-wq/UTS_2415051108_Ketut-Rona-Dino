import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';

class ApiService {
  // Endpoint untuk mencari makanan berdasarkan nama (menggunakan 'a' agar semua huruf a muncul, atau 's' untuk search)
  final String baseUrl = 'https://www.themealdb.com/api/json/v1/1/search.php?s=';

  Future<List<RecipeModel>> fetchRecipes() async {
    try {
      // Kita ambil data dengan query 's=' (kosong) untuk mengambil beberapa data default, 
      // atau kita bisa pakai huruf 'a' agar datanya banyak.
      final response = await http.get(Uri.parse('${baseUrl}a'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['meals'] == null) {
          return []; // Return list kosong jika tidak ada data
        }

        List<dynamic> meals = data['meals'];
        return meals.map((json) => RecipeModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recipes (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}