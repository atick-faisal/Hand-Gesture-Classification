import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.utils import shuffle
from sklearn.neighbors import KNeighborsClassifier
from time import sleep
import serial
import os

data = pd.read_csv('../Desktop_Software/data/dataset.csv')
data.columns = ['1', '2', '3', '4', '5', 'x', 'y', 'z', 'gesture']
train_data = shuffle(data, random_state=42)
train_data.head()

X = train_data.drop(columns=['gesture'])
Y = train_data['gesture']

clf = KNeighborsClassifier(n_neighbors=3);
clf.fit(X, Y);

print(clf.score(X, Y)*100 , "%")

ser = serial.Serial('/dev/ttyUSB0', 115200)

while True:
    incoming = ser.readline().decode('ascii')
    values = incoming.split(',')
    test_data = []
    for i in values:
        test_data.append(float(i))
        
    os.system('clear')
    print(clf.predict([test_data]))
