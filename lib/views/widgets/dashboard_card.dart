import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../controllers/amol_controller.dart';

/// Top dashboard card displaying daily progress and statistics.
class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    /// Rebuilds only when dashboard statistics are updated.
    return GetBuilder<AmolController>(
      id: 'dashboard_stat',
      builder: (ctrl) {
        return Container(
          width: double.infinity,

          /// Main padding including safe area top spacing.
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 25,
            top: MediaQuery.of(context).padding.top + 10,
          ),

          /// Styled header background.
          decoration: const BoxDecoration(
            color: Color(0xFF00695C),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header row with date and stats button.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// Ramadan year and selected day.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "RAMADAN ${ctrl.selectedYear}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                          fontFamily: '',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Day ${ctrl.selectedDay}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  /// Opens monthly statistics bottom sheet.
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showMonthStats(context, ctrl),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.bar_chart_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Stats",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// Progress section with circular indicator and summary.
              Row(
                children: [
                  CircularPercentIndicator(
                    radius: 40.0,
                    lineWidth: 8.0,
                    percent: ctrl.progress,
                    center: Text(
                      "${(ctrl.progress * 100).toInt()}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    progressColor: Colors.white,
                    backgroundColor: Colors.white24,
                    animation: true,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),

                  const SizedBox(width: 20),

                  /// Progress text details.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Daily Progress",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontFamily: ''),
                            children: [
                              TextSpan(
                                text: "${ctrl.totalDone}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: " / ${ctrl.totalTarget}",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ctrl.progress >= 1.0
                              ? "MashaAllah! Goal Complete."
                              : "Keep going, you can do it!",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Displays monthly aggregated statistics in a bottom sheet.
  void _showMonthStats(BuildContext context, AmolController ctrl) {
    Map<String, int> stats = ctrl.getMonthStats();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Drag indicator.
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  margin: const EdgeInsets.only(bottom: 15),
                ),
              ),

              /// Title section.
              Row(
                children: [
                  const Icon(Icons.leaderboard, color: Color(0xFF00695C)),
                  const SizedBox(width: 10),
                  const Text(
                    "Monthly Summary",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00695C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                "Total counts for Ramadan ${ctrl.selectedYear}",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const Divider(height: 30),

              /// Monthly stats list.
              Expanded(
                child: stats.isEmpty
                    ? const Center(child: Text("No records found yet."))
                    : ListView.builder(
                        itemCount: stats.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          String title = stats.keys.elementAt(index);
                          int count = stats.values.elementAt(index);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF00695C,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "$count",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00695C),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
