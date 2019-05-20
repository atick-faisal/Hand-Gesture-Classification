from tkinter import *
import serial
from time import sleep
import serial
import os

window = Tk()
ser = serial.Serial('/dev/ttyACM0', 9600)

value = 45

window.geometry("600x320+600+300")
window.title("Gesture Classification")
window.configure(background="#2f343f")

prediction = Label(window, 
			text=value,
			font="Consolas 32",
			background="#2f343f",
			foreground="#FFFFFF",
			width=30,
			height=7)
prediction.pack()

window.mainloop()

while True:
	ser_bytes = ser.readline()
	try:
		global value
		value = (ser_bytes[0:len(ser_bytes)-2].decode("utf-8"))
		prediction['text'] = value
	except:
		continue
