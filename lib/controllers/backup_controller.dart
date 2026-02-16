import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../models/amol_model.dart';
import 'amol_controller.dart';

/// Controller responsible for handling backup (export)
/// and restore (import) operations of Ramadan Amol data.
class BackupController extends GetxController {
  /// Reference to the main AmolController.
  final AmolController amolCtrl = Get.find<AmolController>();

  /// --------------------------------------------------------------------------
  /// 1. CREATE BACKUP (EXPORT)
  /// --------------------------------------------------------------------------

  /// Creates a JSON backup file containing:
  /// - App metadata
  /// - Master template list
  /// - All daily data
  /// Then shares the file using system share options.
  Future<void> createBackup() async {
    try {
      /// Show loading indicator.
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final Box<List> dailyBox = Hive.box<List>('ramadan_daily_box_v3');
      final Box<List> templateBox = Hive.box<List>('ramadan_template_box_v3');

      /// Base backup structure.
      Map<String, dynamic> backupData = {
        'version': '1.1',
        'timestamp': DateTime.now().toIso8601String(),
        'app_name': 'RamadanAmolTracker',
        'master_template': [],
        'data': {},
      };

      /// Backup master template list.
      if (templateBox.containsKey('master_list')) {
        var masterRaw = templateBox.get('master_list');
        backupData['master_template'] = masterRaw!
            .cast<AmolItem>()
            .map((e) => e.toJson())
            .toList();
      }

      /// Backup all daily entries.
      for (var key in dailyBox.keys) {
        var rawList = dailyBox.get(key);
        if (rawList != null) {
          backupData['data'][key.toString()] = rawList
              .cast<AmolItem>()
              .map((e) => e.toJson())
              .toList();
        }
      }

      /// Convert to JSON and write temporary file.
      String jsonString = jsonEncode(backupData);
      final directory = await getTemporaryDirectory();
      String dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final file = File('${directory.path}/Ramadan_Backup_$dateStr.json');
      await file.writeAsString(jsonString);

      if (Get.isDialogOpen ?? false) Get.back();

      /// Share the backup file.
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'My Ramadan Amol Tracker Backup ($dateStr)');
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();

      /// Show error message if backup fails.
      Get.snackbar(
        "Backup Failed",
        "Error: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// --------------------------------------------------------------------------
  /// 2. RESTORE BACKUP (IMPORT)
  /// --------------------------------------------------------------------------

  /// Opens file picker and allows user to select a JSON backup file.
  /// Shows confirmation dialog before restoring.
  Future<void> restoreBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);

        /// Confirmation dialog before replacing existing data.
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Column(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 50,
                ),
                SizedBox(height: 10),
                Text(
                  "Restore Data?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              "All current data will be replaced with the backup file. This cannot be undone.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  Get.back();
                  await _processRestore(file);
                },
                child: const Text(
                  "RESTORE",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      /// Show file picker error.
      Get.snackbar(
        "Error",
        "Picker Error: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Processes the restore operation:
  /// - Clears existing data
  /// - Restores master template
  /// - Restores daily data
  /// - Refreshes UI
  Future<void> _processRestore(File file) async {
    try {
      /// Show loading indicator during restore.
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      String jsonString = await file.readAsString();
      Map<String, dynamic> decodedData = jsonDecode(jsonString);

      if (decodedData['data'] == null) {
        throw "Invalid File Structure";
      }

      final Box<List> dailyBox = Hive.box<List>('ramadan_daily_box_v3');
      final Box<List> templateBox = Hive.box<List>('ramadan_template_box_v3');

      /// Clear existing data before restore.
      await dailyBox.clear();
      await templateBox.clear();

      /// Restore master template if available.
      if (decodedData['master_template'] != null) {
        List<dynamic> masterJson = decodedData['master_template'];

        List<AmolItem> masterList = masterJson
            .map((e) => AmolItem.fromJson(e))
            .toList();

        await templateBox.put('master_list', masterList);
      }

      /// Restore daily data entries.
      Map<String, dynamic> dataMap = decodedData['data'];

      for (var key in dataMap.keys) {
        List<dynamic> jsonList = dataMap[key];

        List<AmolItem> amolList = jsonList
            .map((jsonItem) => AmolItem.fromJson(jsonItem))
            .toList();

        await dailyBox.put(key, amolList);
      }

      if (Get.isDialogOpen ?? false) Get.back();

      /// Refresh UI after restore.
      amolCtrl.loadDailyData();

      Get.snackbar(
        "Success",
        "Alhamdulillah! Data Restored Successfully.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();

      /// Show restore failure message.
      Get.snackbar(
        "Error",
        "Restore Failed: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
