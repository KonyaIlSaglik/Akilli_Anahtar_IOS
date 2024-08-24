import 'package:akilli_anahtar/controllers/update_controller.dart';
import 'package:akilli_anahtar/entities/box.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class OldVersionItem extends StatefulWidget {
  final Box box;
  final Function() onPressed;
  final bool upgrading;
  const OldVersionItem({
    Key? key,
    required this.box,
    required this.onPressed,
    this.upgrading = false,
  }) : super(key: key);

  @override
  State<OldVersionItem> createState() => _OldVersionItemState();
}

class _OldVersionItemState extends State<OldVersionItem> {
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
            " (Yeni sürüm mevcut: ${updateController.newVersion})",
            style: TextStyle(
              color: Colors.red,
            ),
          )
        ],
      ),
      trailing: widget.upgrading
          ? IconButton(
              icon: Icon(
                Icons.update,
                color: Colors.blue,
              ),
              onPressed: () {
                //
              },
            )
          : IconButton(
              icon: Icon(
                Icons.upload_outlined,
                color: Colors.red,
              ),
              onPressed: widget.onPressed,
            ),
    );
  }
}
