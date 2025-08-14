import 'package:flutter/material.dart';

class ArticlePage extends StatefulWidget{
  final String title;

  const ArticlePage({super.key, required this.title});

  @override
  State<ArticlePage> createState() => _ArticleState();
}

class _ArticleState extends State<ArticlePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text(
          'Article Test Page for ${widget.title}',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}