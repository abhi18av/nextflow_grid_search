import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--train_frame", help='Path to the training data', required=True)
parser.add_argument("--test_frame", help='Path to the testing data', required=True)
args = parser.parse_args()

print(args.train_frame)
print(args.test_frame)
