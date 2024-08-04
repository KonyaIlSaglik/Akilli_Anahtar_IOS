import 'package:flutter/material.dart';

class CustomButtonEski extends StatelessWidget {
  final String text;
  final Function()? onTap;
  const CustomButtonEski({Key? key, required this.text, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: width * 0.7,
        height: height * 0.08,
        child: Opacity(
          opacity: 1,
          child: Card(
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
              borderSide: BorderSide.none,
            ),
            elevation: 5,
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
