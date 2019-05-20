import pyautogui as at
import serial
from time import sleep
import serial
import os

at.PAUSE = 0.001

ser = serial.Serial('/dev/ttyACM0', 9600)

def __move_left():
	at.moveRel(-10, 0, duration=0.001)

def __move_right():
	at.moveRel(10, 0, duration=0.001)

def __scroll_up():
	at.scroll(1)

def __scrol_down():
	at.scroll(-1)

while True:
	ser_bytes = ser.readline()
	try:
		decoded_bytes = int(ser_bytes[0:len(ser_bytes)-2].decode("utf-8"))
		os.system('clear')
		# print(decoded_bytes)
		if(decoded_bytes == 1):
			__move_left()
		elif(decoded_bytes == 2):
			__move_right()
		elif(decoded_bytes == 3):
			__scroll_up()
		elif(decoded_bytes == 4):
			__scrol_down()
	except:
		continue