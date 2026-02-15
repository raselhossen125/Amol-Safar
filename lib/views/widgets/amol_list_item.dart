import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../controllers/amol_controller.dart';
import 'counter_sheet.dart';

/// Displays a single Amol item with progress and completion status.
class AmolListItem extends StatelessWidget {
  /// Index of the item in the controller list.
  final int index;

  const AmolListItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    /// Rebuilds only this specific item using a unique GetBuilder id.
    return GetBuilder<AmolController>(
      id: 'item_$index',
      builder: (ctrl) {
        /// Retrieve the item from controller.
        final item = ctrl.dailyAmols[index];

        /// Safely calculate progress between 0.0 and 1.0.
        double itemProgress = (item.target > 0)
            ? (item.currentCount / item.target).clamp(0.0, 1.0)
            : 0.0;

        return GestureDetector(
          /// Opens the counter bottom sheet on tap.
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => CounterSheet(index: index),
            );
          },

          /// Main card container.
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],

              /// Green border when completed.
              border: item.isCompleted
                  ? Border.all(color: Colors.green, width: 1.5)
                  : null,
            ),
            child: Row(
              children: [
                /// Circular progress indicator.
                CircularPercentIndicator(
                  radius: 22.0,
                  lineWidth: 4.0,
                  percent: itemProgress,
                  animation: true,
                  animateFromLastPercent: true,
                  progressColor: item.isCompleted
                      ? Colors.green
                      : Colors.orange,
                  backgroundColor: Colors.grey.shade200,
                  center: Text(
                    "${(itemProgress * 100).toInt()}%",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                /// Title, progress bar, and count details.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: item.isCompleted
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 5),

                      LinearPercentIndicator(
                        padding: EdgeInsets.zero,
                        lineHeight: 6.0,
                        percent: itemProgress,
                        animation: true,
                        barRadius: const Radius.circular(5),
                        progressColor: const Color(0xFF00695C),
                        backgroundColor: Colors.grey.shade200,
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "${item.currentCount} / ${item.target}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Read-only completion checkbox.
                IgnorePointer(
                  ignoring: true,
                  child: Checkbox(
                    value: item.isCompleted,
                    activeColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {},
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
