import 'package:akilli_anahtar/controllers/admin/user_management_control.dart';
import 'package:akilli_anahtar/entities/box.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BoxSelectWidget extends StatefulWidget {
  const BoxSelectWidget({super.key});

  @override
  State<BoxSelectWidget> createState() => _BoxSelectWidgetState();
}

class _BoxSelectWidgetState extends State<BoxSelectWidget> {
  UserManagementController userManagementControl = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return userManagementControl.boxes.isEmpty
          ? CircularProgressIndicator()
          : SizedBox(
              height: 60,
              child: DropdownSearch<Box>(
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(
                    hintText: "Kutu Seç",
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                ),
                items: (filter, loadProps) {
                  return userManagementControl.filteredBoxes;
                },
                selectedItem: userManagementControl.filteredBoxes
                    .firstWhereOrNull((o) =>
                        o.id == userManagementControl.selectedBoxId.value),
                itemAsString: (item) => item.name,
                onChanged: (value) {
                  if (value != null) {
                    userManagementControl.selectedBoxId.value = value.id;
                    userManagementControl.filterDevices();
                  }
                },
                filterFn: (item, filter) {
                  return item.name.toLowerCase().contains(filter.toLowerCase());
                },
                compareFn: (item1, item2) {
                  return item1.id == item2.id;
                },
                dropdownBuilder: (context, selectedItem) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          selectedItem != null ? selectedItem.name : "Kutu Seç",
                          style: TextStyle(
                            color: selectedItem != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                      if (selectedItem != null)
                        IconButton(
                          padding: EdgeInsets.only(bottom: 10),
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            userManagementControl.selectedBoxId.value = 0;
                            userManagementControl.filterDevices();
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
