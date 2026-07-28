import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:impactai/app/models/model_trending.dart';

class NewsService {
static const String apiKey = "add4a21aa4b7454cac331f4da8d4648f";
static const String apiUrl = "https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey";

static Future<List<ModelTrending>> fetchNews() async {
final response = await http.get(Uri.parse(apiUrl));

if (response.statusCode == 200) {
List articles = jsonDecode(response.body)["articles"];
return articles.map((article) {
return ModelTrending(
headline: article["title"] ?? "No title",
image: article["urlToImage"] ?? "https://via.placeholder.com/150",
);
}).toList();
} else {
throw Exception("Failed to load news");
}
}
}
