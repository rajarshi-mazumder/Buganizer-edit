class CustomUser {
  final String id;
  final String username;
  final String email;
  List? assignedBugs = [];
  List? createdBugs = [];
  List? notifications = [];
  CustomUser({
    required this.id,
    required this.username,
    required this.email,
    this.assignedBugs,
    this.createdBugs,
    this.notifications,
  });

  factory CustomUser.fromMap(Map<String, dynamic> data, String id) {
    return CustomUser(
        id: id,
        username: data['username'],
        email: data['email'],
        assignedBugs: data['assignedBugs'],
        createdBugs: data['createdBugs'],
        notifications: data['notifications']);
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
    };
  }
}
