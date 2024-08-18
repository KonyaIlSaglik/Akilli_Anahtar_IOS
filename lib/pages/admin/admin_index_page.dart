import 'package:flutter/material.dart';

class AdminIndexPage extends StatefulWidget {
  const AdminIndexPage({Key? key}) : super(key: key);

  @override
  State<AdminIndexPage> createState() => _AdminIndexPageState();
}

class _AdminIndexPageState extends State<AdminIndexPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Admin işlemleri"),
    );
  }
}
