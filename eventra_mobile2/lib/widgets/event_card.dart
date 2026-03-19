import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../core/app_theme.dart'; // ตรวจสอบว่า path ถูกต้อง (บางที่ใช้ core/app_theme)

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  // ปรับให้ดึงจาก evnStatus
  Color get _statusColor {
    switch (event.evnStatus) {
      case 'ongoing':
        return AppColors.statusOngoing;
      case 'upcoming':
        return AppColors.statusUpcoming;
      case 'done':
        return AppColors.statusDone;
      default:
        return Colors.grey;
    }
  }

  // ปรับให้ดึงจาก evnStatus และทำตัวพิมพ์ใหญ่ตัวแรก
  String get _statusLabel {
    if (event.evnStatus == null) return 'Unknown';
    return event.evnStatus![0].toUpperCase() + event.evnStatus!.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    // จัดการเรื่องวันที่ ถ้า evnDate เป็น null ให้แสดงค่าว่างหรือข้อความเตือน
    final dateStr = event.evnDate != null
        ? DateFormat('d MMMM yyyy', 'th').format(event.evnDate!)
        : 'ไม่ระบุวันที่';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // เปลี่ยนจาก event.name เป็น event.evnTitle
                  Text(
                    event.evnTitle ?? 'ไม่มีชื่อกิจกรรม',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // เปลี่ยนจาก event.description เป็น event.evnDescription
                  if (event.evnDescription != null &&
                      event.evnDescription!.isNotEmpty)
                    _InfoRow(
                      icon: Icons.article_outlined,
                      text: event.evnDescription!,
                    ),

                  _InfoRow(icon: Icons.calendar_today_outlined, text: dateStr),

                  // ใช้ Helper timeRange ที่ Ohm เขียนไว้ใน Model ได้เลย
                  _InfoRow(
                    icon: Icons.access_time_outlined,
                    text: event.timeRange,
                  ),

                  // เปลี่ยนจาก participantCount เป็น evnLocation เพราะใน Model ใหม่ไม่มีจำนวนคน
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    text: event.evnLocation ?? 'ไม่ระบุสถานที่',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // สถานะ (Status Badge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _statusColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Text(
                _statusLabel,
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
