import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:akilli_anahtar/utils/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomDeviceCard extends StatefulWidget {
  final String title;
  final String status;
  final String? unit;
  final IconData iconData;
  final Color iconColor;
  const CustomDeviceCard({
    super.key,
    required this.title,
    required this.status,
    this.unit,
    required this.iconData,
    required this.iconColor,
  });

  @override
  State<CustomDeviceCard> createState() => _CustomDeviceCardState();
}

class _CustomDeviceCardState extends State<CustomDeviceCard> {
  bool positive = false;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width(context) * 0.45,
      height: width(context) * 0.45,
      child: Card.outlined(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    widget.iconData,
                    shadows: <Shadow>[
                      Shadow(color: widget.iconColor, blurRadius: 15.0)
                    ],
                    size: width(context) * 0.07,
                    color: Colors.white70,
                  ),
                  if (widget.unit != null)
                    Text(
                      widget.unit ?? "",
                      style: textTheme(context).titleLarge,
                    ),
                ],
              ),
              SizedBox(height: 20),
              if (widget.status == "1") _switch(),
              if (widget.status != "1")
                Text(
                  widget.status,
                  style: textTheme(context).displaySmall,
                ),
              SizedBox(height: 20),
              Text(
                widget.title,
                style: textTheme(context).titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _switch() {
    return AnimatedToggleSwitch<bool>.dual(
      current: positive,
      first: false,
      second: true,
      spacing: 0.0,
      loading: loading,
      animationDuration: const Duration(milliseconds: 600),
      style: const ToggleStyle(
        borderColor: Colors.transparent,
        indicatorColor: Colors.white,
        backgroundColor: Colors.amber,
      ),
      customStyleBuilder: (context, local, global) => ToggleStyle(
        backgroundColor: positive ? Colors.green : Colors.red,
      ),
      height: width(context) * 0.12,
      loadingIconBuilder: (context, global) => CupertinoActivityIndicator(
          color: Color.lerp(Colors.blue, Colors.blue, global.spacing)),
      active: !positive && !loading,
      onChanged: (b) async {
        setState(() {
          positive = true;
          loading = true;
        });

        await Future<dynamic>.delayed(const Duration(seconds: 5));

        setState(() {
          positive = true;
          loading = false;
        });

        await Future<dynamic>.delayed(const Duration(seconds: 5));

        setState(() {
          positive = false;
          loading = true;
        });

        await Future<dynamic>.delayed(const Duration(seconds: 5));

        setState(() {
          positive = false;
          loading = false;
        });
      },
      iconBuilder: (value) => value
          ? const Icon(
              FontAwesomeIcons.powerOff,
              color: Colors.green,
              size: 32.0,
            )
          : const Icon(
              FontAwesomeIcons.powerOff,
              color: Colors.red,
              size: 32.0,
            ),
    );
  }
}
