import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_app/pages/voca/voca_additional.dart';
import 'package:flutter_app/pages/voca/voca_lesson_detail.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

class VocaLessonPageUpdate extends StatefulWidget {
  const VocaLessonPageUpdate({super.key});

  @override
  VocaLessonPageState createState() => VocaLessonPageState();
}

class VocaLessonPageState extends State<VocaLessonPageUpdate>
    with TickerProviderStateMixin {
  final Map<int, int> lessonProgress = {};
  late AnimationController _headerAnimationController;
  late ScrollController _scrollController;
  final bool _isSearching = false;
  String _searchQuery = '';
  bool _showGrid = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadLessonProgress();

    _scrollController.addListener(() {
      if (_scrollController.offset > 100) {
        _headerAnimationController.forward();
      } else {
        _headerAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadLessonProgress() async {
    final box = await Hive.openBox('vocaLessonProgress');

    setState(() {
      for (var i = 1; i <= 25; i++) {
        lessonProgress[i] = box.get(i) ?? 0;
      }
    });

    box.listenable().addListener(() {
      if (mounted) {
        setState(() {
          for (var i = 1; i <= 25; i++) {
            lessonProgress[i] = box.get(i) ?? 0;
          }
        });
      }
    });
  }

  Future<void> saveProgress(int lessonNumber, int progress) async {
    final box = await Hive.openBox('vocaLessonProgress');
    await box.put(lessonNumber, progress);
    setState(() {
      lessonProgress[lessonNumber] = progress;
    });
  }

  List<int> get filteredLessons {
    if (_searchQuery.isEmpty) return List.generate(25, (i) => i + 1);
    return List.generate(
      25,
      (i) => i + 1,
    ).where((lesson) => lesson.toString().contains(_searchQuery)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lessons = filteredLessons;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.blurBackground],
                  title: AnimatedOpacity(
                    opacity: innerBoxIsScrolled ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Text('Vocabulary'),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.school,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Master Japanese Vocabulary',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${lessons.length} lessons • ${(lessons.map((l) => lessonProgress[l] ?? 0).reduce((a, b) => a + b) / lessons.length).toStringAsFixed(0)}% complete',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              ],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SearchBar(
                        hintText: 'Search lessons...',
                        leading: const Icon(Icons.search),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(_showGrid ? Icons.list : Icons.grid_view),
                      onPressed: () {
                        setState(() {
                          _showGrid = !_showGrid;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    _showGrid
                        ? _buildGridView(lessons)
                        : _buildListView(lessons),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
            onPressed: () {
              final randomLesson = (DateTime.now().millisecond % 25) + 1;
              _navigateToLesson(randomLesson);
            },
            icon: const Icon(Icons.shuffle),
            label: const Text('Random Lesson'),
          ).animate().scale(),
    );
  }

  Widget _buildListView(List<int> lessons) {
    // Calculate total items: lessons + less_part files
    int totalItems = lessons.length;
    for (var lesson in lessons) {
      if (_hasLessPartFile(lesson)) {
        totalItems++;
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        // Find which lesson and item type this index corresponds to
        int currentIndex = 0;
        for (var i = 0; i < lessons.length; i++) {
          final lessonNumber = lessons[i];
          
          // Lesson card
          if (index == currentIndex) {
            return _buildModernLessonCard(lessonNumber)
                .animate()
                .fadeIn(delay: Duration(milliseconds: i * 50))
                .slideY(begin: 0.2, end: 0);
          }
          currentIndex++;
          
          // Less part card (if exists)
          if (_hasLessPartFile(lessonNumber)) {
            if (index == currentIndex) {
              return _buildLessPartCard(lessonNumber)
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: i * 50 + 25))
                  .slideY(begin: 0.2, end: 0);
            }
            currentIndex++;
          }
        }
        
        return Container(); // Fallback
      },
    );
  }

  Widget _buildGridView(List<int> lessons) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lessonNumber = lessons[index];
        return _buildCompactLessonCard(lessonNumber)
            .animate()
            .fadeIn(delay: Duration(milliseconds: index * 30))
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
      },
    );
  }

  Widget _buildModernLessonCard(int lessonNumber) {
    final progress = lessonProgress[lessonNumber] ?? 0;
    final color = _getLessonColor(lessonNumber);
    final isCompleted = progress >= 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _navigateToLesson(lessonNumber),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isCompleted
                              ? [Colors.green, Colors.lightGreen]
                              : [color, color.withOpacity(0.7)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        isCompleted
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 30,
                            )
                            : Text(
                              lessonNumber.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lesson $lessonNumber',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      //get total number of vocavulary base on lesson
                      FutureBuilder(
                        future: showVocabCount(lessonNumber),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return snapshot.data!;
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                      // showVocabCount(lessonNumber),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          backgroundColor:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLessonCard(int lessonNumber) {
    final progress = lessonProgress[lessonNumber] ?? 0;
    final color = _getLessonColor(lessonNumber);
    final isCompleted = progress >= 100;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToLesson(lessonNumber),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isCompleted
                              ? [Colors.green, Colors.lightGreen]
                              : [color, color.withOpacity(0.7)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        isCompleted
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                            : Text(
                              lessonNumber.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Lesson $lessonNumber',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: progress / 100,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeWidth: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${progress.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLesson(int lessonNumber) async {
    HapticFeedback.lightImpact();

    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                VocaLessonDetailPage(lessonNumber: lessonNumber),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            ),
            child: child,
          );
        },
      ),
    );

    if (result != null) {
      final id = result['id'] as int?;
      final progress = result['progress'] as int?;
      if (id != null && progress != null) {
        await saveProgress(id, progress);
      }
    }
  }

  Color _getLessonColor(int lessonNumber) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[(lessonNumber - 1) % colors.length];
  }

  Future<Widget> showVocabCount(int lessonNumber) async {
    String jsonFileName = 'assets/json/voca_les_$lessonNumber.json';
    // final String jsonString = rootBundle.loadString(jsonFileName);
    String jsonString = await rootBundle.loadString(jsonFileName);
    final List<dynamic> jsonResponse = json.decode(jsonString);
    Logger().d('Lesson $lessonNumber has ${jsonResponse.length} words');
    int vocabCount = jsonResponse.length;
    return Text(
      'Vocabulary • $vocabCount words',
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );

    // Text(
    //   'Vocabulary • ${(progress / 100 * 20).toStringAsFixed(0)} words',
    //   style: TextStyle(
    //     fontSize: 14,
    //     color: Theme.of(context).colorScheme.onSurfaceVariant,
    //   ),
    // ),
  }

  bool _hasLessPartFile(int lessonNumber) {
    // Check if less_part file exists by trying to load it
    // We'll use a simple approach - check if the file path exists in our known assets
    final availableLessParts = [1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 23, 24, 25];
    return availableLessParts.contains(lessonNumber);
  }

  Widget _buildLessPartCard(int lessonNumber) {
    final color = _getLessonColor(lessonNumber);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainer,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Handle less_part tap - could navigate to a different page
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VocaAdditionalPage(
                  lessonNumber: lessonNumber,
                  isLessPart: true,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.article,
                      color: color,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Less Part $lessonNumber',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Additional vocabulary exercises',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
