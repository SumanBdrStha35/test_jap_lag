import 'dart:math';

import 'package:flutter/material.dart';

class FallingLeavesSpring extends StatefulWidget {
  const FallingLeavesSpring({super.key});

  @override
  State<FallingLeavesSpring> createState() => _FallingLeavesSpringState();
}

class _FallingLeavesSpringState extends State<FallingLeavesSpring> with TickerProviderStateMixin {
  final Random random = Random();
  final List<_Leaf> leaves = [];
  
  @override
  void initState() {
    super.initState();
    _spawnLeaves();
  }

  @override
  void dispose() {
    for (var leaf in leaves) {
      leaf.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background_tree.jpg',
              fit: BoxFit.cover,
            ),
          ),
          ...leaves.map((leaf) => leaf.build(context, size)),
        ],
      ),
    );
  }
  
  void _spawnLeaves() {
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 500 + random.nextInt(1000)));
      if (mounted) {
        setState(() {
          leaves.add(_Leaf(
            vsync: this,
            random: random,
            onCompleted: (leaf) {
              setState(() => leaves.remove(leaf));
            },
          ));
        });
      }
      return mounted; // keep spawning until widget is disposed
    });
  }
}

typedef _LeafCallback = void Function(_Leaf);

class _Leaf {
  late AnimationController controller;
  late Animation<double> yPos;
  late Animation<double> xOffset;
  late Animation<double> rotation;
  late Animation<double> opacity;
  final double startX;
  final double size;
  final _LeafCallback onCompleted;

  _Leaf({
    required TickerProvider vsync,
    required Random random,
    required this.onCompleted,
  }) : startX = random.nextDouble(),
       size = 20 + random.nextDouble() * 30 {
    
    final fallDuration = Duration(seconds: 4 + random.nextInt(4));

    controller = AnimationController(vsync: vsync, duration: fallDuration)
      ..forward().whenComplete(() {
        onCompleted(this);
        dispose();
      });

    yPos = Tween<double>(begin: -50, end: 900).animate(
        CurvedAnimation(parent: controller, curve: Curves.linear));

    xOffset = Tween<double>(begin: -20, end: 20).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOutSine));

    rotation = Tween<double>(begin: 0, end: pi * 2).animate(controller);

    opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 0.2),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 0.6),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 0.2),
    ]).animate(controller);
  }

  Widget build(BuildContext context, Size screenSize) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final double x = (screenSize.width * startX) +
            sin(controller.value * pi * 2) * 30 +
            xOffset.value;

        return Positioned(
          top: yPos.value,
          left: x,
          child: Opacity(
            opacity: opacity.value,
            child: Transform.rotate(
              angle: rotation.value,
              child: Image.asset(
                'assets/leaf.png',
                width: size,
                height: size,
              ),
            ),
          ),
        );
      },
    );
  }

  void dispose() {
    controller.dispose();
  }
}
