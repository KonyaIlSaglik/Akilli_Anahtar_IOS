import 'dart:async';
import 'dart:io';
import 'package:akilli_anahtar/controllers/install/wifi_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'custom_provisioner/my_provisioner.dart';
import 'package:udp/udp.dart';

import 'custom_provisioner/src/my_provisioning_request.dart';

class SmartConfigPage extends StatefulWidget {
  const SmartConfigPage({super.key});

  @override
  State<SmartConfigPage> createState() => _SmartConfigPageState();
}

class _SmartConfigPageState extends State<SmartConfigPage> {
  WifiController wifiController = Get.put(WifiController());
  final TextEditingController ssidController = TextEditingController(text: "");
  final TextEditingController passwordController =
      TextEditingController(text: "");
  final formKey = GlobalKey<FormState>();
  bool passVisible = false;
  final provisioner = MyProvisioner.espTouch();
  late Timer timer;
  bool _animate = false;
  int countDown = 0;
  var passwordFocus = FocusNode();
  var espIp = "";

  @override
  void initState() {
    super.initState();
    wifiController.getSSID().then((value) {
      if (value.isNotEmpty) {
        setState(() {
          ssidController.text = value;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _stopProvisioning(close: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.black,
        iconTheme: IconThemeData(size: 30),
        elevation: 10,
        title: Text(
          "KURULUM",
          style: width(context) < minWidth
              ? textTheme(context).titleMedium!
              : textTheme(context).titleLarge!,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding eklenmesi
          child: Column(
            mainAxisSize: MainAxisSize.min, // Burayı ekledik
            children: [
              SizedBox(height: height(context) * 0.02),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text(
                    "Telefonu bir wifi ağına bağlayın. Cihazı wifi ağına bağlamak için ağ adı ve parolasını girin ve yayınlayın. Ardından cihazın bağlanmasını bekleyin."),
              ),
              SizedBox(height: height(context) * 0.02),
              Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Burayı ekledik
                  children: [
                    _buildTextField(
                        ssidController, "SSID", FontAwesomeIcons.wifi),
                    SizedBox(height: height(context) * 0.01),
                    _buildTextField(
                        passwordController, "PAROLA", FontAwesomeIcons.lock,
                        isPassword: true),
                    SizedBox(height: height(context) * 0.05),
                    _buildSubmitButton(),
                    SizedBox(height: height(context) * 0.05),
                    _buildCountdownTimer(),
                    SizedBox(height: height(context) * 0.05),
                    if (espIp.isNotEmpty) _buildInfo(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isPassword = false}) {
    return SizedBox(
      height: height(context) * 0.07,
      width: width(context) * 0.90,
      child: Card.outlined(
        elevation: 10,
        child: Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme:
                TextSelectionThemeData(selectionHandleColor: goldColor),
          ),
          child: TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Zorunlu Alan";
              }
              return null;
            },
            controller: controller,
            obscureText: isPassword && !passVisible,
            cursorColor: Colors.black,
            textInputAction:
                isPassword ? TextInputAction.done : TextInputAction.next,
            focusNode: isPassword ? passwordFocus : null,
            onFieldSubmitted: (value) {
              if (!isPassword) passwordFocus.requestFocus();
            },
            style: textTheme(context).titleLarge,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(icon, size: 20, color: goldColor),
              hintText: hint,
              hintStyle:
                  textTheme(context).titleMedium!.copyWith(color: Colors.grey),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        passVisible
                            ? FontAwesomeIcons.eyeSlash
                            : FontAwesomeIcons.eye,
                        size: 20,
                        color: goldColor,
                      ),
                      onPressed: () {
                        setState(() {
                          passVisible = !passVisible;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(90),
      onTap: () {
        if (provisioner.running) {
          _stopProvisioning();
        } else {
          if (formKey.currentState!.validate()) {
            _startProvisioning();
          }
        }
      },
      child: AvatarGlow(
        duration: Duration(seconds: 3),
        glowCount: 3,
        glowColor: goldColor,
        glowShape: BoxShape.circle,
        animate: _animate,
        curve: Curves.fastOutSlowIn,
        child: Material(
          elevation: 10.0,
          shape: CircleBorder(),
          color: Colors.transparent,
          child: CircleAvatar(
            backgroundColor: goldColor,
            radius: width(context) * 0.20,
            child: Icon(Icons.wifi, color: Colors.white, size: 75),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownTimer() {
    return Visibility(
      visible: provisioner.running,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Kalan Süre: ", style: textTheme(context).titleMedium),
          Text("$countDown",
              style: textTheme(context)
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(" saniye", style: textTheme(context).titleMedium),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      children: [
        Text(
          "Bağlantı Başarılı",
          style: textTheme(context)
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          "IP: $espIp",
          style: textTheme(context)
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _stopProvisioning({bool close = false}) {
    if (provisioner.running) {
      timer.cancel();
      provisioner.stop();
      if (!close) {
        setState(() {
          _animate = false;
        });
      }
    }
  }

  Future<void> _startProvisioning() async {
    var bssid = await wifiController.getBSSID();
    provisioner.start(MyProvisioningRequest.fromStrings(
      ssid: ssidController.text,
      bssid: bssid,
      password: passwordController.text,
    ));

    setState(() {
      _animate = true;
      espIp = "";
    });

    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        countDown = 180 - t.tick;
      });
      if (countDown == 0) {}
    });

    const int udpPort = 4210; // ESP'nin yayın yaptığı port
    UDP? receiver = await UDP.bind(Endpoint.any(port: Port(udpPort)));

    print("UDP Dinleyici Başladı...");

    receiver.asStream().listen((datagram) async {
      if (datagram != null) {
        String message = String.fromCharCodes(datagram.data);
        InternetAddress sender = datagram.address;
        print("Gelen Mesaj: $message, Gönderen: ${sender.address}");
        setState(() {
          espIp = message;
        });
        // ESP'den mesajı aldıktan sonra "STOP" mesajını gönder
        await sendStopMessage(sender);
        receiver.close();
        _stopProvisioning();
      }
    });
  }

  Future<void> sendStopMessage(InternetAddress espAddress) async {
    const int udpPort = 4210; // ESP'nin dinlediği port
    UDP sender = await UDP.bind(Endpoint.any());

    String urlMessage = apiUrlOut;
    sender.send(urlMessage.codeUnits,
        Endpoint.unicast(espAddress, port: Port(udpPort)));

    print("ESP'ye '$apiUrlOut' adresi gönderildi: ${espAddress.address}");

    String stopMessage = "STOP";
    sender.send(stopMessage.codeUnits,
        Endpoint.unicast(espAddress, port: Port(udpPort)));

    print("ESP'ye 'STOP' mesajı gönderildi: ${espAddress.address}");
  }
}
