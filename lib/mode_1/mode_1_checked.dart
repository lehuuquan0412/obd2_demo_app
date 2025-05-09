import 'package:app_chan_doan/connection_manage.dart';
import 'package:app_chan_doan/mode_1/mode_1_chart.dart';
import 'package:app_chan_doan/mode_obj_info.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Checked extends StatelessWidget {
  const Checked({super.key, required this.checkedValue});

  final List<ModeObjInfo> checkedValue;

  @override
  Widget build(BuildContext context) {
    List<ModeObjInfo> temp =
        List.from(checkedValue.where((element) => element.status));
    final databaseRef = FirebaseDatabase.instance.ref();

    return ListView.separated(
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
                            .child('$verifyId${temp[index].firebaseName}')
                            .onValue,
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              !snapshot.hasError &&
                              snapshot.data!.snapshot.value != null) {
                            temp[index].value = snapshot.data!.snapshot.value;
                            return Text(
                              '${temp[index].value}',
                              style: const TextStyle(
                                  fontSize: 17,
                                  color: Color.fromARGB(255, 10, 90, 160)),
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
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
