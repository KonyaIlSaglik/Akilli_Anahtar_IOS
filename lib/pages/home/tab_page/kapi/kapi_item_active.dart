import 'package:akilli_anahtar/entities/relay.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector_v2/focus_detector_v2.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:akilli_anahtar/services/web/my_mqtt_service.dart';
import 'package:turkish/turkish.dart';

class KapiItemActive extends StatefulWidget {
  final Relay kapi;
  const KapiItemActive({Key? key, required this.kapi}) : super(key: key);

  @override
  State<KapiItemActive> createState() => _KapiItemActiveState();
}

class _KapiItemActiveState extends State<KapiItemActive>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FocusDetector(
      child: InkWell(
        onTap: () {
          MyMqttClient? client = MyMqttClient.instance;
          if (client.state == MqttConnectionState.connected) {
            if (widget.kapi.deviceTypeId == 4) {
              client.pub(widget.kapi.topicRec, "0");
            }
            if (widget.kapi.deviceTypeId == 5) {
              client.pub(widget.kapi.topicRec,
                  widget.kapi.topicMessage == "1" ? "0" : "1");
            }
          }
        },
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  goldColor.withOpacity(1),
                  goldColor.withOpacity(1),
                ]),
                borderRadius: BorderRadius.circular(10)),
            child: body(),
          ),
        ),
      ),
    );
  }

  body() {
    var height = MediaQuery.of(context).size.height;
    var kapi = widget.kapi;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: height * 0.035,
          child: Card(
            elevation: 0,
            color: kapi.topicMessage == "AÇILIYOR"
                ? Colors.yellow
                : kapi.topicMessage == "AÇIK" || kapi.topicMessage == "1"
                    ? Colors.blue
                    : kapi.topicMessage == "KAPANIYOR" ||
                            kapi.topicMessage == "0"
                        ? Colors.red
                        : Colors.green[400],
            child: Center(
              child: Text(
                kapi.topicMessage == "1"
                    ? "AÇIK"
                    : kapi.topicMessage == "0"
                        ? "KAPALI"
                        : kapi.topicMessage ?? "",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: height * 0.06,
          child: Center(
            child: kapi.deviceTypeId == 4
                ? ImageIcon(
                    Image.asset("assets/barrier.png").image,
                    size: (Theme.of(context).iconTheme.size ?? 28) * 2,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.door_sliding,
                    size: (Theme.of(context).iconTheme.size ?? 28) * 2,
                    color: Colors.white,
                  ),
          ),
        ),
        Expanded(
          flex: 20,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5, left: 5),
            child: TextScroll(
              kapi.name.toUpperCaseTr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 20,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5),
                child: Text(""),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
