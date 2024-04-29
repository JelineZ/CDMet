# CDMet
This repository contains interpolation codes for generating the China Daily Gridded Meteorological Dataset (CDMet). The dataset can be downloaded here: https://zenodo.org/records/10963932.

Run Preprocess.m in the Preprocessing folder and then use the results to run Main_program.m in the Modelling and Interpolation folder for each variable. The PRE classification folder is a random forest (RF) classification program specific to the occurrence of precipitation, for precipitation only.

## Preprocessing

Preprocess.m completes the following:
1. Resample the reanalyze data and output it.
2. Organise six combinations of covariates.
3. Randomly divide the weather station data into the training and validation set.
4. Remove anomalous records from the observation data.

## Modelling and interpolation

Main_program.m completes the following:
1. Construct interpolation models for six covariate combinations under two methods, Thin-plate spline (TPS) and RF, respectively.
2. Compare and document the accuracy of the models for different methods and different cases.
3. Select the model with the highest accuracy to interpolate the entire area.

## PRE classification

For precipitation, first run the above two procedures as for the other variables, second run Pre_Classification.m in this folder, and finally, use the results of the first two steps to run Pre_final.m to generate the final precipitation interpolation results.

## Note

1. Different meteorological variables and dates require certain modifications when running the program, which have been commented in the code.
2. The TPS method was implemented through ANUSPLIN, specifically the two functions Fun_Anusplin.m and Fun_lapgrd.m.

For questions and comments, please contact Shouzhang Peng at szp@nwafu.edu.cn.
