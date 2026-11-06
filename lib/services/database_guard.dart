import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<T> guardDatabase<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on PostgrestException catch (e) {
    throw Exception('Kesalahan database: ${e.message}');
  } on SocketException {
    throw Exception('Tidak ada koneksi internet.');
  }
}