# NBAIM
Inferring user activity and mobility in LBSNs

- logger_jsonRawDataToTxtFile.R
把原始json檔的check-in data只取出所需的time, lon, lat, userID等資訊，另存成文字檔

- main_vanue_search.R
- foursquare_vanue_search.R
根據經緯度資訊到foursquare API(venue search)抓該location相對應的category，並且看該category的最頂層屬哪個大類別
每一千筆會記錄一次

- split_trainingTesting.R
將整理好的資料依照不同使用者及十個不同行為下去分80% training and 20% testing


______________________________
# offline training: build model

- main_my_method.R
- matrix_factorization.R
NMF method(baseline method)

- build_model_my_method.R
for NBAIM and NMF, you can set the method at the beginning
the model will contain two parts:

- time_activity_model.R
1)time-model
  act-time-weekday: an |act|*|slot| matrix
  act-time-weekend
  n: time slot length(from 1~4 hours)
2)location-model
  type 1, ... ,type 10 (stands for category1 to category 10)
  p_act: the probability of initial activity label
  
Baseline Methods
- multi_NB.R
Naive Bayesian

- multi_SVM.R
Support vector machine

- main_clar.R
- algo_clar.R
www2010 collaborative location and activity recommandation
______________________________
# online testing: inferring user activity part

- accuracy.R
計算activity inferrence的準確度

- CDF.R
calculate the accuracy of activity inferrnece result for each user

- multi_testing_geotext_NBAIM.R
according to the model built in the offline stage, here testing

______________________________
# online testing: infferring user mobility part

- KDE.R
- main_kde.R
______________________________
# barplot and curves
- draw_movility_v2.R
plot the experiment results including CDF, barplot and line plot, error bar

