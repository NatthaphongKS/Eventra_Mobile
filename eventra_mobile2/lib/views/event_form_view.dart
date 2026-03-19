import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';

class EventFormView extends StatefulWidget {
  const EventFormView({super.key});

  @override
  State<EventFormView> createState() => _EventFormViewState();
}

class _EventFormViewState extends State<EventFormView> {
  final eventController = Get.find<EventController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _locationCtrl;

  DateTime? _selectedDate;
  TimeOfDay? _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay? _endTime = const TimeOfDay(hour: 10, minute: 0);
  String _status = 'upcoming';
  EventModel? _existingEvent;

  @override
  void initState() {
    super.initState();
    // ตรวจสอบว่ามีข้อมูลส่งมาแก้ไขไหม
    _existingEvent = Get.arguments as EventModel?;

    _nameCtrl = TextEditingController(text: _existingEvent?.evnTitle ?? '');
    _descCtrl = TextEditingController(
      text: _existingEvent?.evnDescription ?? '',
    );
    _locationCtrl = TextEditingController(
      text: _existingEvent?.evnLocation ?? '',
    );
    _selectedDate = _existingEvent?.evnDate;
    _status = _existingEvent?.evnStatus ?? 'upcoming';
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      Get.snackbar("คำเตือน", "กรุณากรอกข้อมูลและเลือกวันที่ให้ครบ");
      return;
    }

    final data = {
      'name': _nameCtrl.text,
      'description': _descCtrl.text,
      'location': _locationCtrl.text,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'start_time':
          "${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}:00",
      'end_time':
          "${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00",
      'status': _status,
    };

    bool success = await eventController.saveOrUpdateEvent(
      id: _existingEvent?.id,
      data: data,
    );

    if (success) {
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existingEvent == null ? "สร้างกิจกรรม" : "แก้ไขกิจกรรม"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "ชื่อกิจกรรม"),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: "รายละเอียด"),
              maxLines: 3,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(labelText: "สถานที่"),
            ),
            const SizedBox(height: 20),

            ListTile(
              title: Text(
                _selectedDate == null
                    ? "เลือกวันที่"
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2025),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),

            Obx(
              () => ElevatedButton(
                onPressed: eventController.isLoading.value ? null : _submit,
                child: eventController.isLoading.value
                    ? const CircularProgressIndicator()
                    : Text(_existingEvent == null ? "ตกลง" : "บันทึกการแก้ไข"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
