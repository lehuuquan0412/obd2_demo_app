// ignore_for_file: use_build_context_synchronously

import 'package:app_chan_doan/connection_manage.dart';
import 'package:app_chan_doan/mqtt.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_chan_doan/mode_obj_info.dart';

class ShowDTC extends StatefulWidget {
  const ShowDTC({super.key, required this.modeInfoDTC});

  final List<ModeObjInfo> modeInfoDTC;

  @override
  State<ShowDTC> createState() {
    return _ShowDTCState();
  }
}

class _ShowDTCState extends State<ShowDTC> {
  final databaseRef = FirebaseDatabase.instance.ref();
  List<String> dtcCode = List.filled(256, '');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mqtt.publish('{"mode":${widget.modeInfoDTC[0].mode}}');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.modeInfoDTC[0].name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
      body: Column(
        children: [
          StreamBuilder(
            stream: databaseRef
                .child('$verifyId${widget.modeInfoDTC[0].firebaseName}/num')
                .onValue,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  !snapshot.hasError &&
                  snapshot.data!.snapshot.value != null) {
                widget.modeInfoDTC[0].value = snapshot.data!.snapshot.value;
                widget.modeInfoDTC[0].priStat1 = widget.modeInfoDTC[0].value;
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    Center(
                        child: Text(
                      'Số lượng ${widget.modeInfoDTC[0].name}: ${widget.modeInfoDTC[0].priStat1}',
                      style: const TextStyle(fontSize: 18),
                    )),
                    ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: widget.modeInfoDTC[0].priStat1,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return StreamBuilder(
                          stream: databaseRef
                              .child(
                                  '$verifyId${widget.modeInfoDTC[0].firebaseName}/${index + 1}')
                              .onValue,
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                !snapshot.hasError &&
                                snapshot.data!.snapshot.value != null) {
                              dtcCode[index] =
                                  snapshot.data!.snapshot.value.toString();
                              return Card(
                                color: const Color.fromARGB(255, 190, 190, 190),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.warning,
                                    color: Colors.yellow,
                                  ),
                                  title: Text(dtcCode[index],
                                      style: const TextStyle(fontSize: 20)),
                                  onTap: () {
                                    _showDtcDetail(dtcCode[index]);
                                  },
                                ),
                              );
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        );
                      },
                    ),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.delete, size: 25, color: Colors.white),
              label: const Text('Xóa các mã lỗi DTC',
                  style: TextStyle(color: Colors.white)),
              onPressed: () {
                mqtt.publish('{"mode":4}');
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 20), // Adjusted padding
                  textStyle:
                      const TextStyle(fontSize: 20) // Corrected text size
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDtcDetail(String code) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('dtc_codes')
        .doc(code)
        .get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(data['name'] ?? 'Không có dữ liệu'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Mô tả: ${data['description'] ?? 'Không có dữ liệu'}'),
                  const SizedBox(height: 20),
                  Text(
                      'Triệu chứng: ${data['symptoms'] ?? 'Không có dữ liệu'}'),
                  const SizedBox(height: 20),
                  Text(
                      'Cách xử lý: ${data['repair tips'] ?? 'Không có dữ liệu'}'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Đóng'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không có dữ liệu của $code',
            style: const TextStyle(
              fontSize: 18, // Specify the font size
              color: Colors.white, // Optional: Change text color
            ),
          ),
        ),
      );
    }
  }
}
