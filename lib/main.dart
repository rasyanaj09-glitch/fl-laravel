import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'screens/login_page.dart';
import 'screens/sukib.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  Future<String?> ceklogin() async {
  
    await Future.delayed(const Duration(seconds: 1));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_token'); 
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "suki",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, 
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[200], 
      ),
   
      home: FutureBuilder<String?>(
        future: ceklogin(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 20),
                    Text("Memeriksa sesi login...", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            );
          }


          final String? token = snapshot.data;

      
          if (token == null) {
            return const LoginPage();
          } else {
            return const Sukib();
          }
        },
      ),
    );
  }
}
