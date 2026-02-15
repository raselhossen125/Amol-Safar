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

/// Controller responsible for exporting and restoring
/// Ramadan Amol data using JSON backup files.
class BackupController extends GetxController {
  /// Reference to AmolController for refreshing UI after restore.
  final AmolController amolCtrl = Get.find<AmolController>();

  /// Creates a JSON backup file from Hive data
  /// and shares it via system share dialog.
  Future<void> createBackup() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final Box<List> dailyBox = Hive.box<List>('ramadan_daily_box_v3');

      Map<String, dynamic> backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'app_name': 'RamadanAmolTracker',
        'data': {},
      };

      for (var key in dailyBox.keys) {
        var rawList = dailyBox.get(key);
        if (rawList != null) {
          List<Map<String, dynamic>> jsonList = rawList
              .cast<AmolItem>()
              .map((e) => e.toJson())
              .toList();

          backupData['data'][key.toString()] = jsonList;
        }
      }

      String jsonString = jsonEncode(backupData);

      final directory = await getTemporaryDirectory();
      String dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());

      final file = File('${directory.path}/Ramadan_Backup_$dateStr.json');

      await file.writeAsString(jsonString);

      if (Get.isDialogOpen ?? false) Get.back();

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'My Ramadan Amol Tracker Backup ($dateStr)');
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();

      print("Backup Error: $e");

      Get.snackbar(
        "Backup Failed",
        "Error: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  /// Opens file picker to select a JSON backup file
  /// and shows a confirmation dialog before restoring.
  Future<void> restoreBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);

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
              "This will delete all your current progress and replace it with the data from the backup file. This action cannot be undone.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  Get.back();
                  await _processRestore(file);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "RESTORE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Picker Error: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Processes restore operation:
  /// - Clears existing Hive data
  /// - Inserts data from backup file
  /// - Reloads UI data
  Future<void> _processRestore(File file) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      String jsonString = await file.readAsString();

      Map<String, dynamic> decodedData = jsonDecode(jsonString);

      if (decodedData['data'] == null) {
        throw "Invalid File";
      }

      final Box<List> dailyBox = Hive.box<List>('ramadan_daily_box_v3');

      await dailyBox.clear();

      Map<String, dynamic> dataMap = decodedData['data'];

      for (var key in dataMap.keys) {
        List<dynamic> jsonList = dataMap[key];

        List<AmolItem> amolList = jsonList
            .map((jsonItem) => AmolItem.fromJson(jsonItem))
            .toList();

        await dailyBox.put(key, amolList);
      }

      if (Get.isDialogOpen ?? false) Get.back();

      amolCtrl.loadDailyData();

      Get.snackbar(
        "Success",
        "Data Restored!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();

      Get.snackbar(
        "Error",
        "Restore Failed: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
