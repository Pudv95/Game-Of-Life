class CellData {
  int index;
  bool alive = false;
  int aliveNeighbours = 0;

  CellData(
      {required this.alive,
      required this.index,
      required this.aliveNeighbours});

  @override
  String toString() {
    return 'index: $index, aliveNeighbours: $aliveNeighbours';
  }
}
