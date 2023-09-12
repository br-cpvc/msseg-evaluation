import argparse
import os
import pandas as pd


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input-file', required=True)
    parser.add_argument('-c', '--index-column', default=None)
    parser.add_argument('-o', '--output-file', default=None)
    args = parser.parse_args()

    if args.index_column:
        df = pd.read_csv(args.input_file, index_col=args.index_column)
    else:
        df = pd.read_csv(args.input_file, index_col=0)
    results = df.T

    if args.output_file:
        use_index = args.index_column == None
        results.to_csv(args.output_file, index=use_index)
    else:
        print(results)
