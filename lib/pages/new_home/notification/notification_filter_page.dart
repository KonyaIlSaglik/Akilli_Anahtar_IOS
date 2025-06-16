import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:akilli_anahtar/controllers/main/notification_controller.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';

class NotificationFilterModal extends StatelessWidget {
  final NotificationFilterController filterController = Get.find();
  final HomeController homeController = Get.find();

  NotificationFilterModal({super.key});

  List<String> get sensorTypes => homeController.homeDevices
      .map((e) => e.typeName)
      .whereType<String>()
      .toSet()
      .toList();

  List<String> get locations => homeController.homeDevices
      .map((e) => e.boxName ?? e.organisationName)
      .where((e) => e != null && e.isNotEmpty)
      .cast<String>()
      .toSet()
      .toList();

  List<String> get dateOptions => ['Son 24 Saat', 'Son 7 Gün', 'Son 1 Ay'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Obx(() {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filtrele', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 20),
                  Text(
                    'Sensör Tipi',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: sensorTypes.map((type) {
                      final selected =
                          filterController.selectedSensor.value == type;
                      return FilterChip(
                        label: Text(type),
                        selected: selected,
                        onSelected: (_) =>
                            filterController.selectedSensor.value = type,
                        selectedColor: goldColor.withOpacity(0.5),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text('Lokasyon', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: locations.map((loc) {
                      final selected =
                          filterController.selectedLocation.value == loc;
                      return FilterChip(
                        label: Text(loc),
                        selected: selected,
                        onSelected: (_) =>
                            filterController.selectedLocation.value = loc,
                        selectedColor: goldColor.withOpacity(0.5),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tarih',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: dateOptions.map((option) {
                      final selected =
                          filterController.selectedDateFilter.value == option;
                      return FilterChip(
                        label: Text(option),
                        selected: selected,
                        onSelected: (_) =>
                            filterController.selectedDateFilter.value = option,
                        selectedColor: goldColor.withOpacity(0.5),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            filterController.clearFilters();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            textStyle: theme.textTheme.titleMedium,
                          ),
                          child: Text("Temizle",
                              style: TextStyle(color: goldColor)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            textStyle: theme.textTheme.titleMedium,
                          ),
                          child: const Text("Bitir",
                              style: TextStyle(color: goldColor)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
