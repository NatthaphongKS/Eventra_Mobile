import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../utils/app_theme.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  Color get _statusColor {
    switch (event.status) {
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
    switch (event.status) {
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
    final dateStr =
        DateFormat('d MMMM yyyy', 'th').format(event.date);

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
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                      icon: Icons.article_outlined,
                      text: event.description),
                  _InfoRow(
                      icon: Icons.calendar_today_outlined, text: dateStr),
                  _InfoRow(
                      icon: Icons.access_time_outlined,
                      text: '${event.startTime} - ${event.endTime}'),
                  _InfoRow(
                      icon: Icons.people_outline,
                      text: '${event.participantCount} คน'),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _statusColor, width: 1.2),
              ),
              child: Text(
                _statusLabel,
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.w500,
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
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
