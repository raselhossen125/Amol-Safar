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
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 40,
                    color: Colors.red,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "Delete Zikr?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  "Are you sure you want to delete '$title'? This will remove it from all future lists.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 25),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ctrl.deleteAmol(index);
                          Navigator.pop(context); // Close Confirmation
                          Navigator.pop(context); // Close Bottom Sheet
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Delete"),
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

    // Default state for the toggle switch
    bool updateAllDays = true;

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder is required here to update the Switch UI
        // inside the Dialog without rebuilding the entire page.
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit Icon
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00695C).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_note,
                        size: 35,
                        color: Color(0xFF00695C),
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Update Target",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Set a new goal for this Zikr",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Input Field
                    TextField(
                      controller: textCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00695C),
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Scope Selection Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFF00695C),
                      title: const Text(
                        "Apply to all future days?",
                        style: TextStyle(fontSize: 14),
                      ),
                      value: updateAllDays,
                      onChanged: (val) {
                        setState(() {
                          updateAllDays = val;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              int? newTarget = int.tryParse(textCtrl.text);
                              if (newTarget != null && newTarget > 0) {
                                // Calls controller method with the scope flag
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            child: const Text("Save"),
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
}
