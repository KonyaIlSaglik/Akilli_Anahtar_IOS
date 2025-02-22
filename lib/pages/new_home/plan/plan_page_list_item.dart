import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlanPageListItem extends StatefulWidget {
  const PlanPageListItem({super.key});

  @override
  State<PlanPageListItem> createState() => _PlanPageListItemState();
}

class _PlanPageListItemState extends State<PlanPageListItem> {
  bool isSwitched = true;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10, left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Box Adı - Bileşen Adı",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                InkWell(
                  child: Icon(FontAwesomeIcons.pen, size: 18),
                  onTap: () {
                    //
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Başlangıç: 22.02.2025 10:00:00"),
                Text("Süre: 1 Saat"),
                Text("Tekrar: Her Gün"),
              ],
            ),
            trailing: Switch(
              activeColor: goldColor,
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
