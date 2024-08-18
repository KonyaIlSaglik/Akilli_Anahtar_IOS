import 'package:akilli_anahtar/pages/home/tab_page/bahce/zamanlama_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class BahceSulamaCard extends StatefulWidget {
  final String title;
  const BahceSulamaCard({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<BahceSulamaCard> createState() => _BahceSulamaCardState();
}

class _BahceSulamaCardState extends State<BahceSulamaCard> {
  final controller = ValueNotifier<bool>(false);
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        if (controller.value) {
          _checked = true;
        } else {
          _checked = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [goldColor.withOpacity(1), goldColor.withOpacity(1)]),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          _checked
                              ? FontAwesomeIcons.faucetDrip
                              : FontAwesomeIcons.faucet,
                          color: _checked ? Colors.blue : Colors.white,
                        ),
                      ),
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .fontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "En Son: ${DateFormat("dd MMMM yyyy HH:mm", "tr_TR").format(DateTime.now())}",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                AdvancedSwitch(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  inactiveChild: Text("OFF"),
                  activeChild: Text("ON"),
                  width: 70,
                  controller: controller,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.white60,
                ),
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.clock,
                    color: _checked ? Colors.blue : Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            ZamanlamaPage(hat: widget.title),
                      ),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
