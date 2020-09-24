# labor2_articles
저널에 실린 과거 논문에 대한 분석

cd "C:\Users\twter\Google Drive\Graduate\코스웍\2020 최재성 노동경제학2\kiss analysis"
dir
forv i=2011/2015 {
import delim list_`i'.csv, encoding(CP949) clear
save list_`i', replace
