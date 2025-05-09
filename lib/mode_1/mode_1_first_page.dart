import 'package:app_chan_doan/mode_1/mode_1_second_page.dart';
import 'package:flutter/material.dart';
import 'package:app_chan_doan/mode_1/mode_1_list_check.dart';
import 'package:app_chan_doan/mode_obj_info.dart';
import 'package:app_chan_doan/mqtt.dart';

class Mode1FirstPage extends StatefulWidget {
  const Mode1FirstPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Mode1FirstPageState();
  }
}

class _Mode1FirstPageState extends State<Mode1FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đọc dữ liệu của xe'),
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
            for (var item in listMode1info) {
              item.status = false;
            }
            Navigator.of(context).pop();
          },
          child: BackButton(
            color: Colors.black,
            onPressed: () {
              mqtt.publish('{"mode":0}');
              for (var item in listMode1info) {
                item.status = false;
              }
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListCheck(
              checkboxValue: listMode1info,
            ),
          ),
          Row(
            children: [
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    for (var item in listMode1info) {
                      item.status = true;
                    }
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Chọn tất cả'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    for (var item in listMode1info) {
                      item.status = false;
                    }
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Hủy tất cả'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  int value = 0;
                  for (var item in listMode1info) {
                    if (item.status) {
                      value |= (1 << item.priStat1);
                    }
                  }
                  mqtt.publish('{"mode":1,"value":$value}');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Mode1SecondPage(b: listMode1info)));
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
