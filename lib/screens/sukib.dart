// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ner_12_s1_p1/produk/produk.dart';
import 'package:ner_12_s1_p1/screens/add.dart';
import 'package:ner_12_s1_p1/screens/detail.dart';
import 'package:ner_12_s1_p1/screens/edit.dart';
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

  String sortingSuki = "Harga";
  String sortingSuki2 = "A-Z";
  String sortingSuki3 = "Harga Terendah";
  String sortingSuki4 = "Stok";

  @override
  void initState() {
    super.initState();
    _produkFuture = loadProduk();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<Produk>> loadProduk() async {
    try {
      List<Produk> dataAwal;

      if (searchController.text.trim().isNotEmpty) {
        dataAwal = await api.searchProduk(searchController.text.trim());
      } else {
        dataAwal = await api.getProduk();
      }

      prosesData(dataAwal);

      return dataAwal;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data produk: $e")),
        );
      }
      return [];
    }
  }

  void prosesData(List<Produk> listData) {
    if (sortingSuki == "< 500rb") {
      listData.retainWhere((produk) => produk.harga < 500000);
    } else if (sortingSuki == "500rb - 1jt") {
      listData.retainWhere(
          (produk) => produk.harga >= 500000 && produk.harga <= 1000000);
    } else if (sortingSuki == "> 1jt") {
      listData.retainWhere((produk) => produk.harga > 1000000);
    }
    if (sortingSuki2 == "A-Z") {
      listData
          .sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
    } else if (sortingSuki2 == "Z-A") {
      listData
          .sort((a, b) => b.nama.toLowerCase().compareTo(a.nama.toLowerCase()));
    }

    if (sortingSuki3 == "Harga Terendah") {
      listData.sort((a, b) => a.harga.compareTo(b.harga));
    } else if (sortingSuki3 == "Harga Tertinggi") {
      listData.sort((a, b) => b.harga.compareTo(a.harga));
    }

    if (sortingSuki4 == "Stok Sedikit") {
      listData.sort((a, b) => a.stok.compareTo(b.stok));
    } else if (sortingSuki4 == "Stok Terbanyak") {
      listData.sort((a, b) => b.stok.compareTo(a.stok));
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _produkFuture = loadProduk();
    });
  }

  String formatRupiah(num nominal) {
    return "Rp ${nominal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
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

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Berhasil keluar aplikasi!")),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Sukib()),
                );
              } else {
                if (!mounted) return;

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
                  Expanded(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        // 1. HEADER PROFIL
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 16.0, left: 12.0, right: 12.0),
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
                                    "Halo Admin, Selamat Datang!",
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
                                  _produkFuture =
                                      api.searchProduk(value.trim());
                                });
                              } else {
                                _refreshData();
                              }
                            },
                          ),
                        ),

                        // 3. FILTER & SORTING (Dibuat Grid 2x2 agar Ringkas)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Column(
                            children: [
                              // Baris Filter 1: Rentang Harga & Sort Nama
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: sortingSuki,
                                      decoration: const InputDecoration(
                                        labelText: "Filter Harga",
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: "Harga",
                                            child: Text(
                                                "Semua")), 
                                        DropdownMenuItem(
                                            value: "< 500rb",
                                            child: Text("< 500rb")),
                                        DropdownMenuItem(
                                            value: "500rb - 1jt",
                                            child: Text("500rb - 1jt")),
                                        DropdownMenuItem(
                                            value: "> 1jt",
                                            child: Text("> 1jt")),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            sortingSuki = val;
                                            _refreshData();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: sortingSuki2,
                                      decoration: const InputDecoration(
                                        labelText: "Urut Nama",
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: "A-Z", child: Text("A - Z")),
                                        DropdownMenuItem(
                                            value: "Z-A", child: Text("Z - A")),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            sortingSuki2 = val;
                                            _refreshData();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Baris Filter 2: Sort Harga & Sort Stok
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: sortingSuki3,
                                      decoration: const InputDecoration(
                                        labelText: "Urut Harga",
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: "Harga Terendah",
                                            child: Text("Terendah")),
                                        DropdownMenuItem(
                                            value: "Harga Tertinggi",
                                            child: Text("Tertinggi")),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            sortingSuki3 = val;
                                            _refreshData();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: sortingSuki4,
                                      decoration: const InputDecoration(
                                        labelText: "Urut Stok",
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: "Stok",
                                            child: Text(
                                                "Biasa")), 
                                        DropdownMenuItem(
                                            value: "Stok Sedikit",
                                            child: Text("Sedikit")),
                                        DropdownMenuItem(
                                            value: "Stok Terbanyak",
                                            child: Text("Terbanyak")),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            sortingSuki4 = val;
                                            _refreshData();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 4. KARTU DASHBOARD
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
                                  value: formatRupiah(totalNilaiAset),
                                  iconData: Icons.monetization_on,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 5. DAFTAR PRODUK (LIST PRODUK)
                        if (listProduk.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child:
                                Center(child: Text("Produk tidak ditemukan")),
                          )
                        else
                          ListView.builder(
                            shrinkWrap:
                                true, // PENTING: Agar ListView di dalam ListView tidak bentrok
                            physics:
                                const NeverScrollableScrollPhysics(), // Scroll mengikuti ListView utama
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
                                              style: TextStyle(
                                                  color: Colors.white),
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Produk berhasil dihapus!"),
                                          ),
                                        );
                                        _refreshData();
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text("Gagal menghapus produk"),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              );
                            },
                          ),
                      ],
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
            loadProduk().then((_) {
              _refreshData();
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Gagal menambahkan produk"),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
