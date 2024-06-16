import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gameoflife/Controller/controller.dart';
import 'package:gameoflife/Model/cell_model.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final int gridCount = 700;
  List<CellData>? _cells;
  bool isTouching = false;
  Set<int> selectedCells = {};
  Timer? _timer;
  bool running = false;

  @override
  void initState() {
    super.initState();
    _cells = List<CellData>.generate(gridCount, (index) {
      return CellData(index: index, aliveNeighbours: 0, alive: false);
    });
  }

  void nextState() {
    List<int> newBirth = [];
    List<int> newDeath = [];
    for (int i = 0; i < gridCount; i++) {
      if (_cells![i].alive) {
        if (_cells![i].aliveNeighbours < 2 || _cells![i].aliveNeighbours > 3) {
          newDeath.add(i);
        }
      } else {
        if (_cells![i].aliveNeighbours == 3) {
          newBirth.add(i);
        }
      }
    }
    for (int i in newBirth) {
      updateNeighbours(i);
    }
    for (int i in newDeath) {
      updateNeighbours(i);
    }
    for (int i in newBirth) {
      _cells![i].alive = true;
    }
    for (int i in newDeath) {
      _cells![i].alive = false;
    }
    setState(() {});
  }

  void updateNeighbours(int index) {
    final List<int> neighbours = Controller.getNeighbours(index);
    if (!_cells![index].alive) {
      for (var neighbour in neighbours) {
        if (neighbour >= 0 && neighbour < gridCount) {
          _cells![neighbour].aliveNeighbours++;
        }
      }
    } else {
      for (var neighbour in neighbours) {
        if (neighbour >= 0 && neighbour < gridCount) {
          _cells![neighbour].aliveNeighbours--;
        }
      }
    }
  }

  void _changeColor(int index) {
    updateNeighbours(index);
    if (isTouching) {
      setState(() {
        _cells![index].alive = !_cells![index].alive;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onPanStart: (_) {
          setState(() {
            isTouching = true;
          });
        },
        onPanUpdate: (details) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final localPosition = renderBox.globalToLocal(details.globalPosition);
          final gridSize = MediaQuery.of(context).size.width / 20;
          final row = (localPosition.dy / gridSize).floor() - 2;
          final col = (localPosition.dx / gridSize).floor();
          final index = row * 20 + col;
          if (index >= 0 &&
              index < gridCount &&
              !selectedCells.contains(index)) {
            _changeColor(index);
            selectedCells.add(index);
          }
        },
        onPanEnd: (_) {
          setState(() {
            isTouching = false;
            selectedCells.clear();
          });
        },
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gridCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 20,
          ),
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: _cells![index].alive ? Colors.white : Colors.black,
              ),
            );
          },
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (running) {
                _timer!.cancel();
                running = false;
              } else {
                _timer =
                    Timer.periodic(const Duration(milliseconds: 100), (timer) {
                  nextState();
                });
                running = true;
              }
              setState(() {});
            },
            child: running
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              for (var cell in _cells!) {
                cell.alive = false;
                cell.aliveNeighbours = 0;
              }
              setState(() {});
            },
            child: const Icon(Icons.clear),
          ),
        ],
      ),
    );
  }
}
