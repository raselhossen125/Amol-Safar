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
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 10,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const Text(
                        "Add New Zikr",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF004D40), // একটু ডার্ক টিল কালার
                        ),
                      ),
                      const SizedBox(height: 25),

                      /// --- Zikr Name TextField ---
                      TextField(
                        controller: titleCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: "Zikr Name",
                          hintText: "e.g. Subhanallah",
                          prefixIcon: const Icon(
                            Icons.edit_note_rounded,
                            color: Color(0xFF00695C),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          labelStyle: const TextStyle(color: Colors.grey),
                          floatingLabelStyle: const TextStyle(
                            color: Color(0xFF00695C),
                            fontWeight: FontWeight.bold,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Color(0xFF00695C),
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// --- Daily Target TextField ---
                      TextField(
                        controller: targetCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Daily Target",
                          hintText: "100",
                          prefixIcon: const Icon(
                            Icons.track_changes_rounded,
                            color: Color(0xFF00695C),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          labelStyle: const TextStyle(color: Colors.grey),
                          floatingLabelStyle: const TextStyle(
                            color: Color(0xFF00695C),
                            fontWeight: FontWeight.bold,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Color(0xFF00695C),
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// --- Switch ListTile ---
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFE0F2F1,
                          ), // হালকা টিল ব্যাকগ্রাউন্ড
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SwitchListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          activeColor: const Color(0xFF00695C),
                          title: const Text(
                            "Add to all future days?",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF004D40),
                            ),
                          ),
                          secondary: const Icon(
                            Icons.calendar_month_outlined,
                            color: Color(0xFF00695C),
                          ),
                          value: addToAllDays,
                          onChanged: (val) {
                            setState(() {
                              addToAllDays = val;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// --- Buttons ---
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                foregroundColor: Colors.grey[700],
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                "Add Now",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
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
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: Color(0xFF00695C),
                size: 40,
              ),
              const SizedBox(height: 10),
              const Text(
                "Select Ramadan Year",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF004D40),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 350,
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    int year = 2025 + index;
                    bool isSelected = year == ctrl.selectedYear;

                    return InkWell(
                      onTap: () {
                        ctrl.changeDayOrYear(year, ctrl.selectedDay);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00695C)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00695C)
                                : Colors.transparent,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00695C,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 16,
                              ),
                            if (isSelected) const SizedBox(width: 8),
                            Text(
                              "$year",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Close",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
