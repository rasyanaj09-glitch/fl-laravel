import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:io'; 
import 'package:ner_12_s1_p1/produk/produk.dart';
import 'package:ner_12_s1_p1/service/api_se.dart';

class editSuki extends StatefulWidget {
  const editSuki({super.key, required this.produk});
  final Produk produk;

  @override
  State<editSuki> createState() => _editSukiState();
}

class _editSukiState extends State<editSuki> {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  final stokController = TextEditingController();
  final deskController = TextEditingController();
  final ApiService api = ApiService();
  bool loading = false;


  File? image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    namaController.text = widget.produk.nama;
    hargaController.text = widget.produk.harga.toString();
    stokController.text = widget.produk.stok.toString();
    deskController.text = widget.produk.desk;
  }

  @override
  void dispose() {
    namaController.dispose();
    hargaController.dispose();
    stokController.dispose();
    deskController.dispose();
    super.dispose();
  }


  Future<void> pilihgmbr() async {
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  Future<void> updateData() async {
    setState(() {
      loading = true;
    });

    Produk produkBaru = Produk(
      id: widget.produk.id,
      nama: namaController.text,
      harga: int.parse(hargaController.text),
      stok: int.parse(stokController.text),
      desk: deskController.text,
    );

 
    bool berhasil = await api.updateProduk(produkBaru, image);

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil edit produk")),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal edit produk")),
      );
    }
  }

  Future<void> konfirmasiUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    bool? hasil = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Konfirmasi Perubahan'),
          content: const Text('Apakah Anda yakin ingin menyimpan perubahan data produk ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Ya"),
            )
          ],
        );
      },
    );
    if (hasil == true) {
      updateData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Data"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
         
              Center(
                child: GestureDetector(
                  onTap: pilihgmbr,
                  child: image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            image!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : (widget.produk.gambar != null && widget.produk.gambar!.trim().isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                ApiService.getImageUrl(widget.produk.gambar),
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  'assets/images/not.jpg',
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          : Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Image.asset(
                                'assets/images/not.jpg',
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 15),
              // === AKHIR TAMPILAN GAMBAR ===

              Expanded(
                child: ListView(
                  children: [
                    TextFormField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: "Nama produk",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.shop),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? "Nama produk wajib diisi" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: hargaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Harga produk",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.money),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? "Harga produk wajib diisi" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: stokController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Stok produk",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? "Stok produk wajib diisi" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: deskController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Deskripsi produk",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? "Deskripsi produk wajib diisi" : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : konfirmasiUpdate,
                        icon: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save),
                        label: Text(loading ? "Menyimpan.." : "Update"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
