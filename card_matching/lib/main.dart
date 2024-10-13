import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(CardFlipGame());

class CardFlipGame extends StatelessWidget {
  const CardFlipGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 30,
          title: const Text('Card Flip Game'),
        ),
        body: CardGrid(),
      ),
    );
  }
}

class CardGrid extends StatefulWidget {
  const CardGrid({super.key});

  @override
  _CardGridState createState() => _CardGridState();
}

class _CardGridState extends State<CardGrid> with TickerProviderStateMixin {
  List<bool> flipped = List<bool>.filled(18, false);

  final List<String> cardImages = [
    'assets/image001.gif',
    'assets/image002.gif',
    'assets/image003.gif',
    'assets/image004.gif',
    'assets/image005.gif',
    'assets/image006.gif',
    'assets/image007.gif',
    'assets/image008.gif',
    'assets/image009.gif',
    'assets/image010.gif',
    'assets/image011.gif',
    'assets/image012.gif',
  ];

  List<String> Cards = [];

  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _animations = [];

  List<int> faceUpCards = [];

  bool disableInput = false;

  @override
  void initState() {
    super.initState();

    List<String> selectedCards = List<String>.from(cardImages)..shuffle();
    selectedCards = selectedCards.take(9).toList(); 

    Cards = [...selectedCards, ...selectedCards];

    Cards.shuffle(Random());

    for (int i = 0; i < 18; i++) {
      AnimationController controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );

      Animation<double> animation = Tween<double>(begin: 0, end: 1).animate(controller);
      _controllers.add(controller);
      _animations.add(animation);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _flipCard(int index) async {
    if (flipped[index] || disableInput) return;

    setState(() {
      flipped[index] = !flipped[index];
      faceUpCards.add(index);
    });

    if (_controllers[index].isCompleted) {
      _controllers[index].reverse();
    } else {
      _controllers[index].forward();
    }

    if (faceUpCards.length == 2) {
      disableInput = true; 

      await Future.delayed(const Duration(seconds: 1));

      int firstCard = faceUpCards[0];
      int secondCard = faceUpCards[1];

      if (Cards[firstCard] == Cards[secondCard]) {
        setState(() {
          faceUpCards.clear(); 
        });
      } else {
        setState(() {
          flipped[firstCard] = false;
          flipped[secondCard] = false;
        });

        _controllers[firstCard].reverse();
        _controllers[secondCard].reverse();

        await Future.delayed(const Duration(milliseconds: 500)); 
        setState(() {
          faceUpCards.clear(); 
        });
      }

      disableInput = false; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: 18, 
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, 
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _flipCard(index);
            },
            child: AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                final isFront = _animations[index].value < 0.5;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(_animations[index].value * pi),
                  child: isFront
                      ? Image.asset(
                          'assets/card_back.jpg', 
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          Cards[index], 
                          fit: BoxFit.cover,
                        ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
