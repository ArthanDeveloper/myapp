import 'package:flutter/material.dart';
import 'package:myapp/create_ticket_screen.dart';
import 'package:myapp/ticket_details_screen.dart';

class Ticket {
  final String name;
  final String description;
  final String priorityLevel;
  final String status;
  final String ticketId;
  final String relativeTime;
  final String avatarUrl;

  Ticket({
    required this.name,
    required this.description,
    required this.priorityLevel,
    required this.status,
    required this.ticketId,
    required this.relativeTime,
    required this.avatarUrl,
  });
}

class SupportTicketsScreen extends StatelessWidget {
  final List<Ticket> tickets = [
    Ticket(
      name: 'John Doe',
      description: 'Unable to login to my account.',
      priorityLevel: 'High',
      status: 'Open',
      ticketId: '#123456',
      relativeTime: '2 hours ago',
      avatarUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
    ),
    Ticket(
      name: 'Jane Smith',
      description: 'App is crashing on startup.',
      priorityLevel: 'Medium',
      status: 'In Progress',
      ticketId: '#123457',
      relativeTime: '5 hours ago',
      avatarUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
    ),
    Ticket(
      name: 'Peter Jones',
      description: 'Cannot update my profile information.',
      priorityLevel: 'Low',
      status: 'Closed',
      ticketId: '#123458',
      relativeTime: '1 day ago',
      avatarUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
    ),
    Ticket(
      name: 'Samuel Green',
      description: 'Payment failed for my last order.',
      priorityLevel: 'High',
      status: 'Open',
      ticketId: '#123459',
      relativeTime: '2 days ago',
      avatarUrl: 'https://randomuser.me/api/portraits/men/4.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Support Tickets',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.add_comment_outlined, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateTicketScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Below are a list of recent tickets created',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TicketDetailsScreen(ticketId: ticket.ticketId),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ticket.description,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.circle,
                                    color: Colors.green, size: 12),
                                const SizedBox(width: 8),
                                Text(ticket.priorityLevel),
                                const Spacer(),
                                const Icon(Icons.attach_file, color: Colors.grey),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    ticket.status,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Ticket #: ${ticket.ticketId}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Text(
                                    ticket.relativeTime,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(ticket.avatarUrl),
                                    radius: 15,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
