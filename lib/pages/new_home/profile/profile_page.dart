import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var text = "-";
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text("Arka Planda Çalışsın"),
          trailing: TextButton(
              onPressed: () async {
                final service = FlutterBackgroundService();
                var status = await service.isRunning();
                if (status) {
                  service.invoke("stop");
                  setState(() {
                    text = "AÇ";
                  });
                } else {
                  service.startService();
                  setState(() {
                    text = "KAPAT";
                  });
                }
              },
              child: Text(text)),
        ),
      ],
    );
  }
}
