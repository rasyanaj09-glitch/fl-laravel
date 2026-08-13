import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ner_12_s1_p1/produk/produk.dart';
import 'package:ner_12_s1_p1/service/api_se.dart';
import 'dart:io';

class Add extends StatefulWidget {
  const Add({super.key});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final _formKey = GlobalKey<FormState>(); 
  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  final stokController = TextEditingController();
  final deskController = TextEditingController();
  final ApiService api = ApiService();
  bool loading = false;
  File? image;
  final picker = ImagePicker();

  Future<void> pilihgmbr() async {
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  Future<void> simpanp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      loading = true;
    });

    Produk produk = Produk(
      nama: namaController.text,
      harga: int.parse(hargaController.text), 
      stok: int.parse(stokController.text),
      desk: deskController.text,
    );

    bool berhasil = await api.storeProduk(produk,image);
    
    setState(() {
      loading = false;
    });

    if (berhasil) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil menambahkan produk")),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menambahkan produk")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Produk Baru"),
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
                  child: image == null
                      ? Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.add_a_photo, 
                            size: 40,
                            color: Colors.blue,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            image!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 15),
              
           
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Nama produk wajib diisi";
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Harga produk wajib diisi";
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Stok produk wajib diisi";
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Deskripsi produk wajib diisi";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : simpanp,
                        icon: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(loading ? "Menyimpan.." : "Simpan"),
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
