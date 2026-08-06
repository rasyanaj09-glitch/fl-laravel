import 'package:flutter/material.dart';
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

  
  bool berhasil = await api.updateProduk(produkBaru);

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
      ),
    );
  }
}
