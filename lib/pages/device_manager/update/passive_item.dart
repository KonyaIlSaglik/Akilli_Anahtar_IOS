import 'package:akilli_anahtar/entities/box.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PassiveItem extends StatefulWidget {
  final Box box;
  final Function() onPressed;
  const PassiveItem({
    Key? key,
    required this.box,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<PassiveItem> createState() => _PassiveItemState();
}

class _PassiveItemState extends State<PassiveItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        FontAwesomeIcons.hardDrive,
        color: Colors.grey,
        size: 30,
      ),
      title: Text(widget.box.name),
      subtitle: Text("Bağlı değil"),
      trailing: IconButton(
        icon: Icon(
          Icons.refresh,
        ),
        onPressed: widget.onPressed,
      ),
    );
  }
}
