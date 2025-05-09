import 'package:app_chan_doan/mode_obj_info.dart';
import 'package:flutter/material.dart';

class ListCheck extends StatefulWidget {
  const ListCheck({super.key, required this.checkboxValue});

  final List<ModeObjInfo> checkboxValue;

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
