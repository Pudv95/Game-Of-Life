class Controller {
  static List<int> getNeighbours(int index) {
    List<int> neighbours = [];
    if (index % 20 != 0) {
      neighbours.add(index - 21);
      neighbours.add(index - 1);
      neighbours.add(index + 19);
    }
    if (index % 20 != 19) {
      neighbours.add(index - 19);
      neighbours.add(index + 1);
      neighbours.add(index + 21);
    }
    neighbours.add(index - 20);
    neighbours.add(index + 20);
    return neighbours;
  }
}
