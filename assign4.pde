Ship ship;
PowerUp ruby;
Bullet[] bList;
Laser[] lList;
Alien[] aList;

//Game Status
final int GAME_START   = 0;
final int GAME_PLAYING = 1;
final int GAME_PAUSE   = 2;
final int GAME_WIN     = 3;
final int GAME_LOSE    = 4;
int status;              //Game Status
int point;               //Game Score
int expoInit;            //Explode Init Size
int countBulletFrame;    //Bullet Time Counter
int bulletNum;           //Bullet Order Number

/*--------Put Variables Here---------*/
int alienCount = 53;

void setup() {

  status = GAME_START;

  bList = new Bullet[30];
  lList = new Laser[30];
  aList = new Alien[alienCount];

  size(640, 480);
  background(0, 0, 0);
  rectMode(CENTER);

  ship = new Ship(width/2, 460, 3);
  ruby = new PowerUp(int(random(width)), -10);

  reset();
}

void draw() {
  background(50, 50, 50);
  noStroke();

  switch(status) {

  case GAME_START:
    /*---------Print Text-------------*/
    printText();
    /*--------------------------------*/
    break;

  case GAME_PLAYING:
    background(50, 50, 50);

    drawHorizon();
    drawScore();
    drawLife();
    ship.display(); //Draw Ship on the Screen
    drawAlien();
    drawBullet();
    drawLaser();

    /*---------Call functions---------------*/


    checkAlienDead();/*finish this function*/
    checkShipHit();  /*finish this function*/
    alienShoot();

    countBulletFrame+=1;
    break;

  case GAME_PAUSE:
    /*---------Print Text-------------*/
    printText();
    /*--------------------------------*/
    break;

  case GAME_WIN:
    /*---------Print Text-------------*/
    printText();
    /*--------------------------------*/
    winAnimate();
    break;

  case GAME_LOSE:
    loseAnimate();
    /*---------Print Text-------------*/
    printText();
    /*--------------------------------*/
    break;
  }
}

void drawHorizon() {
  stroke(153);
  line(0, 420, width, 420);
}

void drawScore() {
  noStroke();
  fill(95, 194, 226);
  textAlign(CENTER, CENTER);
  textSize(23);
  text("SCORE:"+point, width/2, 16);
}

void keyPressed() {
  if (status == GAME_PLAYING) {
    ship.keyTyped();
    cheatKeys();
    shootBullet(30);
  }
  statusCtrl();
}

/*---------Make Alien Function-------------*/
void alienMaker(int num, int numInRow) {
  int spacingX=40;
  int spacingY=50;
  for(int i=0; i<num;i++){
    int row= int((float)i / (float)numInRow);
    int col= i % numInRow;
    int x = 50 + (spacingX*col);
    int y = 50 + (spacingY*row);
    aList[i]= new Alien(x, y);
  }
}

void drawLife() {
  fill(230, 74, 96);
  text("LIFE:", 36, 455);
  /*---------Draw Ship Life---------*/
  for(int i=0; i<ship.life; i++){
    fill(230, 74, 96);
    ellipse(78+25*i,459, 15, 15);
  }
}

void drawBullet() {
  for (int i=0; i<bList.length; i++) {
    Bullet bullet = bList[i];
    if (bullet!=null && !bullet.gone) { // Check Array isn't empty and bullet still exist
      bullet.move();     //Move Bullet
      bullet.display();  //Draw Bullet on the Screen
      if (bullet.bY<0 || bullet.bX>width || bullet.bX<0) {
        removeBullet(bullet); //Remove Bullet from the Screen
      }
    }
  }
}

void drawLaser() {
  for (int i=0; i<lList.length; i++) { 
    Laser laser = lList[i];
    if (laser!=null && !laser.gone) { // Check Array isn't empty and Laser still exist
      laser.move();      //Move Laser
      laser.display();   //Draw Laser
      if (laser.lY>480) {
        removeLaser(laser); //Remove Laser from the Screen
        lList[i] = null;
      }
    }
  }
}

void drawAlien() {
  for (int i=0; i<aList.length; i++) {
    Alien alien = aList[i];
    if (alien!=null && !alien.die) { // Check Array isn't empty and alien still exist
      alien.move();    //Move Alien
      alien.display(); //Draw Alien
      /*---------Call Check Line Hit---------*/
      checkLineHit();
      /*--------------------------------------*/
    }
  }
}

/*--------Check Line Hit---------*/
void checkLineHit(){
  for (int i=0; i<aList.length; i++) {
    Alien alien = aList[i];
    if (alien.die == false && alien.aY >= 420){
      status = GAME_LOSE;  
      break;
    }
  }
}

/*---------Ship Shoot-------------*/
void shootBullet(int frame) {
  if ( key == ' ' && countBulletFrame>frame) {
    if (!ship.upGrade) {
      bList[bulletNum]= new Bullet(ship.posX, ship.posY, -3, 0);
      if (bulletNum<bList.length-2) {
        bulletNum+=1;
      } else {
        bulletNum = 0;
      }
    } 
    /*---------Ship Upgrade Shoot-------------*/
    else {
      bList[bulletNum]= new Bullet(ship.posX, ship.posY, -3, 0); 
      if (bulletNum<bList.length-2) {
        bulletNum+=1;
      } else {
        bulletNum = 0;
      }
    }
    countBulletFrame = 0;
  }
}

/*---------Check Alien Hit-------------*/
void checkAlienDead() {
  for (int i=0; i<bList.length; i++) {
    Bullet bullet = bList[i];
    for (int j=0; j<aList.length; j++) {
      Alien alien = aList[j];
      if (bullet != null && alien != null && !bullet.gone && !alien.die // Check Array isn't empty and bullet / alien still exist
      && Math.abs(bullet.bX - alien.aX) < alien.aSize + bullet.bSize && Math.abs(bullet.bY - alien.aY) < alien.aSize + bullet.bSize       ) {
        /*-------do something------*/
          removeBullet(bList[i]);
          removeAlien(aList[j]);
          point+=10;
          alienCount--;
          checkWinLose();
      }
    }
  }
}

/*---------Alien Drop Laser-----------------*/
void alienShoot(){
  if (frameCount % 50 == 0) {
    Alien alien = aList[int(random(53))];
    for (int i=0; i<lList.length-1; i++) {  
      if ( lList[i] == null) {
        lList[i] = new Laser(alien.aX, alien.aY);
        break;
      }
    }
  }
}

/*---------Check Laser Hit Ship-------------*/
void checkShipHit() {
  for (int i=0; i<lList.length; i++) {
    Laser laser = lList[i];
    if (laser!= null && !laser.gone // Check Array isn't empty and laser still exist
    && Math.abs(laser.lX - ship.posX) < ship.shipSize/2 + laser.lSize 
    && Math.abs(laser.lY - ship.posY) < ship.shipSize/2 + laser.lSize     ) {
      /*-------do something------*/
      ship.life--;
      removeLaser(laser);
      lList[i] = null;
      checkWinLose();
    }
  }
}

/*---------Check Win Lose------------------*/
void checkWinLose() {
  if ( ship.life <= 0 ) {
    status = GAME_LOSE;
  }
  if ( alienCount <= 0 ) {
    status = GAME_WIN;
  } 
}


void winAnimate() {
  int x = int(random(128))+70;
  fill(x, x, 256);
  ellipse(width/2, 200, 136, 136);
  fill(50, 50, 50);
  ellipse(width/2, 200, 120, 120);
  fill(x, x, 256);
  ellipse(width/2, 200, 101, 101);
  fill(50, 50, 50);
  ellipse(width/2, 200, 93, 93);
  ship.posX = width/2;
  ship.posY = 200;
  ship.display();
}

void loseAnimate() {
  fill(255, 213, 66);
  ellipse(ship.posX, ship.posY, expoInit+200, expoInit+200);
  fill(240, 124, 21);
  ellipse(ship.posX, ship.posY, expoInit+150, expoInit+150);
  fill(255, 213, 66);
  ellipse(ship.posX, ship.posY, expoInit+100, expoInit+100);
  fill(240, 124, 21);
  ellipse(ship.posX, ship.posY, expoInit+50, expoInit+50);
  fill(50, 50, 50);
  ellipse(ship.posX, ship.posY, expoInit, expoInit);
  expoInit+=5;
}

/*---------Check Ruby Hit Ship-------------*/


/*---------Check Level Up------------------*/


/*---------Print Text Function-------------*/
void printText(){
  fill(95,194,226);
  textAlign(CENTER);
  if(status==GAME_START){
    textSize(60);
    text("GALIXIAN", width/2, 240);
    textSize(20);
    text("Press ENTER to Start",width/2, 280);
  }else if(status==GAME_PAUSE){
    textSize(60);
    text("PAUSE", width/2, 240);
    textSize(20);
    text("Press ENTER to Return",width/2, 280);
  }else if(status==GAME_WIN){
    textSize(40);
    text("WINNER", width/2, 300);
    textSize(20);
    text("SCORE:"+point ,width/2,340);
  }else if(status==GAME_LOSE){
    textSize(40);
    text("BOOOM", width/2, 240);
    textSize(20);
    text("You are dead!!!",width/2, 280);
  }
}

void removeBullet(Bullet obj) {
  obj.gone = true;
  obj.bX = 2000;
  obj.bY = 2000;
}

void removeLaser(Laser obj) {
  obj.gone = true;
  obj.lX = 2000;
  obj.lY = 2000;
}

void removeAlien(Alien obj) {
  obj.die = true;
  obj.aX = 1000;
  obj.aY = 1000;
}

/*---------Reset Game-------------*/
void reset() {
  for (int i=0; i<bList.length; i++) {
    bList[i] = null;
    lList[i] = null;
  }

  for (int i=0; i<aList.length; i++) {
    aList[i] = null;
  }

  point = 0;
  expoInit = 0;
  countBulletFrame = 30;
  bulletNum = 0;

  /*--------Init Variable Here---------*/
  

  /*-----------Call Make Alien Function--------*/
  alienMaker(53,12);

  ship.posX = width/2;
  ship.posY = 460;
  ship.upGrade = false;
  ruby.show = false;
  ruby.pX = int(random(width));
  ruby.pY = -10;
}

/*-----------finish statusCtrl--------*/
void statusCtrl() {
  if (key == ENTER) {
    switch(status) {

    case GAME_START:
      status = GAME_PLAYING;
      break;
      /*-----------add things here--------*/
    case GAME_WIN:
       status = GAME_START;
       break;
    case GAME_LOSE:
       status = GAME_START;
       break;
    }
  }
}

void cheatKeys() {

  if (key == 'R'||key == 'r') {
    ruby.show = true;
    ruby.pX = int(random(width));
    ruby.pY = -10;
  }
  if (key == 'Q'||key == 'q') {
    ship.upGrade = true;
  }
  if (key == 'W'||key == 'w') {
    ship.upGrade = false;
  }
  if (key == 'S'||key == 's') {
    for (int i = 0; i<aList.length; i++) {
      if (aList[i]!=null) {
        aList[i].aY+=50;
      }
    }
  }
}
