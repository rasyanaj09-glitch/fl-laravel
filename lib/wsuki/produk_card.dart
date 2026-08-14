import 'package:flutter/material.dart';
import 'package:ner_12_s1_p1/produk/produk.dart';
import 'package:ner_12_s1_p1/service/api_se.dart'; // Digunakan untuk memanggil ApiService.baseUrl

class ProdukCard extends StatelessWidget {
  final Produk produk;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDetail;

  const ProdukCard({
    super.key,
    required this.produk,
    required this.onEdit,
    required this.onDelete,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiService.getImageUrl(produk.gambar);

    return InkWell(
      onTap: onDetail,
      child: Card(
        margin: const EdgeInsets.all(10),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === SUSUNAN ROW: GAMBAR DI KIRI, INFORMASI DI KANAN ===
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. KOTAK TAMPILAN GAMBAR PRODUK
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey.shade200,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/not.jpg',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.contain,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/images/not.jpg',
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                  const SizedBox(width: 15), // Jarak horizontal antara kotak gambar dan teks info

                  // 2. KELOMPOK TEKS INFO UTAMA (Nama, Harga, Stok)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produk.nama,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold, // Diubah ke bold agar nama produk terlihat kontras
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Harga: Rp ${produk.harga}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green, // Warna hijau khusus untuk membedakan teks harga
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Stok: ${produk.stok}",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. DESKRIPSI PRODUK (Diletakkan di bawah agar bisa memanjang dengan rapi)
              Text(
                produk.desk,
                maxLines: 2, // Membatasi teks deskripsi agar halaman home tidak terlalu penuh
                overflow: TextOverflow.ellipsis, // Memberi efek titik-titik (...) jika teks terlalu panjang
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 15),

              // 4. TOMBOL AKSI (Edit & Hapus)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      label: const Text("Edit Data", style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, color: Colors.red), // Perbaikan: Mengubah ikon menjadi tong sampah
                      label: const Text("Hapus Data", style: TextStyle(color: Colors.red)), // Perbaikan: Mengubah teks label menjadi merah
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
