import 'package:akilli_anahtar/pages/user_manager/box_select_widget.dart';
import 'package:akilli_anahtar/widgets/organisation_select_widget.dart';
import 'package:akilli_anahtar/pages/user_manager/device_list_view_widget.dart';
import 'package:flutter/material.dart';

class UserDeviceClaimWidget extends StatefulWidget {
  const UserDeviceClaimWidget({super.key});

  @override
  State<UserDeviceClaimWidget> createState() => _UserDeviceClaimWidgetState();
}

class _UserDeviceClaimWidgetState extends State<UserDeviceClaimWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Cihaz Yetkileri"),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.95,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Cihaz Yetkileri",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    Divider(),
                    OrganisationSelectWidget(
                      onChanged: () {},
                    ),
                    SizedBox(height: 8),
                    BoxSelectWidget(),
                    SizedBox(height: 8),
                    Expanded(
                      child: DeviceListViewWidget(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
