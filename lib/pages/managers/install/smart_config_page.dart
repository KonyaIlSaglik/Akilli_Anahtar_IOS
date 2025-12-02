import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:akilli_anahtar/controllers/install/wifi_controller.dart';
import 'package:akilli_anahtar/pages/new_home/setting/settings_page.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'custom_provisioner/my_provisioner.dart';
import 'package:udp/udp.dart';

import 'package:akilli_anahtar/widgets/app_input_field.dart';
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
  List<Map<String, String>> savedNetworks = [];
  final provisioner = MyProvisioner.espTouch();
  bool _animate = false;
  int countDown = 0;
  var passwordFocus = FocusNode();
  var espIp = "";
  bool _dialogShown = false;
  bool _navigated = false;
  bool _completed = false;
  Timer? _timer;
  UDP? _receiver;
  StreamSubscription? _udpSub;

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

    LocalDb.get("ssidlist").then(
      (value) {
        if (value != null) {
          print(value);
          final parsed = (jsonDecode(value) as List)
              .map((item) => Map<String, String>.from(item))
              .toList();

          setState(() {
            savedNetworks = parsed;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _stopProvisioning(close: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: sheetBackground,
        iconTheme: IconThemeData(size: 30),
        title: Text(
          "Kurulum",
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: height(context) * 0.02),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text(
                    "Telefonu bir 2.4 GHz wifi ağına bağlayın. Cihazı wifi ağına bağlamak için ağ adı ve parolasını girin ve yayınlayın. Ardından cihazın bağlanmasını bekleyin."),
              ),
              SizedBox(height: height(context) * 0.02),
              Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppInputField(
                      controller: ssidController,
                      icon: FontAwesomeIcons.wifi,
                      label: "SSID",
                      suffixIcon: IconButton(
                        tooltip: "Kayıtlı Ağlar",
                        icon: const Icon(FontAwesomeIcons.list),
                        color: goldColor,
                        onPressed: _showSavedNetworks,
                      ),
                    ),
                    SizedBox(height: height(context) * 0.02),
                    AppInputField(
                        controller: passwordController,
                        icon: FontAwesomeIcons.lock,
                        label: "Şifre"),
                    SizedBox(height: height(context) * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: _saveNetwork, child: Text("Kaydet")),
                      ],
                    ),
                    SizedBox(height: height(context) * 0.04),
                    _buildSubmitButton(),
                    SizedBox(height: height(context) * 0.04),
                    _buildCountdownTimer(),
                    SizedBox(height: height(context) * 0.04),
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
                  : IconButton(
                      icon: Icon(
                        FontAwesomeIcons.list,
                        color: goldColor,
                      ),
                      onPressed: () => _showSavedNetworks(),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveNetwork() async {
    if (formKey.currentState!.validate()) {
      final existingNetwork = savedNetworks.firstWhere(
        (network) => network['ssid'] == ssidController.text,
        orElse: () => {},
      );

      if (existingNetwork.isNotEmpty) {
        Get.snackbar(
          "Hata",
          "Bu SSID zaten mevcut.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      setState(() {
        savedNetworks.add({
          'ssid': ssidController.text,
          'password': passwordController.text,
        });
      });
      saveLocalDb();
      successSnackbar(
        "Başarılı",
        "Ağ bilgileri kaydedildi.",
      );
    }
  }

  void saveLocalDb() async {
    await LocalDb.add("ssidlist", json.encode(savedNetworks));
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

  void _goHome() {
    if (_navigated) return;
    _navigated = true;
    try {
      Get.offAllNamed('/layout');
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    if (!mounted /* || _navigated */) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Kurulum başarıyla tamamlandı. Cihazlarınızı ana sayfada görebilirsiniz.",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Cihaz ağa bağlandı.",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    )),
                            if (espIp.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: SelectableText(
                                  "IP: $espIp",
                                  style:
                                      const TextStyle(fontFamily: 'monospace'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Sonraki adımlar",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const _Bullet(
                    "Ana sayfada cihazlarınızı görüntüleyebilir ve kontrol edebilirsiniz."),
                const _Bullet(
                    "Wi-Fi Ayarları bölümünden ana wifi ve yedek Wi-Fi tanımlayabilirsiniz. "
                    "Cihaz master ağa bağlanamazsa otomatik olarak yedeğe geçer."),
              ],
            ),
          ),
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();

                _navigated = true;
                _stopProvisioning(close: true);
                Get.back();
              },
              icon: const Icon(Icons.settings),
              label: const Text("Ayarlar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _goHome();
              },
              child: const Text("Ana Sayfaya Dön"),
            ),
          ],
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_navigated) _goHome();
    });
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

  void _showSavedNetworks() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: height(context) * 0.5,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: Row(
                  children: [
                    Text(
                      "Kayıtlı Ağlar",
                      style: textTheme(context).titleMedium,
                    ),
                  ],
                ),
              ),
              Divider(
                color: goldColor,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: savedNetworks.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          title: Text(savedNetworks[index]['ssid']!),
                          subtitle: Text(savedNetworks[index]['password']!),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Dikkat!"),
                                    content: Text(
                                        "Ağ bilgisini silmek istior musunuz?"),
                                    actions: [
                                      TextButton(
                                        child: Text("Vazgeç"),
                                        onPressed: () {
                                          Get.back();
                                        },
                                      ),
                                      TextButton(
                                        child: Text("Sil"),
                                        onPressed: () {
                                          setState(() {
                                            savedNetworks
                                                .remove(savedNetworks[index]);
                                          });
                                          saveLocalDb();
                                          Get.back();
                                          if (savedNetworks.isEmpty) {
                                            Get.back();
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          onTap: () {
                            ssidController.text = savedNetworks[index]['ssid']!;
                            passwordController.text =
                                savedNetworks[index]['password']!;
                            Navigator.pop(context);
                          },
                        ),
                        Divider(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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
    try {
      if (_timer?.isActive ?? false) _timer!.cancel();
    } catch (_) {}

    try {
      if (provisioner.running) provisioner.stop();
    } catch (_) {}

    try {
      _udpSub?.cancel();
      _udpSub = null;
    } catch (_) {}
    try {
      _receiver?.close();
      _receiver = null;
    } catch (_) {}

    if (!close && mounted) {
      setState(() => _animate = false);
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
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        countDown = 180 - t.tick;
      });
      if (countDown == 0) {
        _stopProvisioning();
      }
    });

    const int udpPort = 4210;
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
        await sendStopMessage(sender);

        receiver.close();
        _stopProvisioning();

        if (!_dialogShown) {
          _dialogShown = true;
          _showSuccessDialog();
        }
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

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• "),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
