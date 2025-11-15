import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/calculator/calculator_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return SafeArea(child: child ?? const SizedBox());
      },
      theme: ThemeData(
        useMaterial3: false,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.pink),
        checkboxTheme: const CheckboxThemeData(
          visualDensity: VisualDensity(horizontal: -4.0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.pink),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusColor: Colors.pink,
          floatingLabelStyle: TextStyle(color: Colors.pink),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.pink),
          ),
        ),
      ),
      themeMode: ThemeMode.light,
      home: const CaluculatorPage(),
    );
  }
}
