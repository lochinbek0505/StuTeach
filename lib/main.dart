import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stu_teacher/LoginPage.dart';
import 'package:stu_teacher/StudentDashboard.dart';
import 'package:stu_teacher/TeacherDashboard.dart';

import 'auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StuTeach App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Loginpage(),
    );
  }
}
