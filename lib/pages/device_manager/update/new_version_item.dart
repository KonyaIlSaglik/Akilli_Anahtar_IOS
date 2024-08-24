import 'package:akilli_anahtar/controllers/update_controller.dart';
import 'package:akilli_anahtar/entities/box.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class NewVersionItem extends StatefulWidget {
  final Box box;
  const NewVersionItem({
    Key? key,
    required this.box,
  }) : super(key: key);

  @override
  State<NewVersionItem> createState() => _NewVersionItemState();
}

class _NewVersionItemState extends State<NewVersionItem> {
  UpdateController updateController = Get.find<UpdateController>();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        FontAwesomeIcons.solidHardDrive,
        color: Colors.blue,
        size: 30,
      ),
      title: Text(widget.box.name),
      subtitle: Row(
        children: [
          Text("Version: ${widget.box.version}"),
          Text(
            " (Sürüm Güncel)",
          )
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.done,
          color: Colors.green,
        ),
        onPressed: () {
          //
        },
      ),
    );
  }
}
