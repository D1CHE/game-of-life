import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

import processing.opengl.*;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Program name: game of life
//  Author: Willem Deen
//  Copyright: 2013
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

Minim minim;
AudioInput in;
FFT fft;

Sim simulation;

boolean monitoring, simulating;
int barSize, freq, upDown, lightMod, colorMod, snareMod, kickMod, frame; 
int w, h, gridSize;
float x, y;

void setup() 
{
  // sketch stuff
  size(1680, 1050, P3D);
  background(0);
  colorMode(HSB);
  frameRate(30);
  smooth();
  // audio stuff
  minim = new Minim(this);
  in = minim.getLineIn();
  fft = new FFT(in.bufferSize(), in.sampleRate());
  monitoring = true;
  simulating = false;
  // other stuff
  w = 1000;
  h = 1000;
  x = 490;
  y = 491;
  upDown = 600;
  lightMod = 20;
  colorMod = 0;
  snareMod = 0;
  kickMod = 0;
  freq = 0;
  frame = 0;
  gridSize = 10;
  barSize = 850;
  simulation = new Sim(w/gridSize, h/gridSize);
}

void draw() 
{
  if (frame > freq) frame=0;
  if (frame == 0) background(0);
  frame++;
  setCamera();
  fft.forward(in.mix);
  if (monitoring) in.enableMonitoring(); 
  else in.disableMonitoring();
  if (simulating) simulation.calculatePixels();
  //if (((in.mix.get(0)+1)/2) > 0.52) addType(13, 46, 46);
  gridSize = 10;
  //drawRoom();
  //drawGrid();
  drawPixels();
}

// VISUALS

void drawRoom()
{
  translate(w/2, h/2, 2200);
  fill(255, 0, 255);
  box(kickMod+1500, kickMod+1500, 5000);
  noFill();
  translate(-w/2, -h/2, -2200);  
}

void drawGrid()
{
  stroke(0, 0, 0);
  for (int i=0; i<w; i+=gridSize)
  {
    line(0, i+gridSize/2, w, i+gridSize/2);
  }

  for (int i=0; i<h; i+=gridSize)
  {
    line(i+gridSize/2, 0, i+gridSize/2, h);
  }
  noStroke();
}

void drawPixels()
{
  int state = -1;
  simulation.resetIndex();
  noStroke();
  colorMod = int((fft.getFreq(800)+fft.getFreq(1000)+fft.getFreq(2000)+fft.getFreq(4000)) * 32);
  if (snareMod > 0) snareMod-= 30;
  if (fft.getFreq(180) > 14) snareMod = 360;
  if (kickMod > 0) kickMod-= 250;
  if (fft.getFreq(83) > 18) kickMod = 3000;
  for (int i=0; i<h/gridSize; i++)
  {
    for (int j=0; j<w/gridSize; j++)
    {
      state = simulation.getPixel();
      barSize = int(1000-(abs(state)* 0.000089406727356) * ((in.mix.get(0)+1)/2));
      fill(kickMod, 255, 0.00001519914365*abs(state), 255);
      if (state < -1)
      {
        specular(204, 102, 0);
        shininess(1.0);
        translate(i*gridSize, j*gridSize, barSize/2);
        box(gridSize, gridSize, barSize);
        translate(-(i*gridSize), -(j*gridSize), -barSize/2);
      }
      noFill();
    }
  }
}

void addType(int obj, int xPos, int yPos)
{
  PImage img;
  switch(obj)
  {
    case 0: img = loadImage("lol.bmp"); break; // BLOCK
    case 1: img = loadImage("peace.bmp"); break; // BEEHIVE
    case 2: img = loadImage("ear.bmp"); break; // LOAF
    case 3: img = loadImage("anime.bmp"); break; // BOAT
    case 4: img = loadImage("blinker_5x5.bmp"); break; // BLINKER
    case 5: img = loadImage("toad_6x6.bmp"); break; // TOAD
    case 6: img = loadImage("ani.gif"); break; // BEACON
    case 7: img = loadImage("blinker_5x5.bmp"); break; // PULSAR
    case 8: img = loadImage("psychedelic.gif"); break; // GLIDER
    case 9: img = loadImage("blinker_5x5.bmp"); break; // SPACESHIP
    case 10: img = loadImage("blinker_5x5.bmp"); break; // R_PENTOMINO
    case 11: img = loadImage("blinker_5x5.bmp"); break; // DIEHARD
    case 12: img = loadImage("blinker_5x5.bmp"); break; // ARCON
    case 13: img = loadImage("evolver_7x7.bmp"); break; // BARS
    case 14: img = loadImage("glider_gun_38x11.bmp") ;break; // GLIDERGUN
    case 15: img = loadImage("blinker_5x5.bmp"); break; // --SPARE--
    case 16: img = loadImage("blinker_5x5.bmp"); break; // --SPARE--
    default: img = loadImage("blinker_5x5.bmp");
  }
  
  img.loadPixels();

  simulation.setPixels(img, xPos, yPos);
}

void setCamera()
{
  angleToXY(snareMod, -upDown);
  if(lightMod > 100) lightMod-= 100;
  if (fft.getFreq(150)+fft.getFreq(170) > 10) lightMod = 850+200;
  pointLight(255, 0, 50, 200, 490, barSize+800);
  pointLight(255, 0, 50, 400, 490, barSize+800);
  pointLight(255, 0, 50, 600, 490, barSize+800);
  pointLight(255, 0, 50, 800, 490, barSize+800);
  camera(x, y, (height/2) + 400/*+upDown*/ / tan(PI*30.0 / 180.0), 490, 490, mouseX, 0, 0, -1);
}

void angleToXY(int angle, int dist)
{
  float distance = dist;
  x = 490+(cos(radians(angle)))*(distance);
  y = 490+(sin(radians(angle)))*(distance);
 
}

// KEYBINDS

void keyPressed()
{
  if (key == CODED)
  { 
    switch (keyCode)
    {
    case UP: upDown = upDown-10; println("upDown: " + upDown); break;
    case DOWN: upDown = upDown+10; println("upDown: " + upDown); break;
    case LEFT: freq--; println("freq: " + freq); break;
    case RIGHT: freq++; println("freq: " + freq); break;
    }
  } 

  switch (key)
  {
    case 32: addType(13, 46, 46); break;
    case '/': addType(0, 0, 0); break;
    case 's': simulating ^= true; break;
    case 'a': simulation.calculatePixels(); break;
    case 'm': monitoring ^= true; break;
    case 'r': simulation.clearPixels(); break;
  }
}

