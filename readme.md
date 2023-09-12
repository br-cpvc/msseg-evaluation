# Evaluation of the MSSEG algorithm using the WHM segmentation challenge dataset

example of execution

```bash
time ./run.sh | tee run.log
```

## MSSEG

Links:

* [article](http://dx.doi.org/10.1016/j.media.2016.08.014), [pdf](http://atc.udg.edu/~aoliver/publications/mia17.pdf)
* [github](https://github.com/sergivalverde/MSSEG)

## WMH segmentation challenge dataset

Links:

* [WMH segmentation challenge](https://wmh.isi.uu.nl/)
* [Dataset](https://dataverse.nl/dataset.xhtml?persistentId=doi:10.34894/AECRSD)

## Preprocessing Tools

### C3D

used to swap dimensions of wmh-sc images from RAI to LPI of both the T1 and FLAIR images

### Robex

used to create brain mask from the T1 image (after it has been converted to LPI).

