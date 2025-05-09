import 'package:app_chan_doan/connection_manage.dart';
import 'package:app_chan_doan/mode_1/mode_1_chart.dart';
import 'package:app_chan_doan/mode_4/mode_4_first_page.dart';
import 'package:app_chan_doan/mode_4/mode_4_livedata.dart';
import 'package:app_chan_doan/mode_obj_info.dart';
import 'package:flutter/material.dart';
import 'package:app_chan_doan/mqtt.dart';
import 'package:firebase_database/firebase_database.dart';

List<String> status = ['Hoàn thành', 'Đang xử lý'];

class Mode4SecondPage extends StatelessWidget {
  const Mode4SecondPage({
    super.key,
    required this.mode4ActInfo,
    required this.streamDataMonitor,
  });

  final ModeObjInfo mode4ActInfo;
  final List<ModeObjInfo> streamDataMonitor;

  @override
  Widget build(BuildContext context) {
    List<ModeObjInfo> temp =
        List.from(streamDataMonitor.where((element) => element.status));
    final databaseRef = FirebaseDatabase.instance.ref();
    if (mode4ActInfo.priStat1 == 0x10) {
      return Scaffold(
        appBar: AppBar(
          title: Text(mode4ActInfo.name),
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
              for (var item in streamDataMonitor) {
                item.status = false;
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Mode4FirstPage()));
            },
            child: BackButton(
              color: Colors.black,
              onPressed: () {
                mqtt.publish('{"mode":0}');
                for (var item in streamDataMonitor) {
                  item.status = false;
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Mode4FirstPage()));
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
            const SizedBox(width: 20),
            Row(
              children: [
                const SizedBox(width: 18),
                const Text(
                  'Trạng thái:',
                  style: TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 20, 50, 220)),
                ),
                const Spacer(),
                StreamBuilder(
                  stream: databaseRef
                      .child('$verifyId${mode4ActInfo.firebaseName}')
                      .onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        !snapshot.hasError &&
                        snapshot.data!.snapshot.value != null) {
                      mode4ActInfo.value = snapshot.data!.snapshot.value;
                      return Text(
                        status[((mode4ActInfo.value + 255) / 256).toInt()],
                        style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 20, 50, 220)),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                const SizedBox(width: 18),
              ],
            ),
            const SizedBox(width: 20),
            const Divider(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: temp.length,
                itemBuilder: (BuildContext context, int index) {
                  if (temp[index].status) {
                    return Row(
                      children: [
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(temp[index].name),
                            Row(
                              children: [
                                StreamBuilder(
                                  stream: databaseRef
                                      .child(
                                          '$verifyId${temp[index].firebaseName}')
                                      .onValue,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        !snapshot.hasError &&
                                        snapshot.data!.snapshot.value != null) {
                                      temp[index].value =
                                          snapshot.data!.snapshot.value;
                                      return Text(
                                        '${temp[index].value}',
                                        style: const TextStyle(
                                            fontSize: 17,
                                            color: Color.fromARGB(
                                                255, 10, 90, 160)),
                                      );
                                    } else {
                                      return const CircularProgressIndicator();
                                    }
                                  },
                                ),
                                const SizedBox(width: 20),
                                Text(temp[index].unit,
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChartWidget(chartValue: temp[index]))),
                            icon: const Icon(Icons.add_chart))
                      ],
                    );
                  }
                  return null;
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              ),
            ),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Mode4Livedata(
                              mode4Info: mode4ActInfo,
                              checkboxValue: streamDataMonitor))),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Thông số'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    mqtt.publish(
                        '{"mode":${mode4ActInfo.mode},"value":${mode4ActInfo.priStat1},"key":${mode4ActInfo.priStat2}}');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ngắt'),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(mode4ActInfo.name),
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
              for (var item in streamDataMonitor) {
                item.status = false;
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Mode4FirstPage()));
            },
            child: BackButton(
              color: Colors.black,
              onPressed: () {
                mqtt.publish('{"mode":0}');
                for (var item in streamDataMonitor) {
                  item.status = false;
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Mode4FirstPage()));
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
            const SizedBox(width: 20),
            Row(
              children: [
                const SizedBox(width: 18),
                const Text(
                  'Trạng thái:',
                  style: TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 20, 50, 220)),
                ),
                const Spacer(),
                StreamBuilder(
                  stream: databaseRef
                      .child('$verifyId${mode4ActInfo.firebaseName}')
                      .onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        !snapshot.hasError &&
                        snapshot.data!.snapshot.value != null) {
                      mode4ActInfo.value = snapshot.data!.snapshot.value;
                      return Text(
                        status[((mode4ActInfo.value + 255) / 256).toInt()],
                        style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 20, 50, 220)),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                const SizedBox(width: 18),
              ],
            ),
            const SizedBox(width: 20),
            const Divider(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                itemCount: temp.length,
                itemBuilder: (BuildContext context, int index) {
                  if (temp[index].status) {
                    return Row(
                      children: [
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(temp[index].name),
                            Row(
                              children: [
                                StreamBuilder(
                                  stream: databaseRef
                                      .child(
                                          '$verifyId${temp[index].firebaseName}')
                                      .onValue,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        !snapshot.hasError &&
                                        snapshot.data!.snapshot.value != null) {
                                      temp[index].value =
                                          snapshot.data!.snapshot.value;
                                      return Text(
                                        '${temp[index].value}',
                                        style: const TextStyle(
                                            fontSize: 17,
                                            color: Color.fromARGB(
                                                255, 10, 90, 160)),
                                      );
                                    } else {
                                      return const CircularProgressIndicator();
                                    }
                                  },
                                ),
                                const SizedBox(width: 20),
                                Text(temp[index].unit,
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChartWidget(chartValue: temp[index]))),
                            icon: const Icon(Icons.add_chart))
                      ],
                    );
                  }
                  return null;
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              ),
            ),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Mode4Livedata(
                              mode4Info: mode4ActInfo,
                              checkboxValue: streamDataMonitor))),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Thông số'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    mqtt.publish(
                        '{"mode":${mode4ActInfo.mode},"value":${mode4ActInfo.priStat1},"key":1}');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Bật'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    mqtt.publish(
                        '{"mode":${mode4ActInfo.mode},"value":${mode4ActInfo.priStat1},"key":0}');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tắt'),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      );
    }
  }
}
