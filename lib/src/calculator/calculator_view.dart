import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/src/calculator/calculator_controller.dart';
import 'package:flutter_application_1/src/calculator/currency_formatter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CaluculatorPage extends StatefulWidget {
  const CaluculatorPage({super.key});

  @override
  State<CaluculatorPage> createState() => CalculatorController();
}

class CalculatorView extends StatelessWidget {
  final CalculatorController state;
  CalculatorView({super.key, required this.state});

  final GlobalKey _screenshotKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "HASIL HITUNG 🚀",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: state.reset, icon: const Icon(Icons.refresh))
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          children: [
            TextField(
              controller: state.diskonController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter()
              ],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Diskon",
              ),
              cursorColor: Colors.pink,
            ),
            TextField(
              controller: state.biayaController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter()
              ],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Biaya Layanan",
              ),
              cursorColor: Colors.pink,
            ),
            // TextField(
            //   controller: state.rekeningController,
            //   keyboardType: TextInputType.number,
            //   inputFormatters: [
            //     FilteringTextInputFormatter.digitsOnly,
            //   ],
            //   decoration: const InputDecoration(
            //     labelText: "No Rekening",
            //   ),
            // ),
            TypeAheadField<String>(
              focusNode: state.focusNode,
              controller: state.rekeningController,
              suggestionsController: state.suggestionsController,
              itemBuilder: (context, value) {
                return ListTile(
                  title: Text(
                    "${value.split(":")[0]} (${value.split(":")[1]})",
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      state.deleteRekening(value);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                );
              },
              builder: (context, controller, focusNode) {
                return TextField(
                  focusNode: focusNode,
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: "No Rekening",
                  ),
                  cursorColor: Colors.pink,
                  onTap: () {
                    state.suggestionsController.refresh();
                  },
                );
              },
              hideOnEmpty: true,
              onSelected: state.onSelectRekening,
              suggestionsCallback: state.suggestionRekening,
            ),
            TextField(
              controller: state.bankController,
              inputFormatters: [UpperInputFormatter()],
              decoration: const InputDecoration(
                labelText: "Nama Bank",
              ),
              cursorColor: Colors.pink,
            ),
            Row(
              children: [
                Checkbox(
                  activeColor: Colors.pink,
                  value: state.saveRekening,
                  onChanged: state.onChangeSaveRekening,
                ),
                const SizedBox(width: 10),
                const Text("Simpan No. Rekening"),
              ],
            ),
            ...List.generate(
              state.jumlahPesertaList.length,
              (index) {
                return textField(
                  state.jumlahPesertaList[index],
                  state.hargaList[index],
                  state.deskripsiList[index],
                  index,
                );
              },
            ),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                onPressed: state.add,
                label: const Text(
                  "Tambahkan Peserta",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 50,
              constraints: const BoxConstraints(maxWidth: 300),
              child: ElevatedButton(
                onPressed: state.calculate,
                child: const Text(
                  "🖨 Hitung",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (state.hasil.isNotEmpty) ...[
              RepaintBoundary(
                key: _screenshotKey,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Table(
                          columnWidths: const {
                            0: FlexColumnWidth(1.5),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(2),
                          },
                          border: TableBorder.all(),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.bottom,
                          children: const [
                            TableRow(
                              decoration: BoxDecoration(color: Colors.pink),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Jumlah Peserta",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Harga\n(per orang)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Harga\n+\nLayanan\n(per orang)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Harga setelah Diskon\n(per orang)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(0.5),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(2),
                          4: FlexColumnWidth(2),
                        },
                        border: TableBorder.all(),
                        children: [
                          ...state.hasil.map(
                            (e) => TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${e["deskripsi"]}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${e["jumlahPeserta"]}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    state.rupiahFormat(e["harga"]),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    state.rupiahFormat(e["hargaBiayaLayanan"]),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    state.rupiahFormat(e["hargaSetelahDiskon"]),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Table(
                        border: TableBorder.all(),
                        children: const [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.pink),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "TOTAL",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1.5),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(2),
                        },
                        border: TableBorder.all(),
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "${state.totalPeserta}",
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  state.rupiahFormat(state.totalHarga),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  state.rupiahFormat(
                                      state.totalHargaBiayaLayanan),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  state.rupiahFormat(state.totalHargaDiskon),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.share),
                onPressed: () {
                  state.saveAndShareScreenshot(_screenshotKey);
                },
                label: const Text(
                  "Bagikan",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget textField(
      TextEditingController pesertaText,
      TextEditingController hargaText,
      TextEditingController deskripsiText,
      int index) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: pesertaText,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Jumlah",
            ),
            cursorColor: Colors.pink,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: TextField(
            controller: deskripsiText,
            inputFormatters: [
              LengthLimitingTextInputFormatter(12),
              UpperInputFormatter()
            ],
            decoration: const InputDecoration(
              labelText: "Deskripsi",
            ),
            cursorColor: Colors.pink,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 5,
          child: TextField(
            controller: hargaText,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter()
            ],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Harga",
            ),
            cursorColor: Colors.pink,
          ),
        ),
        IconButton(
          onPressed: () {
            state.remove(index);
          },
          icon: const Icon(Icons.delete),
        )
      ],
    );
  }
}
