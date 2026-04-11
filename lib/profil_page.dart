import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Profil"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          
          SizedBox(height: 20),

          Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    buildBox(context),
    SizedBox(width: 20),
    buildBox(context),
  ],
),

          SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildMenu("Menu 1"),
              buildMenu("Menu 2"),
              buildMenu("Menu 3"),
            ],
          ),

          SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Flutter adalah framework open-source yang dikembangkan oleh Google untuk membangun aplikasi mobile, web, dan desktop dari satu basis kode. Dengan Flutter, developer dapat membuat aplikasi untuk berbagai platform seperti Android, iOS, Windows, dan web tanpa harus menulis kode terpisah untuk masing-masing sistem. Hal ini membuat proses pengembangan menjadi lebih cepat, efisien, dan mudah dikelola."),
                SizedBox(height: 8),
                Text("Flutter menggunakan bahasa pemrograman Dart sebagai dasar pengembangannya. Salah satu keunggulan utama Flutter adalah konsep widget, yaitu setiap elemen dalam aplikasi—baik tampilan maupun struktur—dibangun menggunakan widget. Flutter juga memiliki fitur hot reload yang memungkinkan developer melihat perubahan kode secara langsung tanpa harus menjalankan ulang aplikasi, sehingga sangat membantu dalam proses pengembangan UI."),
                SizedBox(height: 8),
              
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget buildBox(BuildContext context) {
  double lebar = MediaQuery.of(context).size.width;

  return Container(
    width: lebar * 0.42, 
    height: 150,         
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black, width: 2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(Icons.image, size: 50),
  );
}

  Widget buildMenu(String title) {
  return Column(
    children: [
      Container(
        width: 70,   
        height: 70,  
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      SizedBox(height: 10),
      Text(title),
    ],
  );
}
}