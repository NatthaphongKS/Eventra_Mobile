import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // เริ่มต้นระบบบันทึกข้อมูล
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();

    // เช็คว่าในเครื่องมีข้อมูล user ไหม
    bool isLoggedIn = box.hasData('user');

    return GetMaterialApp(
      title: 'Flutter Laravel Demo',
      debugShowCheckedModeBanner: false,
      // ถ้า Login อยู่แล้วไป /home ถ้าไม่มีไป /login
      initialRoute: isLoggedIn ? '/home' : '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginView()),
        GetPage(name: '/home', page: () => HomeView()),
      ],
    );
  }
}
