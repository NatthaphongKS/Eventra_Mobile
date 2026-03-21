import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/events.dart';
import '../utils/app_theme.dart';

class EventCheckInScreen extends StatefulWidget {
  final Event event;
  const EventCheckInScreen({super.key, required this.event});

  @override
  State<EventCheckInScreen> createState() => _EventCheckInScreenState();
}

class _EventCheckInScreenState extends State<EventCheckInScreen> {
  // 💡 ฟังก์ชันสลับสถานะเช็คชื่อ โดยบันทึก ID แขกลงใน Array ของ Event นั้นๆ
  Future<void> _toggleCheckIn(String guestId, bool isCurrentlyCheckedIn) async {
    final eventRef = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.event.id);

    try {
      if (isCurrentlyCheckedIn) {
        // ถ้าเช็คอินอยู่แล้ว -> เอา ID ออกจาก Array (ยกเลิกเช็คชื่อ)
        await eventRef.update({
          'checkedInList': FieldValue.arrayRemove([guestId]),
        });
      } else {
        // ถ้ายังไม่เช็คอิน -> เพิ่ม ID เข้าไปใน Array (เช็คชื่อ)
        await eventRef.update({
          'checkedInList': FieldValue.arrayUnion([guestId]),
        });
      }
    } catch (e) {
      debugPrint('Error updating check-in status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = widget.event.date;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Event Check-In',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      // 💡 StreamBuilder ตัวแรก: ดึงข้อมูล Event เพื่อดูว่าใครเช็คชื่อไปแล้วบ้าง
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(widget.event.id)
            .snapshots(),
        builder: (context, eventSnapshot) {
          if (eventSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // ดึงรายชื่อ Array ของคนที่เช็คอินแล้วจาก Event
          final eventData = eventSnapshot.data?.data() as Map<String, dynamic>?;
          final List<dynamic> checkedInList = eventData?['checkedInList'] ?? [];
          final checkedInCount = checkedInList.length;

          // 💡 StreamBuilder ตัวที่สอง: ดึงรายชื่อแขก 11 คน (จาก Collection หลัก)
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('guests').snapshots(),
            builder: (context, guestsSnapshot) {
              if (guestsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final guestsDocs = guestsSnapshot.data?.docs ?? [];
              final totalCount = guestsDocs.length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'รวมรายชื่อเช็คแล้ว',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '$checkedInCount/$totalCount',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: totalCount > 0
                                  ? checkedInCount / totalCount
                                  : 0,
                              minHeight: 10,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.green,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  Expanded(
                    child: guestsDocs.isEmpty
                        ? const Center(
                            child: Text(
                              'ยังไม่มีรายชื่อผู้เข้าร่วมในระบบ',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.separated(
                            itemCount: totalCount,
                            separatorBuilder: (_, _) => const Divider(
                              height: 1,
                              color: AppColors.divider,
                            ),
                            itemBuilder: (_, i) {
                              final doc = guestsDocs[i];
                              final guestId = doc.id;
                              final data = doc.data() as Map<String, dynamic>;

                              // 💡 ใช้ชื่อฟิลด์ตาม Firebase ในรูปของคุณ
                              final firstName = data['first_name'] ?? '';
                              final lastName = data['last_name'] ?? '';
                              final fullName = '$firstName $lastName'.trim();
                              final firstLetter = firstName.isNotEmpty
                                  ? firstName[0].toUpperCase()
                                  : '?';

                              // 💡 เช็คว่า ID ของคนนี้ อยู่ใน Array การเช็คชื่อของ Event นี้หรือเปล่า
                              final isCheckedIn = checkedInList.contains(
                                guestId,
                              );

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  child: Text(
                                    firstLetter,
                                    style: const TextStyle(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  fullName.isEmpty ? 'ไม่ระบุชื่อ' : fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: GestureDetector(
                                  onTap: () =>
                                      _toggleCheckIn(guestId, isCheckedIn),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isCheckedIn
                                          ? AppColors.statusDone
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isCheckedIn
                                            ? AppColors.statusDone
                                            : AppColors.textSecondary
                                                  .withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isCheckedIn
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 18,
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
