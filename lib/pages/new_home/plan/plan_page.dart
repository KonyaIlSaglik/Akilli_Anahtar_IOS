import 'package:akilli_anahtar/pages/new_home/plan/plan_page_list_item.dart';
import 'package:flutter/material.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      body: Center(
          child: Text(
        "Henüz plan bulunmuyor.",
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[700],
            ),
      )),
    );
    // return ListView(
    //   padding: const EdgeInsets.all(10),
    //   shrinkWrap: true,
    //   children: [
    //     PlanPageListItem(),
    //     PlanPageListItem(),
    //     PlanPageListItem(),
    //     PlanPageListItem(),
    //   ],
    // );
  }
}

// class PlanModel {
//   int id;
//   String name;
//   int deviceId;
//   DateTime startTime;
//   int runTimeMin;
//   int repeatDay;
// }
