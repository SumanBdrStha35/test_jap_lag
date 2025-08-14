import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/db/DBHelper.dart';
import 'package:flutter_app/pages/article_page.dart';
import 'package:flutter_app/pages/flash/flash_card_page.dart';
import 'package:flutter_app/pages/folk/folktale.dart';
import 'package:flutter_app/pages/grammer/gram_page.dart';
import 'package:flutter_app/pages/hirakata/letter_page.dart';
import 'package:flutter_app/pages/kanji/kanji_steps.dart';
import 'package:flutter_app/pages/test_page.dart';
import 'package:intl/intl.dart';
// Existing imports
import 'package:logger/logger.dart';
import 'package:flutter_app/model/home_items.dart';


class HomePage extends StatefulWidget {
  final String userID;
  const HomePage({super.key, required this.userID});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DBHelper _dbHelper = DBHelper();
  String _userName = '';
  //used by bottom navigation bar
  final int _currentIndex = 0;
  //used by page view
  int _pageIndex = 0;
  double _progress = 0.0;
  Timer? _progressTimer;
  Timer? _pageTimer;
  final PageController _pageController = PageController();
  final int slideDuration = 3; //3 seconds
  final List<String> _imageUrls = [
    'https://picsum.photos/id/1011/600/300',
    'https://picsum.photos/id/1012/600/300',
    'https://picsum.photos/id/1013/600/300',
    'https://picsum.photos/id/1015/600/300',
    'https://picsum.photos/id/1016/600/300',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the database and get user details
    _initializeDatabase();
    _getUserDetails();
    _startProgress();
    _startAutoScroll();
  }

  Future<void> _initializeDatabase() async {
    await _dbHelper.database;
  }

  // Create a logger instance
  final logger = Logger();

  void _getUserDetails() async {
    var userDetails = await _dbHelper.getUserById(widget.userID);
    if (userDetails != null) {
      setState(() {
        _userName = userDetails['name'];
      });
    } else {
      logger.e('User not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = 20.0;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      //using _pageController to control the page view
                      controller: _pageController,
                      itemCount: _imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _pageIndex = index;
                          _startProgress();
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          _imageUrls[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_imageUrls.length, (index) {
                      // bool isActive = index == _pageIndex; // Check if the indicator is active
                      bool isActive = _pageIndex == index; // Check if the indicator is active
                      double width = isActive ? maxWidth * _progress : 6.0; // Calculate width based on progress
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 100), // Animation duration for width
                        margin: const EdgeInsets.symmetric(horizontal: 4), // Margin between indicators
                        width: width, // Width of the indicator
                        height: 6, // Height of the indicator
                        decoration: BoxDecoration( // Decoration for the indicator
                          // shape: BoxShape.circle,
                          color: isActive ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                          shape: BoxShape.rectangle, // Change to rectangle for a different look
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            //show weekly days
            SizedBox(height: 8),
            weeklyDaysWidget(),
            //use GridView of 8 time with 2 column from array list.
             SizedBox(height: 8),

            // Define the array of HomeItems objects and display them in a GridView
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columns
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: _homeItems.length,
                itemBuilder: (context, index) {
                  final item = _homeItems[index];
                  return InkWell(
                    onTap: () {
                      if (item.title == 'Hiragana' || item.title == 'Katakana') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LetterPage(title: item.title),
                          ),
                        );
                      } else if (item.title == 'Kanji Test') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KanjiSteps(title: item.title),
                          ),
                        );
                      } else if (item.title == 'Vocabulary Quiz' ) {
                        // Handle other items as needed
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestPage(title: item.title,),
                          ),
                        );
                      } else if (item.title == 'Grammar Test' ) {
                        // Handle other items as needed
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GramPage(title: item.title),
                          ),
                        );
                      } else if (item.title == 'Global Flashcards' ) {
                        // Handle other items as needed
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlashCardPage(title: item.title),
                          ),
                        );
                      } else if (item.title == 'Folktales' ) {
                        // Handle other items as needed
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FolktalePage(title: item.title),
                          ),
                        );
                      } else if (item.title == 'Articles' ) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticlePage(title: item.title),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  weeklyDaysWidget() {
    // Widget to display the weekly days in the required format
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final daysOfWeek = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: daysOfWeek.map((date) {
                  bool isToday = date.day == now.day && date.month == now.month && date.year == now.year;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                    decoration: BoxDecoration(
                      color: isToday ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 1,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0)
                        ),
                        Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isToday ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            color: isToday ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Define the list of HomeItems objects
  final List<HomeItems> _homeItems = [
    HomeItems(title: 'Hiragana', imageUrl: 'https://picsum.photos/id/1018/200/200'),
    HomeItems(title: 'Katakana', imageUrl: 'https://picsum.photos/id/1015/200/200'),
    HomeItems(title: 'Kanji Test', imageUrl: 'https://picsum.photos/id/1016/200/200'),
    HomeItems(title: 'Vocabulary Quiz', imageUrl: 'https://picsum.photos/id/1019/200/200'),
    HomeItems(title: 'Grammar Test', imageUrl: 'https://picsum.photos/id/1020/200/200'),
    HomeItems(title: 'Global Flashcards', imageUrl: 'https://picsum.photos/id/1021/200/200'),
    HomeItems(title: 'Folktales', imageUrl: 'https://picsum.photos/id/1022/200/200'),
    HomeItems(title: 'Articles', imageUrl: 'https://picsum.photos/id/1023/200/200'),
  ];

  @override
  void dispose() {
    _pageTimer?.cancel(); // Cancel the page timer
    _progressTimer?.cancel(); // Cancel the progress timer  
    _pageController.dispose(); // Dispose of the page controller
    super.dispose();
  }
  
  void _startProgress() {
    _progress = 0.0; // Reset progress
    _progressTimer?.cancel(); // Cancel any existing timer
    _progressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) { // Update progress every 100 milliseconds
      setState(() { // Update the UI
        _progress += 0.1 / slideDuration; // Increment progress
        if (_progress >= 1.0) { // If progress reaches 1.0
          _progress = 0.0; // Reset progress
          timer.cancel(); // Cancel the timer
        }
      });
    });
  }

  void _startAutoScroll() {
    _pageTimer?.cancel(); // Cancel any existing timer
    _pageTimer = Timer.periodic(Duration(seconds: slideDuration), (_) { // Change page every slideDuration seconds
      int nextPage = (_pageIndex + 1) % _imageUrls.length; // Calculate next page index
        _pageController.animateToPage(
          nextPage, // Animate to the next page
          duration: Duration(milliseconds: 350), // Animation duration
          curve: Curves.easeInOut, // Animation curve
        );
    });
  }
}