import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  List<Map<String, String>> _chats = [

  ];

  String _searchText = '';

  List<Map<String, String>> get chats => _searchText.isEmpty
      ? _chats
      : _chats.where((chat) => chat['name']!
      .toLowerCase()
      .contains(_searchText.toLowerCase())).toList();

  void setSearchText(String text) {
    _searchText = text;
    notifyListeners();
  }

  void clearSearch() {
    _searchText = '';
    notifyListeners();
  }
}
