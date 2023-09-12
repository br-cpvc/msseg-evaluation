import argparse
import pandas as pd


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input-file', required=True)
    parser.add_argument('-o', '--output-file', default=None)
    parser.add_argument('-t', '--transpose-output', action='store_true')
    args = parser.parse_args()

    df = pd.read_csv(args.input_file)

    """
    Calculate statistics per column, by using .describe() - found on the page:
    https://pandas.pydata.org/docs/getting_started/intro_tutorials/06_calculate_statistics.html
    """
    results = df.describe()

    if args.transpose_output:
        results = results.T

    if args.output_file:
        results.to_csv(args.output_file)
    else:
        print(results)
