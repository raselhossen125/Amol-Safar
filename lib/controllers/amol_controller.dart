import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/amol_model.dart';

/// Controller that manages daily Amol data,
/// yearly isolation, counting logic, and statistics.
class AmolController extends GetxController {
  /// Hive box storing daily Amol data (year_day based).
  late Box<List> amolBox;

  /// Hive box storing master template list.
  late Box<List> templateBox;

  /// Currently selected year.
  int selectedYear = 2026;

  /// Currently selected Ramadan day (1–30).
  int selectedDay = 1;

  /// List of Amol items for the selected day.
  List<AmolItem> dailyAmols = [];

  /// Total target of all Amols for the day.
  int get totalTarget => dailyAmols.fold(0, (sum, item) => sum + item.target);

  /// Total completed count for the day.
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

  /// Initializes Hive boxes and ensures master template exists.
  Future<void> _initHive() async {
    amolBox = await Hive.openBox<List>('ramadan_daily_box_v3');
    templateBox = await Hive.openBox<List>('ramadan_template_box_v3');

    /// Insert default template if empty.
    if (templateBox.isEmpty) {
      await templateBox.put('master_list', _getInitialDefaults());
    }

    loadDailyData();
  }

  /// Returns default master Amol template list.
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

  /// Loads daily data for selected year and day.
  /// If not available, creates a fresh copy from template.
  void loadDailyData() {
    String dateKey = "${selectedYear}_$selectedDay";

    if (amolBox.containsKey(dateKey)) {
      dailyAmols = amolBox.get(dateKey)!.cast<AmolItem>().toList();
    } else {
      List<AmolItem> masterTemplates =
          (templateBox.get('master_list') ?? _getInitialDefaults())
              .cast<AmolItem>()
              .toList();

      dailyAmols = masterTemplates
          .map(
            (e) => AmolItem(
              title: e.title,
              target: e.target,
              currentCount: 0,
              isCompleted: false,
            ),
          )
          .toList();

      amolBox.put(dateKey, dailyAmols);
    }

    update();
    update(['dashboard_stat']);
  }

  /// Saves current day's data into Hive.
  void saveData() {
    String key = "${selectedYear}_$selectedDay";
    amolBox.put(key, dailyAmols);

    /// Update dashboard statistics.
    update(['dashboard_stat']);
  }

  /// Increments count of a specific Amol item.
  /// Handles haptic feedback and completion state.
  void incrementCount(int index) {
    var item = dailyAmols[index];
    item.currentCount++;
    HapticFeedback.lightImpact();

    /// Show snackbar at every 33 counts for selected Tasbih.
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

    /// Mark as completed when target reached.
    if (item.currentCount >= item.target && !item.isCompleted) {
      item.isCompleted = true;
      HapticFeedback.heavyImpact();
    }

    saveData();
    update(['item_$index', 'dashboard_stat']);
  }

  /// Updates target value.
  /// If global is true, updates all 30 days of the selected year.
  void updateTarget(int index, int newTarget, bool isGlobal) {
    String title = dailyAmols[index].title;

    dailyAmols[index].target = newTarget;
    dailyAmols[index].isCompleted = dailyAmols[index].currentCount >= newTarget;

    saveData();

    if (isGlobal) {
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

  /// Adds a new Amol to current day.
  /// If global is true, adds to all 30 days of selected year.
  void addNewAmol(String title, int target, bool isGlobal) {
    if (dailyAmols.any((e) => e.title == title)) return;

    dailyAmols.add(AmolItem(title: title, target: target));
    saveData();

    if (isGlobal) {
      for (int i = 1; i <= 30; i++) {
        String key = "${selectedYear}_$i";

        List<AmolItem> dayData = amolBox.containsKey(key)
            ? amolBox.get(key)!.cast<AmolItem>().toList()
            : [];

        if (dayData.isNotEmpty && !dayData.any((e) => e.title == title)) {
          dayData.add(AmolItem(title: title, target: target));
          amolBox.put(key, dayData);
        }
      }
    }

    update();
    update(['dashboard_stat']);
  }

  /// Deletes an Amol from current day.
  /// If global is true, removes from all 30 days of selected year.
  void deleteAmol(int index, bool isGlobal) {
    String title = dailyAmols[index].title;

    dailyAmols.removeAt(index);
    saveData();

    if (isGlobal) {
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
    update(['dashboard_stat']);
  }

  /// Resets count and completion state of an Amol.
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

  /// Returns monthly aggregated statistics
  /// (total counts per Amol title).
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
