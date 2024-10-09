import 'package:akilli_anahtar/pages/home/tab_page/bahce/date_time_picker_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';

class ZamanlamaPage extends StatefulWidget {
  final String hat;
  const ZamanlamaPage({super.key, required this.hat});
  @override
  State<ZamanlamaPage> createState() => _ZamanlamaPageState();
}

class _ZamanlamaPageState extends State<ZamanlamaPage> {
  final controller = ValueNotifier<bool>(false);
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;
  bool isActive = false;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now();
    startTime = TimeOfDay.now();
    endDate = DateTime.now();
    endTime = TimeOfDay.now();
    controller.addListener(() {
      setState(() {
        if (controller.value) {
          isActive = true;
        } else {
          isActive = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.hat} Zamanlama"),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 13, bottom: 13, right: 10),
            child: AdvancedSwitch(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              inactiveChild: Text("OFF"),
              activeChild: Text("ON"),
              width: 70,
              controller: controller,
              activeColor: Colors.brown,
              inactiveColor: Colors.grey,
            ),
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: !isActive,
        child: Opacity(
          opacity: isActive ? 1 : 0.3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    DateTimePickerCard(
                      title: "Başlama Zamanı :",
                      onSelected: (dateTime) {
                        setState(() {
                          startDate = dateTime;
                        });
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    DateTimePickerCard(
                      title: "Bitiş Zamanı :",
                      onSelected: (dateTime) {
                        setState(() {
                          endDate = dateTime;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
