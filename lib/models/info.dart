class Info {
  final String? next;

  Info({this.next});

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(next: json["next"]);
  }
}
