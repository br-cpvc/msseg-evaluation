import argparse

from evaluation import getDSC
from evaluation import getHausdorff
from evaluation import getAVD
from evaluation import getLesionDetection
from evaluation import getImages

# inspired of do() function in evaluation.py in wmhchallenge git repo


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-r', '--result-img', type=str, required=True)
    parser.add_argument('-t', '--test_img', type=str, required=True)
    args = parser.parse_args()

    testImage, resultImage = getImages(args.test_img, args.result_img)

    dsc = getDSC(testImage, resultImage)
    h95 = getHausdorff(testImage, resultImage)
    avd = getAVD(testImage, resultImage)
    recall, f1 = getLesionDetection(testImage, resultImage)

    '''
    print('Dice',                dsc,       '(higher is better, max=1)')
    print('HD',                  h95, 'mm',  '(lower is better, min=0)')
    print('AVD',                 avd,  '%',  '(lower is better, min=0)')
    print('Lesion detection', recall,       '(higher is better, max=1)')
    print('Lesion F1',            f1,       '(higher is better, max=1)')
    '''
    print("DSC,H95 (mm),AVD (%),Recall,F1")
    print(",".join(str(e) for e in [dsc, h95, avd, recall, f1]))
