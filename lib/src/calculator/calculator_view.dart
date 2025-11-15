import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/src/calculator/calculator_controller.dart';
import 'package:flutter_application_1/src/calculator/calculator_model.dart';
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
          IconButton(onPressed: state.reset, icon: const Icon(Icons.refresh)),
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
                CurrencyInputFormatter(),
              ],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Diskon"),
              cursorColor: Colors.pink,
            ),
            TextField(
              controller: state.biayaController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Biaya Layanan"),
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
            DropdownButtonFormField(
              decoration: InputDecoration(
                label: Text("Tipe Diskon dan Biaya Layanan"),
              ),
              initialValue: "Berdasarkan Pesanan",
              items: [
                "Berdasarkan Pesanan",
                "Berdasarkan Peserta",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: state.onChangeTipeDiskonBiayaLayanan,
            ),
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: "No Rekening"),
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
              decoration: const InputDecoration(labelText: "Nama Bank"),
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
            ...List.generate(state.pesertaCalculator.length, (index) {
              return textFieldPeserta(state.pesertaCalculator[index], index);
            }),
            // ...List.generate(state.jumlahPesananList.length, (index) {
            //   return textFieldPesanan(
            //     state.jumlahPesananList[index],
            //     state.hargaList[index],
            //     state.deskripsiList[index],
            //     index,
            //   );
            // }),
            const SizedBox(height: 10),
            Container(
              height: 35,
              constraints: const BoxConstraints(maxWidth: 300),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                onPressed: state.addPeserta,
                label: Text(
                  "Tambahkan ${state.tipeDiskonBiayaLayanan == "Berdasarkan Peserta" ? "Peserta" : "Pesanan"}",
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
                    children:
                        state.tipeDiskonBiayaLayanan == "Berdasarkan Pesanan"
                        ? [
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
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "Harga\n(per pesanan)",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "Harga\n+\nLayanan\n(per pesanan)",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "Harga setelah Diskon\n(per pesanan)",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                                          "${e["jumlahPesanan"]}",
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
                                          state.rupiahFormat(
                                            e["hargaBiayaLayanan"],
                                          ),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          state.rupiahFormat(
                                            e["hargaSetelahDiskon"],
                                          ),
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
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
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
                                          state.totalHargaBiayaLayanan,
                                        ),
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
                                          state.totalHargaDiskon,
                                        ),
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
                            ),
                          ]
                        : [
                            ...List.generate(state.hasil.length, (index) {
                              Map<String, dynamic> hasil = state.hasil[index];
                              return Column(
                                children: [
                                  Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(1),
                                      1: FlexColumnWidth(0.5),
                                      2: FlexColumnWidth(2),
                                      3: FlexColumnWidth(2),
                                      4: FlexColumnWidth(2),
                                    },
                                    border: TableBorder.all(),
                                    defaultVerticalAlignment:
                                        TableCellVerticalAlignment.bottom,
                                    children: const [
                                      TableRow(
                                        decoration: BoxDecoration(
                                          color: Colors.pink,
                                        ),
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "Pesanan",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "Qty",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "Harga Satuan",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "Total Harga",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
                                      ...hasil["pesanan"].map(
                                        (e) => TableRow(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                "${e["deskripsi"]}",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                "${e["jumlahPesanan"]}",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                state.rupiahFormat(e["harga"]),
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                state.rupiahFormat(
                                                  e["totalHarga"],
                                                ),
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Table(
                                    border: TableBorder.symmetric(
                                      outside: BorderSide(),
                                    ),
                                    children: [
                                      TableRow(
                                        decoration: BoxDecoration(
                                          color: Colors.pink,
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "TOTAL ${hasil["nama"] ?? ""}",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              state.rupiahFormat(
                                                hasil["totalHarga"],
                                              ),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              );
                            }),

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
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Table(
                              // columnWidths: const {
                              //   0: FlexColumnWidth(1.5),
                              //   1: FlexColumnWidth(2),
                              //   2: FlexColumnWidth(2),
                              // },
                              border: TableBorder.symmetric(
                                outside: BorderSide(),
                                inside: BorderSide(),
                              ),
                              children: [
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "Total Harga",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.all(8.0),
                                    //   child: SizedBox(),
                                    // ),
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
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "Total Harga + Layanan",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.all(8.0),
                                    //   child: SizedBox(),
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        state.rupiahFormat(
                                          state.totalHargaBiayaLayanan,
                                        ),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "Total Harga setelah Diskon",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.all(8.0),
                                    //   child: SizedBox(),
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        state.rupiahFormat(
                                          state.totalHargaDiskon,
                                        ),
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
                            ),
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

  Widget textFieldPeserta(CalculatorByPesertaModel model, int index) {
    if (state.tipeDiskonBiayaLayanan == "Berdasarkan Pesanan") {
      return textFieldPesanan(model.pesanan.first, index, index);
    }
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: model.peserta,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(12),
                  UpperInputFormatter(),
                ],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Nama"),
                cursorColor: Colors.pink,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 35,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  onPressed: () => state.addPesanan(index),
                  label: Text("Pesanan"),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                state.removePeserta(index);
              },
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
        ...List.generate(
          model.pesanan.length,
          (i) => textFieldPesanan(model.pesanan[i], i, index),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget textFieldPesanan(
    CalculatorByPesananModel pesanan,
    int index,
    int pesertaIndex,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: pesanan.jumlah,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Jumlah"),
            cursorColor: Colors.pink,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: TextField(
            controller: pesanan.deskripsi,
            inputFormatters: [
              LengthLimitingTextInputFormatter(12),
              UpperInputFormatter(),
            ],
            decoration: const InputDecoration(labelText: "Deskripsi"),
            cursorColor: Colors.pink,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 5,
          child: TextField(
            controller: pesanan.harga,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Harga"),
            cursorColor: Colors.pink,
          ),
        ),
        IconButton(
          onPressed: () {
            state.removePesanan(index, pesertaIndex);
          },
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }
}
