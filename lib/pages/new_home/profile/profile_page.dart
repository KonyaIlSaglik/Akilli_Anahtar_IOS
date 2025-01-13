import 'package:akilli_anahtar/background_service.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var text = "-";

  @override
  void initState() {
    super.initState();
    isRunning().then(
      (value) {
        setState(() {
          text = value ? "KAPAT" : "AÇ";
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text("Arka Planda Çalışsın"),
          trailing: TextButton(
              onPressed: () async {
                var status = await isRunning();
                if (status) {
                  stopBackgroundService();
                  setState(() {
                    text = "AÇ";
                  });
                } else {
                  await initializeService();
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
