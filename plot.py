import matplotlib.pyplot as plt
import pandas as pd


def get_group(image_id):
    tokens = image_id.split("/")

    site = tokens[4]

    if site == "Utrecht" or site == "Singapore":
        return site
    elif "Amsterdam":
        scanner = tokens[5]
        if "PETMR" in scanner:
            return "AMS PETMR"
        else:
            return "AMS " + scanner


df = pd.read_csv("measurements.csv")
df['group'] = df['image_id'].apply(get_group)
x_label = "Matching voxels in second image"
measurements = [
    'DSC',
    'H95 (mm)',
    'AVD (%)',
    'Recall',
    'F1',
]

scatterplot = True
# scatterplot = False
# measurements = [measurements[1]]

if scatterplot:
    for m in measurements:
        fig, ax = plt.subplots(figsize=(8, 6))
        for n, grp in df.groupby('group'):
            ax.scatter(x=x_label, y=m, data=grp, label=n)
        ax.set_xlabel(x_label)
        ax.set_ylabel(m)
        ax.legend()  # title="Label")
    plt.show()
else:
    for m in measurements:
        fig = plt.figure(label=m)
        dfm = df[[m, 'group']]
        grps = dfm.groupby('group')
        grps.boxplot(subplots=False, vert=True, patch_artist=True)
        fig.axes[0].yaxis.grid(True)
        plt.plot()
    plt.show()
