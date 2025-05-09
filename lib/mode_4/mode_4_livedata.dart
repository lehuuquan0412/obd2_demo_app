import 'package:app_chan_doan/mode_4/mode_4_second_page.dart';
import 'package:app_chan_doan/mode_obj_info.dart';
import 'package:app_chan_doan/mqtt.dart';
import 'package:flutter/material.dart';

class ListCheck extends StatefulWidget {
  const ListCheck(
      {super.key, required this.checkboxValue, required this.mode4Info});

  final List<ModeObjInfo> checkboxValue;
  final ModeObjInfo mode4Info;

  @override
  State<ListCheck> createState() {
    return _ListCheckState();
  }
}

class _ListCheckState extends State<ListCheck> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: widget.checkboxValue.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 50,
          color: Colors.white,
          child: CheckboxListTile(
            title: Text(widget.checkboxValue[index].name),
            value: widget.checkboxValue[index].status,
            onChanged: (bool? value) {
              setState(() {
                widget.checkboxValue[index].status = value!;
              });
            },
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}

class Mode4Livedata extends StatefulWidget {
  const Mode4Livedata(
      {super.key, required this.mode4Info, required this.checkboxValue});

  final ModeObjInfo mode4Info;
  final List<ModeObjInfo> checkboxValue;

  @override
  State<StatefulWidget> createState() {
    return _Mode4LivedataState();
  }
}

class _Mode4LivedataState extends State<Mode4Livedata> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode4Info.name),
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListCheck(
              checkboxValue: widget.checkboxValue,
              mode4Info: widget.mode4Info,
            ),
          ),
          Row(
            children: [
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    for (var item in widget.checkboxValue) {
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
                    for (var item in widget.checkboxValue) {
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
                  for (var item in widget.checkboxValue) {
                    if (item.status) {
                      value |= (1 << item.priStat1);
                    }
                  }
                  mqtt.publish('{"mode":1,"value":$value}');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Mode4SecondPage(
                              mode4ActInfo: widget.mode4Info,
                              streamDataMonitor: widget.checkboxValue)));
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
