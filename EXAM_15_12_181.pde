/*
HEADER
 REMEMBER TO CREDIT THE CREATORS OF SPRITESHEETS ETC
 Note when we have used other peoples code
 MUSIC: Slagsmålsklubben -  Yrsel 606
 
 testtest test
 test karolinefo
 */
import ddf.minim.*;
Minim minim;
AudioPlayer[] audioPlayers = new AudioPlayer[4];

Player[] players = new Player[2];
Shot[] shots = new Shot [50];
Level[] levels = new Level[5];
//Candy[] candies = new Candy[50];
Skeleton[] skeletons = new Skeleton[50];
//Monster[] monsters = new Monster[20];
//Exit exit; 
Tile[] tiles = new Tile [512];
Spark[] sparks = new Spark[200]; //note that I've out them in main so more objects can explode

//variables
char[] controls = new char[5];
char[] controls1 = new char[5];
String[] lines;
PImage floor;
PImage instructions;
PImage menu;
PImage gameOver;
PImage highScoreIMG;
int weAreInLevel=0;
int life=3;
int gamestate=0;
int playerCount=0;
int score = 0;
int highScore=0; 

void setup()
{
  size(800, 400);
  loadImages();
  setupPlayer();
  setControls(); //setting the controls for the players
  setupLevels();
  setupShots();
  setupSparks();
  loadScoreFile();
  setupAudio();

  for (int i=0; i<tiles.length; i++)
  {
    tiles[i] = new Tile();
  }
}

void draw()
{
  imageMode(CORNER);
  if (gamestate==0) {  //gamestate 0 - startscreen and instructions
    showStartScreen();
    audioPlayers[0].play();
  } 
  if (gamestate==1) { //gamestate 1 - playing
    displayBackground();
    showAndUpdateLevels();
    showAndControlPlayers();
    displayAndMoveShots();
    displayScoreAndLife();
    audioPlayers[0].mute();
    audioPlayers[1].play();
    for (int i=0; i<playerCount; i++) { //counts the life(s) and check if the player(s) are gameover
      if (life==0) {
        gamestate=2;
      }
    }
  } else if (gamestate==2) { //gamestate 2 - gameOver
    showGameOverScreen();
    audioPlayers[1].mute();
    audioPlayers[2].play();
  } else if (gamestate==3) { //gamestate 3 - game ends aka player gets through all levels and sees their score
    resetGame();
    audioPlayers[2].mute();
    audioPlayers[3].play();
    endGame();
  }
}

void keyPressed()
{
  for (int i = 0; i < playerCount; i++)
  {
    players[i].keyWasPressed(key);
  }
  if (gamestate==2) {
    showGameOverScreen();
  }
  if (gamestate==0) {
    showStartScreen();
  }
  if (gamestate==3) {
    endGame();
  }
}

void keyReleased()
{
  for (int i = 0; i < playerCount; i++)
  {
    players[i].keyWasReleased(key);
  }
  if (gamestate==2) {
    showGameOverScreen();
  }
  if (gamestate==0) {
    showStartScreen();
  }
  if (gamestate==3) {
    endGame();
  }
}

//setup functions
void setupPlayer() {
  for (int i = 0; i < players.length; i++)
  {
    players[i] = new Player();
  }
}

void setControls() {
  controls[0] = 'L';
  controls[1] = 'J';
  controls[2] = 'I';
  controls[3] = 'K';
  controls[4] = 'M';
  controls1[0] = 'D'; //right
  controls1[1] = 'A'; //left
  controls1[2] = 'W'; //up
  controls1[3] = 'S'; //down
  controls1[4] = 'Z'; //shoot
  for (int i = 0; i < players.length; i++)
  {
    players[0].setControls(controls);
    players[1].setControls(controls1);
  }
}

void displayBackground() {
  image(floor, 0, 0, 800, 400);
}

void loadImages() {
  floor = loadImage("floor.png"); //loading the background
  instructions = loadImage("instructions.png"); //loading the instructions-screen
  menu = loadImage("startmenu.png");
  gameOver = loadImage("gameover.png");
  highScoreIMG = loadImage("highscoreIMG.png");
}

void setupShots() {
  for (int i = 0; i < shots.length; i++)
  {
    shots[i] = new Shot();
  }
}

void setupLevels() {
  for (int i=0; i<levels.length; i++)
  {
    levels[i] = new Level(i);
  }
}

void setupSparks() {
  for (int i = 0; i < sparks.length; i++)
  {
    sparks[i] = new Spark((width * 0.5), (height * 0.5), random(-6, 10), random(-12, 0));
  }
}

void setupAudio() {
  minim = new Minim(this);
  audioPlayers[0] = minim.loadFile("INTRO.wav");
  audioPlayers[1] = minim.loadFile("PLAY.wav");
  audioPlayers[2] = minim.loadFile("GAMEOVER.wav");
  audioPlayers[3] = minim.loadFile("HIGHSCORE.wav");
}

//functions called in draw
void showAndControlPlayers() {
  for (int i=0; i<playerCount; i++) {
    players[i].addPlayer(true);
    players[i].display();
    players[i].movePlayer();
  }
}

void displayAndMoveShots() {
  for (int i=0; i<shots.length; i++) {
    shots[i].display();
    shots[i].move();
  }
}

void showAndUpdateLevels() {
  for (int i=0; i<levels.length; i++) {
    if (weAreInLevel < levels.length) {
      levels[weAreInLevel].display(); //displays the current level
      levels[i].checkAllCollisions();
    } else {
      gamestate=3;
    }
  }
}

void showGameOverScreen() {
  image(gameOver, 0, 0, 800, 400);
  if (keyCode=='N') {
    gamestate=0;
  }
}

void endGame() { //when the player has completed the game (i.e. not gameover)
  drawEndscreenGraphics();
  addScoreToHighscoreList(); //HIGHSCORELIST!
  saveFile();
  sortAndShowHighscoreList();
  image(highScoreIMG, 0, 0, 800, 400);
  if (keyCode=='N') {
    gamestate=0;
  }
}

//void endGameScreen() {
//  image(highScoreIMG, 0, 0, 800, 400); // don't delete
//  fill(255, 255, 0);
//  text(+score, 350, 120);
//  // lines[0]+=highScore;
//  saveFile();
//  showScoresFromHighScoreList ();
//  //EVERTHING SHOULD BE RESET HERE!!!
//  if (keyCode=='N') {
//    gamestate=0;
//  }
//}

//void showScoresFromHighScoreList () {
//  for (int i=0; i<lines.length; i++) {
//    text(lines[5], 600, 120+60*i);
//  }
//}
void drawEndscreenGraphics() {
  image(highScoreIMG, 0, 0, 800, 400);
  fill(255, 255, 0);
  text(+score, 350, 120);
}

void sortAndShowHighscoreList() {
  for (int i=0; i<lines.length; i++)
    lines = sort(lines);
  lines = reverse(lines);
  {
    displayScoresFromHighScoreList();
  }
}

void displayScoresFromHighScoreList () {
  for (int i=0; i<5; i++) { //only show top five
    text(lines[i], 600, 120+60*i);
  }
}

void addScoreToHighscoreList() {
  // for (int i=0; i<lines.length; i++) {
  //set(lines[i+1], score); SET DOESNT WORK WITHOUT INTLIST
  //   expand(lines[i], +1); nullPointException.... 
  //lines.add(new line(score)); ADD() ONLY WORKS FOR OBJECTS...
}

void saveFile() {
  saveStrings("highscoreList.txt", lines);
}

void loadScoreFile() {
  lines = loadStrings("highscoreList.txt");
}

//We don't need highscore when saving it n a file?
//void calcHighscore() {
//  highScore=max(score, highScore);
//}

void displayScoreAndLife() {
  textSize(20);
  fill(0);
  text("SCORE: "+score, 655, 20);
  text("LIFE: "+life, 10, 20);
}

void showStartScreen() {
  image(menu, 0, 0, 800, 400);
  if (keyCode=='V') {
    image(instructions, 0, 0, 800, 400);
  }
  if (keyCode=='N') {
    image(menu, 0, 0, 800, 400);
  }
  if (keyCode=='B') {
    gamestate=1;
    playerCount=1;
  }
  if (keyCode=='C') {
    gamestate=1;
    playerCount=2;
  }
}

void resetGame() { //Some objects might be off already due to other circumstances, but if not, this function take scare of it. The shots turn themselves off if > X or hit somehting
  for (int i=0; i<playerCount; i++) { //turns player of
    players[i].isOn=false;
    players[i].resetPlayerCoordinate();
    //players[i].stopMoving(); //PLAYER STOP MOVING should include speed - see notes in player class
  }
  for (int i=0; i<levels.length; i++) { //resets candy, exits, levels, skeletons, tiles if weAreLevel is more than 5.
    levels[i].resetGame();
  }
  score=0;
  life=3;
  weAreInLevel=0;
  playerCount=0;
}
