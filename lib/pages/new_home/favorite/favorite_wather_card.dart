import 'dart:convert';

import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class FavoriteWatherCard extends StatefulWidget {
  const FavoriteWatherCard({super.key});

  @override
  State<FavoriteWatherCard> createState() => _FavoriteWatherCardState();
}

class _FavoriteWatherCardState extends State<FavoriteWatherCard> {
  String city = "";
  String tempeture = "";
  String humudity = "";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getWather();
  }

  getWather() async {
    setState(() {
      loading = true;
    });
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return;
    }
    var position = await Geolocator.getCurrentPosition();
    var placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks[0]);
    setState(() {
      city =
          "${placemarks[0].administrativeArea!}/${placemarks[0].subAdministrativeArea!}";
    });
    var url =
        "https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m,relative_humidity_2m&forecast_days=1";
    var uri = Uri.parse(url);
    var client = http.Client();
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        var data = json.decode(response.body) as Map<String, dynamic>;
        var result = data["current"] as Map<String, dynamic>;
        var unitResult = data["current_units"] as Map<String, dynamic>;
        tempeture =
            "${result["temperature_2m"]} ${unitResult["temperature_2m"]}";
        humudity =
            "${result["relative_humidity_2m"]} ${unitResult["relative_humidity_2m"]}";
      });
    }
    client.close();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: Colors.grey,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Colors.white54,
                  Colors.brown[50]!,
                  Colors.brown[100]!,
                  Colors.brown[100]!,
                  Colors.brown[200]!,
                ],
              ),
            ),
          ),
          Positioned(
            left: 5,
            bottom: 5,
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                FontAwesomeIcons.cloudSunRain,
                size: 40,
              ),
            ),
          ),
          Positioned(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width(context) * 0.02,
                vertical: width(context) * 0.01,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          loading ? "" : city,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme(context).labelMedium,
                        ),
                      ),
                      if (!loading)
                        InkWell(
                          onTap: () {
                            getWather();
                          },
                          child: Icon(
                            FontAwesomeIcons.rotate,
                            size: height(context) * 0.025,
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (loading)
                          Center(
                            child: CircularProgressIndicator(),
                          ),
                        if (!loading)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: height(context) * 0.015),
                              Text(
                                "Sıcaklık: $tempeture",
                                style: textTheme(context).titleLarge,
                              ),
                              SizedBox(height: height(context) * 0.005),
                              Text(
                                "Nem: $humudity",
                                style: textTheme(context).titleMedium,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
