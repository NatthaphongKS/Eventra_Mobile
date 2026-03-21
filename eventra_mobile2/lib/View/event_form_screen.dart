import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/events.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event; // Optional parameter สำหรับแก้ไข event ที่มีอยู่

  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers สำหรับรับค่าจาก Text Field
  final _nameController = TextEditingController();
  final _detailsController = TextEditingController();
  final _locationController = TextEditingController();

  // ตัวแปรเก็บวันที่และเวลา
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  bool _isLoading = false;
  bool _isEditing = false; // Flag เพื่อบอกว่ากำลังแก้ไขหรือสร้างใหม่

  // โทนสี
  final Color _primaryRed = const Color(0xFF9E2D2F);
  final Color _borderColor = const Color(0xFFECCACA);

  @override
  void initState() {
    super.initState();
    _isEditing = widget.event != null;

    // 💡 ถ้ากำลังแก้ไข ให้โหลดข้อมูลเก่าทั้งหมด
    if (_isEditing) {
      final event = widget.event!;
      _nameController.text = event.name;
      _detailsController.text = event.description;
      _locationController.text = event.location;

      // 💡 แปลง String วันที่ ("20/3/2567") กลับมาเป็น DateTime
      try {
        List<String> dateParts = event.date.split('/');
        if (dateParts.length == 3) {
          int day = int.parse(dateParts[0]);
          int month = int.parse(dateParts[1]);
          int year = int.parse(dateParts[2]) - 543; // แปลง พ.ศ. กลับเป็น ค.ศ.
          _selectedDate = DateTime(year, month, day);
        }
      } catch (e) {
        debugPrint('Error parsing date: $e');
      }

      // 💡 แปลง String เวลา ("13:00 - 15:30") กลับมาเป็น TimeOfDay
      try {
        if (event.time.contains('-')) {
          var timeParts = event.time.split('-');
          var startParts = timeParts[0].trim().split(':');
          var endParts = timeParts[1].trim().split(':');

          _selectedStartTime = TimeOfDay(
            hour: int.parse(startParts[0]),
            minute: int.parse(startParts[1]),
          );
          _selectedEndTime = TimeOfDay(
            hour: int.parse(endParts[0]),
            minute: int.parse(endParts[1]),
          );
        } else {
          // กันเหนียว กรณีเป็นข้อมูลเก่าที่เคยกรอกไว้แค่เวลาเดียว
          var timeParts = event.time.trim().split(':');
          _selectedStartTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
          // สมมติเวลาจบให้เผื่อไว้
          _selectedEndTime = TimeOfDay(
            hour: (int.parse(timeParts[0]) + 2) % 24,
            minute: int.parse(timeParts[1]),
          );
        }
      } catch (e) {
        debugPrint('Error parsing time: $e');
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
          DateTime.now(), // 💡 ถ้ามีข้อมูลเดิมให้โชว์เป็นค่าเริ่มต้น
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryRed,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          _selectedStartTime ??
          TimeOfDay.now(), // 💡 ใช้เวลาเดิมเป็นค่าเริ่มต้น
      builder: (context, child) => _timePickerTheme(child),
    );
    if (picked != null) {
      setState(() => _selectedStartTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? _selectedStartTime ?? TimeOfDay.now(),
      builder: (context, child) => _timePickerTheme(child),
    );
    if (picked != null) {
      setState(() => _selectedEndTime = picked);
    }
  }

  Widget _timePickerTheme(Widget? child) {
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(colorScheme: ColorScheme.light(primary: _primaryRed)),
      child: child!,
    );
  }

  // 💡 ฟังก์ชันบันทึกข้อมูล (อัปเดตใหม่)
  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null ||
        _selectedStartTime == null ||
        _selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกวันที่ และเวลาเริ่ม-จบ ให้ครบถ้วน'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dateString =
          "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year + 543}";

      final startTimeStr =
          "${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}";
      final endTimeStr =
          "${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}";
      final combinedTimeString = "$startTimeStr - $endTimeStr";

      // 💡 เตรียมชุดข้อมูลที่จะเซฟ
      final Map<String, dynamic> eventData = {
        'name': _nameController.text.trim(),
        'description': _detailsController.text.trim(),
        'location': _locationController.text.trim(),
        'date': dateString,
        'time': combinedTimeString,
      };

      // 💡 แยกว่าจะ Create หรือ Update
      if (_isEditing) {
        // แก้ไข: ใช้ .doc(ID).update()
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.event!.id) // อ้างอิง ID ของกิจกรรมที่ถูกกดเข้ามาแก้ไข
            .update(eventData);
      } else {
        // สร้างใหม่: เพิ่ม status ตั้งต้น และเวลาสร้าง
        eventData['status'] = 'upcoming';
        eventData['createdAt'] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance.collection('events').add(eventData);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'แก้ไขกิจกรรมสำเร็จ!' : 'สร้างกิจกรรมสำเร็จ!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  InputDecoration _getInputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryRed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6F6),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _primaryRed),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing
              ? 'Edit Event'
              : 'Create Event', // 💡 เปลี่ยนชื่อหัวข้อตามโหมด
          style: TextStyle(
            color: _primaryRed,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLabeledField(
                  label: 'Event Name',
                  child: TextFormField(
                    controller: _nameController,
                    decoration: _getInputDecoration(),
                    validator: (v) =>
                        v!.isEmpty ? 'กรุณากรอกชื่อกิจกรรม' : null,
                  ),
                ),
                _buildLabeledField(
                  label: 'Details',
                  child: TextFormField(
                    controller: _detailsController,
                    maxLines: 4,
                    decoration: _getInputDecoration(),
                    validator: (v) => v!.isEmpty ? 'กรุณากรอกรายละเอียด' : null,
                  ),
                ),
                _buildLabeledField(
                  label: 'Location',
                  child: TextFormField(
                    controller: _locationController,
                    decoration: _getInputDecoration(),
                    validator: (v) => v!.isEmpty ? 'กรุณากรอกสถานที่' : null,
                  ),
                ),

                _buildLabeledField(
                  label: 'Date',
                  child: InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: _borderColor, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _selectedDate == null
                            ? 'Select Date'
                            : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year + 543}",
                        style: TextStyle(
                          color: _selectedDate == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: _buildLabeledField(
                        label: 'Start Time',
                        child: InkWell(
                          onTap: _pickStartTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _borderColor,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _selectedStartTime == null
                                  ? 'Start'
                                  : "${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                color: _selectedStartTime == null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildLabeledField(
                        label: 'End Time',
                        child: InkWell(
                          onTap: _pickEndTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _borderColor,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _selectedEndTime == null
                                  ? 'End'
                                  : "${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                color: _selectedEndTime == null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryRed,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isEditing
                                ? 'Update Event'
                                : 'Save', // 💡 เปลี่ยนชื่อปุ่ม
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
