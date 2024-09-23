import 'package:akilli_anahtar/controllers/claim_controller.dart';
import 'package:akilli_anahtar/controllers/user_controller.dart';
import 'package:akilli_anahtar/entities/box.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BoxSelectWidget extends StatefulWidget {
  const BoxSelectWidget({Key? key}) : super(key: key);

  @override
  State<BoxSelectWidget> createState() => _BoxSelectWidgetState();
}

class _BoxSelectWidgetState extends State<BoxSelectWidget> {
  UserController userController = Get.find();
  ClaimController claimController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return claimController.boxes.isEmpty
          ? CircularProgressIndicator()
          : SizedBox(
              height: 60,
              child: DropdownSearch<Box>(
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    hintText: "Kutu Seç",
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                ),
                items: claimController.filteredBoxes,
                selectedItem: claimController.filteredBoxes.firstWhereOrNull(
                    (o) => o.id == claimController.selectedBoxId.value),
                itemAsString: (item) => item.name,
                onChanged: (value) {
                  if (value != null) {
                    claimController.selectedBoxId.value = value.id;
                    claimController.filterRelays();
                    claimController.filterSensors();
                    // No need for setState() if using GetX
                  }
                },
                filterFn: (item, filter) {
                  return item.name.toLowerCase().contains(filter.toLowerCase());
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
                      if (selectedItem !=
                          null) // Show clear button if an item is selected
                        IconButton(
                          padding: EdgeInsets.only(bottom: 10),
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            // Clear selection
                            claimController.selectedBoxId.value =
                                0; // Resetting the selected ID
                            claimController
                                .filterRelays(); // Optionally re-filter relays
                            claimController
                                .filterSensors(); // Optionally re-filter sensors
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
