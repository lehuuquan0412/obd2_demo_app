import 'package:app_chan_doan/connection_manage.dart';
import 'package:app_chan_doan/mode_obj_info.dart';
import 'package:app_chan_doan/mqtt.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Mode6Page extends StatelessWidget {
  const Mode6Page({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseRef = FirebaseDatabase.instance.ref();
    mqtt.publish('{"mode":6}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả OBD Test'),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: const Color.fromARGB(255, 145, 220, 255),
        leading: PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, result) {
            if (didPop) {
              return;
            }
            mqtt.publish('{"mode":0}');
            Navigator.of(context).pop();
          },
          child: BackButton(
            color: Colors.black,
            onPressed: () {
              mqtt.publish('{"mode":0}');
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
                1: FixedColumnWidth(90),
                2: FixedColumnWidth(90),
                3: FixedColumnWidth(90),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  children: const [
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child: Text('Tên',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))))),
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child: Text('Min',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))))),
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child: Text('Giá trị',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))))),
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child: Text('Max',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))))),
                  ],
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listMode6info.length,
              itemBuilder: (context, index) {
                return Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: const <int, TableColumnWidth>{
                    0: FlexColumnWidth(),
                    1: FixedColumnWidth(90),
                    2: FixedColumnWidth(90),
                    3: FixedColumnWidth(90),
                  },
                  children: [
                    TableRow(
                      children: [
                        TableCell(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(listMode6info[index].name))),
                        TableCell(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StreamBuilder(
                            stream: databaseRef
                                .child(
                                    '$verifyId${listMode6info[index].firebaseName}/min')
                                .onValue,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  !snapshot.hasError &&
                                  snapshot.data!.snapshot.value != null) {
                                listMode6info[index].value =
                                    snapshot.data!.snapshot.value;
                                return Center(
                                  child: Text(
                                    '${listMode6info[index].value}',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                );
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                            },
                          ),
                        )),
                        TableCell(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StreamBuilder(
                            stream: databaseRef
                                .child(
                                    '$verifyId${listMode6info[index].firebaseName}/test_value')
                                .onValue,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  !snapshot.hasError &&
                                  snapshot.data!.snapshot.value != null) {
                                listMode6info[index].value =
                                    snapshot.data!.snapshot.value;
                                return Center(
                                  child: Text(
                                    '${listMode6info[index].value}',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                );
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                            },
                          ),
                        )),
                        TableCell(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StreamBuilder(
                            stream: databaseRef
                                .child(
                                    '$verifyId${listMode6info[index].firebaseName}/max')
                                .onValue,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  !snapshot.hasError &&
                                  snapshot.data!.snapshot.value != null) {
                                listMode6info[index].value =
                                    snapshot.data!.snapshot.value;
                                return Center(
                                  child: Text(
                                    '${listMode6info[index].value}',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                );
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                            },
                          ),
                        )),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
