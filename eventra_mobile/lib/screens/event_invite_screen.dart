import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/guest.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class EventInviteScreen extends StatefulWidget {
  final Event event;
  const EventInviteScreen({super.key, required this.event});

  @override
  State<EventInviteScreen> createState() => _EventInviteScreenState();
}

class _EventInviteScreenState extends State<EventInviteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Guest> _guests = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGuests();
  }

  Future<void> _loadGuests() async {
    setState(() => _isLoading = true);
    try {
      final guests = await ApiService.getGuests(widget.event.id);
      setState(() {
        _guests = guests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Guest> get _allGuests => _guests;
  List<Guest> get _invitedGuests => _guests.where((g) => g.isInvited).toList();
  List<Guest> get _notInvitedGuests =>
      _guests.where((g) => !g.isInvited).toList();

  Future<void> _invite(Guest guest) async {
    await ApiService.inviteGuest(widget.event.id, guest.id);
    setState(() => guest.isInvited = true);
  }

  Future<void> _removeInvite(Guest guest) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content:
            Text('ต้องการลบ ${guest.fullName} ออกจากรายชื่อผู้ได้รับเชิญ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ยกเลิก')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('ลบ', style: TextStyle(color: AppColors.primary))),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.removeGuest(widget.event.id, guest.id);
      setState(() => guest.isInvited = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500)); // simulate save
    setState(() => _isSaving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
          backgroundColor: AppColors.primary),
    );
    Navigator.pop(context);
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
        title: const Text(
          'Event Invite Guess',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'ทั้งหมด'),
            Tab(text: 'เชิญแล้ว'),
            Tab(text: 'ยังไม่เชิญ'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _GuestListAll(
                          guests: _allGuests,
                          onInvite: _invite,
                          onRemove: _removeInvite),
                      _GuestListInvited(
                          guests: _invitedGuests, onRemove: _removeInvite),
                      _GuestListAll(
                          guests: _notInvitedGuests,
                          onInvite: _invite,
                          onRemove: _removeInvite),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: SizedBox(
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
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Save',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _GuestListAll extends StatelessWidget {
  final List<Guest> guests;
  final Function(Guest) onInvite;
  final Function(Guest) onRemove;

  const _GuestListAll(
      {required this.guests, required this.onInvite, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (guests.isEmpty) {
      return const Center(child: Text('ไม่มีข้อมูล'));
    }
    return ListView.separated(
      itemCount: guests.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.divider),
      itemBuilder: (_, i) {
        final g = guests[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Text(g.firstName[0],
                style: const TextStyle(color: Colors.white)),
          ),
          title: Text(g.fullName,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: g.isInvited
              ? IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.primary),
                  onPressed: () => onRemove(g),
                )
              : SizedBox(
                  width: 72,
                  height: 34,
                  child: ElevatedButton(
                    onPressed: () => onInvite(g),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.inviteButton,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('เชิญ',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ),
        );
      },
    );
  }
}

class _GuestListInvited extends StatelessWidget {
  final List<Guest> guests;
  final Function(Guest) onRemove;

  const _GuestListInvited({required this.guests, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (guests.isEmpty) {
      return const Center(child: Text('ยังไม่มีผู้รับเชิญ'));
    }
    return ListView.separated(
      itemCount: guests.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.divider),
      itemBuilder: (_, i) {
        final g = guests[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Text(g.firstName[0],
                style: const TextStyle(color: Colors.white)),
          ),
          title: Text(g.fullName,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: AppColors.textPrimary),
            onPressed: () => onRemove(g),
          ),
        );
      },
    );
  }
}
