import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/amol_model.dart';

/// Controller responsible for managing daily Amol tracking,
/// Hive storage, and user actions.
class AmolController extends GetxController {
  /// Hive box storing daily Amol data by date key.
  late Box<List> amolBox;

  /// Hive box storing master template list.
  late Box<List> templateBox;

  /// Currently selected year.
  int selectedYear = 2026;

  /// Currently selected day.
  int selectedDay = 1;

  /// List of Amol items for the selected date.
  List<AmolItem> dailyAmols = [];

  /// Total target count of all items.
  int get totalTarget => dailyAmols.fold(0, (sum, item) => sum + item.target);

  /// Total completed count of all items.
  int get totalDone =>
      dailyAmols.fold(0, (sum, item) => sum + item.currentCount);

  /// Overall progress ratio (0.0 - 1.0).
  double get progress {
    if (totalTarget == 0) return 0.0;
    double val = totalDone / totalTarget;
    return val > 1.0 ? 1.0 : val;
  }

  @override
  void onInit() {
    super.onInit();
    _initHive();
  }

  /// Initializes Hive boxes and loads initial data.
  Future<void> _initHive() async {
    amolBox = await Hive.openBox<List>('ramadan_daily_box_v3');
    templateBox = await Hive.openBox<List>('ramadan_template_box_v3');

    if (templateBox.isEmpty) {
      await templateBox.put('master_list', _getInitialDefaults());
    }

    loadDailyData();
  }

  /// Returns default Amol template list.
  List<AmolItem> _getInitialDefaults() {
    return [
      AmolItem(title: "Subhanallah", target: 200),
      AmolItem(title: "Alhamdulillah", target: 200),
      AmolItem(title: "Allahu Akbar", target: 200),
      AmolItem(title: "Astaghfirullah", target: 100),
      AmolItem(title: "La ilaha illallah", target: 100),
      AmolItem(title: "Subhanallahi wa bihamdihi", target: 100),
      AmolItem(title: "La ilaha illallahu wahdahu...", target: 100),
      AmolItem(title: "Surah Ikhlas", target: 15),
      AmolItem(title: "Surah Falak", target: 10),
      AmolItem(title: "Surah Nas", target: 10),
    ];
  }

  /// Loads daily data and syncs with master template.
  void loadDailyData() {
    String dateKey = "${selectedYear}_$selectedDay";

    List<dynamic> rawTemplates =
        templateBox.get('master_list') ?? _getInitialDefaults();
    List<AmolItem> masterTemplates = rawTemplates.cast<AmolItem>();

    List<AmolItem> todayData = [];
    if (amolBox.containsKey(dateKey)) {
      todayData = amolBox.get(dateKey)!.cast<AmolItem>();
    }

    for (var template in masterTemplates) {
      bool exists = todayData.any((element) => element.title == template.title);

      if (!exists) {
        todayData.add(
          AmolItem(
            title: template.title,
            target: template.target,
            currentCount: 0,
            isCompleted: false,
          ),
        );
      }
    }

    dailyAmols = todayData;
    saveData();
    update();
  }

  /// Saves current daily data to Hive.
  void saveData() {
    String key = "${selectedYear}_$selectedDay";
    amolBox.put(key, dailyAmols);
    update(['dashboard_stat']);
  }

  /// Increments count of a specific item.
  /// Handles 33-count notification and completion state.
  void incrementCount(int index) {
    var item = dailyAmols[index];
    item.currentCount++;
    HapticFeedback.lightImpact();

    if (["Subhanallah", "Alhamdulillah", "Allahu Akbar"].contains(item.title)) {
      if (item.currentCount > 0 && item.currentCount % 33 == 0) {
        Get.snackbar(
          "33 Counts Completed",
          "You have recited ${item.title} 33 times.",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.blueGrey,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
        );
      }
    }

    if (item.currentCount >= item.target && !item.isCompleted) {
      item.isCompleted = true;
      HapticFeedback.heavyImpact();
      Get.snackbar(
        "Alhamdulillah",
        "${item.title} Completed!",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
      );
    }

    saveData();
    update(['item_$index', 'dashboard_stat']);
  }

  /// Updates target value for current day.
  /// If [isGlobal] is true, updates master template as well.
  void updateTarget(int index, int newTarget, bool isGlobal) {
    var item = dailyAmols[index];

    item.target = newTarget;
    item.isCompleted = item.currentCount >= item.target;
    saveData();

    if (isGlobal) {
      List<dynamic> rawTemplates = templateBox.get('master_list') ?? [];
      List<AmolItem> masterTemplates = rawTemplates.cast<AmolItem>();

      for (var masterItem in masterTemplates) {
        if (masterItem.title == item.title) {
          masterItem.target = newTarget;
          break;
        }
      }
      templateBox.put('master_list', masterTemplates);
    }

    update(['item_$index', 'dashboard_stat']);
  }

  /// Adds a new Amol item.
  /// If [isGlobal] is true, adds to master list and future days.
  void addNewAmol(String title, int target, bool isGlobal) {
    AmolItem newItem = AmolItem(
      title: title,
      target: target,
      currentCount: 0,
      isCompleted: false,
    );

    if (!dailyAmols.any((e) => e.title == title)) {
      dailyAmols.add(newItem);
      saveData();
    }

    if (isGlobal) {
      List<dynamic> rawTemplates = templateBox.get('master_list') ?? [];
      List<AmolItem> masterTemplates = rawTemplates.cast<AmolItem>();

      if (!masterTemplates.any((e) => e.title == title)) {
        masterTemplates.add(AmolItem(title: title, target: target));
        templateBox.put('master_list', masterTemplates);
      }

      for (int i = selectedDay + 1; i <= 30; i++) {
        String futureKey = "${selectedYear}_$i";
        List<AmolItem> futureList = [];

        if (amolBox.containsKey(futureKey)) {
          var rawList = amolBox.get(futureKey);
          if (rawList != null) {
            futureList = List<AmolItem>.from(rawList.cast<AmolItem>());
          }
        } else {
          futureList = masterTemplates
              .map(
                (e) => AmolItem(
                  title: e.title,
                  target: e.target,
                  currentCount: 0,
                  isCompleted: false,
                ),
              )
              .toList();
        }

        if (!futureList.any((item) => item.title == title)) {
          futureList.add(
            AmolItem(
              title: title,
              target: target,
              currentCount: 0,
              isCompleted: false,
            ),
          );

          amolBox.put(futureKey, futureList);
        } else if (!amolBox.containsKey(futureKey)) {
          amolBox.put(futureKey, futureList);
        }
      }
    }

    update();
  }

  /// Deletes an item from daily list and master template.
  void deleteAmol(int index) {
    String titleToRemove = dailyAmols[index].title;

    dailyAmols.removeAt(index);
    saveData();

    List<dynamic> rawTemplates = templateBox.get('master_list') ?? [];
    List<AmolItem> masterTemplates = rawTemplates.cast<AmolItem>();

    masterTemplates.removeWhere((item) => item.title == titleToRemove);
    templateBox.put('master_list', masterTemplates);

    update();
  }

  /// Resets count and completion state of an item.
  void resetAmol(int index) {
    dailyAmols[index].currentCount = 0;
    dailyAmols[index].isCompleted = false;
    saveData();
    update(['item_$index', 'dashboard_stat']);

    Get.snackbar(
      "Reset",
      "Count reset to 0",
      duration: const Duration(seconds: 1),
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Changes selected date and reloads data.
  void changeDayOrYear(int year, int day) {
    selectedYear = year;
    selectedDay = day;
    loadDailyData();
  }

  /// Returns aggregated monthly statistics (Day 1–30).
  Map<String, int> getMonthStats() {
    Map<String, int> stats = {};
    for (int i = 1; i <= 30; i++) {
      String key = "${selectedYear}_$i";
      if (amolBox.containsKey(key)) {
        List<dynamic> dayList = amolBox.get(key)!;
        for (var item in dayList) {
          if (item is AmolItem) {
            stats[item.title] = (stats[item.title] ?? 0) + item.currentCount;
          }
        }
      }
    }
    return stats;
  }
}
