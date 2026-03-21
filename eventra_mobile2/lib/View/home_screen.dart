import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // เพิ่ม import สำหรับ Timer
import '../models/events.dart';
import '../utils/app_theme.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';
import 'search_screen.dart';
import 'login.dart';
import 'event_form_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Event> _events = [];
  bool _isLoading = true;
  Timer? _refreshTimer; // เพิ่มตัวแปร Timer

  final List<String> _tabs = ['Upcoming', 'Ongoing', 'Done'];
  final List<String> _statuses = ['upcoming', 'ongoing', 'done'];
  final List<Color> _dotColors = [
    AppColors.statusUpcoming,
    AppColors.statusOngoing,
    AppColors.statusDone,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);

    //  ดักจับการเปลี่ยน Tab เพื่อให้วาด UI ใหม่ (คำนวณ currentStatus ใหม่)
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // setState เพื่อให้หน้าจอคำนวณ .currentStatus แยกหมวดใหม่
        setState(() {});
      }
    });

    _loadEvents();

    // 💡 2. ตั้ง Timer ให้รีเฟรชหน้าจอ (คำนวณสถานะใหม่) ทุกๆ 1 นาที
    // กรณีผู้ใช้เปิดหน้าจอค้างไว้ พอถึงเวลาปุ๊บ กิจกรรมจะย้าย Tab เอง
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // 💡 อย่าลืมเคลียร์ Timer และ Controller คืนหน่วยความจำ
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // 💡 ฟังก์ชันดึงข้อมูลจาก Firebase Firestore
  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .get();

      setState(() {
        _events = snapshot.docs.map((doc) {
          final data = doc.data();
          return Event.fromMap(doc.id, data);
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading events: $e');
      setState(() => _isLoading = false);
    }
  }

  // ใช้ e.currentStatus ที่คำนวณแบบ Real-time แทนการเช็คกับ e.status ดิบจากฐานข้อมูล
  List<Event> _filteredEvents(String status) =>
      _events.where((e) => e.currentStatus == status).toList();

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onSelected: (v) {
              if (v == 'logout') _logout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'logout', child: Text('ออกจากระบบ')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          tabs: List.generate(
            _tabs.length,
            (i) => Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _dotColors[i],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(_tabs[i]),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh:
                  _loadEvents, // เวลาดึงหน้าจอลงมา จะโหลดข้อมูลจาก Firebase ใหม่
              child: TabBarView(
                controller: _tabController,
                children: List.generate(
                  _statuses.length,
                  (i) => _EventTabView(
                    events: _filteredEvents(_statuses[i]),
                    onEventTap: (event) async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailScreen(event: event),
                        ),
                      );
                      _loadEvents(); // โหลดข้อมูลใหม่เผื่อมีการแก้ไขในหน้ารายละเอียด
                    },
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventFormScreen()),
          );
          _loadEvents(); // โหลดข้อมูลใหม่หลังจากสร้าง Event เสร็จ
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _EventTabView extends StatelessWidget {
  final List<Event> events;
  final Function(Event) onEventTap;

  const _EventTabView({required this.events, required this.onEventTap});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 12),
            Text(
              'ไม่มีกิจกรรม',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: events.length,
      itemBuilder: (_, i) =>
          EventCard(event: events[i], onTap: () => onEventTap(events[i])),
    );
  }
}
