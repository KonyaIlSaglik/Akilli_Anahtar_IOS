import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () async {
            var uri = Uri.parse("https://www.ossbs.com");
            if (await canLaunchUrl(uri)) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Image.asset("assets/anahtar1.png"),
        ),
      ],
    );
  }
}
