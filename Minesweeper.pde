final int MINEFIELD_WIDTH = 16;
final int MINEFIELD_HEIGHT = 16;
final int NUM_MINES = 50;
final int FIXED_SEED = 0;

final int CELL_WIDTH = 32;
final int CELL_HEIGHT = 32;


PImage mine, flag, numbers[];

boolean gameover = false, won, rematch;

boolean tobiMode = false, autoRevealMode = false, fullAssistMode = false;

int startTime;
int gameoverTime;

int seed;

int firstClickedX, firstClickedY;

Cell minefield[][];

void settings() {
  size(MINEFIELD_WIDTH * (CELL_WIDTH + 1), MINEFIELD_HEIGHT * (CELL_HEIGHT + 1));
}

void setup () {
  
  mine = loadImage("pic/png/mine.png");
  flag = loadImage("pic/png/flag.png");

  numbers = new PImage[9];

  numbers[0] = loadImage("pic/png/empty.png");
  numbers[1] = loadImage("pic/png/one.png");
  numbers[2] = loadImage("pic/png/two.png");
  numbers[3] = loadImage("pic/png/three.png");
  numbers[4] = loadImage("pic/png/four.png");
  numbers[5] = loadImage("pic/png/five.png");
  numbers[6] = loadImage("pic/png/six.png");
  numbers[7] = loadImage("pic/png/seven.png");
  numbers[8] = loadImage("pic/png/eight.png");

  minefield = new Cell[MINEFIELD_WIDTH][MINEFIELD_HEIGHT];

  restart(false);
}

void draw () {
  background(240);

  int minesRemaining = NUM_MINES;
  // Draw field contents
  for (int x = 0; x < MINEFIELD_WIDTH; x++) {
    for (int y = 0; y < MINEFIELD_HEIGHT; y++) {
      if (minefield[x][y].revealed) {
        noStroke();
        fill(200);
        rect(x*(CELL_WIDTH+1), y*(CELL_HEIGHT+1), CELL_WIDTH, CELL_HEIGHT);
        if (minefield[x][y].mined) {
          image(mine, x*(CELL_WIDTH+1) + 1, y*(CELL_HEIGHT+1) + 1);
        } else {
          if (minefield[x][y].mined_neighbours > 0) {
            image(numbers[minefield[x][y].mined_neighbours], x*(CELL_WIDTH+1) + 1, y*(CELL_HEIGHT+1) + 1);
          }
        }
      } else {
        if (minefield[x][y].flagged) {
          image(flag, x*(CELL_WIDTH+1) + 1, y*(CELL_HEIGHT+1) + 1);
          minesRemaining--;
        }
      }
    }
  }
  surface.setTitle("Mines remaining: " + minesRemaining);


  // Draw grid
  stroke(160);
  for (int i = CELL_WIDTH; i< width; i+=CELL_WIDTH+1) {
    line(i, 0, i, height);
  }
  for (int i = CELL_HEIGHT; i< height; i+=CELL_WIDTH+1) {
    line(0, i, width, i);
  }

  if (gameover) {
    textSize(64);
    fill(#FF0000);
    textAlign(CENTER, BOTTOM);
    if (won) {
      text("YOU WON!", width/2, height/2 - 10);

      textAlign(CENTER, TOP);
      fill(255);
      noStroke();
      rect(width/2 - 75, height/2 + 5, 150, 30);
      textSize(16);
      fill(0);
      text("Time: " + (gameoverTime - startTime)/1000.0 + " s", width/2, height/2 + 10);
    } else text("GAMEOVER!", width/2, height/2 - 10);
  }

  if (tobiMode) {
    int mx = mouseX/(CELL_WIDTH+1);
    int my = mouseY/(CELL_HEIGHT+1);
    noFill();
    stroke(120);
    rect((mx-1)*(CELL_WIDTH+1), (my-1)*(CELL_HEIGHT+1), (CELL_WIDTH+1)*3, (CELL_WIDTH+1)*3);
  }
}

boolean firstClick = true;

void mousePressed() {
  if (!gameover) {
    int x = mouseX/(CELL_WIDTH+1);
    int y = mouseY/(CELL_HEIGHT+1);

    if (mouseButton == LEFT) {

      if (firstClick) {
        if (rematch) {
          generateBoard(firstClickedX, firstClickedY); 
          reveal(firstClickedX, firstClickedY);
        } else {
          generateBoard(x, y);
          reveal(x, y);
        }
        firstClick = false;
      } else {
        if (!minefield[x][y].revealed) {
          reveal(x, y);
        } else {
          autoreveal(x, y);
        }
      }
    } else if (mouseButton == RIGHT) {
      if (!minefield[x][y].revealed) {
        minefield[x][y].flagged = !minefield[x][y].flagged;
      }
    }
    
    if (!gameover && (autoRevealMode || fullAssistMode)) autorevealAll();
  } else {
    restart(false);
  }
}

void keyPressed() {
  if (key == 'r') {
    restart(false);
  }
  if (key == 't') {
    tobiMode = !tobiMode;
  }
  if (key == 'f') {
    fullAssistMode = !fullAssistMode;
    if (fullAssistMode) {
      println("Auto mode on!");
      autorevealAll();
    } else println("Auto mode off!");
  }
  if (key == ' ') {
    autorevealAll();
  }

  if (key == 'a') {
    autoRevealMode = !autoRevealMode;
    if (autoRevealMode) {
      println("Auto mode on!");
      autorevealAll();
    } else println("Auto mode off!");
  }

  if (key == 'm') {
    restart(true);
  }
}

boolean autoreveal(int x, int y) {
  boolean changed = false;
  if (countFlaggedNeighbours(x, y) == minefield[x][y].mined_neighbours) {
    for (int nx = x-1; nx <=x+1; nx++) {
      for (int ny = y-1; ny <= y+1; ny++) {
        if (nx >= 0 && nx < MINEFIELD_WIDTH && ny >= 0 && ny < MINEFIELD_HEIGHT && !minefield[nx][ny].flagged) {
          if (reveal(nx, ny)) changed = true;
        }
      }
    }
  }
  return changed;
}

boolean fullAssist(int x, int y) {
  int n = 0;
  for (int nx = x-1; nx <= x+1; nx++) {
    for (int ny = y-1; ny <= y+1; ny++) {
      if (nx >= 0 && nx < MINEFIELD_WIDTH && ny >= 0 && ny < MINEFIELD_HEIGHT) {
        Cell nm = minefield[nx][ny];
        if (!nm.revealed) {
          n++;
        }
      }
    }
  }
  if (n == minefield[x][y].mined_neighbours && n != countFlaggedNeighbours(x, y)) {
    for (int nx = x-1; nx <= x+1; nx++) {
      for (int ny = y-1; ny <= y+1; ny++) {
        if (nx >= 0 && nx < MINEFIELD_WIDTH && ny >= 0 && ny < MINEFIELD_HEIGHT) {
          if (!minefield[nx][ny].revealed) minefield[nx][ny].flagged = true;
        }
      }
    }
    return true;
  }

  return false;
}

void autorevealAll() {
  boolean keepGoing = true;
  while (keepGoing) {
    keepGoing = false;
    for (int x = 0; x < MINEFIELD_WIDTH; x++) {
      for (int y = 0; y < MINEFIELD_HEIGHT; y++) {
        if (minefield[x][y].revealed) {
          if (fullAssistMode) {
            if (fullAssist(x, y)) keepGoing = true;
          }
          if (autoreveal(x, y)) keepGoing = true;
        }
      }
    }
  }
}

// Returns whether something got revealed
boolean reveal(int x, int y) {
  boolean changed = false;
  if (!minefield[x][y].flagged && !minefield[x][y].revealed) {
    minefield[x][y].revealed = true;
    changed = true;
    if (minefield[x][y].mined) {
      gameover(false);
    } else {
      if (minefield[x][y].mined_neighbours == 0) {
        for (int nx = x-1; nx <= x+1; nx++) {
          for (int ny = y-1; ny <= y+1; ny++) {
            if (nx >= 0 && nx < MINEFIELD_WIDTH && ny >= 0 && ny < MINEFIELD_HEIGHT && (nx != x || ny != y)) reveal(nx, ny);
          }
        }
      }

      for (int i = 0; i < MINEFIELD_WIDTH; i++) {
        for (int j = 0; j < MINEFIELD_HEIGHT; j++) {
          if (!(minefield[i][j].mined || minefield[i][j].revealed)) return changed;
        }
      }
      gameover(true);
    }
  }
  return changed;
}
void gameover(boolean win) {
  gameover = true;
  won = win;
  if (win) {
    for (int x = 0; x < MINEFIELD_WIDTH; x++) {
      for (int y = 0; y < MINEFIELD_HEIGHT; y++) {
        if (minefield[x][y].mined) minefield[x][y].flagged = true;
      }
    }
  } else {
    for (int x = 0; x < MINEFIELD_WIDTH; x++) {
      for (int y = 0; y < MINEFIELD_HEIGHT; y++) {
        if (minefield[x][y].mined) minefield[x][y].revealed = true;
      }
    }
  }
  gameoverTime = millis();
}

void restart(boolean keepSeed) {
  rematch = keepSeed;
  gameover = false;
  firstClick = true;
  for (int x = 0; x < MINEFIELD_WIDTH; x++) {
    for (int y = 0; y < MINEFIELD_HEIGHT; y++) {
      minefield[x][y] = new Cell(false);
    }
  }
  if (!keepSeed) {
    if (FIXED_SEED != 0) {
      println("Running with fixed seed!");
      seed = FIXED_SEED;
    } else {
      seed = int(random(-(1<<30), 1<<30));
      println("Seed: " + seed);
    }
  }
  randomSeed(seed);
}

void generateBoard(int clickX, int clickY) {
  for (int i = 0; i < NUM_MINES; i++) {
    int bx, by;
    do {
      bx = int(random(0, MINEFIELD_WIDTH));
      by = int(random(0, MINEFIELD_HEIGHT));
    } while (minefield[bx][by].mined || (abs(bx-clickX) <= 1 && abs(by-clickY) <= 1));
    minefield[bx][by].mined = true;
  }

  for (int i = 0; i < MINEFIELD_WIDTH; i++) {
    for (int j = 0; j < MINEFIELD_HEIGHT; j++) {
      minefield[i][j].mined_neighbours = countMinedNeighbours(i, j);
    }
  }

  firstClickedX = clickX; 
  firstClickedY = clickY;

  startTime = millis();
}

// Includes (x,y) itself in the count
int countMinedNeighbours(int x, int y) {
  int n = 0;
  for (int nx = x-1; nx <= x+1; nx++) {
    for (int ny = y-1; ny <= y+1; ny++) {
      if (nx >= 0 && nx < MINEFIELD_WIDTH && ny >= 0 && ny < MINEFIELD_HEIGHT && minefield[nx][ny].mined) n++;
    }
  }
  return n;
}

// Includes (x,y) itself in the count
int countFlaggedNeighbours(int x, int y) {
  int n = 0;
  for (int nx = x-1; nx <= x+1; nx++) {
    for (int ny = y-1; ny <= y+1; ny++) {
      if (nx >= 0 && nx < MINEFIELD_WIDTH && ny >= 0 && ny < MINEFIELD_HEIGHT && minefield[nx][ny].flagged && !minefield[nx][ny].revealed) n++;
    }
  }
  return n;
}
