import 'package:flutter/material.dart';

class ProductCartPage extends StatefulWidget {
  const ProductCartPage({super.key});

  @override
  State<ProductCartPage> createState() => _ProductCartPageState();
}

class _ProductCartPageState extends State<ProductCartPage> {
  @override
  Widget build(BuildContext context) {
 return Scaffold(
      appBar: AppBar(title: Text('Keranjang Belanja')),
      body: Center(child: Text('Fitur keranjang dalam pengembangan')), // Implementasi selanjutnya
    );  }
}