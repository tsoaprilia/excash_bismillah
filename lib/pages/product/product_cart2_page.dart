import 'package:flutter/material.dart';

class ProductCart2Page extends StatefulWidget {
  const ProductCart2Page({super.key});

  @override
  State<ProductCart2Page> createState() => _ProductCart2PageState();
}

class _ProductCart2PageState extends State<ProductCart2Page> {
  @override
  Widget build(BuildContext context) {
 return Scaffold(
      appBar: AppBar(title: Text('Keranjang Belanja')),
      body: Center(child: Text('Fitur keranjang dalam pengembangan')), // Implementasi selanjutnya
    );  }
}