import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/src/calculator/calculator_view.dart';
import 'package:flutter_application_1/src/calculator/storage_util.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CalculatorController extends State<CaluculatorPage> {
  @override
  Widget build(BuildContext context) => CalculatorView(state: this);

  final List<TextEditingController> jumlahPesertaList = [];
  final List<TextEditingController> hargaList = [];
  final List<TextEditingController> deskripsiList = [];

  final TextEditingController diskonController =
      TextEditingController(text: "0");
  final TextEditingController biayaController =
      TextEditingController(text: "0");
  final TextEditingController rekeningController =
      TextEditingController(text: "");
  final TextEditingController bankController = TextEditingController(text: "");
  SuggestionsController<String> suggestionsController = SuggestionsController();
  FocusNode focusNode = FocusNode();

  final List<Map<String, dynamic>> hasil = [];

  double totalHarga = 0.0, totalHargaBiayaLayanan = 0.0, totalHargaDiskon = 0.0;
  int totalPeserta = 0;
  bool saveRekening = true;

  List<String> rekeningTersimpan = [];

  @override
  void initState() {
    super.initState();
    StorageUtil.readData("rekening").then(loadRekening);
  }

  void loadRekening(val) {
    setState(() {
      if (val != null) {
        rekeningTersimpan = val;
      }
    });
  }

  void add() {
    jumlahPesertaList.add(TextEditingController());
    hargaList.add(TextEditingController());
    deskripsiList.add(TextEditingController());
    setState(() {});
  }

  void remove(int index) {
    jumlahPesertaList.removeAt(index);
    hargaList.removeAt(index);
    setState(() {});
  }

  void onChangeSaveRekening(val) {
    setState(() {
      saveRekening = val;
    });
  }

  void calculate() {
    hasil.clear();
    totalHarga = 0.0;
    totalHargaBiayaLayanan = 0.0;
    totalHargaDiskon = 0.0;
    if (jumlahPesertaList.isEmpty) {
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

    totalPeserta = 0;

    for (var i = 0; i < jumlahPesertaList.length; i++) {
      totalPeserta += int.tryParse(jumlahPesertaList[i].text) ?? 0;
    }

    for (var i = 0; i < hargaList.length; i++) {
      int jumlahPeserta = int.tryParse(jumlahPesertaList[i].text) ?? 0;

      double harga =
          double.tryParse(hargaList[i].text.replaceAll(",", "")) ?? 0;
      double hargaBiayaLayanan = harga + (biayaLayanan / totalPeserta);
      double hargaSetelahDiskon = hargaBiayaLayanan - (diskon / totalPeserta);
      hasil.add({
        "deskripsi": deskripsiList[i].text,
        "jumlahPeserta": jumlahPeserta,
        "harga": harga,
        "hargaBiayaLayanan": hargaBiayaLayanan,
        "hargaSetelahDiskon": hargaSetelahDiskon,
      });
      for (var j = 0; j < jumlahPeserta; j++) {
        totalHarga += harga;
        totalHargaBiayaLayanan += hargaBiayaLayanan;
        totalHargaDiskon += hargaSetelahDiskon;
        // hasil.add({
        //   "jumlahPeserta": 1,
        //   "harga": harga,
        //   "hargaBiayaLayanan": hargaBiayaLayanan,
        //   "hargaSetelahDiskon": hargaSetelahDiskon,
        // });
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
    return NumberFormat.currency(locale: "id", decimalDigits: 0, symbol: "Rp ")
        .format(amount);
  }

  void saveAndShareScreenshot(screenshotKey) async {
    Uint8List? bytes = await captureScreenshot(screenshotKey);
    if (bytes == null) {
      return;
    }
    await shareScreenshot(bytes);
  }

  Future<Uint8List?> captureScreenshot(GlobalKey screenshotKey) async {
    try {
      final RenderRepaintBoundary boundary = screenshotKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
          await image.toByteData(format: ImageByteFormat.png);
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
    Share.shareXFiles(
      [XFile.fromData(screenshotBytes, mimeType: "image/png")],
      text:
          'Jangan lupa bayar ya!!!\nBank: ${bankController.text}\nNo Rekening: ${rekeningController.text}',
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
    diskonController.text = "0";
    biayaController.text = "0";
    rekeningController.text = "";
    bankController.text = "";
    hasil.clear();
    jumlahPesertaList.clear();
    hargaList.clear();
    deskripsiList.clear();
    setState(() {});
  }
}
