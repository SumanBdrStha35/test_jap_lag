import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VocaAdditionalPage extends StatefulWidget {
  int lessonNumber;
  bool isLessPart;

  VocaAdditionalPage({
    super.key,
    required this.lessonNumber,
    required this.isLessPart,
  });

  @override
  _VocaAdditionalPageState createState() => _VocaAdditionalPageState();
}

class _VocaAdditionalPageState extends State<VocaAdditionalPage> {
  dynamic _lessPartData;

  @override
  void initState() {
    super.initState();
    _loadLessPartData();
  }

  Future<void> _loadLessPartData() async {
    final data = await rootBundle.loadString(
      'assets/json/less_part_${widget.lessonNumber}.json',
    );
    setState(() {
      _lessPartData = jsonDecode(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Additional Vocabularies - Lesson ${widget.lessonNumber}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body:
          _lessPartData == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading vocabulary data...',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : _buildContent(),
    );
  }

  Widget buildVocabularyItem(
    String label,
    String kanji,
    String hiragana,
    String english,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          kanji,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: 2),
        Text(hiragana, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        SizedBox(height: 2),
        Text(
          english,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    // Handle the case where data is a Map (like less_part_3.json or less_part_5.json)
    if (_lessPartData is Map<String, dynamic>) {
      final Map<String, dynamic> data = _lessPartData as Map<String, dynamic>;
      
      // Check for building structure (less_part_3.json)
      if (data.containsKey('building')) {
        final String building = data['building'] as String;
        final List<dynamic> floors = data['floors'] as List<dynamic>;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                building,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    ...floors.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final Map<String, dynamic> floor =
                          entry.value as Map<String, dynamic>;
                      final List<dynamic> itemsList =
                          floor['items'] as List<dynamic>;
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${floor['floor']} - ${floor['english']}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children:
                                    itemsList.map((item) {
                                      return Chip(
                                        label: Text(
                                          item.toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                Theme.of(context)
                                                    .colorScheme
                                                    .onSecondaryContainer,
                                          ),
                                        ),
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondaryContainer,
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(
                        delay: Duration(milliseconds: index * 50),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      
      // Check for title and holidays structure (less_part_5.json)
      else if (data.containsKey('title') && data.containsKey('holidays')) {
        final Map<String, dynamic> title = data['title'] as Map<String, dynamic>;
        final List<dynamic> holidays = data['holidays'] as List<dynamic>;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title['kanji'] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title['hiragana'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                title['english'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 16),
              
              // Holidays list
              Expanded(
                child: ListView.builder(
                  itemCount: holidays.length,
                  itemBuilder: (context, index) {
                    final dynamic holiday = holidays[index];
                    if (holiday is Map<String, dynamic> && 
                        holiday.containsKey('date') && 
                        holiday.containsKey('name') && 
                        holiday['name'] is Map<String, dynamic>) {
                      final Map<String, dynamic> name = holiday['name'] as Map<String, dynamic>;
                      
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                holiday['date'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              buildVocabularyItem(
                                "Holiday",
                                name['kanji'] ?? '',
                                name['hiragana'] ?? '',
                                name['english'] ?? '',
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 50));
                    }
                    
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          "Invalid holiday format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This holiday doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
      
      // Check for title and categories structure (less_part_6.json)
      else if (data.containsKey('title') && data.containsKey('categories')) {
        final Map<String, dynamic> title = data['title'] as Map<String, dynamic>;
        final List<dynamic> categories = data['categories'] as List<dynamic>;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title['kanji'] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title['hiragana'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                title['english'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 16),
              
              // Categories list
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final dynamic category = categories[index];
                    if (category is Map<String, dynamic> && 
                        category.containsKey('category') && 
                        category['category'] is Map<String, dynamic> &&
                        category.containsKey('items') && 
                        category['items'] is List<dynamic>) {
                      final Map<String, dynamic> categoryInfo = category['category'] as Map<String, dynamic>;
                      final List<dynamic> items = category['items'] as List<dynamic>;
                      
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category title
                              Text(
                                categoryInfo['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                categoryInfo['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                categoryInfo['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              SizedBox(height: 12),
                              
                              // Items list
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: items.map((item) {
                                  if (item is Map<String, dynamic>) {
                                    return Chip(
                                      label: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['kanji'] ?? '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                                            ),
                                          ),
                                          Text(
                                            item['hiragana'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                                            ),
                                          ),
                                          Text(
                                            item['english'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                    );
                                  }
                                  return Chip(
                                    label: Text(
                                      "Invalid item",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 50));
                    }
                    
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          "Invalid category format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This category doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
      
      // Check for title and groups structure (less_part_7.json)
      else if (data.containsKey('title') && data.containsKey('groups')) {
        final Map<String, dynamic> title = data['title'] as Map<String, dynamic>;
        final List<dynamic> groups = data['groups'] as List<dynamic>;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title['kanji'] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title['hiragana'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                title['english'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 16),
              
              // Groups list
              Expanded(
                child: ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final dynamic group = groups[index];
                    if (group is Map<String, dynamic> && 
                        group.containsKey('group') && 
                        group['group'] is Map<String, dynamic> &&
                        group.containsKey('members') && 
                        group['members'] is List<dynamic>) {
                      final Map<String, dynamic> groupInfo = group['group'] as Map<String, dynamic>;
                      final List<dynamic> members = group['members'] as List<dynamic>;
                      
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Group title
                              Text(
                                groupInfo['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                groupInfo['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                groupInfo['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              SizedBox(height: 12),
                              
                              // Members list
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: members.map((member) {
                                  if (member is Map<String, dynamic>) {
                                    return Chip(
                                      label: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            member['kanji'] ?? '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                                            ),
                                          ),
                                          Text(
                                            member['hiragana'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                                            ),
                                          ),
                                          Text(
                                            member['english'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                    );
                                  }
                                  return Chip(
                                    label: Text(
                                      "Invalid member",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 50));
                    }
                    
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          "Invalid group format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This group doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
      
      // Check for title and rooms structure (less_part_10.json)
      else if (data.containsKey('title') && data.containsKey('rooms')) {
        final Map<String, dynamic> title = data['title'] as Map<String, dynamic>;
        final List<dynamic> rooms = data['rooms'] as List<dynamic>;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title['kanji'] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title['hiragana'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                title['english'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 16),
              
              // Rooms list
              Expanded(
                child: ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final dynamic room = rooms[index];
                    if (room is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                room['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                room['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 50));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          "Invalid room format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This room doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
      
      // Check for title with places and festivals structure (less_part_12.json)
      else if (data.containsKey('title') && data.containsKey('places') && data.containsKey('festivals')) {
        final Map<String, dynamic> title = data['title'] as Map<String, dynamic>;
        final List<dynamic> places = data['places'] as List<dynamic>;
        final List<dynamic> festivals = data['festivals'] as List<dynamic>;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title['kanji'] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title['hiragana'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                title['english'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 16),
              
              // Places section
              Text(
                "Places of Note",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final dynamic place = places[index];
                    if (place is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                place['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                place['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 30));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid place format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This place doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 16),
              
              // Festivals section
              Text(
                "Festivals",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: festivals.length,
                  itemBuilder: (context, index) {
                    final dynamic festival = festivals[index];
                    if (festival is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                festival['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                festival['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                festival['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 30));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid festival format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This festival doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
      
      // Check for title with places structure (less_part_13.json)
      else if (data.containsKey('title') && data.containsKey('places')) {
        final Map<String, dynamic> title = data['title'] as Map<String, dynamic>;
        final List<dynamic> places = data['places'] as List<dynamic>;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title['kanji'] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title['hiragana'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                title['english'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 16),
              
              // Places list
              Expanded(
                child: ListView.builder(
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final dynamic place = places[index];
                    if (place is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                place['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                place['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 30));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid place format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This place doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
      
      // Check for title with occupations structure (less_part_15.json)
      else if (data.containsKey('title') && data.containsKey('occupations')) {
        final Map<String, dynamic> title = data['title'] as Map<String, dynamic>;
        final List<dynamic> occupations = data['occupations'] as List<dynamic>;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title['kanji'] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title['hiragana'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                title['english'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 16),
              
              // Occupations list
              Expanded(
                child: ListView.builder(
                  itemCount: occupations.length,
                  itemBuilder: (context, index) {
                    final dynamic occupation = occupations[index];
                    if (occupation is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                occupation['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                occupation['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                occupation['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 30));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid occupation format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This occupation doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
      
      // Check for title with functions, terms, and steps structure (less_part_16.json)
      else if (data.containsKey('title') && data.containsKey('functions') && data.containsKey('terms') && data.containsKey('steps')) {
        final Map<String, dynamic> title = data['title'] as Map<String, dynamic>;
        final List<dynamic> functions = data['functions'] as List<dynamic>;
        final List<dynamic> terms = data['terms'] as List<dynamic>;
        final List<dynamic> steps = data['steps'] as List<dynamic>;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title['kanji'] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title['hiragana'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                title['english'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 16),
              
              // Functions section
              Text(
                "Functions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: functions.length,
                  itemBuilder: (context, index) {
                    final dynamic function = functions[index];
                    if (function is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                function['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                function['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                function['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 20));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid function format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This function doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 16),
              
              // Terms section
              Text(
                "Terms",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: terms.length,
                  itemBuilder: (context, index) {
                    final dynamic term = terms[index];
                    if (term is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                term['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                term['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                term['english'] ?? '',
                                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 20));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid term format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This term doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 16),
              
              // Steps section
              Text(
                "Steps",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    final dynamic step = steps[index];
                    if (step is Map<String, dynamic> && step.containsKey('step') && step.containsKey('japanese') && step.containsKey('english')) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(step['step'].toString()),
                          ),
                          title: Text(step['japanese'] ?? ''),
                          subtitle: Text(step['english'] ?? ''),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 20));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid step format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This step doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
      
      // Check for title with phrases, body_parts, and illnesses structure (less_part_17.json)
      else if (data.containsKey('title') && data.containsKey('phrases') && data.containsKey('body_parts') && data.containsKey('illnesses')) {
        final Map<String, dynamic> title = data['title'] as Map<String, dynamic>;
        final List<dynamic> phrases = data['phrases'] as List<dynamic>;
        final List<dynamic> bodyParts = data['body_parts'] as List<dynamic>;
        final List<dynamic> illnesses = data['illnesses'] as List<dynamic>;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title['kanji'] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title['hiragana'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                title['english'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 16),
              
              // Phrases section
              Text(
                "Phrases",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: phrases.length,
                  itemBuilder: (context, index) {
                    final dynamic phrase = phrases[index];
                    if (phrase is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                phrase['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                phrase['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                phrase['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 20));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid phrase format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This phrase doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 16),
              
              // Body Parts section
              Text(
                "Body Parts",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: bodyParts.length,
                  itemBuilder: (context, index) {
                    final dynamic bodyPart = bodyParts[index];
                    if (bodyPart is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bodyPart['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                bodyPart['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                bodyPart['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 20));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid body part format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This body part doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 16),
              
              // Illnesses section
              Text(
                "Illnesses",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: illnesses.length,
                  itemBuilder: (context, index) {
                    final dynamic illness = illnesses[index];
                    if (illness is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                illness['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                illness['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                illness['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 20));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid illness format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This illness doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
      
      // Check for title with actions structure (less_part_18.json)
      else if (data.containsKey('title') && data.containsKey('actions')) {
        final Map<String, dynamic> title = data['title'] as Map<String, dynamic>;
        final List<dynamic> actions = data['actions'] as List<dynamic>;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title['kanji'] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title['hiragana'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                title['english'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 16),
              
              // Actions list
              Expanded(
                child: ListView.builder(
                  itemCount: actions.length,
                  itemBuilder: (context, index) {
                    final dynamic action = actions[index];
                    if (action is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                action['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                action['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                action['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 30));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid action format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This action doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
      
      // Check for title with items structure (less_part_19.json)
      else if (data.containsKey('title') && data.containsKey('items')) {
        final Map<String, dynamic> title = data['title'] as Map<String, dynamic>;
        final List<dynamic> items = data['items'] as List<dynamic>;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title['kanji'] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title['hiragana'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                title['english'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 16),
              
              // Items list
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final dynamic item = items[index];
                    if (item is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                item['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                item['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 30));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid item format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This item doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }

      // Check for title with facilities, trains, and tickets structure (less_part_14.json)
      else if (data.containsKey('title') && data.containsKey('facilities') && data.containsKey('trains') && data.containsKey('tickets')) {
        final Map<String, dynamic> title = data['title'] as Map<String, dynamic>;
        final List<dynamic> facilities = data['facilities'] as List<dynamic>;
        final List<dynamic> trains = data['trains'] as List<dynamic>;
        final List<dynamic> tickets = data['tickets'] as List<dynamic>;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title['kanji'] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title['hiragana'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                title['english'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 16),
              
              // Facilities section
              Text(
                "Facilities",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: facilities.length,
                  itemBuilder: (context, index) {
                    final dynamic facility = facilities[index];
                    if (facility is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                facility['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                facility['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                facility['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 20));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid facility format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This facility doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 16),
              
              // Trains section
              Text(
                "Trains",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: trains.length,
                  itemBuilder: (context, index) {
                    final dynamic train = trains[index];
                    if (train is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                train['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                train['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                train['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 20));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid train format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This train doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 16),
              
              // Tickets section
              Text(
                "Tickets",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final dynamic ticket = tickets[index];
                    if (ticket is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                ticket['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                ticket['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 20));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid ticket format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This ticket doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }

      // Check for title with stages structure (less_part_25.json)
      else if (data.containsKey('title') && data.containsKey('stages')) {
        final Map<String, dynamic> title = data['title'] as Map<String, dynamic>;
        final List<dynamic> stages = data['stages'] as List<dynamic>;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title['kanji'] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title['hiragana'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                title['english'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 16),
              
              // Stages list
              Expanded(
                child: ListView.builder(
                  itemCount: stages.length,
                  itemBuilder: (context, index) {
                    final dynamic stage = stages[index];
                    if (stage is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Stage header
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stage['age'] ?? '',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (stage['kanji'] != null)
                                          Text(
                                            stage['kanji'] ?? '',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                        if (stage['hiragana'] != null)
                                          Text(
                                            stage['hiragana'] ?? '',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        if (stage['english'] != null)
                                          Text(
                                            stage['english'] ?? '',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context).colorScheme.secondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Events list
                              if (stage.containsKey('events') && stage['events'] is List<dynamic>)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 12),
                                    Text(
                                      "Events:",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    ...(stage['events'] as List<dynamic>).map((event) {
                                      if (event is Map<String, dynamic>) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("• ", style: TextStyle(fontSize: 16)),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    if (event['kanji'] != null)
                                                      Text(
                                                        event['kanji'] ?? '',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    if (event['hiragana'] != null)
                                                      Text(
                                                        event['hiragana'] ?? '',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey[600],
                                                        ),
                                                      ),
                                                    if (event['english'] != null)
                                                      Text(
                                                        event['english'] ?? '',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Theme.of(context).colorScheme.secondary,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return SizedBox.shrink();
                                    }),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 50));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          "Invalid stage format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This stage doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
              
              // Life expectancy info
              if (data.containsKey('life_expectancy'))
                Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Life Expectancy (${data['life_expectancy']['year'] ?? ''})",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Men: ${data['life_expectancy']['men'] ?? ''} years",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Women: ${data['life_expectancy']['women'] ?? ''} years",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Source: ${data['life_expectancy']['source'] ?? ''}",
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      }

      // Check for title with government, education, company, bank, station, hospital, police structure (less_part_21.json)
      else if (data.containsKey('title') && data.containsKey('government') && data.containsKey('education') && data.containsKey('company') && data.containsKey('bank') && data.containsKey('station') && data.containsKey('hospital') && data.containsKey('police')) {
        final Map<String, dynamic> title = data['title'] as Map<String, dynamic>;
        final List<dynamic> government = data['government'] as List<dynamic>;
        final List<dynamic> education = data['education'] as List<dynamic>;
        final List<dynamic> company = data['company'] as List<dynamic>;
        final List<dynamic> bank = data['bank'] as List<dynamic>;
        final List<dynamic> station = data['station'] as List<dynamic>;
        final List<dynamic> hospital = data['hospital'] as List<dynamic>;
        final List<dynamic> police = data['police'] as List<dynamic>;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title['kanji'] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title['hiragana'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                title['english'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 16),
              
              // Government section
              Text(
                "Government",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: government.length,
                  itemBuilder: (context, index) {
                    final dynamic govItem = government[index];
                    if (govItem is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                govItem['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                govItem['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                govItem['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 20));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid government item format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This government item doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 16),
              
              // Education section
              Text(
                "Education",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: education.length,
                  itemBuilder: (context, index) {
                    final dynamic eduItem = education[index];
                    if (eduItem is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eduItem['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                eduItem['hiragana'] ?? '',
                                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                eduItem['english'] ?? '',
                                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 20));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid education item format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This education item doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 16),
              
              // Company section
              Text(
                "Company",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: company.length,
                  itemBuilder: (context, index) {
                    final dynamic compItem = company[index];
                    if (compItem is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                compItem['kanji'] ?? '',
                                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                compItem['hiragana'] ?? '',
                                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                compItem['english'] ?? '',
                                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 20));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid company item format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This company item doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 16),
              
              // Bank section
              Text(
                "Bank",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: bank.length,
                  itemBuilder: (context, index) {
                    final dynamic bankItem = bank[index];
                    if (bankItem is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bankItem['kanji'] ?? '',
                                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                bankItem['hiragana'] ?? '',
                                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                bankItem['english'] ?? '',
                                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 20));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid bank item format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This bank item doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 16),
              
              // Station section
              Text(
                "Station",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: station.length,
                  itemBuilder: (context, index) {
                    final dynamic stationItem = station[index];
                    if (stationItem is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stationItem['kanji'] ?? '',
                                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                stationItem['hiragana'] ?? '',
                                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                stationItem['english'] ?? '',
                                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 20));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid station item format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This station item doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 16),
              
              // Hospital section
              Text(
                "Hospital",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: hospital.length,
                  itemBuilder: (context, index) {
                    final dynamic hospitalItem = hospital[index];
                    if (hospitalItem is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hospitalItem['kanji'] ?? '',
                                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                hospitalItem['hiragana'] ?? '',
                                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                hospitalItem['english'] ?? '',
                                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 20));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid hospital item format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This hospital item doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 16),
              
              // Police section
              Text(
                "Police",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: police.length,
                  itemBuilder: (context, index) {
                    final dynamic policeItem = police[index];
                    if (policeItem is Map<String, dynamic>) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                policeItem['kanji'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                policeItem['hiragana'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                policeItem['english'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 20));
                    }
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          "Invalid police item format",
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text("This police item doesn't match expected structure"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    }

    // Handle List type (like less_part_1.json structure)
    if (_lessPartData is List<dynamic>) {
      final List<dynamic> data = _lessPartData as List<dynamic>;
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final dynamic item = data[index];

            if (item is Map<String, dynamic>) {
              // less2 case - check if item has 'name' key and it is a Map
              if (item.containsKey('name') &&
                  item['name'] is Map<String, dynamic>) {
                final name = item['name'] as Map<String, dynamic>;
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      name['kanji'] ?? '',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          name['hiragana'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          name['english'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: index * 50));
              }

              // less1 case - check if item has 'country' key and it is a Map
              if (item.containsKey('country') &&
                  item['country'] is Map<String, dynamic> &&
                  item['people'] is Map<String, dynamic> &&
                  item['language'] is Map<String, dynamic>) {
                final country = item['country'] as Map<String, dynamic>;
                final people = item['people'] as Map<String, dynamic>;
                final language = item['language'] as Map<String, dynamic>;
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Country
                        buildVocabularyItem(
                          "Country",
                          country['kanji'] ?? '',
                          country['hiragana'] ?? '',
                          country['english'] ?? '',
                        ),
                        SizedBox(height: 12),
                        // People
                        buildVocabularyItem(
                          "People",
                          people['kanji'] ?? '',
                          people['hiragana'] ?? '',
                          people['english'] ?? '',
                        ),
                        SizedBox(height: 12),
                        // Language
                        buildVocabularyItem(
                          "Language",
                          language['kanji'] ?? '',
                          language['hiragana'] ?? '',
                          language['english'] ?? '',
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: index * 50));
              }
            }

            return Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  "Invalid item format",
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: Text("This item doesn't match expected structure"),
              ),
            );
          },
        ),
      );
    }

    return Center(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Unsupported JSON format",
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      ),
    );
  }
}