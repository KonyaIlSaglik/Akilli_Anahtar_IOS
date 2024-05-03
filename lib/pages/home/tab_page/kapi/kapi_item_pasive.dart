import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';

class KapiItemPasive extends StatelessWidget {
  const KapiItemPasive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              mainColor.withOpacity(0.2),
              mainColor.withOpacity(0.2)
            ]),
            borderRadius: BorderRadius.circular(10)),
        child: body(context, height),
      ),
    );
  }

  Widget body(BuildContext context, double height) {
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
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      "DURUM",
                      style: TextStyle(
                        color: Colors.grey[300],
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
          child: Icon(
            Icons.door_sliding,
            size: (Theme.of(context).iconTheme.size ?? 28) * 1.50,
            color: Colors.white,
          ),
        ),
        Expanded(
          flex: 20,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5, left: 5),
            child: Text(
              "KAPI ADI",
              maxLines: 2,
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
                  "BİNA ADI",
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
}
