import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/controllers/home_controller.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrganisationSelectWidget extends StatefulWidget {
  final Function() onChanged;

  const OrganisationSelectWidget({super.key, required this.onChanged});

  @override
  State<OrganisationSelectWidget> createState() =>
      _OrganisationSelectWidgetState();
}

class _OrganisationSelectWidgetState extends State<OrganisationSelectWidget> {
  HomeController homeControl = Get.find();
  AuthController authController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SizedBox(
        height: 60,
        child: DropdownSearch<Organisation>(
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: "Kurum Seç",
              border: OutlineInputBorder(),
              // The suffix icon can be added to the decoration directly
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
          ),
          items: (filter, loadProps) {
            return authController.organisations;
          },
          selectedItem: authController.organisations.firstWhereOrNull(
              (o) => o.id == homeControl.selectedOrganisationId.value),
          itemAsString: (item) => item.name,
          onChanged: (value) {
            if (value != null) {
              homeControl.selectedOrganisationId.value = value.id;
              widget.onChanged();
            }
          },
          filterFn: (item, filter) {
            return item.name.toLowerCase().contains(filter.toLowerCase());
          },
          compareFn: (item1, item2) {
            return item1.id == item2.id; // Compare based on the unique ID
          },
          // Add a clear button in the dropdown menu
          dropdownBuilder: (context, selectedItem) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedItem != null ? selectedItem.name : "",
                    style: TextStyle(
                        color:
                            selectedItem != null ? Colors.black : Colors.grey),
                  ),
                ),
                if (selectedItem != null)
                  IconButton(
                    padding: EdgeInsets.only(bottom: 10),
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      // Clear selection
                      homeControl.selectedOrganisationId.value = 0;
                      widget.onChanged();
                    },
                  ),
              ],
            );
          },
        ),
      );
    });
  }
}
