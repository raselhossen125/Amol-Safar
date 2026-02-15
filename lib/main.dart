import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Local Imports
import 'models/amol_model.dart';
import 'views/home_view.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized before calling native code
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Hive (Local Database)
  await Hive.initFlutter();

  // 3. Register the Manual Adapter
  // This allows Hive to understand how to save/read our custom 'AmolItem' object
  Hive.registerAdapter(AmolItemAdapter());

  // 4. Run the Application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // GetMaterialApp is required for GetX features (Navigation, Snackbars, Dialogs)
    return GetMaterialApp(
      title: 'Ramadan Tracker',
      debugShowCheckedModeBanner: false, // Hides the "Debug" banner
      // -----------------------------------------------------------------------
      // GLOBAL THEME CONFIGURATION
      // -----------------------------------------------------------------------
      theme: ThemeData(
        useMaterial3: true,

        // Primary Brand Color (Deep Teal/Green)
        primaryColor: const Color(0xFF00695C),

        // Light grey background for better contrast with white cards
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),

        // App Bar Styling
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00695C),
          foregroundColor: Colors.white, // Title and icon color
        ),
      ),

      // Starting Screen
      home: const HomeView(),
    );
  }
}
