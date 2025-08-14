import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/pages/kanji/kanji_lesson.dart';

class TreeWithFallingLeaves extends StatefulWidget {
  const TreeWithFallingLeaves({super.key});

  @override
  State<TreeWithFallingLeaves> createState() => _TreeWithFallingLeavesState();
}

class _TreeWithFallingLeavesState extends State<TreeWithFallingLeaves>
    with SingleTickerProviderStateMixin {
  final List<_LeafData> _leaves = [];
  late ReceivePort _receivePort;
  Isolate? _isolate;
  List<KanjiStep> _steps = [];
  bool _isLoading = true;

  static const List<String> _leafImages = [
    'assets/leaf_01.png',
    'assets/leaf_02.png',
    'assets/leaf_03.png',
  ];

  // Grid pattern configuration
  static const List<int> _patternSequence = [1, 2, 3, 2];
  
  Future<List<KanjiStep>> _loadKanjiSteps() async {
    try {
      final jsonString = await rootBundle.loadString('assets/json/ak.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      return jsonMap.entries
          .map((entry) => KanjiStep.fromJson(
                int.tryParse(entry.key) ?? 0,
                entry.value,
              ))
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id));
    } catch (e, stacktrace) {
      debugPrint('Error loading kanji steps: $e');
      debugPrint(stacktrace.toString());
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    _startLeafAnimation();
  }

  Future<void> _initializeData() async {
    try {
      final steps = await _loadKanjiSteps();
      if (mounted) {
        setState(() {
          _steps = steps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startLeafAnimation() {
    _receivePort = ReceivePort();
    
    Isolate.spawn<_IsolateParams>(
      _leafSpawner,
      _IsolateParams(
        sendPort: _receivePort.sendPort,
        screenSize: window.physicalSize / window.devicePixelRatio,
        leafImages: _leafImages,
      ),
    ).then((isolate) {
      _isolate = isolate;
    });

    _receivePort.listen((data) {
      if (mounted) {
        setState(() => _leaves.add(data));
      }
    });
  }

  @override
  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _receivePort.close();
    super.dispose();
  }

  List<Widget> _buildKanjiGrid() {
    if (_steps.isEmpty) return [];
    
    final gridItems = <Widget>[];
    int currentIndex = 0;
    int rowIndex = 0;

    while (currentIndex < _steps.length) {
      final itemsInRow = _calculateItemsForRow(rowIndex, _steps.length - currentIndex);
      final rowItems = _steps.sublist(currentIndex, currentIndex + itemsInRow);
      
      gridItems.add(_KanjiRow(
        items: rowItems,
        startIndex: currentIndex,
        onItemTap: _handleKanjiTap,
      ));
      
      currentIndex += itemsInRow;
      rowIndex++;
    }

    return gridItems;
  }

  int _calculateItemsForRow(int rowIndex, int remainingItems) {
    if (remainingItems <= 0) return 0;
    
    // Handle special cases for remainders
    if (remainingItems == 3) return 2;
    if (remainingItems == 1) return 1;
    
    // Use pattern sequence
    final patternIndex = rowIndex % _patternSequence.length;
    final patternValue = _patternSequence[patternIndex];
    
    return patternValue.clamp(1, remainingItems);
  }

  void _handleKanjiTap(KanjiStep item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KanjiLessonPage(
          id: item.id,
          name: item.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/background_tree.jpg',
              fit: BoxFit.cover,
            ),
          ),
          
          // Falling leaves
          ..._leaves.map((leaf) => _LeafWidget(
            key: ValueKey(leaf.id),
            leafData: leaf,
            screenSize: size,
            onComplete: () {
              if (mounted) {
                setState(() => _leaves.removeWhere((l) => l.id == leaf.id));
              }
            },
          )),
          
          // Kanji content
          if (!_isLoading)
            _KanjiContent(
              children: _buildKanjiGrid(),
            ),
        ],
      ),
    );
  }
}

/// Simplified Kanji row widget
class _KanjiRow extends StatelessWidget {
  final List<KanjiStep> items;
  final int startIndex;
  final Function(KanjiStep) onItemTap;

  const _KanjiRow({
    required this.items,
    required this.startIndex,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spacing = items.length > 1 ? 12.0 : 0.0;
          final totalSpacing = spacing * (items.length - 1);
          final itemWidth = ((constraints.maxWidth - totalSpacing) / items.length)
              .clamp(80.0, 180.0);

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              
              return Padding(
                padding: EdgeInsets.only(right: index < items.length - 1 ? spacing : 0),
                child: _KanjiItem(
                  item: item,
                  width: itemWidth,
                  onTap: () => onItemTap(item),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

/// Individual Kanji item widget
class _KanjiItem extends StatelessWidget {
  final KanjiStep item;
  final double width;
  final VoidCallback onTap;

  const _KanjiItem({
    required this.item,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = (width * 0.35).clamp(30.0, 55.0);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: radius,
              backgroundColor: Colors.green.shade50,
              backgroundImage: AssetImage(item.image),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Content container for Kanji grid
class _KanjiContent extends StatelessWidget {
  final List<Widget> children;

  const _KanjiContent({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(children: children),
      ),
    );
  }
}

/// Isolate parameters
class _IsolateParams {
  final SendPort sendPort;
  final Size screenSize;
  final List<String> leafImages;

  const _IsolateParams({
    required this.sendPort,
    required this.screenSize,
    required this.leafImages,
  });
}

/// Leaf data model
class _LeafData {
  final String id;
  final double x;
  final double size;
  final int startTime;
  final String asset;

  const _LeafData({
    required this.id,
    required this.x,
    required this.size,
    required this.startTime,
    required this.asset,
  });
}

/// Isolate function for leaf generation
void _leafSpawner(_IsolateParams params) async {
  final random = Random();
  const spawnInterval = Duration(milliseconds: 600);
  
  while (true) {
    await Future.delayed(spawnInterval);
    
    final leaf = _LeafData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      x: random.nextDouble() * params.screenSize.width,
      size: 30 + random.nextDouble() * 25,
      startTime: DateTime.now().millisecondsSinceEpoch,
      asset: params.leafImages[random.nextInt(params.leafImages.length)],
    );
    
    params.sendPort.send(leaf);
  }
}

/// Enhanced leaf animation widget
class _LeafWidget extends StatefulWidget {
  final _LeafData leafData;
  final Size screenSize;
  final VoidCallback onComplete;

  const _LeafWidget({
    super.key,
    required this.leafData,
    required this.screenSize,
    required this.onComplete,
  });

  @override
  State<_LeafWidget> createState() => _LeafWidgetState();
}

class _LeafWidgetState extends State<_LeafWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yPos;
  late Animation<double> _rotation;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    final random = Random();
    final fallDuration = Duration(seconds: 4 + random.nextInt(4));

    _controller = AnimationController(
      vsync: this,
      duration: fallDuration,
    );

    // Sync animation to start time
    final elapsed = DateTime.now().millisecondsSinceEpoch - widget.leafData.startTime;
    final progress = (elapsed / fallDuration.inMilliseconds).clamp(0.0, 1.0);
    _controller.value = progress;
    _controller.forward(from: progress);

    _setupAnimations(random);
    _controller.addStatusListener(_handleAnimationStatus);
  }

  void _setupAnimations(Random random) {
    _yPos = Tween<double>(
      begin: -50,
      end: widget.screenSize.height + 50,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _rotation = Tween<double>(
      begin: 0,
      end: 2 * pi * (0.5 + random.nextDouble() * 1.5),
    ).animate(_controller);

    _opacity = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 0.2,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 0.6,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 0.2,
      ),
    ]).animate(_controller);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final sway = sin(_controller.value * pi * 2) * 40;
        
        return Positioned(
          left: widget.leafData.x + sway,
          top: _yPos.value,
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.rotate(
              angle: _rotation.value,
              child: Image.asset(
                widget.leafData.asset,
                width: widget.leafData.size,
                height: widget.leafData.size,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Kanji data model
class KanjiStep {
  final int id;
  final String name;
  final String image;
  final String description;

  const KanjiStep({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
  });

  factory KanjiStep.fromJson(int id, Map<String, dynamic> json) {
    return KanjiStep(
      id: id,
      name: json['category'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
