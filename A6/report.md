#### CS6640 A6















Haoyang Shi 







2025/11/5















#### 1. LLM queries







I did not consult LLM on this task.







#### 2. Ground Truth File







I used the provided `ground_truth.mat` file in my experiments.









#### 3. Technical basis



First, I find the center patch of where labels should be using the provided `CS6640_get_center` function and clip to the label region. Right after that I applied a gradient magnitude edge detector to detect the "no bottle" defect first, and if there is no bottle, I return a "no label" defect.



Then I turn the middle patch into grayscale and binarize with threshold `100` to separate the dark coke regions. Then I applied dilation followed by erosion on the coke regions, with a radius 5 disk as structure element. The small regions are thus filtered out, and the remaining unselected region is identified as the "label pixels". Then I counted the number of the label pixels `n`, and divide it by threshold label pixel count `t` to get the probability that it has a label. The final probability is $1 -  \frac{n}{t}$. The threshold label pixel count is set to the label pixel count on the extreme case `image109` with crooked label, which has around 2500 label pixels. This method achieves a 100% precision on the test images. 





33 |  34 | 35
:-------------------------:|:-------------------------:|:-------------------------:
![](Figure_1.png)  |  ![](Figure_2.png) | ![](Figure_3.png)
![](Figure_4.png)| ![](5.png) | ![](Figure_6.png)

**Figure 3.1. Binary image after the dilation and erosion operations. The remaining black pixels are then selected as the "label pixels".**



#### 4. Failure case for previous defects



The detectors for overfilled, label missing, white label, crooked label, and no cap defects all get 100% accuracy. 



My detector for underfilled has false positives on images 52, 136, and 137. Those are all deformed bottles and their liquid surfaces are all somewhat below average, so I counted them as underfilled bottles in my own version of ground truth. I need to re-set the threshold for underfilled for better coherence for the new ground truth. 

![](results.png)
**Figure 4.1. My previous thresholds for detecting overfilled and underfiled defects.**


My detector for "crooked label" has trouble with the deformed bottles 129 and 137. Both of my methods relys on the shape of white stripes on the label, and the deformed plastic creates specular reflections near the top of the label and is identified as white stripe by my detector, thus leading to failure. To improve the robustness to the specular highlights, I could do a median filter before detecting the white stripes, as the specular regions tend to be small. However, the real solution should be that I make at least one of the methods to use the bulk red region on the label to better fight the noise, e.g., dilate the red label regions and detect the corners, and compare it to the rectangular reference shape. 





#### 5. Technical basis for previous defect detection methods 















I have not changed the previous defect functions.



