import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/amol_controller.dart';
import '../controllers/backup_controller.dart';
import 'widgets/dashboard_card.dart';
import 'widgets/day_selector.dart';
import 'widgets/amol_list_item.dart';

/// Main home screen of the application.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    /// Initialize main controller.
    final controller = Get.put(AmolController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      /// Top app bar with year picker and settings.
      appBar: AppBar(
        title: const Text(
          "Ramadan Amol Tracker",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        actions: [
          /// Opens year selection dialog.
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: "Change Year",
            onPressed: () => _showYearPicker(context, controller),
          ),

          /// Opens backup & restore settings sheet.
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Backup & Settings",
            onPressed: () => _showSettingsSheet(context),
          ),
        ],
      ),

      /// Main body layout.
      body: Column(
        children: [
          const DashboardCard(),
          const SizedBox(height: 15),
          const DaySelector(),
          const SizedBox(height: 10),

          /// Amol list section.
          Expanded(
            child: GetBuilder<AmolController>(
              builder: (ctrl) {
                if (ctrl.dailyAmols.isEmpty) {
                  return Center(
                    child: Text(
                      "No deeds added for this day.",
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 5, 16, 80),
                  itemCount: ctrl.dailyAmols.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return AmolListItem(index: index);
                  },
                );
              },
            ),
          ),
        ],
      ),

      /// Floating button to add new Amol.
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () => _showAddDialog(context, controller),
        label: const Text(
          "Add New",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
      ),
    );
  }

  /// Displays backup and restore options.
  void _showSettingsSheet(BuildContext context) {
    final backupCtrl = Get.put(BackupController());

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Drag handle indicator.
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const Text(
                "Data Backup & Restore",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00695C),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Save your progress to Google Drive or Local Storage.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 20),

              /// Backup action.
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.cloud_upload_rounded,
                  color: Colors.blue,
                ),
                title: const Text(
                  "Backup Data",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Export file to save in Google Drive"),
                onTap: () async {
                  Navigator.pop(context);
                  await backupCtrl.createBackup();
                },
              ),

              const Divider(height: 20),

              /// Restore action.
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.cloud_download_rounded,
                  color: Colors.orange,
                ),
                title: const Text(
                  "Restore Data",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Import a previously saved JSON file"),
                onTap: () async {
                  Navigator.pop(context);
                  await backupCtrl.restoreBackup();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows dialog for adding a new Amol item.
  void _showAddDialog(BuildContext context, AmolController ctrl) {
    TextEditingController titleCtrl = TextEditingController();
    TextEditingController targetCtrl = TextEditingController(text: "100");
    bool addToAllDays = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Add New Zikr",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Title input.
                      TextField(
                        controller: titleCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: "Zikr Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// Target input.
                      TextField(
                        controller: targetCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Daily Target",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// Option to add to future days.
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF00695C),
                        title: const Text(
                          "Add to all future days?",
                          style: TextStyle(fontSize: 14),
                        ),
                        value: addToAllDays,
                        onChanged: (val) {
                          setState(() {
                            addToAllDays = val;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (titleCtrl.text.isNotEmpty) {
                                  ctrl.addNewAmol(
                                    titleCtrl.text,
                                    int.tryParse(targetCtrl.text) ?? 100,
                                    addToAllDays,
                                  );
                                  Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00695C),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Add Now"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Displays year selection dialog.
  void _showYearPicker(BuildContext context, AmolController ctrl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Ramadan Year", textAlign: TextAlign.center),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          height: 300,
          width: 300,
          child: ListView.builder(
            itemCount: 16,
            itemBuilder: (context, index) {
              int year = 2025 + index;
              bool isSelected = year == ctrl.selectedYear;

              return ListTile(
                title: Text(
                  "Ramadan $year",
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFF00695C)
                        : Colors.black87,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFF00695C))
                    : const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
                onTap: () {
                  ctrl.changeDayOrYear(year, ctrl.selectedDay);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
