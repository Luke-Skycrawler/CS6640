#### CS6640 A2

Haoyang Shi 
2025/09/10

#### 1. LLM queries

I did not consult LLM on this task.

#### 2. Technical basis

I detected the liquid level by thresholding and kmeans methods, and compared to the preset average levels for underfilled, perfect and overfilled bottles. In pixel coordinates, those three levels are set to 168, 137, and 119 respectively. Those average levels are computed by running our liquid level detection once and labelling each image ("no bottle" defect excluded) with its liquid level, and then doing a kmeans clustering with 3 clusters. 

##### 2.1 Thresholding

The threshold for binarizing the image was set to 0.5922. This magic number is the otsu threshold derived on the first image. I tried doing otsu algorithm on each image but it turns out failing for some empty bottles because it uses a criteria that no longer distict the coke but only detects the cap or the label, which leads to random liquid surface outcomes. I was only keeping the binarized red channel, because in red channel the red label and white background will be high illuminance as opposed to low-illuminance coke.

After getting a binary image, I crop it to the region (62, 96) -(234, 192). This gives the central 1/3 region in width, and region below the cap and above the label in height. Then I used gradient gx, gy of the cropped binarized image in x and y direction. 

I used the criterial gx == 0 && gy < 0 to detect the upper boundary of the liquid-filled region. After this filtering, there was only the surface line and a few noise pixels left. For the final step, I took the median of the y coordinate for the remaining pixels and make it the detected water level. For the corner case where there is not enough pixels (< 40) left, it is probably an empty bottle and we set the liquid level to 255, which means very much underfilled.  


##### 2.2 Kmeans
I cropped the image first to the narrow central region as shown below where it's sure to be bottle. Then I ran kmeans with 3 clusters with (r,g,b) as 3d coordinates for each pixel in the cropped image. Then I find the coke cluster by selecting the group with the lowest averge red value. Finally, I record the liquid level as the min of the y coordinate for pixels in the coke group.  


##### 3. Accuracy 

- Overfilled: 100% (for both methods)
- Underfilled: 100% (for both methods)

##### 4. New method for "no bottle" defect

I have not changed the "no bottle" defect function from A1, except for modifications to follow the specified programming style.