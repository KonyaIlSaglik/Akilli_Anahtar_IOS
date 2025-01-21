import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DeviceListViewItemBackIcon extends StatelessWidget {
  final int typeId;
  const DeviceListViewItemBackIcon({
    super.key,
    required this.typeId,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.2,
      child: typeId == 1
          ? Icon(
              FontAwesomeIcons.temperatureHigh,
              size: 40,
            )
          : typeId == 2
              ? Icon(
                  FontAwesomeIcons.droplet,
                  size: 40,
                )
              : typeId == 3
                  ? Icon(
                      FontAwesomeIcons.volcano,
                      size: 40,
                    )
                  : typeId == 4 || typeId == 6
                      ? Icon(
                          FontAwesomeIcons.roadBarrier,
                          size: 40,
                        )
                      : typeId == 5
                          ? RotatedBox(
                              quarterTurns: 2,
                              child: Icon(
                                FontAwesomeIcons.lightbulb,
                                size: 40,
                              ),
                            )
                          : typeId == 8
                              ? Icon(
                                  FontAwesomeIcons.faucetDrip,
                                  size: 40,
                                )
                              : null,
    );
  }
}
