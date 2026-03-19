import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/invite_controller.dart';
import '../models/event_model.dart';
import '../models/checkin_model.dart';

class EventInviteView extends StatelessWidget {
  final InviteController controller = Get.put(InviteController());

  @override
  Widget build(BuildContext context) {
    final EventModel event = Get.arguments;
    controller.loadGuests(event.id!);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'จัดการรายชื่อผู้เข้าร่วม',
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'ทั้งหมด'),
              Tab(text: 'เชิญแล้ว'),
              Tab(text: 'ยังไม่เชิญ'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            children: [
              _buildList(controller.allGuests),
              _buildList(controller.invitedGuests),
              _buildList(controller.notInvitedGuests),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildList(List<CheckinModel> list) {
    if (list.isEmpty) return const Center(child: Text('ไม่มีข้อมูล'));

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final g = list[i];
        bool isInvited = g.empInviteStatus != 'not_invite';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: Text(g.empNickname?[0] ?? "?"),
          ),
          title: Text(g.empFullname ?? ""),
          subtitle: Text(g.empInviteStatus ?? ""),
          trailing: isInvited
              ? IconButton(
                  icon: const Icon(
                    Icons.person_remove,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _confirmRemove(g),
                )
              : ElevatedButton(
                  onPressed: () => controller.inviteEmployee(g),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'เชิญ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
        );
      },
    );
  }

  void _confirmRemove(CheckinModel guest) {
    Get.dialog(
      AlertDialog(
        title: const Text('ยกเลิกการเชิญ?'),
        content: Text(
          'คุณต้องการลบ ${guest.empFullname} ออกจากกิจกรรมนี้หรือไม่?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () {
              controller.removeInvitation(guest);
              Get.back();
            },
            child: const Text('ยืนยัน', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
