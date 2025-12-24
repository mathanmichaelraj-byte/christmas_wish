import 'dart:math';
import 'dart:ui';

import 'package:christmas_wish/widgets/christmas_wish_dialog.dart';
import 'package:christmas_wish/widgets/ornament.dart';
import 'package:christmas_wish/widgets/painter.dart';
import 'package:flutter/material.dart';

class GameHomePage extends StatefulWidget {
  const GameHomePage({Key? key}) : super(key: key);

  @override
  State<GameHomePage> createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> with TickerProviderStateMixin {
  List<Ornament> placedOrnaments = [];
  List<TargetOrnament> targetOrnaments = [];
  int correctPlacements = 0;
  bool showReference = true;
  late AnimationController _sparkleController;
  OrnamentType? selectedOrnament;
  int score = 0;
  int streak = 0;
  
  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _generateTargetPattern();
  }

  void _generateTargetPattern() {
    setState(() {
      targetOrnaments = [
        TargetOrnament(position: const Offset(148, 55), type: OrnamentType.star),
        TargetOrnament(position: const Offset(100, 100), type: OrnamentType.redBall),
        TargetOrnament(position: const Offset(195, 100), type: OrnamentType.blueBall),
        TargetOrnament(position: const Offset(100, 160), type: OrnamentType.candy),
        TargetOrnament(position: const Offset(150, 150), type: OrnamentType.bell),
        TargetOrnament(position: const Offset(200, 160), type: OrnamentType.snowflake),
        //TargetOrnament(position: const Offset(85, 210), type: OrnamentType.redBall),
        TargetOrnament(position: const Offset(150, 270), type: OrnamentType.gift),
        //TargetOrnament(position: const Offset(215, 210), type: OrnamentType.blueBall),
      ];
    });
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  void toggleReference() {
    setState(() {
      showReference = !showReference;
    });
  }

  void addOrnament(Offset position, OrnamentType type) {
    for (var target in targetOrnaments) {
      if (!target.isMatched && 
          (target.position - position).distance < 40 && 
          target.type == type) {
        setState(() {
          target.isMatched = true;
          placedOrnaments.add(Ornament(
            position: target.position,
            type: type,
            id: DateTime.now().millisecondsSinceEpoch,
            isCorrect: true,
          ));
          correctPlacements++;
          streak++;
          score += 10 * streak;
          
          if (correctPlacements == targetOrnaments.length) {
            Future.delayed(const Duration(milliseconds: 500), () {
              _showChristmasWish();
            });
          }
        });
        return;
      }
    }
    setState(() {
      streak = 0;
    });
  }

  void _showChristmasWish() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChristmasWishDialog(
        score: score,
        onRestart: () {
          Navigator.pop(context);
          _restartGame();
        },
      ),
    );
  }

  void _restartGame() {
    setState(() {
      placedOrnaments.clear();
      correctPlacements = 0;
      selectedOrnament = null;
      score = 0;
      streak = 0;
      for (var target in targetOrnaments) {
        target.isMatched = false;
      }
    });
  }

  String _getOrnamentIcon(OrnamentType type) {
    switch (type) {
      case OrnamentType.redBall:
        return '🔴';
      case OrnamentType.blueBall:
        return '🔵';
      case OrnamentType.star:
        return '⭐';
      case OrnamentType.candy:
        return '🍭';
      case OrnamentType.bell:
        return '🔔';
      case OrnamentType.snowflake:
        return '❄️';
      case OrnamentType.gift:
        return '🎁';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isSmallScreen),
              Expanded(
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size.infinite,
                      painter: StarsPainter(_sparkleController),
                    ),
                    if (isSmallScreen)
                      _buildMobileLayout()
                    else
                      _buildDesktopLayout(),
                    if (showReference) _buildReferenceOverlay(screenWidth, screenHeight),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(child: _buildWorkTree()),
        _buildOrnamentPaletteHorizontal(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildOrnamentPalette(),
        Expanded(child: _buildWorkTree()),
      ],
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 20, 
        vertical: isSmallScreen ? 8 : 16
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade800, Colors.red.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎄 Christmas Tree',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 16 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isSmallScreen)
                  const Text(
                    'Match the pattern',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12, 
                  vertical: isSmallScreen ? 6 : 8
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade600, Colors.amber.shade400],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: isSmallScreen ? 16 : 20),
                    SizedBox(width: isSmallScreen ? 4 : 8),
                    Text(
                      '$correctPlacements/${targetOrnaments.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isSmallScreen ? 4 : 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12, 
                  vertical: isSmallScreen ? 6 : 8
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade600, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: isSmallScreen ? 16 : 20),
                    SizedBox(width: isSmallScreen ? 4 : 8),
                    Text(
                      '$score',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isSmallScreen ? 4 : 8),
              Material(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: toggleReference,
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                    child: Icon(
                      showReference ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white,
                      size: isSmallScreen ? 20 : 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrnamentPalette() {
    final allTypes = [
      OrnamentType.redBall,
      OrnamentType.blueBall,
      OrnamentType.star,
      OrnamentType.candy,
      OrnamentType.bell,
      OrnamentType.snowflake,
      OrnamentType.gift,
    ];

    return Container(
      width: 100,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.shade900.withOpacity(0.8),
            Colors.green.shade700.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade800,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: const Center(
              child: Text(
                '🎨',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: allTypes.length,
              itemBuilder: (context, index) {
                final type = allTypes[index];
                final isSelected = selectedOrnament == type;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOrnament = type;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [Colors.amber.shade400, Colors.amber.shade600],
                            )
                          : LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.amber : Colors.white.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          _getOrnamentIcon(type),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (streak > 1)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.red.shade400],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '🔥 $streak',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: _restartGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: const Icon(Icons.refresh, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrnamentPaletteHorizontal() {
    final allTypes = [
      OrnamentType.redBall,
      OrnamentType.blueBall,
      OrnamentType.star,
      OrnamentType.candy,
      OrnamentType.bell,
      OrnamentType.snowflake,
      OrnamentType.gift,
    ];

    return Container(
      height: 100,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade900.withOpacity(0.8),
            Colors.green.shade700.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: allTypes.length,
              itemBuilder: (context, index) {
                final type = allTypes[index];
                final isSelected = selectedOrnament == type;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOrnament = type;
                    });
                  },
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [Colors.amber.shade400, Colors.amber.shade600],
                            )
                          : LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.amber : Colors.white.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _getOrnamentIcon(type),
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: _restartGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.refresh, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceOverlay(double screenWidth, double screenHeight) {
    final overlayWidth = screenWidth > 800 ? 320.0 : screenWidth * 0.85;
    final isSmallScreen = screenWidth < 600;

    return Positioned(
      top: 8,
      right: isSmallScreen ? null : 8,
      left: isSmallScreen ? (screenWidth - overlayWidth) / 2 : null,
      child: Container(
        width: overlayWidth,
        height: isSmallScreen ? screenHeight * 0.5 : screenHeight * 0.7,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade900.withOpacity(0.95),
              Colors.blue.shade900.withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade800, Colors.purple.shade600],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      '📋 Reference',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: toggleReference,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 300,
                  height: 320,
                  child: Stack(
                    children: [
                      Center(
                        child: CustomPaint(
                          size: const Size(300, 320),
                          painter: ChristmasTreePainter(),
                        ),
                      ),
                      ...targetOrnaments.map((target) {
                        return Positioned(
                          left: target.position.dx - 16,
                          top: target.position.dy - 16,
                          child: Text(
                            _getOrnamentIcon(target.type),
                            style: const TextStyle(fontSize: 24),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkTree() {
    final key = GlobalKey();
    
    return GestureDetector(
      onTapDown: (details) {
        if (selectedOrnament != null && key.currentContext != null) {
          final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
          final localPosition = box.globalToLocal(details.globalPosition);
          
          final centerX = box.size.width / 2;
          final centerY = box.size.height / 2;
          
          final adjustedPosition = Offset(
            localPosition.dx - centerX + 150,
            localPosition.dy - centerY + 120,
          );
          
          addOrnament(adjustedPosition, selectedOrnament!);
        }
      },
      child: Container(
        key: key,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900.withOpacity(0.3),
              Colors.blue.shade700.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final centerX = constraints.maxWidth / 2;
            final centerY = constraints.maxHeight / 2;
            
            return Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: SnowPainter(),
                ),
                Positioned(
                  left: centerX - 150,
                  top: centerY - 140,
                  child: CustomPaint(
                    size: const Size(300, 320),
                    painter: ChristmasTreePainter(),
                  ),
                ),
                ...targetOrnaments.map((target) {
                  if (!target.isMatched) {
                    return Positioned(
                      left: centerX + target.position.dx - 150 - 16,
                      top: centerY + target.position.dy - 140 - 16,
                      child: AnimatedBuilder(
                        animation: _sparkleController,
                        builder: (context, child) {
                          return Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.yellow.withOpacity(
                                  0.6 + sin(_sparkleController.value * 2 * pi) * 0.2
                                ),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }).toList(),
                ...placedOrnaments.map((ornament) {
                  return Positioned(
                    left: centerX + ornament.position.dx - 150 - 16,
                    top: centerY + ornament.position.dy - 140 - 16,
                    child: TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 400),
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      curve: Curves.elasticOut,
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Text(
                            _getOrnamentIcon(ornament.type),
                            style: const TextStyle(fontSize: 32),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
                if (selectedOrnament != null)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber.shade600, Colors.amber.shade400],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '✨ Tap yellow circles to place ${_getOrnamentIcon(selectedOrnament!)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}