import argparse
import os
import pandas as pd


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input-files', nargs='+', required=True)
    parser.add_argument('-m', '--merge-column', required=True)
    parser.add_argument('-o', '--output-file', default=None)
    args = parser.parse_args()

    dfs = []
    for f in args.input_files:
        df = pd.read_csv(f)
        df = df.set_index(args.merge_column)
        dfs.append(df)

    results = dfs[0]
    for df in dfs[1:]:
        results = pd.merge(results, df, left_index=True, right_index=True)

    if args.output_file:
        results.to_csv(args.output_file)
    else:
        print(results)
