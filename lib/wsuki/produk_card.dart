import 'package:flutter/material.dart';
import 'package:ner_12_s1_p1/produk/produk.dart';
import 'package:ner_12_s1_p1/service/api_se.dart'; 

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
  String formatRupiah(num nominal) {
    return "Rp ${nominal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

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
           
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
       
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
                  const SizedBox(width: 15), 

                 
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produk.nama,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold, 
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Harga:${(formatRupiah(produk.harga))}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green, 
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

       
              Text(
                produk.desk,
                maxLines: 2, 
                overflow: TextOverflow.ellipsis, 
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 15),

             
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
                      icon: const Icon(Icons.delete, color: Colors.red), 
                      label: const Text("Hapus Data", style: TextStyle(color: Colors.red)), 
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
