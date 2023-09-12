import argparse
import os
import pandas as pd


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input-files', nargs='+', required=True)
    parser.add_argument('-o', '--output-file', default=None)
    args = parser.parse_args()

    dfs = []
    idcol_name = 'image_id'
    for f in args.input_files:
        df = pd.read_csv(f)
        df[idcol_name] = os.path.dirname(f)
        dfs.append(df)
    results = pd.concat(dfs)
    results = results.set_index(idcol_name)

    if args.output_file:
        results.to_csv(args.output_file)
    else:
        print(results)
