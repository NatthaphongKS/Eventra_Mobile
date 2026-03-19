import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import Views
import 'views/login_view.dart';
import 'views/event_list_view.dart';
import 'views/event_details_view.dart';
import 'views/event_form_view.dart';
import 'views/event_checkin_view.dart';
import 'views/search_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // เริ่มต้น Storage
  await initializeDateFormatting('th', null); // รองรับวันที่ภาษาไทย

  runApp(const EventraApp());
}

class EventraApp extends StatelessWidget {
  const EventraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();

    // เช็คว่าเคย Login ค้างไว้ไหม
    String initialRoute = box.hasData('user') ? '/home' : '/login';

    return GetMaterialApp(
      title: 'Eventra MS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/login', page: () => LoginView()),
        GetPage(name: '/home', page: () => EventListView()),
        GetPage(name: '/event-details', page: () => const EventDetailsView()),
        GetPage(name: '/event-form', page: () => const EventFormView()),
        GetPage(name: '/checkin', page: () => EventCheckinView()),
        GetPage(name: '/search', page: () => SearchView()),
      ],
    );
  }
}
