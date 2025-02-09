import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ozisan_with_text_field/sign_up_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 画面の向きを縦に固定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ozisan Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // テキストサイズを固定
            textScaler: TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
      home: const OzisanPage(),
    );
  }
}
