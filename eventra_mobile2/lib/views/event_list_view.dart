import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';
import '../widgets/event_card.dart'; // อย่าลืมปรับ EventCard ให้รับ EventModel

class EventListView extends StatelessWidget {
  final EventController controller = Get.put(EventController());

  final List<String> _tabs = ['Upcoming', 'Ongoing', 'Done'];
  final List<String> _statuses = ['upcoming', 'ongoing', 'done'];
  final List<Color> _dotColors = [Colors.blue, Colors.orange, Colors.green];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Event Management',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => Get.toNamed('/search'),
            ),
            PopupMenuButton<String>(
              onSelected: (v) => v == 'logout' ? controller.logout() : null,
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'logout', child: Text('ออกจากระบบ')),
              ],
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            tabs: List.generate(
              _tabs.length,
              (i) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _dotColors[i],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_tabs[i]),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: controller.fetchEvents,
            child: TabBarView(
              children: List.generate(
                _statuses.length,
                (i) => _buildEventList(controller.filteredEvents(_statuses[i])),
              ),
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () async {
            var result = await Get.toNamed('/event-form');
            if (result == true) controller.fetchEvents();
          },
        ),
      ),
    );
  }

  Widget _buildEventList(List<EventModel> events) {
    if (events.isEmpty) {
      return const Center(
        child: Text(
          'ไม่มีกิจกรรมในขณะนี้',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: events.length,
      itemBuilder: (_, i) => EventCard(
        event: events[i],
        onTap: () async {
          await Get.toNamed('/event-details', arguments: events[i]);
          controller.fetchEvents(); // รีเฟรชข้อมูลเผื่อมีการแก้ไข
        },
      ),
    );
  }
}
