#!/usr/bin/env python
# coding: utf-8

# # Handwritten Digit Reconnition
# 
# **Dataset: MNIST [Download Here](https://www.kaggle.com/c/digit-recognizer/data)**
# 
# **Classifier: Decision Tree Classifier**

# ### 1. Import the libraries

# In[1]:


import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.tree import DecisionTreeClassifier


# ### 2. Load the dataset as Pandas Dataframe
# - The first column of each row of the dataset is the label and the later ones are the 784 pixels of the image

# In[2]:


dataframe = pd.read_csv('./Dataset/train.csv')
dataframe.head()


# ### 3. Split dataset into train and test sets

# - Total dataset contains 42000 samples
# - Take the first 30000 for training
# - Use the later for testing

# In[3]:


data = dataframe.to_numpy() # convert to numpy array
train_images = data[0:30000, 1:]
train_labels = data[0:30000, 0]


# In[4]:


test_images =  data[30001:, 1:]
test_labels = data[30001:, 0]


# ### 4. Plot a sample image from dataset

# In[5]:


sample_digit = train_images[42] # select the 42th image
print(sample_digit.size)


# - the image contains a total of 784 pixels
# - so the array contains 784 elements since it is 1D
# - first convert this array into a 28x28 2D array

# In[6]:


sample_digit.shape = (28, 28)
plt.imshow(sample_digit)


# ### 5. Train the classifier

# In[7]:


clf = DecisionTreeClassifier()
clf.fit(train_images, train_labels);


# ### 6. Predict a random image

# In[8]:


random_test_image = test_images[99]
random_test_label = test_labels[99]
print('actual label =', random_test_label)
prediction = clf.predict([random_test_image])
print('prediction =', prediction)


# ### 7. Calculate accuracy for the test set

# In[10]:


test_results = clf.predict(test_images)
count = 0
for i in range(0, test_results.size):
    if test_results[i] == test_labels[i]:
        count = count + 1      
percentage = (count / test_results.size) * 100
print('Accuracy = ', percentage)

