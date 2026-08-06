class Produk {
  int? id; 
  String nama;
  int harga;
  int stok;
  String desk;
  String? gambar;


  Produk({
    this.id, 
    required this.nama, 
    required this.harga,
    required this.stok,
    required this.desk,
    this.gambar,
  });


  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'],
      nama: json['nama'],
      harga: json['harga'],
      stok: json['stok'],
      desk: json['desk'],
      gambar: json['gambar'],
    );
  }
  Map<String,dynamic>toJson(){
    return{
     "id" :id,
     "nama" :nama,
     "harga" :harga,
     "stok" :stok,
     "desk" :desk,
     "gambar" :gambar,
    };
  }
}
