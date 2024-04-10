# Build a Flutter Hacker News App

I will test how to make an app that displays stories from Hacker News, along with the comments.
Hacker News provides an excellent and well-documented JSON API, available publicly. You can check out the API on [this Githu link](https://github.com/HackerNews/API).


## Fetching Top Stories

The first step is to implement a web service to fetch top stories. There are several packages available to perform networking tasks in Flutter.

For the sake of simplicity, we are going to use the http package. Install the package by adding the http package in the pubspec.yaml file as shown below:

### pubspec.yaml
```sh 
name: hackernews
description: "A new hackernews app."
publish_to: 'none' # Remove this line if you wish to publish to pub.dev
version: 1.0.0+1

environment:
  sdk: '>=3.3.3 <4.0.0'
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  http: ^1.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
flutter:
  uses-material-design: true
```

In VS Code, once you save the pubspec.yaml file, it will automatically download the packages. If you manually want to install the packages then simply run:
```sh 
flutter pub get
```

We will implement our getTopStories method in a `services/Webservice.dart` file. The implementation is shown below:

```dart
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
```


We used the http package to invoke the following URL:

https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty

If you check out the response from the above URL, you will realize that it returns an array of story IDs. We use those IDs to retrieve the actual stories and utilize Future.wait to wait for all the responses.

Once all the responses have been evaluated, a Future<List<Response>> is returned to the caller.


## Displaying Top Stories
The TopArticleList widget is responsible for displaying the top Hacker News stories to the user. We call _populateTopStories inside the initState method. The build function is responsible for creating the user interface for the app. The implementation is shown below:
  
```dart 
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hackernews/models/story.dart';
import 'package:hackernews/services/webservice.dart';

import 'commentListPage.dart';

class TopArticleList extends StatefulWidget {
  @override
  _TopArticleListState createState() => _TopArticleListState();
}

class _TopArticleListState extends State<TopArticleList> {
  List<Story> _stories = [];

  @override
  void initState() {
    super.initState();
    _populateTopStories();
  }

  void _populateTopStories() async {
    final responses = await Webservice().getTopStories();
    final stories = responses.map((response) {
      final json = jsonDecode(response.body);
      return Story.fromJSON(json);
    }).toList();

    setState(() {
      _stories = stories;
    });
  }

  void _navigateToShowCommentsPage(BuildContext context, int index) async {
    final story = this._stories[index];
    final responses = await Webservice().getCommentsByStory(story);
    final comments = responses.map((response) {
      final json = jsonDecode(response.body);
      return Comment.fromJSON(json);
    }).toList();

    debugPrint("$comments");

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CommentListPage(story: story, comments: comments)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Hacker News"),
          backgroundColor: Colors.orange,
        ),
        body: ListView.builder(
          itemCount: _stories.length,
          itemBuilder: (_, index) {
            return ListTile(
              onTap: () {
                _navigateToShowCommentsPage(context, index);
              },
              title: Text(_stories[index].title ?? "",
                  style: const TextStyle(fontSize: 18)),
              trailing: Container(
                  decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                  alignment: Alignment.center,
                  width: 50,
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text("${_stories[index].commentIds?.length}",
                        style: TextStyle(color: Colors.white)),
                  )),
            );
          },
        ));
  }
}

```

## Displaying Comments for Story
At present, a story does not display the number of comments associated with the story. The following JSON endpoint returns a particular story, along with the IDs of the comments, represented by the child’s property in the JSON response.

https://hacker-news.firebaseio.com/v0/item/8863.json?print=pretty

To accommodate this need, we have updated the Story model to include commentIds as shown below:

### models/story.dart 
```dart 
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

```
  
  ![Screenshot from 2024-04-10 23-46-04](https://gist.github.com/assets/6800568/caef272b-9eee-44ad-82de-acb6a50ff0b7)
  
  ![Screenshot from 2024-04-10 23-46-11](https://gist.github.com/assets/6800568/b5a1cc55-c6f1-4e8f-8c65-b08f5b0a49d0)


  
  
👉 The link for the full source code is here.

[![Download Source code](https://gist.github.com/assets/6800568/2dbceee5-661b-40ef-881d-054bcd2cbe25)](https://github.com/aungthuoo/hackernews)



