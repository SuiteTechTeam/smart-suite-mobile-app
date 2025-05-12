class Notifications {
  final int? typesNotificationsId;
  final int? ownersId;
  final int? adminsId;
  final int? workersId;
  final String? title;
  final String? description;

  Notifications(
      this.typesNotificationsId,
      this.ownersId,
      this.adminsId,
      this.workersId,
      this.title,
      this.description,
      );

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      json['typesNotificationsId'],
      json['ownersId'],
      json['adminsId'],
      json['workersId'],
      json['title'],
      json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'typesNotificationsId': typesNotificationsId,
      'ownersId': ownersId,
      'adminsId': adminsId,
      'workersId': workersId,
      'title': title,
      'description': description,
    };
  }
}
