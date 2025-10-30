#### CS6640 A5







Haoyang Shi 



2025/10/30







#### 1. LLM queries



I did not consult LLM on this task.



#### 2. Ground Truth File



I used the provided `ground_truth.mat` file in my experiments.



#### 3. Independent Defect Detection



I made sure there are no dependencies between the functions.







#### 4. Technical basis





##### 4.1 Preprocess



This stage finds the upper white strip of the label. 



First, I find the center patch of where labels should be using the provided `CS6640_get_center` function and clip to the label region. Then I turn it into grayscale and binarize with threshold `150` to separate the white regions. Then I applied opening (dilate after erosion) with a horizontal line of length 10 as structure element, only keeping regions with long horizontal span. Then I do a connected component analysis and select the component with the longest horizontal span. This patch is identified as the white strip on the label. 



crooked label             |  normal label
:-------------------------:|:-------------------------:
![](open.png)  |  ![](open2.png)
![](patch.png)| ![](patchc.png)



**Figure 4.1. Binary image after the opening operation. The longest component is then selected as the target white stripe.**



##### 4.2 Procrustes 



I find the four corners of the extracted white stripe and compare it to a reference $5\times 100$ rectangle. For selecting the corners, I used the oracles $x + y$ and $x - y$, where x, y are the rows and colums of the pixel, e.g, the bottom right, top left have the largest and smallest $x + y$ value respectively. The corners are then organized in `[top_right, bottom right, bottom left, top left]` order as the reference rectangle, and a procrustes transformation is computed to map the reference shape to the extracted shape. Then I get the rotation matrix $R$ in the transformation, and used the absolute value of the off-diagonal term `R(1, 2)` to indicate the rotation angle. The probability of crooked label is then computed as $\frac{|R(1, 2)|}{0.1}$, where 0.1 is close to the least `|R(1,2)|` value of the positive samples. The probability threshold is set to 0.5. 



![](procrustes.png)



**Figure 4.2. The extracted shape X(in blue), reference shape Y(in red) and transformed shape after best-fit procrustes transformation(in yellow).**





This method works notably well for distracting white label cases, where the whole label is detected as the region of interest. The procrustes method still find a resonable transformation with correct rotation. 

![](prowhite.png)



However, it fails for 3 deformed bottle images 61, 129 and 137. The accuracy is 138/141. 



##### 4.3 Eigen Vector Method



My implementation follows the paradigm in the course: 

0. Segment the component of interest (done in preprocess)

1. Get a range scan.

2. Convert to x,y points.

3. Get the covariance matrix.

4. Get the eigenvalues and eigenvectors.



crooked label             |  normal label | reference |
:-------------------------:|:-------------------------:|:--------:|
![](polar.png)  |  ![](polar2.png) | ![](polarref.png)
$V = \begin{pmatrix}-0.9785,   -0.2064\\ 0.2064,   -0.9785\end{pmatrix}$ D = diag(122.3035,4.0765) | $V = \begin{pmatrix} -1.0,-0.0 \\ 0.0,-1.0\end{pmatrix}$, D = diag(122.3035,4.0765) | $V = \begin{pmatrix} -1.0,-0.0 \\ 0.0,-1.0\end{pmatrix}$, D = diag(100, 5)



**Figure 4.3. Polar scans and eigen vectors of crooked label, normal label and reference shape.** 



Then I used the same measure described in section 4.2 to compute the probability, i.e. $p = \frac{|R(1, 2)|}{0.1}$, only now $R$ is the matrix whose columns are formed by the eigen vectors, instead of the rotation matrix in section 4.2.   



This method also fails for deformed bottle images 129 and 137. The accuracy is 139/141.







With the two methods independently developed, the fusion will be a simple averaging. 







#### 5. Technical basis for previous defect detection methods 







I have not changed the previous defect functions.

