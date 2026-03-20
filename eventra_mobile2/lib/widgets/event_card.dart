// widget event card
import 'package:flutter/material.dart';
import '../models/events.dart'; // แก้ชื่อไฟล์ให้ตรงกับของคุณ (เดิม events.dart)
import '../utils/app_theme.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  Color get _statusColor {
    switch (event.currentStatus) {
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

  String get _statusLabel {
    switch (event.currentStatus) {
      case 'ongoing':
        return 'Ongoing';
      case 'upcoming':
        return 'Upcoming';
      case 'done':
        return 'Done';
      default:
        return event.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 ไม่ต้องใช้ DateFormat แล้ว เพราะเราบันทึกเป็น String เช่น "20/3/2567" มาจากฟอร์มเลย
    final dateStr = event.date;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.white.withValues(alpha: 0.95)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.article_outlined,
                    text: event.description,
                  ),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: dateStr,
                  ), // ใช้วันที่จาก Model
                  _InfoRow(
                    icon: Icons.access_time_outlined,
                    text: event.time,
                  ), // ใช้ event.time จาก Model
                  _InfoRow(
                    icon: Icons
                        .location_on_outlined, // เปลี่ยนจากไอคอนคนเป็นสถานที่
                    text: event.location,
                  ), // ใช้ event.location จาก Model
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _statusColor.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Text(
                _statusLabel,
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
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
          Icon(
            icon,
            size: 14,
            color: AppColors.primary.withValues(alpha: 0.75),
          ),
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
