import 'package:flutter/material.dart';

class DashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> tasks = [
    {
      'id': 1,
      'priority': 'High',
      'type': 'Bug',
      'title': 'Fix login issue',
      'Reporter': 'John',
      'status': 'In Progress',
      'lastModified': '2023-08-20',
      'details': 'This is a critical issue that needs to be fixed...',
    },
    {
      'id': 2,
      'priority': 'Medium',
      'type': 'Feature',
      'title': 'Add user profile page',
      'Reporter': 'Jane',
      'status': 'Open',
      'lastModified': '2023-08-19',
      'details': 'Add a user profile page with user information...',
    },
    // Add more tasks here...
  ];

  void _showTaskDetails(int taskId) {
    showDialog(
      context: context,
      builder: (context) {
        final task = tasks.firstWhere((task) => task['id'] == taskId);
        return AlertDialog(
          title: Text(task['title']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDetailRow(
                  Icons.priority_high,
                  'Priority',
                  task['priority'],
                ),
                buildDetailRow(
                  Icons.bug_report,
                  'Type',
                  task['type'],
                ),
                buildDetailRow(
                  Icons.check_circle,
                  'Status',
                  task['status'],
                ),
                buildDetailRow(
                  Icons.person,
                  'Reporter',
                  task['Reporter'],
                ),
                buildDetailRow(
                  Icons.calendar_today,
                  'Last Modified',
                  task['lastModified'],
                ),
                SizedBox(height: 16),
                Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(task['details']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget buildDetailRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 4),
          Text(subtitle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Issues assigned to me'),
      ),
      body: Column(
        children: tasks.map((task) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('${task['title']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Priority: ${task['priority']}'),
                  Text('Type: ${task['type']}'),
                  Text('Status: ${task['status']}'),
                  Text('Reporter: ${task['Reporter']}'),
                  Text('Last Modified: ${task['lastModified']}'),
                  ElevatedButton(
                    onPressed: () {
                      _showTaskDetails(task['id']);
                    },
                    child: Text('Details'),
                  ),
                ],
              ),
              minVerticalPadding: 20,
              trailing: Container(
                height: 120, // Adjust the height as needed
                child:
                    SizedBox(), // Leave this empty since the button is now in the subtitle
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
