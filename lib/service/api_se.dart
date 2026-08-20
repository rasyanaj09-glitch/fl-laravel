import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ner_12_s1_p1/produk/produk.dart';

class ApiService {
  // Base URL dikonfigurasi TANPA '/api/' sesuai default kustom Laravel Anda
  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://localhost:8000/"; 
    }
  
    return "http://localhost:8000/";
  }

  static String get baseStorageUrl {
    if (Platform.isAndroid) {
      return "http://localhost:8000/";
    }
    return "http://localhost:8000/";
  }

  // Fungsi untuk mendapatkan URL lengkap gambar produk dari server
  static String getImageUrl(String? gambar) {
    if (gambar == null || gambar.trim().isEmpty) {
      return "";
    }

    final cleanPath = gambar.trim().replaceAll('\\', '/');
    final normalized = cleanPath.startsWith('/')
        ? cleanPath.substring(1)
        : cleanPath;

    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return normalized;
    }

    final pathWithoutStorage = normalized.startsWith('storage/')
        ? normalized.substring('storage/'.length)
        : normalized;

    final pathWithoutPublic = pathWithoutStorage.startsWith('public/')
        ? pathWithoutStorage.substring('public/'.length)
        : pathWithoutStorage;

    return "${baseStorageUrl}storage/$pathWithoutPublic";
  }

  // 🔒 FUNGSI OTOMATIS GENERATE HEADER TOKEN SANCTUM
  Future<Map<String, String>> _getHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');
    
    // Log pemantau untuk debugging di terminal VS Code
    debugPrint("=== INFO TOKEN SANCTUM ===");
    debugPrint("Token yang dikirim: Bearer $token");

    return {
      'Authorization': 'Bearer ${token?.trim() ?? ""}',
      'Accept': 'application/json', // Memaksa Laravel membalas dengan format JSON jika token salah
    };
  }

  // ==========================================
  // 1. READ: Menampilkan Semua Data Produk
  // ==========================================
  Future<List<Produk>> getProduk() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse("${baseUrl}produk"), 
        headers: headers,
      );

      if (response.statusCode == 200) {
        List jsonData = jsonDecode(response.body);
        return jsonData.map((e) => Produk.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw Exception("Sesi login berakhir (401). Silakan login ulang dari aplikasi.");
      } else {
        throw Exception("Gagal memuat produk. Kode Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error Read: ${e.toString()}");
    }
  }

  // ==========================================
  // 2. CREATE: Menambah Produk Baru (+ Upload Gambar)
  // ==========================================
  Future<bool> storeProduk(Produk produk, File? image) async {
    try {
      final headers = await _getHeaders();
      var request = http.MultipartRequest('POST', Uri.parse("${baseUrl}produk"));

      // Sisipkan token keamanan ke Multipart Request
      request.headers.addAll(headers);

      // Masukkan field teks data produk
      request.fields['nama'] = produk.nama;
      request.fields['harga'] = produk.harga.toString();
      request.fields['stok'] = produk.stok.toString();
      request.fields['desk'] = produk.desk;

      // Jika user mengunggah file gambar produk
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'gambar',
            image.path,
          ),
        );
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      // Status 201 artinya Created (Data berhasil ditambahkan di Laravel)
      return response.statusCode == 201;
    } catch (e) {
      debugPrint("Error Create: ${e.toString()}");
      return false;
    }
  }

  // ==========================================
  // 3. UPDATE: Mengubah Data Produk (+ Ganti Gambar)
  // ==========================================
  Future<bool> updateProduk(Produk produk, File? image) async {
    try {
      final headers = await _getHeaders();
      final fields = {
        'nama': produk.nama,
        'harga': produk.harga.toString(),
        'stok': produk.stok.toString(),
        'desk': produk.desk,
      };

      // Fungsi internal untuk memicu trik Laravel PUT via POST form-data
      Future<http.Response> sendWithMethod(String method) async {
        final request = http.MultipartRequest(method, Uri.parse("${baseUrl}produk/${produk.id}"));

        request.headers.addAll(headers);
        request.fields.addAll(fields);

        // Jika lewat method POST, sisipkan spoofing PUT agar Laravel mengenali proses edit
        if (method == 'POST') {
          request.fields['_method'] = 'PUT';
        }

        if (image != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'gambar',
              image.path,
            ),
          );
        }

        final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
        return http.Response.fromStream(streamedResponse);
      }

      // Coba kirim via metode POST dengan spoofing _method = PUT (Sangat direkomendasikan di Laravel)
      final postResponse = await sendWithMethod('POST');
      if (postResponse.statusCode == 200 || postResponse.statusCode == 201 || postResponse.statusCode == 204) {
        return true;
      }

      // Jalur cadangan jika Laravel Anda murni menerima request PUT langsung
      final putResponse = await sendWithMethod('PUT');
      return putResponse.statusCode == 200 ||
          putResponse.statusCode == 201 ||
          putResponse.statusCode == 204;
    } catch (e) {
      debugPrint("Error Update: ${e.toString()}");
      return false;
    }
  }

  // ==========================================
  // 4. DELETE: Menghapus Data Produk
  // ==========================================
  Future<bool> deleteProduk(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse("${baseUrl}produk/$id"),
        headers: headers, 
      );
      
      // Status 200 (OK) atau 204 (No Content) menandakan data sukses dihapus
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("Error Delete: ${e.toString()}");
      return false;
    }
  }
}
