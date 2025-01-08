import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrganisationSelectWidget extends StatefulWidget {
  final Function(int id) onChanged;

  const OrganisationSelectWidget({super.key, required this.onChanged});

  @override
  State<OrganisationSelectWidget> createState() =>
      _OrganisationSelectWidgetState();
}

class _OrganisationSelectWidgetState extends State<OrganisationSelectWidget> {
  HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SizedBox(
        height: 60,
        child: DropdownSearch<Organisation>(
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: "Kurum Seç",
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  style: BorderStyle.solid,
                  color: goldColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  style: BorderStyle.solid,
                  color: goldColor,
                ),
              ),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
          ),
          items: (filter, loadProps) {
            return homeController.organisations;
          },
          selectedItem: homeController.organisations.firstWhereOrNull(
              (o) => o.id == homeController.selectedOrganisationId.value),
          itemAsString: (item) => item.name,
          onChanged: (value) {
            if (value != null) {
              homeController.selectedOrganisationId.value = value.id;
              widget.onChanged(value.id);
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
                      homeController.selectedOrganisationId.value = 0;
                      widget.onChanged(0);
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
