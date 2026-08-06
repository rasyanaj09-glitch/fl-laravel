import 'package:flutter/material.dart';
import 'package:ner_12_s1_p1/produk/produk.dart';
import 'package:ner_12_s1_p1/screens/add.dart';
import 'package:ner_12_s1_p1/service/api_se.dart';
import 'package:ner_12_s1_p1/wsuki/produk_card.dart';
import 'package:ner_12_s1_p1/screens/edit.dart'; 

class Sukib extends StatefulWidget {
  const Sukib({super.key});

  @override
  State<Sukib> createState() => _SukibState();
}

class _SukibState extends State<Sukib> {
  final ApiService api = ApiService();
  late Future<List<Produk>> _produkFuture;

  @override
  void initState() {
    super.initState();
    _produkFuture = api.getProduk();
  }

  // Fungsi muat ulang data API
  Future<void> _refreshData() async {
    setState(() {
      _produkFuture = api.getProduk();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("data produk"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<Produk>>(
          future: _produkFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(child: Text(snapshot.error.toString())),
                ],
              );
            }
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              List<Produk> listProduk = snapshot.data!;
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: listProduk.length,
                itemBuilder: (context, index) {
                  return ProdukCard(
                    produk: listProduk[index],
                    onEdit: () async {
                      final hasil = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => editSuki(produk: listProduk[index]),
                        ),
                      );
                     
                      if (hasil == true) {
                        _refreshData(); 
                      }
                    },
                   onDelete: () async {
 
  bool? konfirmasi = await showDialog<bool>(
    context: context,
    barrierDismissible: false, 
    builder: (context) {
      return AlertDialog(
        title: const Text("Hapus Produk"),
        content: Text("Apakah Anda yakin ingin menghapus produk '${listProduk[index].nama}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Jika batal, kirim false
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red), // Warna merah untuk tanda hapus
            onPressed: () => Navigator.pop(context, true), // Jika yakin, kirim true
            child: const Text("Ya, Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );

 
  if (konfirmasi == true) {
    
    if (listProduk[index].id != null) {
      
      bool berhasil = await api.deleteProduk(listProduk[index].id!);

      if (mounted) {
        if (berhasil) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Produk berhasil dihapus!")),
          );
          _refreshData(); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal menghapus produk")),
          );
        }
      }
    }
  }
},

                  );
                },
              );
            }
            // Kondisi jika data kosong
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                const Center(
                  child: Text("Tidak ada data produk"),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bool? berhasilSimpan = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Add(),
            ),
          );
          if (berhasilSimpan == true) {
            _refreshData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
