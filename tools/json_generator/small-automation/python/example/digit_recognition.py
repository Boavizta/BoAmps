"""
================================
Recognizing hand-written digits
================================

This example shows how scikit-learn can be used to recognize images of
hand-written digits, from 0-9.

"""

# Author: Gael Varoquaux <gael dot varoquaux at normalesup dot org>
# License: BSD 3 clause

from sklearn import datasets, metrics, svm
from sklearn.model_selection import train_test_split
from codecarbon import EmissionsTracker

from aimps import Formulaire

form = Formulaire(

    dataset={
        "type": "image"
    }
)


digits = datasets.load_digits()

# flatten the images
n_samples = len(digits.images)
data = digits.images.reshape((n_samples, -1))

# Create a classifier: a support vector classifier
clf = svm.SVC(gamma=0.001)

# Split data into 50% train and 50% test subsets
X_train, X_test, y_train, y_test = train_test_split(
    data, digits.target, test_size=0.1, shuffle=False
)

# Learn the digits on the train subset
with EmissionsTracker() as tracker:
    clf.fit(X_train, y_train)


form.add_measure_codecarbon(tracker)
print(tracker.final_emissions_data)

# Predict the value of the digit on the test subset
predicted = clf.predict(X_test)
