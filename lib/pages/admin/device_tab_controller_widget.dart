import 'package:akilli_anahtar/pages/admin/relay_list_view_widget.dart';
import 'package:akilli_anahtar/pages/admin/sensor_list_view_widget.dart';
import 'package:flutter/material.dart';

class DeviceTabControllerWidget extends StatelessWidget {
  const DeviceTabControllerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                text: "Röleler",
              ),
              Tab(
                text: "Sensörler",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            RelayListViewWidget(),
            SensorListViewWidget(),
          ],
        ),
      ),
    );
  }
}
