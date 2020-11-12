import h2o
from h2o.estimators import H2ONaiveBayesEstimator
h2o.init()

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--train_frame", help='Path to the training data', required=True)
parser.add_argument("--test_frame", help='Path to the testing data', required=True)
args = parser.parse_args()


# Import them via parameters
# Import a sample binary outcome train/test set into H2O
train = h2o.import_file(args.train_frame)
test = h2o.import_file(args.test_frame)

# Identify predictors and response
x = train.columns
y = "response"
x.remove(y)

# For binary classification, response should be a factor
train[y] = train[y].asfactor()
test[y] = test[y].asfactor()

# Number of CV folds (to generate level-one data for stacking)
nfolds = 5

# Build and train the model:
nb_model = H2ONaiveBayesEstimator(laplace=0,
                                 nfolds=5,
                                 seed=1234)

nb_model.train(x=predictors,
              y=response,
              training_frame=train)

# Eval performance:
test_perf = nb_model.model_performance(test)

print(test_perf.auc())

