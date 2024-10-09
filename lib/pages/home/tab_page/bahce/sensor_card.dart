import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String birim;
  const SensorCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.birim,
  });

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
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(height: 0),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: Theme.of(context).iconTheme.size,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .fontSize),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Expanded(
                    flex: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .fontSize,
                          ),
                        ),
                        Text(
                          birim,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .fontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
