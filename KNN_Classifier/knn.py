#!/usr/bin/env python
# coding: utf-8

# # Gesture Classification
# ### Classifier: K Nearest Neighbours
# ### Accuracy: 70%

# In[36]:


import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.utils import shuffle
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import confusion_matrix


# In[58]:


def plot_confusion_matrix(y_true, y_pred, classes,
                          normalize=False,
                          title=None,
                          cmap=plt.cm.Blues):
    
    if not title:
        if normalize:
            title = 'Normalized confusion matrix'
        else:
            title = 'Confusion matrix, without normalization'

    # Compute confusion matrix
    cm = confusion_matrix(y_true, y_pred)
    # Only use the labels that appear in the data
#     classes = classes[unique_labels(y_true, y_pred)]
    if normalize:
        cm = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]
        print("Normalized confusion matrix")
    else:
        print('Confusion matrix, without normalization')

    print(cm)

    fig, ax = plt.subplots()
    im = ax.imshow(cm, interpolation='nearest', cmap=cmap)
    ax.figure.colorbar(im, ax=ax)
    # We want to show all ticks...
    ax.set(xticks=np.arange(cm.shape[1]),
           yticks=np.arange(cm.shape[0]),
           # ... and label them with the respective list entries
           xticklabels=classes, yticklabels=classes,
           title=title,
           ylabel='True label',
           xlabel='Predicted label')

    # Rotate the tick labels and set their alignment.
    plt.setp(ax.get_xticklabels(), rotation=45, ha="right",
             rotation_mode="anchor")

    # Loop over data dimensions and create text annotations.
    fmt = '.2f' if normalize else 'd'
    thresh = cm.max() / 2.
    for i in range(cm.shape[0]):
        for j in range(cm.shape[1]):
            ax.text(j, i, format(cm[i, j], fmt),
                    ha="center", va="center",
                    color="white" if cm[i, j] > thresh else "black")
    #fig.tight_layout()
    plt.show()
    return ax


# In[46]:


data = pd.read_csv('../Desktop_Software/data/dataset.csv')
gestures = ['Come Here','Go Away','Fist','Finger Crossed','Cash','One','Two','Three','Four','Five','Excellent','Stop','Thumbs Up','Thumbs Down']
data.columns = ['1', '2', '3', '4', '5', 'x', 'y', 'z', 'gesture']
#train_data = shuffle(data, random_state=42)
train_data = data;
train_data.head()


# In[47]:


X = train_data.drop(columns=['gesture'])
Y = train_data['gesture']


# In[48]:


clf = KNeighborsClassifier(n_neighbors=5);
clf.fit(X, Y);


# In[49]:


print(clf.score(X, Y)*100 , "%")


# In[50]:


print(clf.predict_proba([[3030.399902,2895.300049,3100.000000,2911.199951,3170.600098,-44.238281,-30.981445,64.526367]]))


# In[51]:


Y_pred = clf.predict(X)


# In[54]:


confusion_matrix(Y, Y_pred, labels=gestures)


# In[59]:


plot_confusion_matrix(Y, Y_pred, classes=gestures, title='Confusion matrix, without normalization')


# In[ ]:




