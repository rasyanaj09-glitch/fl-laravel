import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ner_12_s1_p1/produk/produk.dart';

class ApiService {
  static const String baseUrl = "http://localhost:8000/";

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

  Future<bool> storeProduk(Produk produk) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}produk"),
        body: {
          "nama": produk.nama,
          "harga": produk.harga.toString(),
          "stok": produk.stok.toString(),
          "desk": produk.desk,
          "gambar": "",
        },
      );

     
      return response.statusCode == 201;
      
    } catch (e) {
    
      return false;
    }
  }
Future<bool> updateProduk(Produk produk) async {
  try {
    final response = await http.post(
      Uri.parse("${baseUrl}produk/${produk.id}"), 
      body: {
        "_method": "PUT", 
        "nama": produk.nama,
        "harga": produk.harga.toString(),
        "stok": produk.stok.toString(),
        "desk": produk.desk,
        "gambar": "",
      },
    );
    
   
    return response.statusCode == 200; 
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
