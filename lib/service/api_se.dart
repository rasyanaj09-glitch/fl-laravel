import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ner_12_s1_p1/produk/produk.dart';

class ApiService {
  static String baseUrl = "http://localhost:8000/";
  static String baseStorageUrl = "http://localhost:8000/";

  static String getImageUrl(String? gambar) {
    if (gambar == null || gambar.trim().isEmpty) {
      return "";
    }
    final path = gambar.trim().replaceAll('\\', '/').replaceAll('storage/', '').replaceAll('public/', '');
    return "${baseStorageUrl}storage/$path";
  }

  Future<List<Produk>> getProduk() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('api_token');
 
      final response = await http.get(
        Uri.parse("${baseUrl}produk"), 
        headers: {
          'Authorization': 'Bearer ${token ?? ""}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List jsonData = jsonDecode(response.body);
        return jsonData.map((e) => Produk.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw Exception("Sesi login berakhir (401). Silakan login ulang.");
      } else {
        throw Exception("Gagal memuat produk. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal terhubung ke server: $e");
    }
  }

  Future<bool> storeProduk(Produk produk, File? image) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('api_token');

      var request = http.MultipartRequest('POST', Uri.parse("${baseUrl}produk"));

      request.headers.addAll({'Authorization': 'Bearer ${token ?? ""}', 'Accept': 'application/json'});

      request.fields['nama'] = produk.nama;
      request.fields['harga'] = produk.harga.toString();
      request.fields['stok'] = produk.stok.toString();
      request.fields['desk'] = produk.desk;

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('gambar', image.path),
        );
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProduk(Produk produk, File? image) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('api_token');

      // 1. Ubah MultipartRequest menjadi POST agar bisa mengirimkan file gambar
      var request = http.MultipartRequest('POST', Uri.parse("${baseUrl}produk/${produk.id}"));

      request.headers.addAll({'Authorization': 'Bearer ${token ?? ""}', 'Accept': 'application/json'});

      request.fields['nama'] = produk.nama;
      request.fields['harga'] = produk.harga.toString();
      request.fields['stok'] = produk.stok.toString();
      request.fields['desk'] = produk.desk;
      
      // 2. Tambahkan spoofing _method = PUT agar Laravel mengenalinya sebagai route PUT
      request.fields['_method'] = 'PUT';

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('gambar', image.path),
        );
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduk(int id) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('api_token');

      final response = await http.delete(
        Uri.parse("${baseUrl}produk/$id"),
        headers: {'Authorization': 'Bearer ${token ?? ""}', 'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('api_token');

      http.post(
        Uri.parse("${baseUrl}logout"),
        headers: {'Authorization': 'Bearer ${token ?? ""}', 'Accept': 'application/json'},
      );

      await prefs.remove('api_token');
      return true;
    } catch (e) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('api_token');
      return true;
    }
  }
    Future<List<Produk>> searchProduk(String keyword) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('api_token');

      // Mengirim kata kunci lewat query parameter (?keyword=...)
      final response = await http.get(
        Uri.parse("${baseUrl}produk/search?keyword=$keyword"), 
        headers: {
          'Authorization': 'Bearer ${token ?? ""}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List jsonData = jsonDecode(response.body);
        return jsonData.map((e) => Produk.fromJson(e)).toList();
      } else {
        throw Exception("Gagal mencari produk");
      }
    } catch (e) {
      throw Exception("Gagal terhubung ke server: $e");
    }
  }

}
