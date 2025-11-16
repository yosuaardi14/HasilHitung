import 'package:flutter/material.dart';

class CalculatorByPesertaModel {
  final TextEditingController peserta = TextEditingController(text: "");
  final List<CalculatorByPesananModel> pesanan = [CalculatorByPesananModel()];

  void dispose() {
    peserta.dispose();
    for (var e in pesanan) {
      e.dispose();
    }
  }
}

class CalculatorByPesananModel {
  final TextEditingController jumlah = TextEditingController(text: "0");
  final TextEditingController harga = TextEditingController(text: "0");
  final TextEditingController deskripsi = TextEditingController(text: "");

  void dispose() {
    jumlah.dispose();
    harga.dispose();
    deskripsi.dispose();
  }
}
