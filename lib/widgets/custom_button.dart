// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  final void Function() onPressed;
  final String title;
  bool? loading = false;
  Color? color;
  CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.loading,
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return ButtonTheme(
      child: Card(
        color: color ?? Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: OutlinedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            minimumSize: Size(double.infinity, height * 0.075),
          ),
          child: loading == null || !loading!
              ? Text(
                  title,
                  style: TextStyle(
                    color: color == null ? Colors.black : Colors.white,
                    fontSize:
                        Theme.of(context).textTheme.headlineSmall!.fontSize,
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(
                    color: goldColor,
                  ),
                ),
        ),
      ),
    );
  }
}
