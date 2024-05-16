import 'dart:async';
import 'dart:typed_data';

import 'package:casavia/model/hebergement.dart';
import 'package:flutter/material.dart';

class HebergementImageAnimator extends StatefulWidget {
  final Hebergement hebergement;

  HebergementImageAnimator({Key? key, required this.hebergement})
      : super(key: key);

  @override
  _HebergementImageAnimatorState createState() =>
      _HebergementImageAnimatorState();
}

class _HebergementImageAnimatorState extends State<HebergementImageAnimator> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.hebergement.images!.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var imageList = widget.hebergement.images!;
    return AnimatedSwitcher(
      duration: Duration(seconds: 1),
      child: Image.memory(
        imageList[_currentIndex].image as Uint8List,
        key: ValueKey<int>(_currentIndex),
        height: 150,
        width: double.infinity,
        fit: BoxFit.fill,
      ),
    );
  }
}
