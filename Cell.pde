class Cell {
  boolean mined;
  boolean flagged;
  boolean revealed;
  
  int mined_neighbours;
  
  public Cell(boolean mined) {
    this.mined = mined;
    flagged = false;
    revealed = false;
  }
}
