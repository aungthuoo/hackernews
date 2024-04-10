class Comment {
  String text = "";
  final int commentId;
  Story story;
  Comment({required this.commentId, required this.text, required this.story});

  factory Comment.fromJSON(Map<String, dynamic> json) {
    return Comment(
        commentId: json["id"],
        text: json["text"],
        story: Story(title: "", url: "", commentIds: []));
  }
}

class Story {
  final String? title;
  final String? url;
  List<int>? commentIds;

  Story({required this.title, required this.url, required this.commentIds});

  factory Story.fromJSON(Map<String, dynamic> json) {
    return Story(
        title: json["title"],
        url: json["url"],
        commentIds: json["kids"] == null ? [] : json["kids"].cast<int>());
  }
}
