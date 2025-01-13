import 'package:akilli_anahtar/controllers/admin/box_management_controller.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/dtos/bm_box_dto.dart';
import 'package:akilli_anahtar/pages/managers/box/box_detail/box_add_edit.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class BoxListItem extends StatefulWidget {
  final BmBoxDto box;
  const BoxListItem({super.key, required this.box});

  @override
  State<BoxListItem> createState() => _BoxListItemState();
}

class _BoxListItemState extends State<BoxListItem> {
  BoxManagementController boxManagementController = Get.find();
  HomeController homeController = Get.find();
  late BmBoxDto box;

  @override
  void initState() {
    super.initState();
    box = widget.box;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: goldColor.withOpacity(0.8)),
        width: width(context) * 0.1,
        height: width(context) * 0.1,
        child: Center(
          child: Text(
            box.id.toString(),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      title: Text(box.name!),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(box.organisationName ?? "-"),
          Text("Versiyon: ${box.version!.isNotEmpty ? box.version : "-"}"),
          // if (box.isOld == -1)
          //   Text(
          //     "Yeni Version: ${boxManagementController.newVersion.value.version}",
          //     style: TextStyle(color: Colors.red),
          //   ),
          // if (box.isOld == 0)
          //   Text(
          //     "Sürüm Güncel",
          //     style: TextStyle(color: Colors.green),
          //   ),
          // if (box.isOld == 1)
          //   Text(
          //     "Test Sürüm",
          //     style: TextStyle(color: Colors.blue),
          //   ),
        ],
      ),
      trailing: Icon(
        FontAwesomeIcons.angleRight,
        color: goldColor,
      ),
      onTap: () {
        Get.to(() => BoxAddEdit(box: box));
      },
    );
  }
}
