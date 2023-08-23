class Bug {
  final String id;
  String heading;
  String description;
  String? assignedTo = "";
  String? createdBy = "";
  static int totalBugs = 0;
  String? bugType;
  List<String>? comments = [];
  DateTime? dateCreated;
  String? priority;
  String? component;

  Bug(
      {required this.id,
      required this.heading,
      required this.description,
      this.assignedTo,
      this.createdBy,
      this.bugType,
      this.comments,
      this.dateCreated,
      this.priority,
      this.component});
}

enum BugType { none, featureRequest, ProductBreakingBug }

List<String> priorityOpts = ['P0', 'P1', 'P2', 'P3', 'P4'];
List<String> bugTypeOpts = [
  'None',
  'Bug',
  'Feature Request',
  'Process',
  'Vulnerability',
  'Project'
];
List<String> bugStatusOpts = [
  'New',
  'Open',
  'assigned',
  'accepted',
  'closed',
  'fixed',
  'verified',
  'duplicate',
  'infeasible',
  'intended behavior',
  'not reproducible',
  'obsolete'
];

List<String> componentOpts = ['Gmail', 'GMeet', 'GChat', 'GCalendar'];
