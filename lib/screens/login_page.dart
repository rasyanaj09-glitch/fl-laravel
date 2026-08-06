import 'package:flutter/material.dart';
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

  void login() {
  
    if (emailController.text == "suki@mau" && pwController.text == "12") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const Sukib(), 
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("email atau pw slh"),
          backgroundColor: Colors.red,
        ),
      );
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
                  height: 30,
                    child : ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
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
