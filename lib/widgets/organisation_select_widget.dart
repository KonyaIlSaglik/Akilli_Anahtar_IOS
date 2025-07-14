import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class OrganisationSelectWidget extends StatefulWidget {
  final List<Organisation> list;
  final int selectedId;
  final Function(int id) onChanged;
  final String? Function(Organisation?)? validator;

  const OrganisationSelectWidget(
      {super.key,
      required this.list,
      required this.onChanged,
      this.selectedId = 0,
      this.validator});

  @override
  State<OrganisationSelectWidget> createState() =>
      _OrganisationSelectWidgetState();
}

class _OrganisationSelectWidgetState extends State<OrganisationSelectWidget> {
  HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<Organisation>(
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: "Kurum Seç",
          labelStyle: TextStyle(color: goldColor),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: goldColor,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
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
        return widget.list;
      },
      selectedItem: widget.selectedId > 0
          ? widget.list.firstWhereOrNull((o) => o.id == widget.selectedId)
          : null,
      itemAsString: (item) => item.name!,
      onChanged: (value) {
        widget.onChanged(value?.id ?? 0);
      },
      filterFn: (item, filter) {
        return item.name!.toLowerCase().contains(filter.toLowerCase());
      },
      suffixProps: DropdownSuffixProps(
        clearButtonProps: ClearButtonProps(
          isVisible: true,
        ),
      ),
      compareFn: (item1, item2) {
        return item1.id == item2.id;
      },
      dropdownBuilder: (context, selectedItem) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedItem != null ? selectedItem.name! : "",
                style: TextStyle(
                  color: selectedItem != null ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
      validator: widget.validator,
    );
  }
}
