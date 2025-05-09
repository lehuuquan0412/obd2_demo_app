import 'package:app_chan_doan/connection_manage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_chan_doan/mqtt.dart';
import 'package:app_chan_doan/mode_obj_info.dart';

class RadarChartPage extends StatefulWidget {
  const RadarChartPage({
    super.key,
  });

  @override
  State<RadarChartPage> createState() {
    return _RadarChartPageState();
  }
}

class _RadarChartPageState extends State<RadarChartPage> {
  final databaseRef = FirebaseDatabase.instance.ref().child('$verifyId/41');

  List<String> selectedKeys = [
    "CEL",
    "ET",
    "IMAP",
    "ES",
    "VS",
    "IAT",
    "TP",
    "CMV"
  ];

  // Define max and min for each key
  final Map<String, Map<String, double>> rangeValues = {
    "CEL": {"min": 0, "max": 100},
    "ET": {"min": -40, "max": 215},
    "IMAP": {"min": 0, "max": 255},
    "ES": {"min": 0, "max": 16383},
    "VS": {"min": 0, "max": 255},
    "IAT": {"min": -40, "max": 215},
    "TP": {"min": 0, "max": 100},
    "CMV": {"min": 0, "max": 65},
  };

  Map<String, double> radarData = {};
  Map<String, double> originalData = {};
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _fetchRadarData();
  }

  void _fetchRadarData() {
    databaseRef.onValue.listen((event) {
      if (!isPaused) {
        final snapshotValue = event.snapshot.value;

        if (snapshotValue is! Map) {
          print("Dữ liệu không đúng định dạng Map.");
          return;
        }

        final data = Map<String, dynamic>.from(snapshotValue);

        final filteredData = data.entries
            .where((entry) => selectedKeys.contains(entry.key))
            .toList();

        setState(() {
          originalData = Map.fromEntries(
            filteredData
                .map((entry) => MapEntry(entry.key, entry.value.toDouble())),
          );

          radarData = Map.fromEntries(
            filteredData.map((entry) {
              String key = entry.key;
              double value = entry.value.toDouble();

              // Apply normalization based on min/max
              double min = rangeValues[key]!["min"]!;
              double max = rangeValues[key]!["max"]!;
              double normalizedValue =
                  ((value - min) / (max - min)).clamp(0.0, 1.0);

              return MapEntry(key, normalizedValue);
            }),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int transData = 0;
    for (var index in listRadarinfo) {
      transData |= (1 << index.priStat1);
    }
    mqtt.publish('{"mode":1,"value":$transData}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đồ thị radar'),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: const Color.fromARGB(255, 145, 220, 255),
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            mqtt.publish('{"mode":0}');
            Navigator.of(context).pop();
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 2.0,
          ),
        ),
      ),
      body: radarData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: kToolbarHeight),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8,
                      child: RadarChart(
                        RadarChartData(
                          dataSets: [
                            RadarDataSet(
                              dataEntries: radarData.values
                                  .map((value) => RadarEntry(value: value))
                                  .toList(),
                              borderColor: Colors.blue,
                              fillColor: Colors.blue.withValues(alpha: 0.3),
                              borderWidth: 2,
                              entryRadius: 4,
                            ),
                          ],
                          radarShape: RadarShape.polygon,
                          titleTextStyle: const TextStyle(fontSize: 12),
                          getTitle: (index, angle) {
                            String key = radarData.keys.toList()[index];
                            double originalValue = originalData[key] ?? 0;
                            return RadarChartTitle(
                              text:
                                  '$key\n(${originalValue.toStringAsFixed(1)})',
                            );
                          },
                          radarBorderData:
                              const BorderSide(color: Colors.white),
                          gridBorderData: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.7)),
                          tickBorderData: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3)),
                          ticksTextStyle: TextStyle(
                              color: Colors.grey.withValues(alpha: 0.5)),
                          tickCount: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: const Column(
                    children: [
                      Text(
                        'Chú thích:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('CEL: Tải trọng của động cơ (%)'),
                      Text('CMV: Điện áp mô đun điều khiển (V)'),
                      Text('ES: Tốc độ của động cơ (rpm)'),
                      Text('ET: Nhiệt độ nước làm mát (độ C)'),
                      Text('IMAP: Áp suất đường ống nạp (kPa)'),
                      Text('TP: Vị trí của bướm ga (%)'),
                      Text('IAT: Nhiệt độ khí nap (độ C)'),
                      Text('VS: Tốc độ của phương tiện (km/h)'),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isPaused = true;
                        });
                      },
                      child: const Text("Tạm dừng"),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isPaused = false;
                        });
                      },
                      child: const Text("Tiếp tục"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
