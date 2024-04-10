import 'dart:convert';

import 'package:hackernews/models/story.dart';
import 'package:hackernews/helpers/urlHelper.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class Webservice {
  Future<Response> _getStory(int storyId) {
    return http.get(Uri.parse(UrlHelper.urlForStory(storyId)));
  }

  Future<List<Response>> getCommentsByStory(Story story) async {
    return Future.wait(story.commentIds!.map((commentId) {
      return http.get(Uri.parse(UrlHelper.urlForCommentById(commentId)));
    }));
  }

  Future<List<Response>> getTopStories() async {
    final response = await http.get(Uri.parse(UrlHelper.urlForTopStories()));
    if (response.statusCode == 200) {
      Iterable storyIds = jsonDecode(response.body);
      return Future.wait(storyIds.take(10).map((storyId) {
        return _getStory(storyId);
      }));
    } else {
      throw Exception("Unable to fetch data!");
    }
  }
}
