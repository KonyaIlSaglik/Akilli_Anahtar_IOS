import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_device_card.dart';
import 'package:flutter/material.dart';

class VerticalList extends StatefulWidget {
  final String listTitle;
  final Function() titleOnPressed;
  final List<CustomDeviceCard> items;
  const VerticalList({
    super.key,
    required this.listTitle,
    required this.titleOnPressed,
    required this.items,
  });

  @override
  State<VerticalList> createState() => _VerticalListState();
}

class _VerticalListState extends State<VerticalList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.listTitle,
              style: textTheme(context).titleMedium,
            ),
            TextButton(
              onPressed: widget.titleOnPressed,
              child: Text("Düzenle"),
            ),
          ],
        ),
        SizedBox(
          height: height(context) * 0.40,
          child: GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            clipBehavior: Clip.none,
            children: widget.items,
          ),
        ),
      ],
    );
  }
}
