import 'package:app_chan_doan/connection_manage.dart';
import 'package:app_chan_doan/mode_obj_info.dart';
import 'package:app_chan_doan/mqtt.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rebi_vin_decoder/rebi_vin_decoder.dart';

class ModuleInformationPage extends StatelessWidget {
  const ModuleInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseRef = FirebaseDatabase.instance.ref();
    mqtt.publish('{"mode":9}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đọc số VIN'),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: const Color.fromARGB(255, 145, 220, 255),
        leading: PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, result) {
            if (didPop) {
              return;
            }
            Navigator.of(context).pop();
          },
          child: BackButton(
            color: Colors.black,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 2.0,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: listMode9info.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${listMode9info[index].name}: ',
                    style: const TextStyle(fontSize: 18),
                  ),
                  StreamBuilder(
                    stream: databaseRef
                        .child('$verifyId${listMode9info[index].firebaseName}')
                        .onValue,
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          !snapshot.hasError &&
                          snapshot.data!.snapshot.value != null) {
                        listMode9info[index].value =
                            snapshot.data!.snapshot.value;
                        return Text(
                          '${listMode9info[index].value}',
                          style: const TextStyle(fontSize: 18),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                child: const Text('Giải mã số VIN'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      var vin = VIN(
                          number: '${listMode9info[index].value}',
                          extended: true);
                      return Dialog(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 10),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    Text('WMI: ${vin.wmi}'),
                                    Text('VDS: ${vin.vds}'),
                                    Text('VIS: ${vin.vis}'),
                                    Text("Mẫu: ${vin.modelYear()}"),
                                    Text("Số se-ri: ${vin.serialNumber()}"),
                                    Text(
                                        "Nhà máy lắp ráp: ${vin.assemblyPlant()}"),
                                    Text(
                                        "Nhà sản xuất: ${vin.getManufacturer()}"),
                                    Text("Năm sản xuất: ${vin.getYear()}"),
                                    Text("Khu vực: ${vin.getRegion()}"),
                                    Text("Chuỗi số VIN: $vin"),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ],
                            ),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Đóng'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
