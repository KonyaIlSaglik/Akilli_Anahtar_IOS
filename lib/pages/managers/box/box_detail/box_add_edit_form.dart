import 'package:akilli_anahtar/controllers/admin/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/admin/device_management_controller.dart';
import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/utils/validate_listener.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BoxAddEditForm extends StatefulWidget {
  const BoxAddEditForm({super.key});

  @override
  State<BoxAddEditForm> createState() => _BoxAddEditFormState();
}

class _BoxAddEditFormState extends State<BoxAddEditForm>
    implements ValidateListener {
  BoxManagementController boxManagementController = Get.find();
  late DeviceManagementController deviceManagementController = Get.find();
  MqttController mqttController = Get.find();
  HomeController homeController = Get.find();
  final _formKey = GlobalKey<FormState>();
  late String boxName;
  late String chipId;
  late String topicRec;
  late String topicRes;
  late bool active;
  late String version;
  late int organisationId;
  late String restartTimeOut;

  @override
  void initState() {
    super.initState();

    boxName = "";
    chipId = "";
    topicRec = "";
    topicRes = "";
    active = true;
    version = "";
    organisationId = Get.find<AuthController>().user.value.organisationId;
    restartTimeOut = "";
    if (boxManagementController.selectedBox.value.id > 0) {
      boxName = boxManagementController.selectedBox.value.name;
      chipId = boxManagementController.selectedBox.value.chipId.toString();
      topicRec = boxManagementController.selectedBox.value.topicRec;
      topicRes = boxManagementController.selectedBox.value.topicRes;
      active = boxManagementController.selectedBox.value.active == 1;
      version = boxManagementController.selectedBox.value.version;
      restartTimeOut =
          (boxManagementController.selectedBox.value.restartTimeout ~/ 60000)
              .toString();
    }
  }

  void _saveBox() async {
    if (_formKey.currentState!.validate()) {
      if (boxManagementController.selectedBox.value.id == 0) {
        var newBox = Box(
          id: 0,
          active: 1,
          name: boxName,
          chipId: int.tryParse(chipId) ?? 0,
          organisationId: organisationId,
          restartTimeout: (int.tryParse(restartTimeOut) ?? 0) * 60000,
          topicRec: "",
          topicRes: "",
          version: "",
        );
        await boxManagementController.register(newBox);
      } else {
        boxManagementController.selectedBox.value.name = boxName;
        boxManagementController.selectedBox.value.chipId =
            int.tryParse(chipId) ?? 0;
        boxManagementController.selectedBox.value.active = active ? 1 : 0;
        boxManagementController.selectedBox.value.organisationId =
            organisationId;
        boxManagementController.selectedBox.value.restartTimeout =
            (int.tryParse(restartTimeOut) ?? 0) * 60000;
        boxManagementController.selectedBox.value.topicRec = "";
        boxManagementController.selectedBox.value.topicRes = "";
        boxManagementController.selectedBox.value.version = "";

        await boxManagementController
            .updateBox(boxManagementController.selectedBox.value);
      }
      setState(() {});
    }
  }

  organisationSelect() {
    return SizedBox(
      height: height(context) * 0.07,
      child: DropdownSearch<Organisation>(
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
          return homeController.organisations;
        },
        selectedItem: organisationId > 0
            ? homeController.organisations.singleWhere(
                (o) => o.id == organisationId,
              )
            : null,
        itemAsString: (item) => item.name,
        onChanged: (value) => organisationId = value?.id ?? 0,
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
                    color: selectedItem != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ],
          );
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
                    initialValue: boxName,
                    onChanged: (value) => setState(() => boxName = value),
                    labelText: "Kutu Adı"),
                SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: width * 0.45,
                      child: textFormField(context, 0,
                          initialValue: chipId,
                          onChanged: (value) => setState(() => chipId = value),
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
                            value: active,
                            onChanged: (value) {
                              setState(() {
                                active = value ?? false;
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
                    initialValue: restartTimeOut,
                    onChanged: (value) =>
                        setState(() => restartTimeOut = value),
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
