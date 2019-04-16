#include <Arduino.h>
#include <Wire.h>
//#include "BluetoothSerial.h"

void __configure_sensor();
void __read_accelerometer();
void __process_acc_data();
void __read_flex_data();
void __gen_data_string();

//BluetoothSerial bt;

#define I2C_ADDRESS 0x68

#define FLEX_1 12
#define FLEX_2 27
#define FLEX_3 25
#define FLEX_4 32
#define FLEX_5 34

short accX, accY, accZ;
float X, Y, Z;
int FLEX_PINS[] = {12, 27, 25, 32, 34};
float flex_data[] = {0, 0, 0, 0, 0};

String data;
char buffer[100];

void setup() {
  Serial.begin(9600);
  //bt.begin("ESP_32");
  //Serial.println("Bluetooth is ready...");
  Wire.begin();
  __configure_sensor();
}

void loop() {
  __read_accelerometer();
  __process_acc_data();
  __read_flex_data();
  __gen_data_string();
  Serial.println(data);
  //bt.println(data);
  delay(500);
}

void __configure_sensor() {
  //----------------- Disable Sleep Mode ----------------//
  Wire.beginTransmission(I2C_ADDRESS);
  Wire.write(0x6B);
  Wire.write(0b000000);
  Wire.endTransmission();
  //----------------- Setting Up Accelerometer ----------------//
  Wire.beginTransmission(I2C_ADDRESS);
  Wire.write(0x1C);
  Wire.write(0b000000);
  Wire.endTransmission();
}

void __read_accelerometer() {
  Wire.beginTransmission(I2C_ADDRESS);
  Wire.write(0x3B);
  Wire.endTransmission();
  Wire.requestFrom(I2C_ADDRESS, 6);
  while(Wire.available() < 6);
  accX = Wire.read() << 8 | Wire.read();
  accY = Wire.read() << 8 | Wire.read();
  accZ = Wire.read() << 8 | Wire.read();
}

void __process_acc_data() {
  X = - (float) accX * 100 / 16384.0;
  Y = - (float) accY * 100 / 16384.0;
  Z = - (float) accZ * 100 / 16384.0;
}

void __read_flex_data() {
  for(int i = 0; i < 5; i++) {
    flex_data[i] = analogRead(FLEX_PINS[i]) - 2700;
  }
}

void __gen_data_string() {
  sprintf(buffer, "%f,%f,%f,%f,%f,%f,%f,%f,", flex_data[0], flex_data[1], flex_data[2], flex_data[3], flex_data[4], X, Y, Z);
  data = buffer;
}