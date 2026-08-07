import 'package:flutter/material.dart';
import 'package:ner_12_s1_p1/produk/produk.dart';
import 'package:ner_12_s1_p1/screens/edit.dart';

class Detail extends StatefulWidget {
  final Produk produk;
  const Detail({super.key, required this.produk});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  // Variabel lokal untuk menampung data produk terupdate
  late Produk _currentProduk;
  // Sinyal untuk memberi tahu halaman home (Sukib) agar ikut refresh saat kita kembali
  bool _isEdited = false;

  @override
  void initState() {
    super.initState();
    // Ambil data kiriman awal dari halaman utama
    _currentProduk = widget.produk;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("detail"),
        centerTitle: true,
        // KUNCI 1: Menangkap tombol back kiri atas bawaan AppBar
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
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Icon(
                    Icons.monitor,
                    size: 120,
                    color: Colors.black,
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
                  // Menunggu objek data produk baru dari halaman editSuki
                  final hasil = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => editSuki(produk: _currentProduk),
                    ),
                  );

                  // KUNCI 2: Jika hasil kembalian dari editSuki berupa objek Produk baru
                  if (hasil is Produk) {
                    setState(() {
                      _currentProduk = hasil; // Mengganti data lama di layar detail seketika
                      _isEdited = true;       // Menandai true agar Home tahu data berubah
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
                  // KUNCI 3: Mengirim status edit saat menekan tombol balik di bawah
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
