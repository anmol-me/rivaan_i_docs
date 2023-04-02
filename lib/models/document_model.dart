class DocumentModel {
  final String uid;
  final String id;
  final String title;
  final List content;
  final int createdAt;

  const DocumentModel({
    required this.uid,
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      uid: map['uid'] ?? '' ,
      id: map['_id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? [],
      createdAt: map['createdAt'] as int,
    );
  }
}