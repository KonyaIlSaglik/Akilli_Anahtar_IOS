import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class BahceSuTankCard extends StatelessWidget {
  final double value;
  final double top;
  const BahceSuTankCard({Key? key, this.value = 0, this.top = 100})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: LiquidLinearProgressIndicator(
        backgroundColor: goldColor,
        direction: Axis.vertical,
        valueColor: AlwaysStoppedAnimation(Colors.blue.withOpacity(0.7)),
        value: value / top,
        borderRadius: 5,
        borderColor: Colors.transparent,
        borderWidth: 1,
        center: Column(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(height: 0),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Icon(
                      FontAwesomeIcons.water,
                      color: Colors.white,
                      size: Theme.of(context).iconTheme.size,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Depo",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .fontSize),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 15,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).textTheme.headlineLarge!.fontSize,
                    ),
                  ),
                  Text(
                    "Litre",
                    style: TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).textTheme.headlineLarge!.fontSize,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                "${top.toInt()} lt",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
