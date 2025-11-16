import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/src/calculator/calculator_model.dart';
import 'package:flutter_application_1/src/calculator/calculator_view.dart';
import 'package:flutter_application_1/src/calculator/storage_util.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CalculatorController extends State<CaluculatorPage> {
  @override
  Widget build(BuildContext context) => CalculatorView(state: this);

  // final List<TextEditingController> jumlahPesananList = [];
  // final List<TextEditingController> hargaList = [];
  // final List<TextEditingController> deskripsiList = [];

  final List<CalculatorByPesertaModel> pesertaCalculator = [];

  final TextEditingController diskonController = TextEditingController(
    text: "0",
  );
  final TextEditingController biayaController = TextEditingController(
    text: "0",
  );
  final TextEditingController rekeningController = TextEditingController(
    text: "",
  );
  final TextEditingController bankController = TextEditingController(text: "");
  SuggestionsController<String> suggestionsController = SuggestionsController();
  FocusNode focusNode = FocusNode();

  final List<Map<String, dynamic>> hasil = [];

  double totalHarga = 0.0, totalHargaBiayaLayanan = 0.0, totalHargaDiskon = 0.0;
  int totalPeserta = 0;
  bool saveRekening = true;
  String tipeDiskonBiayaLayanan = "Berdasarkan Pesanan";

  List<String> rekeningTersimpan = [];

  @override
  void initState() {
    super.initState();
    StorageUtil.readData("rekening").then(loadRekening);
  }

  void loadRekening(dynamic val) {
    setState(() {
      if (val != null) {
        rekeningTersimpan = val;
      }
    });
  }

  void addPeserta() {
    pesertaCalculator.add(CalculatorByPesertaModel());
    setState(() {});
  }

  void addPesanan(int pesertaIndex) {
    pesertaCalculator[pesertaIndex].pesanan.add(CalculatorByPesananModel());
    // jumlahPesananList.add(TextEditingController());
    // hargaList.add(TextEditingController());
    // deskripsiList.add(TextEditingController());
    setState(() {});
  }

  void removePesanan(int index, int pesertaIndex) {
    if (tipeDiskonBiayaLayanan == "Berdasarkan Pesanan") {
      pesertaCalculator[index].dispose();
      pesertaCalculator.removeAt(index);
    } else {
      pesertaCalculator[pesertaIndex].pesanan[index].dispose();
      pesertaCalculator[pesertaIndex].pesanan.removeAt(index);
    }
    setState(() {});
  }

  void removePeserta(int index) {
    pesertaCalculator[index].dispose();
    pesertaCalculator.removeAt(index);
    setState(() {});
  }

  void onChangeSaveRekening(bool? val) {
    setState(() {
      saveRekening = val ?? false;
    });
  }

  void onChangeTipeDiskonBiayaLayanan(String? val) {
    setState(() {
      tipeDiskonBiayaLayanan = val ?? "Berdasarkan Pesanan";
      if (hasil.isNotEmpty || pesertaCalculator.isNotEmpty) {
        reset();
      }
    });
  }

  void calculate() {
    hasil.clear();
    totalHarga = 0.0;
    totalHargaBiayaLayanan = 0.0;
    totalHargaDiskon = 0.0;
    if (pesertaCalculator.isEmpty) {
      return;
    }
    double biayaLayanan = 0.0;
    if (biayaController.text.isNotEmpty) {
      biayaLayanan = double.parse(biayaController.text.replaceAll(",", ""));
    }

    double diskon = 0.0;
    if (diskonController.text.isNotEmpty) {
      diskon = double.parse(diskonController.text.replaceAll(",", ""));
    }

    if (tipeDiskonBiayaLayanan == "Berdasarkan Pesanan") {
      totalPeserta = 0;

      for (var i = 0; i < pesertaCalculator.length; i++) {
        totalPeserta +=
            int.tryParse(pesertaCalculator[i].pesanan.first.jumlah.text) ?? 0;
      }

      for (var i = 0; i < pesertaCalculator.length; i++) {
        CalculatorByPesananModel pesanan = pesertaCalculator[i].pesanan.first;
        int jumlahPesanan = int.tryParse(pesanan.jumlah.text) ?? 0;

        double harga =
            double.tryParse(pesanan.harga.text.replaceAll(",", "")) ?? 0;
        double hargaBiayaLayanan = harga + (biayaLayanan / totalPeserta);
        double hargaSetelahDiskon = hargaBiayaLayanan - (diskon / totalPeserta);
        hasil.add({
          "nama": pesanan.deskripsi.text,
          "deskripsi": pesanan.deskripsi.text,
          "jumlahPesanan": jumlahPesanan,
          "harga": harga,
          "hargaBiayaLayanan": hargaBiayaLayanan,
          "hargaSetelahDiskon": hargaSetelahDiskon,
        });

        totalHarga += harga * jumlahPesanan;
        totalHargaBiayaLayanan += hargaBiayaLayanan * jumlahPesanan;
        totalHargaDiskon += hargaSetelahDiskon * jumlahPesanan;
      }
    } else {
      totalPeserta = pesertaCalculator.length;

      for (var i = 0; i < pesertaCalculator.length; i++) {
        String nama = pesertaCalculator[i].peserta.text;

        List<Map<String, dynamic>> listMapPesanan = [];

        for (var j = 0; j < pesertaCalculator[i].pesanan.length; j++) {
          CalculatorByPesananModel pesanan = pesertaCalculator[i].pesanan[j];
          int jumlahPesanan = int.tryParse(pesanan.jumlah.text) ?? 0;

          double harga =
              double.tryParse(pesanan.harga.text.replaceAll(",", "")) ?? 0;
          listMapPesanan.add({
            "deskripsi": pesanan.deskripsi.text,
            "jumlahPesanan": jumlahPesanan,
            "harga": harga,
            "totalHarga": harga * jumlahPesanan,
          });

          totalHarga += harga * jumlahPesanan;
          totalHargaBiayaLayanan += harga * jumlahPesanan;
          totalHargaDiskon += harga * jumlahPesanan;
        }
        if (biayaLayanan != 0.0) {
          listMapPesanan.add({
            "deskripsi": "Biaya Layanan".toUpperCase(),
            "jumlahPesanan": 1,
            "harga": biayaLayanan / totalPeserta,
            "totalHarga": biayaLayanan / totalPeserta,
          });
          totalHargaBiayaLayanan += (biayaLayanan / totalPeserta);
        }
        if (diskon != 0.0) {
          listMapPesanan.add({
            "deskripsi": "Diskon".toUpperCase(),
            "jumlahPesanan": 1,
            "harga": -(diskon / totalPeserta),
            "totalHarga": -(diskon / totalPeserta),
          });
          totalHargaDiskon +=
              (biayaLayanan / totalPeserta) + -(diskon / totalPeserta);
        }

        Map<String, dynamic> tempHasil = {
          "nama": nama,
          "pesanan": listMapPesanan,
          "totalHarga": listMapPesanan.fold(
            0.0,
            (value, e) => value + (e["totalHarga"] ?? 0.0),
          ),
        };
        hasil.add(tempHasil);
      }
    }

    if (saveRekening) {
      String rekening = "${rekeningController.text}:${bankController.text}";
      if (!rekeningTersimpan.contains(rekening)) {
        rekeningTersimpan.add(rekening);
      }
      StorageUtil.saveData("rekening", rekeningTersimpan);
    }
    setState(() {});
  }

  String rupiahFormat(double amount) {
    return NumberFormat.currency(
      locale: "id",
      decimalDigits: 0,
      symbol: "Rp ",
    ).format(amount);
  }

  void saveAndShareScreenshot(
    GlobalKey<State<StatefulWidget>> screenshotKey,
  ) async {
    Uint8List? bytes = await captureScreenshot(screenshotKey);
    if (bytes == null) {
      return;
    }
    await shareScreenshot(bytes);
  }

  Future<Uint8List?> captureScreenshot(GlobalKey screenshotKey) async {
    try {
      final RenderRepaintBoundary boundary =
          screenshotKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(
        format: ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  Future<void> saveScreenshot(Uint8List screenshotBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/screenshot.png');
    await file.writeAsBytes(screenshotBytes);
  }

  Future<void> shareScreenshot(Uint8List screenshotBytes) async {
    // await saveScreenshot(screenshotBytes);
    SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            screenshotBytes,
            mimeType: "image/png",
            name: "screenshot.png",
          ),
        ],
        text:
            'Jangan lupa bayar ya!!!\nBank: ${bankController.text}\nNo Rekening: ${rekeningController.text}',
      ),
    );
  }

  FutureOr<List<String>?> suggestionRekening(String val) async {
    rekeningTersimpan = await StorageUtil.readData("rekening") ?? [];
    List<String> a = rekeningTersimpan.where((e) => e.startsWith(val)).toList();
    return a;
  }

  void deleteRekening(String value) {
    setState(() {
      rekeningTersimpan.remove(value);
    });
    StorageUtil.saveData("rekening", rekeningTersimpan);
    focusNode.unfocus();
  }

  void onSelectRekening(String val) {
    if (val.contains(":")) {
      focusNode.unfocus();
      rekeningController.text = val.split(":")[0];
      bankController.text = val.split(":")[1];
    }
  }

  void reset() {
    for (var peserta in pesertaCalculator) {
      peserta.dispose();
    }
    pesertaCalculator.clear();
    diskonController.text = "0";
    biayaController.text = "0";
    rekeningController.text = "";
    bankController.text = "";
    hasil.clear();
    // jumlahPesananList.clear();
    // hargaList.clear();
    // deskripsiList.clear();
    setState(() {});
  }
}
