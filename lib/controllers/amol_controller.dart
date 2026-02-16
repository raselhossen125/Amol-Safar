import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/amol_model.dart';

/// Controller responsible for managing daily Amol data,
/// template data, counting logic, and monthly statistics.
class AmolController extends GetxController {
  /// Hive box that stores daily Amol data (30 days per year).
  late Box<List> amolBox;

  /// Hive box that stores the master template list.
  late Box<List> templateBox;

  /// Currently selected year.
  int selectedYear = 2026;

  /// Currently selected Ramadan day (1–30).
  int selectedDay = 1;

  /// List of Amol items for the selected day.
  List<AmolItem> dailyAmols = [];

  /// Total target count of all Amols for the day.
  int get totalTarget => dailyAmols.fold(0, (sum, item) => sum + item.target);

  /// Total completed count of all Amols for the day.
  int get totalDone =>
      dailyAmols.fold(0, (sum, item) => sum + item.currentCount);

  /// Overall progress ratio (0.0 – 1.0).
  double get progress =>
      totalTarget == 0 ? 0.0 : (totalDone / totalTarget).clamp(0.0, 1.0);

  @override
  void onInit() {
    super.onInit();
    _initHive();
  }

  /// Initializes Hive boxes and loads initial data.
  Future<void> _initHive() async {
    amolBox = await Hive.openBox<List>('ramadan_daily_box_v3');
    templateBox = await Hive.openBox<List>('ramadan_template_box_v3');

    /// If template is empty, insert default Amol list.
    if (templateBox.isEmpty) {
      await templateBox.put('master_list', _getInitialDefaults());
    }

    loadDailyData();
  }

  /// Returns the default master Amol template list.
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

  /// Loads daily data for the selected year and day.
  /// If no data exists, it creates a fresh copy from master template.
  void loadDailyData() {
    String dateKey = "${selectedYear}_$selectedDay";

    List<AmolItem> masterTemplates =
        (templateBox.get('master_list') ?? _getInitialDefaults())
            .cast<AmolItem>();

    List<AmolItem> todayData = [];

    if (amolBox.containsKey(dateKey)) {
      todayData = amolBox.get(dateKey)!.cast<AmolItem>().toList();
    } else {
      todayData = masterTemplates
          .map(
            (e) => AmolItem(
              title: e.title,
              target: e.target,
              currentCount: 0,
              isCompleted: false,
            ),
          )
          .toList();

      amolBox.put(dateKey, todayData);
    }

    dailyAmols = todayData;
    update();
  }

  /// Saves the current day's data into Hive.
  void saveData() {
    String key = "${selectedYear}_$selectedDay";
    amolBox.put(key, dailyAmols);

    /// Update only dashboard statistics UI.
    update(['dashboard_stat']);
  }

  /// Increments the count of a specific Amol item.
  /// Triggers light haptic feedback and completion logic.
  void incrementCount(int index) {
    var item = dailyAmols[index];
    item.currentCount++;
    HapticFeedback.lightImpact();

    /// Shows a snackbar alert at every 33 counts
    /// for selected Tasbih items.
    if (["Subhanallah", "Alhamdulillah", "Allahu Akbar"].contains(item.title)) {
      if (item.currentCount > 0 && item.currentCount % 33 == 0) {
        Get.snackbar(
          "33 Completed",
          "${item.title} 33 times",
          snackPosition: SnackPosition.TOP,
          duration: 1.seconds,
        );
      }
    }

    /// Marks as completed if target reached.
    if (item.currentCount >= item.target && !item.isCompleted) {
      item.isCompleted = true;
      HapticFeedback.heavyImpact();
    }

    saveData();
    update(['item_$index', 'dashboard_stat']);
  }

  /// Updates the target of a specific Amol.
  /// If global is true, updates master list and all 30 days.
  void updateTarget(int index, int newTarget, bool isGlobal) {
    String title = dailyAmols[index].title;

    dailyAmols[index].target = newTarget;
    dailyAmols[index].isCompleted = dailyAmols[index].currentCount >= newTarget;

    saveData();

    if (isGlobal) {
      List<AmolItem> master = (templateBox.get('master_list') ?? [])
          .cast<AmolItem>()
          .toList();

      for (var e in master) {
        if (e.title == title) e.target = newTarget;
      }

      templateBox.put('master_list', master);

      /// Update all existing daily entries of this year.
      for (int i = 1; i <= 30; i++) {
        String key = "${selectedYear}_$i";

        if (amolBox.containsKey(key)) {
          List<AmolItem> dayData = amolBox.get(key)!.cast<AmolItem>().toList();

          for (var e in dayData) {
            if (e.title == title) e.target = newTarget;
          }

          amolBox.put(key, dayData);
        }
      }
    }

    update(['item_$index', 'dashboard_stat']);
  }

  /// Adds a new Amol item.
  /// If global is true, it is added to master and all 30 days.
  void addNewAmol(String title, int target, bool isGlobal) {
    if (dailyAmols.any((e) => e.title == title)) return;

    dailyAmols.add(AmolItem(title: title, target: target));
    saveData();

    if (isGlobal) {
      List<AmolItem> master = (templateBox.get('master_list') ?? [])
          .cast<AmolItem>()
          .toList();

      if (!master.any((e) => e.title == title)) {
        master.add(AmolItem(title: title, target: target));
        templateBox.put('master_list', master);
      }

      /// Ensures new Amol exists in all 30 days.
      for (int i = 1; i <= 30; i++) {
        String key = "${selectedYear}_$i";

        List<AmolItem> dayData = amolBox.containsKey(key)
            ? amolBox.get(key)!.cast<AmolItem>().toList()
            : master
                  .map((e) => AmolItem(title: e.title, target: e.target))
                  .toList();

        if (!dayData.any((e) => e.title == title)) {
          dayData.add(AmolItem(title: title, target: target));
        }

        amolBox.put(key, dayData);
      }
    }

    update();
  }

  /// Deletes an Amol item.
  /// If global is true, removes from master and all 30 days.
  void deleteAmol(int index, bool isGlobal) {
    String title = dailyAmols[index].title;

    dailyAmols.removeAt(index);
    saveData();

    if (isGlobal) {
      List<AmolItem> master = (templateBox.get('master_list') ?? [])
          .cast<AmolItem>()
          .toList();

      master.removeWhere((e) => e.title == title);
      templateBox.put('master_list', master);

      /// Remove from all 30 days.
      for (int i = 1; i <= 30; i++) {
        String key = "${selectedYear}_$i";

        if (amolBox.containsKey(key)) {
          List<AmolItem> dayData = amolBox.get(key)!.cast<AmolItem>().toList();

          dayData.removeWhere((e) => e.title == title);
          amolBox.put(key, dayData);
        }
      }
    }

    update();
  }

  /// Resets count and completion state of a specific Amol.
  void resetAmol(int index) {
    dailyAmols[index].currentCount = 0;
    dailyAmols[index].isCompleted = false;

    saveData();
    update(['item_$index', 'dashboard_stat']);
  }

  /// Changes selected year or day and reloads data.
  void changeDayOrYear(int year, int day) {
    selectedYear = year;
    selectedDay = day;
    loadDailyData();
  }

  /// Returns aggregated monthly statistics
  /// (total count per Amol title).
  Map<String, int> getMonthStats() {
    Map<String, int> stats = {};
    for (int i = 1; i <= 30; i++) {
      String key = "${selectedYear}_$i";
      if (amolBox.containsKey(key)) {
        var rawList = amolBox.get(key);
        if (rawList != null) {
          List<AmolItem> dayList = rawList.cast<AmolItem>();
          for (var item in dayList) {
            stats[item.title] = (stats[item.title] ?? 0) + item.currentCount;
          }
        }
      }
    }
    return stats;
  }
}
