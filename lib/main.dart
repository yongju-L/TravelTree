import 'package:flutter/material.dart';
import 'package:traveltree/page/mainpage/MainPage.dart';
import 'dart:async';

void main() {
  runZonedGuarded(() {
    runApp(const TTApp());
  }, (error, stackTrace) {
    print('Caught an error: $error'); // 전역 에러를 로깅하거나 처리하는 코드
  });

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
}

class TTApp extends StatelessWidget {
  const TTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
    );
  }
}
