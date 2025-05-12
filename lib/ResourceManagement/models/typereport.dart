class TypesReport {
  final int id;
  final String title;
  final String description;
  final String? fileUrl; // fileUrl can be null, so it's nullable

  TypesReport({
    required this.id,
    required this.title,
    required this.description,
    this.fileUrl,
  });

  // Factory constructor to create a TypesReport from JSON
  factory TypesReport.fromJson(Map<String, dynamic> json) {
    return TypesReport(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      fileUrl: json['fileUrl'],
    );
  }

  // Convert a TypesReport object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
    };
  }
}
