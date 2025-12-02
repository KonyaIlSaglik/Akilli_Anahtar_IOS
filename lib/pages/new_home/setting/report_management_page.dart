import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SensorReportsPage extends StatelessWidget {
  SensorReportsPage({super.key});

  String formatDate(String dateString) {
    final dt = DateTime.parse(dateString).toLocal();
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.isLoading.value = true;
      await controller.initializeReports();
      controller.isLoading.value = false;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensör Raporları'),
        backgroundColor: sheetBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _openFilterModal(context, controller),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.reportData.isEmpty
                        ? const Center(child: Text('Veri bulunamadı.'))
                        : ListView.builder(
                            itemCount: controller.reportData.length,
                            itemBuilder: (context, index) {
                              final item = controller.reportData[index];

                              int alarm = item['alarmStatus'] ?? 0;
                              Color cardColor = alarm > 0
                                  ? Colors.red.shade50
                                  : Colors.green.shade50;

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 3),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: alarm > 0
                                        ? Colors.red.shade200
                                        : Colors.green.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${item['sensorTypeName'] ?? 'Sensör'}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: alarm > 0
                                                ? Colors.red.shade700
                                                : Colors.green.shade700,
                                          ),
                                        ),
                                        Text(
                                          "${item['value'] ?? '-'} ${item['unit'] ?? ''}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: alarm > 0
                                                ? Colors.red.shade700
                                                : Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          " ${item['boxName'] ?? ''}",
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          "Alarm : ${alarm}",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: alarm > 0
                                                ? Colors.red.shade800
                                                : Colors.green.shade800,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      " ${item['orgName'] ?? ''}",
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      " ${formatDate(item['dateTime'])}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    if (item['referance'] != null) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        "Referans: ${item['referance']}",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                    ),
                    onPressed: () => controller.exportReport(context, 'excel'),
                    icon: const Icon(
                      Icons.table_chart,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Excel İndir',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                    ),
                    onPressed: () => controller.exportReport(context, 'pdf'),
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text('PDF İndir',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFilterModal(BuildContext context, HomeController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Filtreleme",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: controller.selectedOrganisationId.value == 0
                    ? null
                    : controller.selectedOrganisationId.value,
                items: controller.organisationList
                    .map((o) => DropdownMenuItem(
                          value: o.organisationId,
                          child: Text(o.organisationName ?? ''),
                        ))
                    .toList(),
                onChanged: (v) {
                  controller.selectedOrganisationId.value = v ?? 0;
                },
                decoration:
                    const InputDecoration(labelText: "Organizasyon Seç"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: controller.selectedRange.value,
                items: controller.rangeOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => controller.selectedRange.value = value!,
                decoration: const InputDecoration(labelText: 'Dönem Aralığı'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: controller.onlyAlarms.value,
                    onChanged: (val) =>
                        controller.onlyAlarms.value = val ?? false,
                  ),
                  const Text("Sadece Alarm"),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  controller.fetchReports();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600,
                ),
                child: const Text(
                  "Filtreyi Uygula",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
            ],
          );
        }),
      ),
    );
  }
}
