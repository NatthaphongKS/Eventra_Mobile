import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../utils/app_theme.dart';
import 'event_invite_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMMM yyyy', 'th').format(_event.date);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              dateStr,
              style:
                  const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            _DetailSection(
              title: 'รายละเอียด',
              content: _event.description,
            ),
            const SizedBox(height: 16),
            _DetailSection(
              title: 'สถานที่จัด',
              content: _event.location,
            ),
            const SizedBox(height: 20),
            Text(
              '${_event.startTime} - ${_event.endTime}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ผู้เข้าร่วม ${_event.participantCount} คน',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _DetailSection(
              title: 'สถานะ',
              content: _statusThai,
            ),
            const SizedBox(height: 32),
            // Buttons
            _OutlineButton(
              label: 'แก้ไข',
              color: AppColors.primary,
              onTap: () async {
                final updated = await Navigator.push<Event>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventFormScreen(event: _event),
                  ),
                );
                if (updated != null) {
                  setState(() => _event = updated);
                }
              },
            ),
            const SizedBox(height: 12),
            _FilledButton(
              label: 'จัดการผู้เข้าร่วม',
              color: AppColors.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventInviteScreen(event: _event),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _FilledButton(
              label: 'เชคชื่อผู้เข้าร่วม',
              color: AppColors.primaryDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventCheckInScreen(event: _event),
                ),
              ),
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
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(content,
            style:
                const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OutlineButton(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _FilledButton(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
