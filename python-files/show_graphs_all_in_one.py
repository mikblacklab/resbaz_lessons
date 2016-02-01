import sys
import numpy as np
from matplotlib import pyplot as plt
import glob

def display(files):
  for f in files:
    plt.figure(figsize=(10.0, 3.0))
    data = np.loadtxt(fname=f, delimiter=',')
    plt.subplot(1, 3, 1)
    plt.ylabel('average')
    plt.plot(data.mean(axis=0))

    plt.subplot(1, 3, 2)
    plt.ylabel('max')
    plt.plot(data.max(axis=0))

    plt.subplot(1, 3, 3)
    plt.ylabel('min')
    plt.plot(data.min(axis=0))

    plt.tight_layout()
    plt.show()


files = sys.argv[1:]
display(files)
