#include <Arduino.h>
#include <Wire.h>
//#include "BluetoothSerial.h"

void __configure_sensor();
void __read_accelerometer();
void __process_acc_data();
void __read_gyroscope();
void __process_gyro_data();
void __calculate_acc_angle();
void __calculate_gyro_angle();
void __apply_complementary_filter();
void __calculate_imu_error();
void __read_flex_data();
void __gen_data_string();
void __apply_mean_filter();
void __apply_median_filter();
void __auto_calibration();
void __auto_calibration_median();

//BluetoothSerial bt;

#define I2C_ADDRESS 0x68

#define FLEX_1 12
#define FLEX_2 27
#define FLEX_3 25
#define FLEX_4 32
#define FLEX_5 34

short accX, accY, accZ;
short gyroX, gyroY, gyroZ;
float ax, ay, az;
float gx, gy, gz;
float accAngleX, accAngleY, accAngleZ;
float gyroAngleX, gyroAngleY, gyroAngleZ;
float accErrorX, accErrorY, accErrorZ;
float gyroErrorX, gyroErrorY, gyroErrorZ;
float currentTime, previousTime, elapsedTime;
float yaw, pitch, roll;
int FLEX_PINS[] = {12, 27, 25, 32, 34};
float flex_data[] = {0, 0, 0, 0, 0};
float calibrated_values[] = {0, 0, 0, 0, 0};

String data;
char buffer[100];

void setup() {
  Serial.begin(115200);
  pinMode(LED_BUILTIN, OUTPUT);
  //bt.begin("ESP_32");
  //Serial.println("Bluetooth is ready...");
  Wire.begin();
  Serial.println("Configuring Sensors...");
  __configure_sensor();
  //__calculate_imu_error();
  Serial.println("Calibrating Sensors...");
  //__auto_calibration();
  digitalWrite(LED_BUILTIN, HIGH);
  //__auto_calibration_median();
  digitalWrite(LED_BUILTIN, LOW);
}

void loop() {
  __read_accelerometer();
  __process_acc_data();
  __calculate_acc_angle();
  __read_gyroscope();
  __process_gyro_data();
  __calculate_gyro_angle();
  __apply_complementary_filter();
  //__apply_mean_filter();
  //__apply_median_filter();
  __gen_data_string();
  Serial.println(data);
  //bt.println(data);
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
  //-------------------- Setting Up Gyroscope --------------------//
  Wire.beginTransmission(I2C_ADDRESS);
  Wire.write(0x1B);
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

void __read_gyroscope() {
  // ----------------- Calculate elapsed time between readings ------------//
  previousTime = currentTime;
  currentTime = millis();
  elapsedTime = (currentTime - previousTime + 1) / 1000;
  //------------- Take gyro Readings ---------------//
  Wire.beginTransmission(I2C_ADDRESS);
  Wire.write(0x43);
  Wire.endTransmission();
  Wire.requestFrom(I2C_ADDRESS, 6);
  while(Wire.available() < 6);
  gyroX = Wire.read() << 8 | Wire.read();
  gyroY = Wire.read() << 8 | Wire.read();
  gyroZ = Wire.read() << 8 | Wire.read();
}

void __process_acc_data() {
  ax = - (float) accX / 16384.0;
  ay = - (float) accY / 16384.0;
  az = - (float) accZ / 16384.0;
}

void __process_gyro_data() {
  gx = - (float) gyroX / 131.0 - 3.78;
  gy = - (float) gyroY / 131.0 - 1.00;
  gz = - (float) gyroZ / 131.0 - 0.91;
}

void __calculate_acc_angle() {
  accAngleX = (atan(ay / sqrt(pow(ax, 2) + pow(az, 2))) * 180 / PI) - 3.81;
  accAngleY = (atan(-1 * ax / sqrt(pow(ay, 2) + pow(az, 2))) * 180 / PI) + 14.98;
}

void __calculate_gyro_angle() {
  gyroAngleX = gyroAngleX + gx * elapsedTime;
  gyroAngleY = gyroAngleY + gy * elapsedTime;
  yaw =  yaw + gz * elapsedTime;
}

void __apply_complementary_filter() {
  roll = 0.96 * gyroAngleX + 0.04 * accAngleX;
  pitch = 0.96 * gyroAngleY + 0.04 * accAngleY;
}

void __calculate_imu_error() {
  int counter = 0;
  while(counter < 700) {
    __read_accelerometer();
    __process_acc_data();
    accErrorX = accErrorX + ((atan((ay) / sqrt(pow((ax), 2) + pow((az), 2))) * 180 / PI));
    accErrorY = accErrorY + ((atan(-1 * (ax) / sqrt(pow((ay), 2) + pow((az), 2))) * 180 / PI));
    counter ++;
  }
  accErrorX = accErrorX / 700;
  accErrorY = accErrorY / 700;

  counter = 0;
  while(counter < 700) {
    __read_gyroscope();
    __process_gyro_data();
    gyroErrorX = gyroErrorX + gx;
    gyroErrorY = gyroErrorY + gy;
    gyroErrorZ = gyroErrorZ + gz;
    counter ++;
  }
  gyroErrorX = gyroErrorX / 700;
  gyroErrorY = gyroErrorY / 700;
  gyroErrorZ = gyroErrorZ / 700;

  Serial.print("AccErrorX: ");
  Serial.println(accErrorX);
  Serial.print("AccErrorY: ");
  Serial.println(accErrorY);
  Serial.print("GyroErrorX: ");
  Serial.println(gyroErrorX);
  Serial.print("GyroErrorY: ");
  Serial.println(gyroErrorY);
  Serial.print("GyroErrorZ: ");
  Serial.println(gyroErrorZ);
}

void __read_flex_data() {
  for(int i = 0; i < 5; i++) {
    flex_data[i] = analogRead(FLEX_PINS[i]) - 2700;
  }
}

void __gen_data_string() {
  sprintf(buffer, "%f\t%f\t%f", accAngleX, gyroAngleX, roll);
  // sprintf(buffer, "%f\t%f\t%f", yaw, pitch, roll);
  //sprintf(buffer, "%f\t%f\t%f", ax, ay, az);
  //sprintf(buffer, "%f,%f,%f,%f,%f,%f,%f,%f", flex_data[0], flex_data[1], flex_data[2], flex_data[3], flex_data[4], ax, ay, az);
  data = buffer;
}

void __apply_mean_filter() {
  float sum[] = {0, 0, 0, 0, 0};
  for (int i = 0; i < 10; i++) {
    for(int i = 0; i < 5; i++) {
      sum[i] = sum[i] + analogRead(FLEX_PINS[i]);
    }
    delay(10);
  }
  for(int i = 0; i < 5; i++) {
    flex_data[i] = (sum[i] / 10 - calibrated_values[i]) * 2;
  }
}

void __apply_median_filter() {
  int flex[5][7];
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < 7; j++) {
      flex[i][j] = 0;
    }
  }
  for(int i = 0; i < 7; i++) {
    for(int j = 0; j < 5; j++) {
      flex[j][i] = analogRead(FLEX_PINS[j]);
      for(int k = 0; k < i; k++) {
        for(int l = 1; l < 7; l++) {
          if(flex[j][l] > flex[j][l-1]) {
            int temp = flex[j][l];
            flex[j][l] = flex[j][l-1];
            flex[j][l-1] = temp;
          }
        }
      }
    }
    delay(10);
  }
  for(int i = 0; i < 5; i++) {
    flex_data[i] = (flex[i][4] - calibrated_values[i]) * 2;
  }
}

void __auto_calibration_median() {
  int flex[5][100];
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < 100; j++) {
      flex[i][j] = 0;
    }
  }
  for(int i = 0; i < 100; i++) {
    for(int j = 0; j < 5; j++) {
      flex[j][i] = analogRead(FLEX_PINS[j]);
      for(int k = 0; k < i; k++) {
        for(int l = 1; l < 100; l++) {
          if(flex[j][l] > flex[j][l-1]) {
            int temp = flex[j][l];
            flex[j][l] = flex[j][l-1];
            flex[j][l-1] = temp;
          }
        }
      }
    }
    delay(70);
  }
  for(int i = 0; i < 5; i++) {
    calibrated_values[i] = flex[i][50];
    //Serial.println(calibrated_values[i]);
  }
}

void __auto_calibration() {
  float sum[] = {0, 0, 0, 0, 0};
  for (int i = 0; i < 700; i++) {
    for(int i = 0; i < 5; i++) {
      sum[i] = sum[i] + analogRead(FLEX_PINS[i]);
    }
    delay(10);
  }
  for(int i = 0; i < 5; i++) {
    calibrated_values[i] = sum[i] / 700;
  }
}