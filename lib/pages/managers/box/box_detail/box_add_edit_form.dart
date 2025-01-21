import 'package:akilli_anahtar/controllers/admin/box_management_controller.dart';
import 'package:akilli_anahtar/dtos/bm_box_dto.dart';
import 'package:akilli_anahtar/dtos/bm_organisation_dto.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/utils/validate_listener.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BoxAddEditForm extends StatefulWidget {
  final BmBoxDto? box;
  const BoxAddEditForm({super.key, this.box});

  @override
  State<BoxAddEditForm> createState() => _BoxAddEditFormState();
}

class _BoxAddEditFormState extends State<BoxAddEditForm>
    implements ValidateListener {
  BoxManagementController boxManagementController = Get.find();
  final _formKey = GlobalKey<FormState>();

  late BmBoxDto box;

  @override
  void initState() {
    super.initState();
    box = widget.box ?? BmBoxDto();
  }

  void _saveBox() async {
    if (_formKey.currentState!.validate()) {
      if (box.id == null) {
        //await boxManagementController.register(box);
      } else {
        // await boxManagementController.updateBox(box);
      }
    }
  }

  organisationSelect() {
    return SizedBox(
      height: height(context) * 0.07,
      child: DropdownSearch<BmOrganisationDto>(
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(left: 10),
            labelText: "Kurum Seç",
            labelStyle:
                textTheme(context).labelSmall!.copyWith(color: goldColor),
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
          return boxManagementController.organisationList;
        },
        selectedItem: box.id != null
            ? boxManagementController.organisationList.singleWhere(
                (o) => o.id == box.organisationId,
              )
            : null,
        itemAsString: (item) => item.name!,
        onChanged: (value) => box.organisationId = value?.id,
        filterFn: (item, filter) {
          return item.name!.toLowerCase().contains(filter.toLowerCase());
        },
        compareFn: (item1, item2) {
          return item1.id == item2.id;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: height(context) * 0.02),
                organisationSelect(),
                SizedBox(height: 8),
                textFormField(context, 0,
                    initialValue: box.name,
                    onChanged: (value) => setState(() => box.name = value),
                    labelText: "Kutu Adı"),
                SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: width * 0.45,
                      child: textFormField(context, 0,
                          initialValue: box.chipId?.toString() ?? "",
                          onChanged: (value) =>
                              setState(() => box.chipId = int.tryParse(value)),
                          labelText: "Chip Id"),
                    ),
                    SizedBox(
                      width: width * 0.40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Kutu Aktif"),
                          Checkbox(
                            activeColor: goldColor,
                            value: box.active == 1,
                            onChanged: (value) {
                              setState(() {
                                box.active = value! ? 1 : 0;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                textFormField(context, 0,
                    initialValue: box.restartTimeout?.toString() ?? "",
                    onChanged: (value) => setState(
                        () => box.restartTimeout = int.tryParse(value)),
                    labelText: "Yeniden Başlatma Süresi (dk)"),
                // SizedBox(height: 8),
                // TextFormField(
                //   decoration: InputDecoration(labelText: 'Topic Rec'),
                //   initialValue: topicRec,
                //   enabled: false,
                // ),
                // SizedBox(height: 8),
                // TextFormField(
                //   decoration: InputDecoration(labelText: 'Topic Res'),
                //   initialValue: topicRes,
                //   enabled: false,
                // ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    _saveBox();
                  },
                  child: SizedBox(
                    height: height(context) * 0.06,
                    width: width * 0.50,
                    child: Card(
                      elevation: 5,
                      color: goldColor.withOpacity(0.7),
                      child: Center(
                        child: Text(
                          "Kaydet",
                          style: textTheme(context)
                              .titleLarge!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget textFormField(
    BuildContext context,
    int formIndex, {
    TextEditingController? controller,
    String? labelText,
    String? initialValue,
    void Function(String)? onChanged,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    Widget? suffix,
  }) {
    return SizedBox(
      height: height(context) * 0.07,
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme:
              TextSelectionThemeData(selectionHandleColor: goldColor),
        ),
        child: TextFormField(
          controller: controller,
          cursorColor: goldColor,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle:
                textTheme(context).labelMedium!.copyWith(color: goldColor),
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
            suffix: suffix,
          ),
          initialValue: initialValue,
          style: textTheme(context).titleSmall,
          onChanged: onChanged,
          validator: (value) {
            return validate(formIndex, value);
          },
          focusNode: focusNode,
          textInputAction:
              nextFocus == null ? TextInputAction.done : TextInputAction.next,
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(nextFocus);
          },
        ),
      ),
    );
  }

  @override
  String? validate(int formIndex, String? value) {
    //late var actions = <String>["save", "saveAs", "update", "passUpdate"];
    print("$formIndex : $value");
    if (value == null || value.isEmpty) {
      if (formIndex == 0) return "Kulanıcı adı boş olamaz";
      if (formIndex == 1) return "Ad soyad boş olamaz";
      if (formIndex == 3 || formIndex == 4) return null;
      if (formIndex == 2) {
        //
      }
    } else {
      //
    }
    return null;
  }
}
