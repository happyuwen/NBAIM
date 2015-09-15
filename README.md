# NBAIM
Inferring user activity and mobility in LBSNs

# logger_jsonRawDataToTxtFile.R
把原始json檔的check-in data只取出所需的time, lon, lat, userID等資訊，另存成文字檔

# main_vanue_search.R
# foursquare_vanue_search.R
根據經緯度資訊到foursquare API(venue search)抓該location相對應的category，並且看該category的最頂層屬哪個大類別
每一千筆會記錄一次

______________________________



______________________________

# accuracy.R
計算activity inferrence的準確度

# CDF.R
計算每個useractivity inferrence
