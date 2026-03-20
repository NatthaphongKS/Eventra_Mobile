import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // เพิ่ม import Firestore

import '../models/events.dart';
import '../utils/app_theme.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Event> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  // --- ปรับฟังก์ชันค้นหาให้ดึงข้อมูลจาก Firebase ---
  Future<void> _search(String query) async {
    final searchQuery = query.trim().toLowerCase(); // ทำให้เป็นตัวเล็กเพื่อเทียบง่ายๆ

    if (searchQuery.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }
    
    setState(() => _isSearching = true);
    
    try {
      // 1. ดึงข้อมูลกิจกรรมทั้งหมดจาก Firestore
      final snapshot = await FirebaseFirestore.instance.collection('events').get();
      
      // 2. แปลงเป็น List<Event> และกรองข้อมูลที่มีคำที่ค้นหาอยู่ในชื่อ (name)
      final allEvents = snapshot.docs
          .map((doc) => Event.fromMap(doc.id, doc.data()))
          .toList();
          
      final results = allEvents.where((event) {
        // ค้นหาจากชื่อกิจกรรม (คุณสามารถเพิ่ม || event.description.contains... เพื่อค้นหาจากรายละเอียดได้ด้วย)
        return event.name.toLowerCase().contains(searchQuery);
      }).toList();

      setState(() {
        _results = results;
        _isSearching = false;
        _hasSearched = true;
      });
    } catch (e) {
      debugPrint('Error searching events: $e');
      setState(() => _isSearching = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'ค้นหาอีเว้น...', // ตามในรูปของคุณ
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textSecondary),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onChanged: _search, // ค้นหาอัตโนมัติเมื่อพิมพ์
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('✕',
                        style: TextStyle(
                            fontSize: 20, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isSearching
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : _hasSearched && _results.isEmpty
                      ? const Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 56, color: AppColors.textSecondary),
                            SizedBox(height: 12),
                            Text('ไม่พบกิจกรรม',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16)),
                          ],
                        ))
                      : ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (_, i) => EventCard(
                            event: _results[i],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EventDetailScreen(event: _results[i]),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}