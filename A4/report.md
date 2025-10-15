#### CS6640 A4



Haoyang Shi 

2025/10/15



#### 1. LLM queries







I did not consult LLM on this task.







#### 4. Technical basis



First, I find the center patch of where labels should be. 





Using the 1D FFT method, I first extract the columns in the patch and apply FFT on the blue channel. Then I look at the frequency domain and count the number of columns whose maximum strength (excluding the constant term) is under the threshold. This threshold is set to half of the average strength of a normal label (as the white label strength is close to 0), obtained by pre-running 1D FFT on all columns in patches of sampled normal labels pictures. The probability is determined by the number of columns that satisfy both `max strength < threshold` and `constant > white_average` divided by the total number of columns. I tried applying FFT on each row or column, and it turns out columns have a slight edge as the pattern tends to spread out horizontally. 



For the 2D FFT, I directly apply it on the patch and record the max strength, excluding the constant at (1, 1). By comparing it to the prescribed "white label" average and "normal label" average by pre-experiment, the probability can be set to the ratio of the distance to each "cluster center", i.e. $p_1 = \frac{f - f_{normal} }{f_{normal} - f_{white}}$. Lastly, I need to distinguish the "white label" and "label missing" defect. For this, I derived a probability `p2`, which is the distance ratio of the constant term value to the normal label and white label constant, i.e. $p_2 = \frac{C - C_{normal} }{C_{white} - C_{normal}}$. As the "label white" defect should have both a small magnitude and a large illumination, the "label white" probability is set to $p_1 p_2$;



![](fft2.png)

**Figure 4.1. Left: white label patch after FFT2. Right: normal label after FFT2. Notice there is more activity at the four corners in the right figure.**



With the two methods independently developed, the fusion will be a simple averaging. 



##### 5. Comparisons



Performance-wise, both methods achieved 100% accuracy. The 2D FFT and 1D FFT both require a prescribed threshold or "cluster center" computation, so I would say that both of them are similar in terms of implementation difficulty. For the execution time, 1D and 2D FFT methods both have complexity O(n), where n is the number of pixels in the centeral patch, so again they achieve a comparable performance. The 1D FFT is my personal favourite, because it has fewer prescribed parameters and the "white label" defect is much more evident in the 1D frequency domain, where typically the non-constant magnitude differ by an order of 10 times. 





#### 6. Technical basis for previous defect detection methods 



I have not changed the previous defect functions.