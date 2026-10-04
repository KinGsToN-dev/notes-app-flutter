class Note {
  final int id;
  final String title;
  final String text;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.text,
    required this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'] ?? '',
        text: json['text'] ?? '',
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );
}