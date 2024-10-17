import 'package:akilli_anahtar/pages/admin/box_select_widget.dart';
import 'package:akilli_anahtar/pages/admin/device_list_view_widget.dart';
import 'package:akilli_anahtar/pages/admin/organisation_select_widget.dart';
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
          isScrollControlled: true, // Allows for scrolling if content is large
          builder: (context) {
            return SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.95, // Makes it responsive
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Optional padding
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Wraps content
                  children: [
                    // Title for the modal
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
                            Navigator.pop(context); // Closes the modal
                          },
                        ),
                      ],
                    ),
                    Divider(), // Optional divider for separation
                    OrganisationSelectWidget(),
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
