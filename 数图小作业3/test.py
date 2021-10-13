import matplotlib.pyplot as plt 
from skimage import filters,io,color 
import numpy as np 

filename='D:/lena.jpg' 
img_gray = [[1] * 256] * 256

frequency=0.6 
#调用gabor函数 
real, imag = filters.gabor(img_gray, frequency=0.6,theta=45,n_stds=5) 
#取模图像 
img_mod=np.sqrt(real.astype(float)**2+imag.astype(float)**2) 
#图像显示 
plt.figure() 
plt.subplot(2,2,1) 
plt.imshow(img_gray,cmap='gray') 
plt.subplot(2,2,2) 
plt.imshow(img_mod,cmap='gray') 
plt.subplot(2,2,3) 
plt.imshow(real,cmap='gray') 
plt.subplot(2,2,4) 
plt.imshow(imag,cmap='gray') 
plt.show()
