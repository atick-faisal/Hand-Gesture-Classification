/*
    Code : Collect and Test data For Gesture Classification
    Author : Atick Faisal
    License : GPL-3.0
*/

import processing.serial.*;
import java.io.FileWriter;
import java.io.*;

final int NUM_FEATURES = 8;
final int NUM_GESTURES = 14;

Serial port;

PFont font;
PImage img;

color header = color(47,52,63);

int selection = 0;
int predicted = 0;
boolean mode = false;

double weights[][] = new double[NUM_GESTURES][NUM_FEATURES];
double biases[] = new double[NUM_GESTURES];
double result[] = new double[NUM_GESTURES];
double prediction[] = new double[NUM_GESTURES];

String data = "40,30,50,20,100,-140,-20,40";
float flex_data[] = {100, 50, -70, 5, 70};
float adxl_data[] = {-140, -20, -40};
float test_data[] = new float[NUM_FEATURES];

int count;

///////////////////////////////////////////////////////////////////////////////// ==>> Setup
void setup() {
  fullScreen();
  // hcitool scan
  // sudo rfcomm bind /dev/rfcomm0 CC:50:E3:A1:5D:1A
  //port = new Serial(this, "/dev/ttyUSB0", 115200);
  //port.bufferUntil('\n');
  //get_weights();
  //get_biases();
  count = 0;
}
/////////////////////////////////////////////////////////////////////////////// ==>> Drawing
void draw() {
  background(255);
  draw_backgrounds();
  draw_bar_chart();
  draw_spider();
  draw_rects();
  draw_texts();
  if(!mode) {
    draw_selector_1();
    draw_save_button();
    stroke(120);
    strokeWeight(1);
    fill(255, 236, 179);
    rect(200, 200 + selection*30, 250, 30);
    draw_gestures();
  }
  else {
    draw_selector_2();
    stroke(120);
    strokeWeight(1);
    fill(165, 214, 167);
    rect(200, 200 + predicted*30, 250, 30);
    draw_gestures();
    draw_prediction_texts();
  }
}
/////////////////////////////////////////////////////////////////////////////// ==>> Drawing Background
void draw_backgrounds() {
  img = loadImage("logo.jpeg");
  image(img, width/2 - 330, 30, 100, 100);
  noStroke();
  fill(255);
  rect(width/2 - 330, 135, 100, 40);
  fill(90);
  font = loadFont("Ubuntu-52.vlw");
  textFont(font, 52);
  text("Gesture Classification", width/2 - 200, 100);
}
/////////////////////////////////////////////////////////////////////////////// ==>> Drawing selector
void draw_selector_1() {
  noStroke();
  fill(48, 63, 159);
  rect(width/2 - 100, 140, 100, 40, 7, 0, 0, 7);
  fill(230);
  rect(width/2, 140, 100, 40, 0, 7, 7, 0);
  fill(230);
  font = loadFont("Ubuntu-20.vlw");
  textFont(font, 20);
  text("Train", width/2 - 75, 167);
  fill(70);
  font = loadFont("Ubuntu-20.vlw");
  textFont(font, 20);
  text("Test", width/2 + 25, 167);
}
//////////////////////////////////////////////////////////////////////////////// ==>> Drawing selector
void draw_selector_2() {
  noStroke();
  fill(230);
  rect(width/2 - 100, 140, 100, 40, 7, 0, 0, 7);
  fill(48, 63, 159);
  rect(width/2, 140, 100, 40, 0, 7, 7, 0);
  fill(70);
  font = loadFont("Ubuntu-20.vlw");
  textFont(font, 20);
  text("Train", width/2 - 75, 167);
  fill(230);
  font = loadFont("Ubuntu-20.vlw");
  textFont(font, 20);
  text("Test", width/2 + 25, 167);
}
//////////////////////////////////////////////////////////////////////////////////// ==>> Drawing Bar Chart
void draw_bar_chart() {
  int startX = 575;
  int startY = 420;
  int sep = 0;
  for (int i = 0; i < 5; i++) {
    int bar_height = (int) flex_data[i];
    int bar_width = 40;
    fill(48, 63, 159);
    noStroke();
    rect(startX + sep, startY - bar_height, bar_width, bar_height);
    sep += 50;
  }
  strokeWeight(1);
  stroke(120);
  line(startX - 10, startY, startX + 260, startY);
  fill(100);
  font = loadFont("Ubuntu-20.vlw");
  textFont(font, 14);
  //text("1          2          3          4          5", startX + 17, startY + 30);
}
//////////////////////////////////////////////////////////////////////////////////////////// ==>> Drawing spider Chart
void draw_spider() {
  int startX = 1100;
  int startY = 420;
  strokeWeight(1);
  stroke(200);
  fill(240, 240, 240, 40);
  for(int i = 1; i < 5; i++) {
    ellipse(startX, startY, i*80, i*80);
  }
  for(int i = 0; i < 8; i++) {
    line(startX, startY, startX + 170*cos(i* PI/4), startY - 170*sin(i* PI/4));
  }
  strokeWeight(3);
  stroke(121, 134, 203);
  line(startX + adxl_data[0]*cos(0*2*PI/3), startY - adxl_data[0]*sin(0*2*PI/3), startX + adxl_data[1]*cos(1*2*PI/3), startY - adxl_data[1]*sin(1*2*PI/3));
  line(startX + adxl_data[1]*cos(1*2*PI/3), startY - adxl_data[1]*sin(1*2*PI/3), startX + adxl_data[2]*cos(2*2*PI/3), startY - adxl_data[2]*sin(2*2*PI/3));
  line(startX + adxl_data[2]*cos(2*2*PI/3), startY - adxl_data[2]*sin(2*2*PI/3), startX + adxl_data[0]*cos(0*2*PI/3), startY - adxl_data[0]*sin(0*2*PI/3));
  noStroke();
  font = loadFont("Ubuntu-12.vlw");
  textFont(font, 12);
  fill(102, 187, 106);
  ellipse(startX + adxl_data[0]*cos(0*2*PI/3), startY - adxl_data[0]*sin(0*2*PI/3), 15, 15);
  ellipse(startX + 100, startY - 200, 10, 10);
  fill(70);
  text("Yaw", startX + 110, startY - 197);
  fill(171, 71, 188);
  ellipse(startX + adxl_data[1]*cos(1*2*PI/3), startY - adxl_data[1]*sin(1*2*PI/3), 15, 15);
  ellipse(startX + 100, startY - 185, 10, 10);
  fill(70);
  text("Pitch", startX + 110, startY - 182);
  fill(245, 124, 0);
  ellipse(startX + adxl_data[2]*cos(2*2*PI/3), startY - adxl_data[2]*sin(2*2*PI/3), 15, 15);
  ellipse(startX + 100, startY - 170, 10, 10);
  fill(70);
  text("Roll", startX + 110, startY - 167);
}
///////////////////////////////////////////////////////////////////////////////// ==>> Drawing Table Rectangles
void draw_rects() {
  int startX = 150;
  int startY = 200;
  strokeWeight(1);
  stroke(120);
  fill(255, 205, 210);
  rect(startX, startY, 50, 30*NUM_GESTURES);
  noFill();
  for(int i = 0; i < NUM_GESTURES; i++) {
    rect(startX, startY + i*30, 300, 30);
  }
}
////////////////////////////////////////////////////////////////////////////////// ==>> Drawing Table Text
void draw_texts() {
  int startX = 170;
  int startY = 221;
  fill(70);
  font = loadFont("Ubuntu-14.vlw");
  textFont(font, 14);
  for(char x = 65, i = 0;i < NUM_GESTURES; x++, i++) {
    text(x, startX, startY + i*30);
  }
}
////////////////////////////////////////////////////////////////////////////////// ==>> Drawing table gestures
void draw_gestures() {
  int startX = 220;
  int startY = 221;
  BufferedReader reader = createReader("gestures.csv");
  String line = null;
  try {
    line = reader.readLine();
    reader.close();
  } catch (IOException e) {
    e.printStackTrace();
  }
  String gestures[] = split(line, ',');
  font = loadFont("Ubuntu-14.vlw");
  textFont(font, 14);
  fill(70);
  for (int i = 0; i < NUM_GESTURES; i ++) {
    text(gestures[i], startX, startY + i*30);
  }
}
//////////////////////////////////////////////////////////////////////////////////////// ==>> Drawing Save Button
void draw_save_button() {
  noStroke();
  fill(56, 142, 60);
  rect(width/2 - 90, 617, 200, 50, 4);
  
  fill(255);
  font = loadFont("Ubuntu-20.vlw");
  textFont(font, 20);
  text("Save Data", width/2 - 36, 650);
}
///////////////////////////////////////////////////////////////////////////////////////// ==>> Drawing Prediction Text
void draw_prediction_texts() {
  int startX = 385;
  int startY = 221;
  stroke(120);
  strokeWeight(1);
  line(370, 200, 370, 200 + NUM_GESTURES*30);
  font = loadFont("Ubuntu-14.vlw");
  textFont(font, 14);
  fill(70);
  for (int i = 0; i < NUM_GESTURES; i ++) {
    String s = String.format("%.2f %%", prediction[i]);
    text(s, startX, startY + i*30);
  }
}
////////////////////////////////////////////////////////////////////////////////////////// ==>> KeyPressed
void keyPressed() {
  selection = key - 97;
}
////////////////////////////////////////////////////////////////////////////////////////// ==>> Mouse clicked
void mouseClicked() {
  if(!mode) {
    if(mouseY > 600) {
      saveData();
    }
  }
  if(mouseY < 300) {
    mode = !mode;
  }
}
/////////////////////////////////////////////////////////////////////////////////////////// ==>> Save Data
void saveData() {
  BufferedReader reader = createReader("gestures.csv");
  String line = null;
  try {
    line = reader.readLine();
    reader.close();
  } catch (IOException e) {
    e.printStackTrace();
  }
  String gestures[] = split(line, ',');
  try {
    File file =new File(sketchPath() + "/data/dataset.csv");
 
    if (!file.exists()) {
      file.createNewFile();
    }
    FileWriter fw = new FileWriter(file, true);
    BufferedWriter bw = new BufferedWriter(fw);
    PrintWriter pw = new PrintWriter(bw);
    String write_data = data.substring(0, data.length() - 2) + ',' + gestures[selection] + '\n';
    pw.write(write_data);
    pw.close();
  }
  catch(IOException ioe) {
    System.out.println("Exception ");
    ioe.printStackTrace();
  }
}
//////////////////////////////////////////////////////////////////////////////////////// ==>> Serial Event
void serialEvent (Serial port) {
  data = port.readStringUntil('\n');
  println(data);
  while(count < 10) {
    count++;
    return;
  }
  String values[] = split(data, ',');
  for (int i = 0; i < NUM_FEATURES; i++) {
    test_data[i] = Float.parseFloat(values[i]);
    if(i >= 5) {
      adxl_data[i-5] = Float.parseFloat(values[i]);
    }
    else {
      flex_data[i] = Float.parseFloat(values[i]);
    }
  }
  if(mode) {
    claculate_probabilities();
    predicted = get_heighest_prediction_index(prediction);
  }
}
//////////////////////////////////////////////////////////////////////////////////////// ==>> Get weights from file
void get_weights() {
  BufferedReader reader = createReader("weights.csv");
  String line = null;
  int j = 0;
  try {
    while ((line = reader.readLine()) != null) {
      String[] pieces = split(line, ",");
      for(int i = 0; i < NUM_FEATURES; i++) {
        weights[j][i] = Double.parseDouble(pieces[i]);
      }
      j++;
    }
    reader.close();
  } catch (IOException e) {
    e.printStackTrace();
  }
}
////////////////////////////////////////////////////////////////////////////////////////// ==>> Get biases from file
void get_biases() {
  BufferedReader reader = createReader("biases.csv");
  String line = null;
  try {
    line = reader.readLine();
    reader.close();
  } catch (IOException e) {
    e.printStackTrace();
  }
  String pieces[] = split(line, ',');
  for(int i = 0; i < NUM_GESTURES; i++) {
    biases[i] = float(pieces[i]);
  }
}
////////////////////////////////////////////////////////////////////////////////////////// ==>> sigmoid function
double sigmoid(double x) {
  return 1/(1 + exp(- (float) x));
}
////////////////////////////////////////////////////////////////////////////////////////// ==>> Probabillity calculation
void claculate_probabilities() {
  double sum = 0;
  for(int i = 0; i < NUM_GESTURES; i++) {
    for(int j = 0; j < NUM_FEATURES; j++) {
      sum = sum + weights[i][j] * test_data[j];
    }
    result[i] = sum;
    sum = 0;
  }
  for(int i = 0; i < NUM_GESTURES; i++) {
    prediction[i] = sigmoid(result[i]) * 100;
  }
}
////////////////////////////////////////////////////////////////////////////////////// ==>> Get the prediction
int get_heighest_prediction_index(double[] array) {
  if ( array == null || array.length == 0 ) return -1;
  int largest = 0;
  for ( int i = 1; i < array.length; i++ ) {
      if ( array[i] > array[largest] ) largest = i;
  }
  return largest;
}
