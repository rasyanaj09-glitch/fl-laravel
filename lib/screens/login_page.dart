import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'sukib.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  bool isLoading = false;

  final Dio dio = Dio();

  Future<void> login() async {
    if (emailController.text.isEmpty || pwController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email dan password wajib diisi"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await dio.post(
        'http://127.0.0.1:8000/login',
        data: {
          'email': emailController.text,
          'password': pwController.text,
        },
      );

      if (response.statusCode == 200) {
        String token = response.data['token'];
        debugPrint("Token Sanctum Berhasil Diterima: $token");

   
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('api_token', token); 
        debugPrint("Token resmi tersimpan di memori lokal Windows!");


        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const Sukib(),
          ),
        );
      }
    } on DioException catch (e) {
      String errorMessage = "Terjadi kesalahan sistem";

      if (e.response != null && e.response?.statusCode == 401) {
        errorMessage = e.response?.data['message'] ?? "Email atau password salah";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = "Gagal terhubung ke server. Pastikan 'php artisan serve' sudah menyala.";
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Suki"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shop, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  "suki",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                
                TextField(
                  controller: pwController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                
                SizedBox(
                  width: double.infinity,
                  height: 50, 
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Masuk",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
