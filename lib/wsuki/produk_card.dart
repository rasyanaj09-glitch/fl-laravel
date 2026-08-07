import 'package:flutter/material.dart';
import 'package:ner_12_s1_p1/produk/produk.dart';

class ProdukCard extends StatelessWidget {
  final Produk produk;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDetail;
  const ProdukCard({super.key,required this.produk,
  required this.onEdit,
  required this.onDelete,
  required this.onDetail});

  @override
  Widget build(BuildContext context) {
    return InkWell(
    onTap: onDetail,

    
   child:  Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      child: Padding(padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(produk.nama,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal
          ),
          ),
          const SizedBox(height: 10,),

          Text("harga:${produk.harga}",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal
          ),
          ),
          const SizedBox(height: 10,),
              Text("stok:${produk.stok}",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal
          ),
          ),
          const SizedBox(height: 10,),

             Text(produk.desk,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal
          ),
          ),
          const SizedBox(height: 10),
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
        icon: const Icon(Icons.edit, color: Color.fromARGB(255, 255, 0, 0)),
        label: const Text("hapus Data", style: TextStyle(color: Colors.blue)), 
      ),
    ),
  ]
)



        ],
      ),
      ),),
    );
  }
}