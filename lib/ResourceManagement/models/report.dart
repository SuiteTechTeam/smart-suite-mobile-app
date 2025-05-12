class Report {
  int id;
  int typesReportsId;
  int adminsId;
  int workersId;
  String fileUrl;
  String title;
  String description;

  Report({
    required this.id,
    required this.typesReportsId,
    required this.adminsId,
    required this.workersId,
    required this.fileUrl,
    required this.title,
    required this.description,
  });

  // Método para convertir un JSON en un objeto Report
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      typesReportsId: json['typesReportsId'],
      adminsId: json['adminsId'],
      workersId: json['workersId'],
      fileUrl: json['fileUrl'],
      title: json['title'],
      description: json['description'],
    );
  }

  // Método para convertir un objeto Report a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'typesReportsId': typesReportsId,
      'adminsId': adminsId,
      'workersId': workersId,
      'fileUrl': fileUrl,
      'title': title,
      'description': description,
    };
  }
}
