import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/amol_controller.dart';

/// Horizontal day selector for choosing a Ramadan day (1–30).
class DaySelector extends StatelessWidget {
  const DaySelector({super.key});

  @override
  Widget build(BuildContext context) {
    /// Access controller instance.
    final AmolController ctrl = Get.find();

    /// Horizontal scrollable day list.
    return SizedBox(
      height: 65,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        itemBuilder: (context, index) {
          /// Convert index to actual day number.
          int day = index + 1;

          /// Rebuilds when controller state updates.
          return GetBuilder<AmolController>(
            builder: (_) {
              /// Check if this day is currently selected.
              bool isSelected = day == ctrl.selectedDay;

              return GestureDetector(
                /// Change selected day if different.
                onTap: () {
                  if (!isSelected) {
                    ctrl.changeDayOrYear(ctrl.selectedYear, day);
                  }
                },

                /// Animated visual container for smooth transitions.
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00695C) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFF00695C).withOpacity(0.4)
                            : Colors.grey.withOpacity(0.1),
                        blurRadius: isSelected ? 6 : 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: isSelected
                        ? Border.all(color: Colors.transparent)
                        : Border.all(color: Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Day",
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? Colors.white70
                              : Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        "$day",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
