import 'package:flutter/material.dart';

class CalculatorByPesertaModel {
  final TextEditingController peserta = TextEditingController(text: "");
  final List<CalculatorByPesananModel> pesanan = [CalculatorByPesananModel()];
}

class CalculatorByPesananModel {
  final TextEditingController jumlah = TextEditingController(text: "0");
  final TextEditingController harga = TextEditingController(text: "0");
  final TextEditingController deskripsi = TextEditingController(text: "");
}
