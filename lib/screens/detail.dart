import 'package:flutter/material.dart';
import 'package:ner_12_s1_p1/produk/produk.dart';
import 'package:ner_12_s1_p1/screens/edit.dart';
import 'package:ner_12_s1_p1/service/api_se.dart';

class Detail extends StatefulWidget {
  final Produk produk;
  const Detail({super.key, required this.produk});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
 
  late Produk _currentProduk;
  
  bool _isEdited = false;

  @override
  void initState() {
    super.initState();
 
    _currentProduk = widget.produk;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiService.getImageUrl(_currentProduk.gambar);

    return Scaffold(
      appBar: AppBar(
        title: const Text("detail"),
        centerTitle: true,
        
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _isEdited),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Hero(
              tag: _currentProduk.id!,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: 220,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 120,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 120,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 15),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentProduk.nama,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(Icons.attach_money),
                        const SizedBox(width: 10),
                        Text(
                          "rp.${_currentProduk.harga}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(Icons.gif_box),
                        const SizedBox(width: 10),
                        Text(
                          "stok : ${_currentProduk.stok}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const Divider(height: 35),
                    const Text(
                      "desk : ",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _currentProduk.desk,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("edit"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () async {
            
                  final hasil = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => editSuki(produk: _currentProduk),
                    ),
                  );

                  if (hasil is Produk) {
                    setState(() {
                      _currentProduk = hasil; 
                      _isEdited = true;       
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text("balik"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  
                  Navigator.pop(context, _isEdited);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
