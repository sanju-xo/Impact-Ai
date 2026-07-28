import 'package:flutter/material.dart';
import 'package:impactai/app/data/news_service.dart';
import 'package:impactai/app/models/model_trending.dart';

class NewsListScreen extends StatefulWidget {
  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  List<ModelTrending> newsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      List<ModelTrending> news = await NewsService.fetchNews();
      setState(() {
        newsList = news;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All News")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.network(newsList[index].image, width: 50, height: 50, fit: BoxFit.cover),
            title: Text(newsList[index].headline),
          );
        },
      ),
    );
  }
}
