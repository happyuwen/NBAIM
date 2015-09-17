# NBAIM
  Inferring user activity and mobility in LBSNs
______________________________

[intro]
paper and some introduction
- 20150830 infering activity.pdf
  口試用的slide，有詳細介紹及model建構方式舉例

- 20150908 experiment results_geotext.pdf
  針對geotext這個dataset的實驗結果圖。

- NCTU_yuwen_0909_v4.pdf
  model的想法介紹，及公式推導等。

[codes]
- NOTE: input 指令在code的前五行會寫，用#註解的部分
  要執行檔案時可先find "write.table"，這部分需要設定write.table(file="PATH")寫出檔案的位置
  原始timeslot length設定在1~4hour，如需改變及在main_my_method.R and build_model_my_method.R那邊將n值改成需要的length


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
  baseline method
  kernel density estimation

- main_kde.R
______________________________
# barplot and curves
- draw_movility_v2.R
  plot the experiment results including CDF, barplot and line plot, error bar

______________________________
- 實驗資料較大時，會把資料分成file1~file38
  code裡面會有file_num，這邊指的就是分割後的第幾個file

[models]
- GeoText_Model_factorization.Rda
  已建好的model，這是baseline 方法NMF
  time slot length:動態設定1~4小時

- GeoText_Model_order1.Rda
  已建好的model，是我的方法
  time slot length:動態設定1~4小時
  每個user的model裡面會記錄
______________________________
[plot]
- plot_n_freq.R
  畫fig4.1(a)
  會用到geotext_acc.txt
  structure:("ID","Freq","NB","SVM","NMF","CLAR","NBAIM","n")
    "ID": user ID
    "Freq": how many check-ins the user checks
    "NB","SVM","NMF","CLAR","NBAIM": the accuracy with respect to the methods
    "n": time slot length
    
- acc_Freq.R
  畫fig4.1(b)
  會用到geotext_acc_trainingSize.txt
  structure:同上
  
- acc_cate_bar.R
  畫fig4.2(a)
  會用到geotext_acc_category.txt
  structure: 
    每列代表一個方法，分別為"NB","SVM","NMF","CLAR","NBAIM"；每行代表一個categor，共十個。其值代表accuracy
  
- draw_CDF.R
  畫Fig.4.2(b)
  會用到geotext_acc.txt
  structure:("ID","Freq","NB","SVM","NMF","CLAR","NBAIM","n")
    "ID": user ID
    "Freq": how many check-ins the user checks
    "NB","SVM","NMF","CLAR","NBAIM": the accuracy with respect to the methods
    "n": time slot length
  
- draw_experiment_result.R
  畫Fig.4.3(a)~(e)
  會用到以下檔案:
    geotext_likelihood_both.txt所有的likelihood
    geotext_likelihood_both_20.txt 打卡數有20筆當成training data的user的likelihood
    geotext_likelihood_both_40.txt
    geotext_likelihood_both_60.txt
    geotext_likelihood_both_80.txt
  structure:(userID,likelihood of kde, likelihood of NBAIM)，每列代表一個user的結果

- Note: 這部分主要是在桌機的Rstudio畫的。
______________________________
[server]
path: /home/happyuwen/~
code: /home/happyuwen/R/R/bin
data: /home/happyuwen/GeoText/experiment_v2 (including training and testing file )
      /home/happyuwen/Gowalla/gowalla_v3/catch_category/ (check-in少於100筆的那些user的data)更新中
      /home/happyuwen/Gowalla/gowalla_v3/training/ 因檔案過大，分割後的training data(最低打卡數為100)
      /home/happyuwen/Gowalla/gowalla_v3/testing/ 因檔案過大，分割後的testing data(最低打卡數為100)
      /home/happyuwen/Gowalla/gowalla_v3/gowalla_all.txt 總資料
      /home/happyuwen/Gowalla/gowalla_v3/gowalla_less100.txt 少於一百筆打卡資料的那些user的資料
      /home/happyuwen/Gowalla/gowalla_v3/gowalla_10to100.txt 介於十到一百筆打卡資料的那些user的資料
      
structure: ("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category","NB","SVM","NMF","CLAR","NBAIM")
  "ID": user ID
  "lon","lat":經緯度
  "year","month","date":年月日
  "hour","min":幾點幾分
  "day":星期幾 (0代表星期日)
  "act":在HTCdataset裡面是依照字母排列對應到的六個activity(dining,entertainment,shopping,sporting,transportation,working)
        在LBSNs裡面是foursquare十個主要的category對應到六個activity的結果
  "datatype": 原始category的英文名稱
  "Freq": 該使用者總打卡數
  "category": 十個category的類別，依照字母排列，詳細可見/intro/NCTU_yuwen_0909_v4的preliminary說明
  "NB","SVM","NMF","CLAR","NBAIM"：baseline四個方法及此model infer的結果，便於計算accuracy及畫圖
