import 'package:flutter/material.dart';
import 'package:ner_12_s1_p1/produk/produk.dart';
import 'package:ner_12_s1_p1/screens/add.dart';
import 'package:ner_12_s1_p1/screens/detail.dart';
import 'package:ner_12_s1_p1/screens/edit.dart';
import 'package:ner_12_s1_p1/screens/login_page.dart';
import 'package:ner_12_s1_p1/service/api_se.dart';
import 'package:ner_12_s1_p1/wsuki/produk_card.dart';
import 'package:ner_12_s1_p1/wsuki/dashboard.dart';

class Sukib extends StatefulWidget {
  const Sukib({super.key});

  @override
  State<Sukib> createState() => _SukibState();
}

class _SukibState extends State<Sukib> {
  final ApiService api = ApiService();
  final searchController = TextEditingController();
  late Future<List<Produk>> _produkFuture;

  @override
  void initState() {
    super.initState();
    _produkFuture = api.getProduk();
  }

  Future<void> _refreshData() async {
    setState(() {
      _produkFuture = api.getProduk();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Produk"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              bool berhasil = await api.logout();
              if (berhasil == true) {
                if (!mounted) return;

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Berhasil keluar aplikasi!")),
                );
                Navigator.pushReplacement(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } else {
                if (!mounted) return;

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Gagal logout, periksa server!")),
                );
              }
            },
          ),
        ],
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
            if (snapshot.hasData) {
              List<Produk> listProduk = snapshot.data!;

              int hitungStok = 0;
              int totalNilaiAset = 0;

              for (int i = 0; i < listProduk.length; i++) {
                hitungStok = hitungStok + listProduk[i].stok;

                totalNilaiAset =
                    totalNilaiAset + (listProduk[i].harga * listProduk[i].stok);
              }

              return Column(
                children: [
                  const Padding(
                    padding:
                        EdgeInsets.only(top: 16.0, left: 12.0, right: 12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Halo Admin, Selamat Datang di App!",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Sistem Manajemen Stok Suki",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Cari nama produk...",
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            _refreshData();
                          },
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          setState(() {
                            _produkFuture = api.searchProduk(value.trim());
                          });
                        } else {
                          _refreshData();
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Dashboard(
                            title: "Total Produk",
                            value: listProduk.length.toString(),
                            iconData: Icons.shopping_bag,
                            color: Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: Dashboard(
                            title: "Total Stok",
                            value: hitungStok.toString(),
                            iconData: Icons.inventory,
                            color: Colors.green,
                          ),
                        ),
                        Expanded(
                          child: Dashboard(
                            title: "Total Aset",
                            value: "Rp ${totalNilaiAset.toString()}",
                            iconData: Icons.monetization_on,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: listProduk.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                              const Center(
                                child: Text("Produk tidak ditemukan"),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: listProduk.length,
                            itemBuilder: (context, index) {
                              final produk = listProduk[index];
                              return ProdukCard(
                          produk: produk,
                          onDetail: () async {
                            final hasil = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Detail(produk: produk),
                              ),
                            );
                            if (hasil == true) {
                              _refreshData();
                            }
                          },
                          onEdit: () async {
                            final hasil = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => editSuki(produk: produk),
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
                                  content: Text(
                                    "Apakah Anda yakin ingin menghapus produk '${produk.nama}'?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Batal"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        "Ya, Hapus",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (konfirmasi == true && produk.id != null) {
                              bool berhasil =
                                  await api.deleteProduk(produk.id!);
                              if (mounted) {
                                if (berhasil) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Produk berhasil dihapus!"),
                                    ),
                                  );
                                  _refreshData();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Gagal menghapus produk"),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                              );
                            },
                          ),
                  ),
                ],
              );
            }
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
