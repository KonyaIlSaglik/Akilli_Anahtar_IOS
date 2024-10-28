import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/widgets/custom_device_card.dart';
import 'package:flutter/material.dart';

class HorizontalList extends StatefulWidget {
  final String listTitle;
  final Function() titleOnPressed;
  final List<CustomDeviceCard> items;
  const HorizontalList({
    super.key,
    required this.listTitle,
    required this.titleOnPressed,
    required this.items,
  });

  @override
  State<HorizontalList> createState() => _HorizontalListState();
}

class _HorizontalListState extends State<HorizontalList> {
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
              child: Text("Tümü"),
            ),
          ],
        ),
        SizedBox(
          height: height(context) * 0.20,
          child: GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
            ),
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: widget.items,
          ),
        ),
      ],
    );
  }
}
