#### CS6640 A4



Haoyang Shi 

2025/10/15



#### 1. LLM queries



I did not consult LLM on this task.



#### 4. Technical basis

First, I find the center patch of where labels should be. 


Using the 1D FFT method, I first extract the rows in the patch and apply FFT on them. Then I look at the frequency domain and count the number of rows whose high frequency component strength is under the threshold. This threshold is set to half of the average strength of a normal label, obtained by pre-running 1D FFT on all rows in patches of normal labels. The probability is determined by the number of rows that "have patterns" divided by total number of rows. I tried applying FFT on each row or column, and it turns out columns have a slight edge as the pattern tends to spread out horizontally. 

For the 2D FFT, I directly apply it on the patch and record the average high-frequency strength. By comparing it to prescribed "white label" average and "normal label" average by pre-expriment, the probability can be set to the ratio of the distance to each "cluster center". 

<!-- threshold to half the average strength of a normal label patch. However, this time I count the (fx, fy) -->

With the two methods independently developed, the fusion will be a simple averaging. 


##### 5. Comparisons

Performance-wise, both methods achieved 100% accuracy. The 2D FFT and 1D FFT both require prescribed threshold or "cluster center" computation, so I would say that both of them are similar in aspect of implementation difficulty. For the execution time, 1D and 2D FFT methods both have complexity O(n), where n is the number of the pixels in the centeral patch, so again they achieve a comparable performance. 


#### 6. Technical basis for previous defect detection methods 

I have not changed the previous defect functions.s