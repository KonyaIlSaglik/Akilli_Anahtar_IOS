import 'package:akilli_anahtar/models/box_with_devices.dart';
import 'package:flutter/material.dart';

class UserDevicesPage extends StatefulWidget {
  const UserDevicesPage({Key? key}) : super(key: key);

  @override
  State<UserDevicesPage> createState() => _UserDevicesPageState();
}

class _UserDevicesPageState extends State<UserDevicesPage> {
  List<BoxWithDevices> boxes = List.empty();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SizedBox(
      width: width * 0.80,
      height: height * 0.60,
      child: ListView.separated(
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: boxes.length,
        itemBuilder: ((context, i) {
          return ExpansionTile(
            title: Text(boxes[i].box!.name),
            children: boxes[i]
                .sensors!
                .map(
                  (e) => ListTile(
                    title: Text(e.name),
                  ),
                )
                .toList(),
          );
        }),
      ),
    );
  }
}
