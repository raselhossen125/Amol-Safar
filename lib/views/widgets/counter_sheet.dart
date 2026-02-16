import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/amol_controller.dart';

/// A Modal Bottom Sheet widget that provides a detailed view for a specific Zikr.
///
/// Features:
/// 1. Large tap area for counting.
/// 2. Target editing (with global scope option).
/// 3. Reset and Delete functionalities.
class CounterSheet extends StatelessWidget {
  /// The index of the item in the [AmolController.dailyAmols] list.
  final int index;

  const CounterSheet({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    // GetBuilder ensures this sheet updates in real-time when the count changes.
    // We use the unique ID 'item_$index' to listen to specific item updates.
    return GetBuilder<AmolController>(
      id: 'item_$index',
      builder: (ctrl) {
        final item = ctrl.dailyAmols[index];

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ---------------------------------------------------------------
              // 1. DRAG HANDLE
              // ---------------------------------------------------------------
              Container(
                height: 4,
                width: 40,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.only(bottom: 20),
              ),

              // ---------------------------------------------------------------
              // 2. HEADER (Title & Target Edit)
              // ---------------------------------------------------------------
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // Edit Target Button
              InkWell(
                onTap: () =>
                    _showEditTargetDialog(context, ctrl, index, item.target),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Target: ${item.target}",
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.edit, size: 14, color: Colors.blueGrey),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ---------------------------------------------------------------
              // 3. MAIN INTERACTION AREA (Circular Tap Button)
              // ---------------------------------------------------------------
              GestureDetector(
                onTap: () => ctrl.incrementCount(index),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00695C).withOpacity(0.1),
                    border: Border.all(
                      color: const Color(0xFF00695C),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00695C).withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${item.currentCount}",
                        style: const TextStyle(
                          fontSize: 65,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00695C),
                        ),
                      ),
                      const Text(
                        "TAP HERE",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ---------------------------------------------------------------
              // 4. FOOTER CONTROLS (Delete, Reset, Done)
              // ---------------------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Delete Button
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(
                      context,
                      ctrl,
                      item.title,
                      index,
                    ),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.grey,
                      size: 28,
                    ),
                    tooltip: "Delete Zikr",
                  ),

                  // Reset Button
                  TextButton.icon(
                    onPressed: () => ctrl.resetAmol(index),
                    icon: const Icon(Icons.refresh, color: Colors.orange),
                    label: const Text(
                      "Reset",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),

                  // Done / Close Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00695C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Done"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Displays a confirmation dialog before deleting an item.
  /// Warns the user that this action affects the global list.
  void _showDeleteConfirmation(
    BuildContext context,
    AmolController ctrl,
    String title,
    int index,
  ) {
    bool deleteAllFuture = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Warning Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Delete Zikr?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Are you sure you want to remove '$title'?",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),

                    // Scope Selection Card
                    Container(
                      decoration: BoxDecoration(
                        color: deleteAllFuture
                            ? Colors.red.withOpacity(0.05)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: deleteAllFuture
                              ? Colors.red.withOpacity(0.2)
                              : Colors.transparent,
                        ),
                      ),
                      child: SwitchListTile(
                        activeColor: Colors.red,
                        title: const Text(
                          "Remove from all future days?",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        secondary: Icon(
                          Icons.auto_delete_rounded,
                          color: deleteAllFuture ? Colors.red : Colors.grey,
                        ),
                        value: deleteAllFuture,
                        onChanged: (val) {
                          setState(() => deleteAllFuture = val);
                        },
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ctrl.deleteAmol(index, deleteAllFuture);
                              Navigator.pop(context); // Close Confirmation
                              Navigator.pop(
                                context,
                              ); // Close Bottom Sheet (Counter sheet)
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Delete",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Displays a dialog to update the target count.
  /// Includes a switch to apply the change globally (Master List).
  void _showEditTargetDialog(
    BuildContext context,
    AmolController ctrl,
    int index,
    int currentTarget,
  ) {
    TextEditingController textCtrl = TextEditingController(
      text: currentTarget.toString(),
    );

    bool updateAllDays = true;

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
                      // Top Handle
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      // Icon & Title
                      const Icon(
                        Icons.track_changes_rounded,
                        size: 45,
                        color: Color(0xFF00695C),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Update Target",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF004D40),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Adjust your goal for this Zikr",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 25),

                      /// --- Modern Input Field ---
                      TextField(
                        controller: textCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        autofocus: true,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00695C),
                        ),
                        decoration: InputDecoration(
                          labelText: "New Target",
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          filled: true,
                          fillColor: Colors.grey[100],
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
                            vertical: 20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// --- Switch Card ---
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SwitchListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          activeColor: const Color(0xFF00695C),
                          title: const Text(
                            "Apply to all future days?",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF004D40),
                            ),
                          ),
                          secondary: const Icon(
                            Icons.auto_mode_rounded,
                            color: Color(0xFF00695C),
                          ),
                          value: updateAllDays,
                          onChanged: (val) {
                            setState(() {
                              updateAllDays = val;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Action Buttons
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
                                int? newTarget = int.tryParse(textCtrl.text);
                                if (newTarget != null && newTarget > 0) {
                                  ctrl.updateTarget(
                                    index,
                                    newTarget,
                                    updateAllDays,
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
                                "Save Changes",
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
}
