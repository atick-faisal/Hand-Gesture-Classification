# Code: Classifier comparison
# Author: Atick Faisal
# License: GPL - 3.0

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.utils import shuffle
from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsClassifier
from sklearn import svm
from sklearn.ensemble import RandomForestClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import confusion_matrix
from sklearn.utils.multiclass import unique_labels
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score
from sklearn.metrics import balanced_accuracy_score
from sklearn.metrics import classification_report

def plot_confusion_matrix(y_true, y_pred, classes,
        normalize = False,
        title = None,
        cmap = plt.cm.Blues):

    cm = confusion_matrix(y_true, y_pred)
    if normalize:
        cm = cm.astype('float') / cm.sum(axis = 1)[: , np.newaxis]
        print("Normalized confusion matrix")
    else :
        print('Confusion matrix, without normalization')

    print(cm)

    classes = unique_labels(y_true)

    fig, ax = plt.subplots()
    im = ax.imshow(cm, interpolation = 'nearest', cmap = cmap)
    ax.figure.colorbar(im, ax = ax)# We want to show all ticks...
    ax.set(xticks = np.arange(cm.shape[1]),
        yticks = np.arange(cm.shape[0]),
        xticklabels = classes, yticklabels = classes,
        title = title,
        ylabel = 'True label',
        xlabel = 'Predicted label')

    plt.setp(ax.get_xticklabels(), rotation = 45, ha = "right",
        rotation_mode = "anchor")
    fmt = '.2f' if normalize else 'd'
    thresh = cm.max() / 2.
    for i in range(cm.shape[0]):
        for j in range(cm.shape[1]):
            ax.text(j, i, format(cm[i, j], fmt),
                ha = "center", va = "center",
                color = "white"
                if cm[i, j] > thresh
                else "black")
    plt.show()
    return ax

data = pd.read_csv('../Desktop_Software/data/dataset.csv')
gestures = ['Come Here','Go Away','Fist','Finger Crossed','Cash','One','Two','Three','Four','Five','Excellent','Stop','Thumbs Up','Thumbs Down']
data.columns = ['1', '2', '3', '4', '5', 'x', 'y', 'z', 'gesture']
train_data = shuffle(data, random_state=42)
train_data = data;
#train_data.head()

X = train_data.drop(columns=['gesture'])
y = train_data['gesture']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

# ##################################################################
clf = KNeighborsClassifier(n_neighbors=3);
clf.fit(X_train, y_train);
print("KNN :", clf.score(X_test, y_test)*100 , "%")
y_pred = clf.predict(X_test)
print("Precision: ", precision_score(y_test, y_pred, average=None))
print("Recall: ", recall_score(y_test, y_pred, average=None))
print(classification_report(y_test, y_pred, target_names=unique_labels(y_test)))
print("BCR: ", balanced_accuracy_score(y_test, y_pred))
#precision_recall_curve(y_test, y_pred)
#plot_confusion_matrix(y_test, y_pred, classes=gestures, title='KNN Confusion Matrix')
# ##################################################################
clf = svm.SVC(kernel='rbf', gamma='scale');
clf.fit(X_train, y_train);
print("SVM :", clf.score(X_test, y_test)*100 , "%")
y_pred = clf.predict(X_test)
print("Precision: ", precision_score(y_test, y_pred, average=None))
print("Recall: ", recall_score(y_test, y_pred, average=None))
print("BCR: ", balanced_accuracy_score(y_test, y_pred))
#(y_test, y_pred, classes=gestures, title='SVM Confusion Matrix')
##################################################################
clf = RandomForestClassifier(n_estimators=100, max_depth=7, random_state=0);
clf.fit(X_train, y_train);
print("RnF :", clf.score(X_test, y_test)*100 , "%")
y_pred = clf.predict(X_test)
print("Precision: ", precision_score(y_test, y_pred, average=None))
print("Recall: ", recall_score(y_test, y_pred, average=None))
print("BCR: ", balanced_accuracy_score(y_test, y_pred))
#plot_confusion_matrix(y_test, y_pred, classes=gestures, title='RnF Confusion Matrix')
##################################################################
clf = DecisionTreeClassifier();
clf.fit(X_train, y_train);
print("DT :", clf.score(X_test, y_test)*100 , "%")
y_pred = clf.predict(X_test)
print("Precision: ", precision_score(y_test, y_pred, average=None))
print("Recall: ", recall_score(y_test, y_pred, average=None))
print("BCR: ", balanced_accuracy_score(y_test, y_pred))
#plot_confusion_matrix(y_test, y_pred, classes=gestures, title='DT Confusion Matrix')

print(unique_labels(y_test))