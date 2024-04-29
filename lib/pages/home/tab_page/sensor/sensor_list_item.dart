import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';

class SensorListItem extends StatelessWidget {
  final int? id;
  final String? adi;
  final String? kurum;
  final String? durum;
  final String? deger;
  final String? birim;
  final int? baglanti;
  const SensorListItem({
    Key? key,
    this.id,
    this.adi,
    this.kurum,
    this.durum,
    this.deger,
    this.birim,
    this.baglanti,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: mainColor,
        child: Row(
          children: [
            Card(
              color: baglanti == 1 ? Colors.green : Colors.red,
              child: SizedBox(
                width: 15,
                height: 100,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    adi!,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                  // Text(
                  //   kurum!,
                  //   style: TextStyle(color: Colors.white),
                  // ),
                  Text(
                    "Durum: $durum",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${deger!} ${birim!}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
