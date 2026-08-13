import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ner_12_s1_p1/produk/produk.dart';

class ApiService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000/";
    }
    return "http://localhost:8000/";
  }

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

    return "${baseUrl}storage/$pathWithoutPublic";
  }

  Future<List<Produk>> getProduk() async {
    final response = await http.get(
      Uri.parse("${baseUrl}produk"), 
    );
    if (response.statusCode == 200) {
      List jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Produk.fromJson(e)).toList();
    } else {
      throw Exception("Data gagal diambil. Kode Status: ${response.statusCode}");
    }
  }


  Future<bool> storeProduk(Produk produk, File? image) async {
    try {
    
      var request = http.MultipartRequest('POST', Uri.parse("${baseUrl}produk"));
      
    
      request.fields['nama'] = produk.nama;
      request.fields['harga'] = produk.harga.toString();
      request.fields['stok'] = produk.stok.toString();
      request.fields['desk'] = produk.desk;

      
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'gambar', 
            image.path,
          ),
        );
      }

     
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 201;
      
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProduk(Produk produk, File? image) async {
    try {
      final fields = {
        'nama': produk.nama,
        'harga': produk.harga.toString(),
        'stok': produk.stok.toString(),
        'desk': produk.desk,
      };

      Future<http.Response> sendWithMethod(String method) async {
        final request = http.MultipartRequest(method, Uri.parse("${baseUrl}produk/${produk.id}"));

        request.fields.addAll(fields);

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

        final streamedResponse = await request.send();
        return http.Response.fromStream(streamedResponse);
      }

      final postResponse = await sendWithMethod('POST');
      if (postResponse.statusCode == 200 || postResponse.statusCode == 201 || postResponse.statusCode == 204) {
        return true;
      }

      final putResponse = await sendWithMethod('PUT');
      return putResponse.statusCode == 200 ||
          putResponse.statusCode == 201 ||
          putResponse.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduk(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("${baseUrl}produk/$id"),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
