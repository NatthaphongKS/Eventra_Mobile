import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 อย่าลืม import firestore นะครับ
import '../models/events.dart'; 
import '../utils/app_theme.dart';
import 'event_checkin_screen.dart';
import 'event_form_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Event _event;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  String get _statusThai {
    switch (_event.status) {
      case 'ongoing':
        return 'กำลังจัด';
      case 'upcoming':
        return 'กำลังจะจัด';
      case 'done':
        return 'เสร็จสิ้น';
      default:
        return _event.status;
    }
  }

  // 💡 ฟังก์ชันสำหรับลบกิจกรรม
  Future<void> _handleDeleteEvent() async {
    // 1. โชว์ Dialog ถามเพื่อความชัวร์
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('คุณแน่ใจหรือไม่ว่าต้องการลบกิจกรรม "${_event.name}"?\nข้อมูลนี้จะไม่สามารถกู้คืนได้'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // ไม่ลบ
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // ยืนยันลบ
            child: const Text('ลบกิจกรรม', style: TextStyle(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    // 2. ถ้ากดยืนยันการลบ
    if (confirm == true) {
      try {
        // สั่งลบจาก Firestore โดยใช้ ID ของกิจกรรม
        await FirebaseFirestore.instance.collection('events').doc(_event.id).delete();
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบกิจกรรมสำเร็จ')),
        );
        
        // ลบเสร็จแล้วให้เด้งกลับไปหน้า Home
        Navigator.pop(context); 
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการลบ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _event.date;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Event Detail',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _event.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              dateStr,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: AppColors.divider),
            const SizedBox(height: 16),
            _DetailSection(title: 'รายละเอียด', content: _event.description),
            const SizedBox(height: 16),
            _DetailSection(title: 'สถานที่จัด', content: _event.location),
            const SizedBox(height: 20),
            Text(
              _event.time, 
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _DetailSection(title: 'สถานะ', content: _statusThai),
            const SizedBox(height: 32),
            
            // Buttons
            _OutlineButton(
              label: 'แก้ไข',
              color: AppColors.primary,
              onTap: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventFormScreen(event: _event),
                  ),
                );
                if (updated != null && updated is Event) {
                  setState(() => _event = updated);
                }
              },
            ),
            const SizedBox(height: 12),
            
            _FilledButton(
              label: 'เช็คชื่อผู้เข้าร่วม',
              color: AppColors.primaryDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventCheckInScreen(event: _event),
                ),
              ),
            ),
            
            const SizedBox(height: 12), // เพิ่มระยะห่าง

            // 💡 ปุ่มลบกิจกรรม สไตล์ Outline วางไว้ล่างสุด
            _OutlineButton(
              label: 'ลบกิจกรรม',
              color: AppColors.accent, // สีแดงน้ำตาล
              onTap: _handleDeleteEvent, // เรียกฟังก์ชันลบ
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
class _DetailSection extends StatelessWidget {
  final String title;
  final String content;
  const _DetailSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OutlineButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _FilledButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
