import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'favorites_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List verses = [];
  late Box favoritesBox;

  @override
  void initState() {
    super.initState();
    favoritesBox = Hive.box('favorites');
    fetchRandomVerses();
  }

  Future<void> fetchRandomVerses() async {
    List tempVerses = [];
    for (int i = 0; i < 10; i++) {
      final response = await http.get(Uri.parse('https://bible-api.com/?random=verse'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        tempVerses.add(data['verses'][0]);
      }
    }
    setState(() {
      verses = tempVerses;
    });
  }

  void toggleFavorite(String verseText) {
    final DateTime now = DateTime.now();
    final favoriteItem = {
      'text': verseText,
      'timestamp': now.toString(),
    };

    setState(() {
      if (favoritesBox.containsKey(verseText)) {
        favoritesBox.delete(verseText);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed from favorites')),
        );
      } else {
        favoritesBox.put(verseText, favoriteItem);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added to favorites')),
        );
      }
    });
  }

  void showVerseDetails(Map verse) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${verse['book_name']} ${verse['chapter']}:${verse['verse']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                verse['text'],
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'Translation: World English Bible',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 5),
              Text(
                'Note: Public Domain',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Bible Verses', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: verses.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: verses.length,
          itemBuilder: (context, index) {
            final verse = verses[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                onTap: () => showVerseDetails(verse),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        verse['text'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${verse['book_name']} ${verse['chapter']}:${verse['verse']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              favoritesBox.containsKey(verse['text'])
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => toggleFavorite(verse['text']),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FavoritesPage()),
          );
        },
        backgroundColor: Colors.lightBlueAccent,
        child: Icon(Icons.favorite),
        tooltip: 'Go to Favorites',
      ),
    );
  }
}
