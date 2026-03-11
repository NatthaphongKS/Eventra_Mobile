import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event; // null = create, non-null = edit
  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _locationCtrl;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _status = 'upcoming';
  bool _isSaving = false;

  bool get _isEdit => widget.event != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _selectedDate = e?.date;
    _status = e?.status ?? 'upcoming';
    if (e != null) {
      final sp = e.startTime.split(':');
      final ep = e.endTime.split(':');
      if (sp.length == 2) {
        _startTime =
            TimeOfDay(hour: int.parse(sp[0]), minute: int.parse(sp[1]));
      }
      if (ep.length == 2) {
        _endTime = TimeOfDay(hour: int.parse(ep[0]), minute: int.parse(ep[1]));
      }
    }
  }

  String _formatTime(TimeOfDay? t) {
    if (t == null) return '--:--';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart
        ? (_startTime ?? TimeOfDay.now())
        : (_endTime ?? TimeOfDay.now());
    final t = await showTimePicker(context: context, initialTime: initial);
    if (t != null) {
      setState(() {
        if (isStart) {
          _startTime = t;
        } else {
          _endTime = t;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('กรุณาเลือกวันที่')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final data = {
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'start_time': _formatTime(_startTime),
        'end_time': _formatTime(_endTime),
        'status': _status,
      };

      Event result;
      if (_isEdit) {
        result = await ApiService.updateEvent(widget.event!.id, data);
      } else {
        result = await ApiService.createEvent(data);
      }

      if (!mounted) return;
      Navigator.pop(context, result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'แก้ไขกิจกรรม' : 'สร้างกิจกรรม',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _label('ชื่อกิจกรรม'),
            TextFormField(
              controller: _nameCtrl,
              decoration: _inputDec('ชื่อกิจกรรม'),
              validator: (v) => v!.isEmpty ? 'กรุณากรอกชื่อกิจกรรม' : null,
            ),
            const SizedBox(height: 16),
            _label('รายละเอียด'),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: _inputDec('รายละเอียดกิจกรรม'),
            ),
            const SizedBox(height: 16),
            _label('สถานที่จัด'),
            TextFormField(
              controller: _locationCtrl,
              decoration: _inputDec('สถานที่'),
            ),
            const SizedBox(height: 16),
            _label('วันที่'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate != null
                          ? DateFormat('d MMMM yyyy', 'th')
                              .format(_selectedDate!)
                          : 'เลือกวันที่',
                      style: TextStyle(
                          color: _selectedDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary),
                    ),
                    const Icon(Icons.calendar_today_outlined,
                        color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('เวลาเริ่ม'),
                      GestureDetector(
                        onTap: () => _pickTime(true),
                        child: _timePicker(_formatTime(_startTime)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('เวลาสิ้นสุด'),
                      GestureDetector(
                        onTap: () => _pickTime(false),
                        child: _timePicker(_formatTime(_endTime)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _label('สถานะ'),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              items: const [
                DropdownMenuItem(value: 'upcoming', child: Text('Upcoming')),
                DropdownMenuItem(value: 'ongoing', child: Text('Ongoing')),
                DropdownMenuItem(value: 'done', child: Text('Done')),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : Text(_isEdit ? 'บันทึกการแก้ไข' : 'สร้างกิจกรรม',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textPrimary)),
      );

  InputDecoration _inputDec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      );

  Widget _timePicker(String val) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(val, style: const TextStyle(color: AppColors.textPrimary)),
            const Icon(Icons.access_time_outlined,
                color: AppColors.primary, size: 18),
          ],
        ),
      );
}
