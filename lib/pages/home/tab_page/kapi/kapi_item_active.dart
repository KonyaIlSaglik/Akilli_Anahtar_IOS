import 'package:flutter/material.dart';
import 'package:focus_detector_v2/focus_detector_v2.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:turkish/turkish.dart';
import 'package:akilli_anahtar/services/web/my_mqtt_service.dart';
import 'package:akilli_anahtar/models/kullanici_kapi_result.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class KapiItemActive extends StatefulWidget {
  final KullaniciKapiResult kapi;
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
            client.pub(widget.kapi.topicRec!, "0");
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
                  mainColor.withOpacity(0.8),
                  mainColor,
                ]),
                borderRadius: BorderRadius.circular(10)),
            child: body(),
          ),
        ),
      ),
    );
  }

  body() {
    var kapi = widget.kapi;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 25,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Card(
                  elevation: 0,
                  color: kapi.topicMessage == "AÇILIYOR"
                      ? Colors.yellow
                      : kapi.topicMessage == "AÇIK"
                          ? Colors.blue
                          : kapi.topicMessage == "KAPANIYOR"
                              ? Colors.red
                              : Colors.green[400],
                  child: Center(
                    child: Text(
                      kapi.topicMessage ?? "",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            Theme.of(context).textTheme.titleMedium!.fontSize,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 60,
          child: Center(
            child: kapi.kapiTurAdi == "BARİYER"
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
            child: Text(
              kapi.kapiAdi!.toUpperCaseTr(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
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
                child: Text(
                  kapi.siteAdi!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
                  ),
                ),
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
