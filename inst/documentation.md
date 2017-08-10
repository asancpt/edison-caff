

# Caffeine Concentration Simulation

- Report Time: 2017-08-10 11:56:49 

## Introduction

- `Caffeine Concentration Simulation` <https://www.edison.re.kr/web/cmed/run_simulation>
- There is also `Caffeine Concentration Predictor` shiny app. <https://asan.shinyapps.io/caff>
- `Caffeine Concentration Simulation` is open to everyone. We are happy to take your input. Please fork the repo, modify the codes and submit a pull request. <https://github.com/shanmdphd/CaffeineEdison>

### Caffeine Contents
- Red Bull®, 80 mg
- Monster® and Rockstar®, 160 mg
- 5 h Energy Extra Strength® 242 mg

## Materials and Methods

**Simulation Condition**

Simulation is shown in \@ref(tab:SimulationCondition).


|Input                    |Value  |Unit  |
|:------------------------|:------|:-----|
|Body Weight              |30     |kg    |
|Caffeine Dose            |250    |mg    |
|Simulation Subject N     |20     |      |
|Log Y-axis               |FALSE  |      |
|Plot Format              |Jitter |      |
|Multiple Dosing Interval |12     |hour  |
|Multiple Dosing          |5      |times |

**Pharmacokinetic Parameters**

The pharmacokinetic parameters from the paper [1] were derived and used in the app as follows:

$$
\begin{split}
\begin{bmatrix}
     \eta_1\\
     \eta_2\\
     \eta_3
\end{bmatrix}
& \sim MVN \bigg(
\begin{bmatrix}
     0\\
     0\\
     0
\end{bmatrix}
, 
\begin{bmatrix}
     0.1599 & 6.095 \cdot 10^{-2} & 9.650 \cdot 10^{-2}\\
     6.095 \cdot 10^{-2} & 4.746 \cdot 10^{-2} & 1.359 \cdot 10^{-2}\\
     9.650 \cdot 10^{-2} & 1.359 \cdot 10^{-2} & 1.004
\end{bmatrix}
\bigg)
\end{split}
$$

$$
\begin{split}
CL\ (mg/L) &= 0.09792 \cdot W \cdot e^{\eta1}\\
V\ (L) &= 0.7219 \cdot W \cdot e^{\eta2}\\
k_a\ (1/hr) &= 4.268 \cdot e^{\eta3}
\end{split}
$$

$$
\begin{split}
k\ (1/hr) & = \frac{CL}{V}\\
t_{1/2}\ (hr) & = \frac{0.693}{k}\\
t_{max}\ (hr) & = \frac{ln(k_a) - ln(k)}{k_a - k}\\
C_{max}\ (mg/L) & = \frac{Dose}{V} \cdot \frac{k_a}{k_a - k} \cdot (e^{-k \cdot  t_{max}} - e^{-k_a \cdot t_{max}})\\
AUC\ (mg \cdot hr / L)  & = \frac{Dose}{CL}\\
\\
C_{av,ss} & = \frac{Dose}{CL \cdot \tau}\\ 
AI & = \frac{1}{1-e^{-k_e \cdot \tau}}\\
\end{split}
$$

(Abbreviation: $AI$, accumulation index; $AUC$, area under the plasma drug concentration-time curve; $CL$, total clearance of drug from plasma; $C_{av,ss}$, average drug concentration in plasma during a dosing interval at steady state on administering a fixed dose at equal dosing intervals; $C_{max}$, highest drug concentration observed in plasma; $MVN$, multivariate normal distribution; $V$, Volume of distribution (apparent) based on drug concentration in plasma; $W$, body weight (kg); $\eta$, interindividual random variability parameter; $k$, elimination rate constant;  $k_a$, absorption rate constant; $\tau$, dosing interval; $t_{1/2}$, elimination half-life)


## Results

### Single Dose

#### Figure 1. Concentration-Time Plot
![](Plot_SingleDose.jpg)


**Reference range**

- Below 10 mg/L: generally considered safe (Green horizontal line)
- Over 40 mg/L: several fatalities (Blue horizontal line)
- Over 80 mg/L: fatal caffeine poisoning (Red horizontal line)
- Reference: de Wijkerslooth LR et al.(2008), Seifert et al.(2013), Banerjee et al. (2014), Cannon et al. (2001)


#### Table 1. Descriptive Statistics of Single Dose PK Parameters

|   |Parameter      | median|   sd|  min| Q0.25| mean| Q0.75|   max|
|:--|:--------------|------:|----:|----:|-----:|----:|-----:|-----:|
|1  |T~max~ (hr)    |    0.6|  0.5|  0.2|   0.4|  0.8|   1.0|   2.3|
|2  |C~max~ (mg/L)  |   10.2|  2.4|  6.8|   8.6| 10.4|  11.9|  14.7|
|3  |AUC (mg*hr/L)  |   79.0| 34.5| 40.5|  55.7| 84.9| 107.9| 172.1|
|4  |Half-life (hr) |    4.9|  1.4|  2.6|   3.8|  4.9|   5.7|   8.2|
|5  |CL (L/hr)      |    3.2|  1.3|  1.5|   2.3|  3.4|   4.5|   6.2|
|6  |V (L)          |   21.9|  4.5| 16.3|  19.1| 22.2|  24.7|  35.0|
|7  |K~a~ (1/hr)    |    6.3|  6.3|  1.0|   3.2|  8.1|  11.0|  23.6|
|8  |K~e~ (1/hr)    |    0.1|  0.0|  0.1|   0.1|  0.2|   0.2|   0.3|

#### Figure 2. Cmax Plot
![](Plot_Cmax.jpg)

#### Figure 3. AUC Plot
![](Plot_AUC.jpg)

### Multiple Dose

#### Figure 4. Concentration-Time Plot
![](Plot_MultipleDose.jpg)

**Reference range**

- Below 10 mg/L: generally considered safe (Green horizontal line)
- Over 40 mg/L: several fatalities (Blue horizontal line)
- Over 80 mg/L: fatal caffeine poisoning (Red horizontal line)
- Reference: de Wijkerslooth LR et al.(2008), Seifert et al.(2013), Banerjee et al. (2014), Cannon et al. (2001)

#### Table 2. Descriptive Statistics of Multiple Dose PK Parameters

|   |Parameter             | median|   sd|  min| Q0.25|  mean| Q0.75|   max|
|:--|:---------------------|------:|----:|----:|-----:|-----:|-----:|-----:|
|1  |T~max,single~ (hr)    |    0.9|  1.8|  0.2|   0.5|   1.4|   1.7|   8.4|
|2  |C~max,single~ (mg/L)  |   11.9|  2.8|  4.0|  10.1|  11.3|  12.8|  17.0|
|3  |AUC~single~ (mg*hr/L) |   92.5| 29.8| 60.1|  73.3|  98.8| 124.0| 161.7|
|4  |R~ac~ (1/hr)          |    1.3|  0.2|  1.1|   1.1|   1.3|   1.4|   1.6|
|5  |A~av,ss~ (mg)         |  158.4| 47.3| 87.0| 112.9| 158.8| 185.3| 265.0|
|6  |C~av,ss~ (mg/L)       |    7.7|  2.5|  5.0|   6.1|   8.2|  10.3|  13.5|
|7  |C~max,ss~ (mg/L)      |   16.6|  3.0| 11.7|  14.8|  16.6|  18.8|  21.2|
|8  |C~min,ss~ (mg/L)      |    3.3|  2.0|  0.9|   1.8|   3.5|   4.8|   8.1|

## Acknowledgements

The main idea and intellectual resources were mainly provided by Professor Kyun-Seop Bae <k@acr.kr>.

## Reference

This work is solely dependent on the interesting paper published in Eur J Pediatr in 2015. 

1. "Prediction of plasma caffeine concentrations in young adolescents following ingestion of caffeinated energy drinks: a Monte Carlo simulation." Eur J Pediatr. 2015 Dec;174(12):1671-8. doi: 10.1007/s00431-015-2581-x <https://www.ncbi.nlm.nih.gov/pubmed/26113286>
2. "Clinical pharmacokinetics and pharmacodynamics: concepts and applications, 4th edition" Lippincott Williams & Wilkins. 2011. ISBN 978-0-7817-5009-7

**R Packages**

- H. Wickham. ggplot2: Elegant Graphics for Data Analysis. Springer-Verlag New York, 2009.
- Winston Chang, Joe Cheng, JJ Allaire, Yihui Xie and Jonathan McPherson (2016). shiny: Web Application Framework for R. R package version 0.14.2. https://CRAN.R-project.org/package=shiny
- JJ Allaire, Jeffrey Horner, Vicent Marti and Natacha Porte (2015). markdown: 'Markdown' Rendering for R. R package version 0.7.7. https://CRAN.R-project.org/package=markdown
- Hadley Wickham and Romain Francois (2016). dplyr: A Grammar of Data Manipulation. R package version 0.5.0. https://CRAN.R-project.org/package=dplyr

## Contact

- `Caffeine Concentration Simulation` Edison Science App developer: Sungpil Han <shan@acp.kr> / <https://shanmdphd.github.io>
- Copyright: 2016, Sungpil Han
- License: GPL-3
