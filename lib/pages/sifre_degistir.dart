import 'package:akilli_anahtar/models/kullanici_giris_result.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/services/web/web_service.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import '../utils/constants.dart';
import '../widgets/custom_container.dart';
import '../widgets/custom_text_field.dart';

class SifreDegistirPage extends StatefulWidget {
  const SifreDegistirPage({Key? key}) : super(key: key);

  @override
  State<SifreDegistirPage> createState() => _SifreDegistirPageState();
}

class _SifreDegistirPageState extends State<SifreDegistirPage> {
  bool keboardVisible = false;
  KullaniciGirisResult? user;
  String password = "";
  final oldPasswordCont = TextEditingController(text: "");
  final oldPasswordFocus = FocusNode();
  final newPasswordCont = TextEditingController(text: "");
  final newPasswordFocus = FocusNode();
  final newPasswordAgainCont = TextEditingController(text: "");
  final newPasswordAgainFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    LocalDb.get(userKey).then((value) {
      setState(() {
        user =
            KullaniciGirisResult.fromXML(XmlDocument.parse(value!).rootElement);
      });
    });
    LocalDb.get(passwordKey).then((value) {
      setState(() {
        password = value!;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    //FocusScope.of(context).dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: mainColor,
      ),
      body: PopScope(
        onPopInvoked: (didPop) async {
          Navigator.pop(context);
        },
        child: SingleChildScrollView(
          child: CustomContainer(
            flex: 5,
            body: Column(
              children: [
                SizedBox(height: keboardVisible ? 0 : 50),
                CustomContainer(
                  flex: keboardVisible ? 20 : 5,
                  body: Image.asset(
                    "assets/anahtar.png",
                  ),
                ),
                SizedBox(height: keboardVisible ? 0 : 25),
                Card(
                  color: mainColor,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: CustomContainer(
                    flex: 10,
                    body: form(height),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  form(double height) {
    return Column(
      children: [
        SizedBox(height: keboardVisible ? 20 : 30),
        formTitle(),
        SizedBox(height: keboardVisible ? 20 : 30),
        CustomTextField(
          controller: oldPasswordCont,
          focusNode: oldPasswordFocus,
          nextFocus: newPasswordFocus,
          icon: Icon(Icons.lock),
          hintText: "Eski Şifre",
          isPassword: true,
        ),
        SizedBox(height: keboardVisible ? 10 : 20),
        CustomTextField(
          controller: newPasswordCont,
          focusNode: newPasswordFocus,
          nextFocus: newPasswordAgainFocus,
          icon: Icon(Icons.lock),
          hintText: "Yeni Şifre",
          isPassword: true,
        ),
        SizedBox(height: keboardVisible ? 10 : 20),
        CustomTextField(
          controller: newPasswordAgainCont,
          focusNode: newPasswordAgainFocus,
          icon: Icon(Icons.lock),
          hintText: "Yeni Şifre Tekrar",
          isPassword: true,
        ),
        SizedBox(height: keboardVisible ? 10 : 20),
        girisButon(height),
        SizedBox(height: keboardVisible ? 10 : 20),
        otherButtons(),
        SizedBox(height: keboardVisible ? 10 : 20),
      ],
    );
  }

  formTitle() {
    return Text(
      "Şifre Değiştir",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: Theme.of(context).textTheme.headlineLarge!.fontSize,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  girisButon(double height) {
    return ButtonTheme(
      child: ElevatedButton(
        onPressed: () async {
          sifreDegistir(context);
        },
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          minimumSize: Size(double.infinity, height * 0.075),
        ),
        child: Text(
          "KAYDET",
          style: TextStyle(
              fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize),
        ),
      ),
    );
  }

  sifreDegistir(context) async {
    if (oldPasswordCont.text != password) {
      CherryToast.error(
        toastPosition: Position.bottom,
        title: Text("Hatalı şifre"),
      ).show(context);
      return;
    }
    if (newPasswordCont.text.isEmpty) {
      CherryToast.error(
        toastPosition: Position.bottom,
        title: Text("Yeni Şifre boş olamaz"),
      ).show(context);
      return;
    }
    if (newPasswordCont.text != newPasswordAgainCont.text) {
      CherryToast.error(
        toastPosition: Position.bottom,
        title: Text("Şifreler eşit değil"),
      ).show(context);
      return;
    }
    var result = await WebService.kullaniciSifreDegistir(
        kad: user!.kad, eskiSifre: password, yeniSifre: newPasswordCont.text);
    if (result != null && result) {
      CherryToast.success(
        toastPosition: Position.bottom,
        title: Text("Şifre güncellendi"),
      ).show(context);
      setState(() {
        password = newPasswordCont.text;
      });
      await LocalDb.add(passwordKey, password);
      oldPasswordCont.clear();
      newPasswordCont.clear();
      newPasswordAgainCont.clear();
    }
  }

  otherButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: Text(
            'Vazgeç',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
