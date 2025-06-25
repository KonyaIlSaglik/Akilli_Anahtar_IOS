import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/notification_filter_controller.dart';

class NotificationFilterPage extends StatefulWidget {
  const NotificationFilterPage({super.key});

  @override
  State<NotificationFilterPage> createState() => _NotificationFilterPageState();
}

class _NotificationFilterPageState extends State<NotificationFilterPage> {
  final NotificationFilterController filterController = Get.find();
  final HomeController homeController = Get.find();
  final RxBool _expandedLocation = false.obs;

  List<String> get sensorTypes => homeController.homeDevices
      .map((e) => e.typeName ?? '')
      .where((e) => e.isNotEmpty)
      .toSet()
      .toList();

  List<String> get locations => homeController.homeDevices
      .map((e) => e.boxName ?? e.organisationName ?? '')
      .where((e) => e.isNotEmpty)
      .toSet()
      .toList();

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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Obx(() {
            return Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filtrele',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilterSection(
                          context,
                          title: 'Sensör Tipi',
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: sensorTypes.map((type) {
                                final selected =
                                    filterController.selectedSensor.value ==
                                        type;
                                return ChoiceChip(
                                  label: Text(type),
                                  selected: selected,
                                  onSelected: (_) => filterController
                                      .selectedSensor
                                      .value = selected ? '' : type,
                                  selectedColor: goldColor.withOpacity(0.3),
                                  labelStyle: TextStyle(
                                    color: selected
                                        ? Colors.black
                                        : colorScheme.onSurface,
                                  ),
                                  backgroundColor: colorScheme.surfaceVariant,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Obx(() => _buildExpandableSection(
                              context,
                              title: 'Lokasyon',
                              expanded: _expandedLocation.value,
                              onExpand: () => _expandedLocation.toggle(),
                              children: [
                                if (_expandedLocation.value) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: locations.map((loc) {
                                      final selected = filterController
                                              .selectedLocation.value ==
                                          loc;
                                      return ChoiceChip(
                                        label: Text(loc),
                                        selected: selected,
                                        onSelected: (_) => filterController
                                            .selectedLocation
                                            .value = selected ? "" : loc,
                                        selectedColor:
                                            goldColor.withOpacity(0.3),
                                        labelStyle: TextStyle(
                                          color: selected
                                              ? Colors.black
                                              : colorScheme.onSurface,
                                        ),
                                        backgroundColor:
                                            colorScheme.surfaceVariant,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            )),
                        const SizedBox(height: 20),
                        _buildFilterSection(
                          context,
                          title: 'Alarm Durumu',
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                {'label': 'Kritik', 'value': '2'},
                                {'label': 'Uyarı', 'value': '1'},
                              ].map<Widget>((Map<String, String> alarm) {
                                final selected =
                                    filterController.selectedAlarmLevel.value ==
                                        alarm['value'];
                                return ChoiceChip(
                                  label: Text(alarm['label']!),
                                  selected: selected,
                                  onSelected: (_) {
                                    filterController.selectedAlarmLevel.value =
                                        selected ? '' : alarm['value']!;
                                  },
                                  selectedColor: goldColor.withOpacity(0.3),
                                  labelStyle: TextStyle(
                                    color: selected
                                        ? Colors.black
                                        : colorScheme.onSurface,
                                  ),
                                  backgroundColor: colorScheme.surfaceVariant,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                );
                              }).toList(),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            filterController.clearFilters();
                            Navigator.pop(context, true);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: goldColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Temizle",
                            style: TextStyle(color: goldColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: goldColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Uygula",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Widget _buildFilterSection(BuildContext context,
      {required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(children: children),
      ],
    );
  }

  Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required bool expanded,
    required VoidCallback onExpand,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onExpand,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: theme.iconTheme.color,
                ),
              ],
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
