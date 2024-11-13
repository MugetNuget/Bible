import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favoritesBox = Hive.box('favorites');

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ValueListenableBuilder(
        valueListenable: favoritesBox.listenable(),
        builder: (context, Box box, _) {
          final favorites = box.values.toList();

          if (favorites.isEmpty) {
            return Center(
              child: Text(
                'No favorites yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favoriteItem = favorites[index];
              final String verseText;
              final String? formattedTimestamp;

              if (favoriteItem is String) {
                // Caso donde el elemento es solo un String
                verseText = favoriteItem;
                formattedTimestamp = null;
              } else if (favoriteItem is Map) {
                // Caso donde el elemento es un Map con texto y fecha
                verseText = favoriteItem['text'];

                // Formatear la fecha si existe
                final timestamp = favoriteItem['timestamp'];
                if (timestamp != null) {
                  final dateTime = DateTime.parse(timestamp);
                  formattedTimestamp = DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
                } else {
                  formattedTimestamp = null;
                }
              } else {
                return SizedBox.shrink();
              }

              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: ListTile(
                  title: Text(
                    verseText,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Favorite Details"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                verseText,
                                style: TextStyle(fontSize: 18),
                              ),
                              if (formattedTimestamp != null) ...[
                                SizedBox(height: 10),
                                Text(
                                  'Added on: $formattedTimestamp',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
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
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      box.deleteAt(index); // Eliminar el ítem de favoritos
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Removed from favorites')),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
