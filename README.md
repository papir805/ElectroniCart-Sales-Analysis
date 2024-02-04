# ElectroniCart Sales Analysis
## Objective and Background
ElectroniCart is an online electronics retailer. The company has collected a wealth of data from 100k+ orders since it was first established in 2019.  So far, the dataset has been underutilized and this project aims to provide insights and recommendations on the following key areas:

1) **Overall Sales Trends**
    * North Star Metrics (NSM)
        * Total sales
        * Average order value (AOV)
        * Sales volume
    * Seasonality
        * How do the NSMs change over time?
        * Which month(s) see the highest or lowest NSMs?
    * Segmentation Analysis
        * How do the NSMs change with respect to country or region?
    * Loyalty Program Performance
        * How do the NSMs compare for regular vs. loyalty customers?
2) **Category 2**
    * Coming Soon
3) **Category 3**
    * Coming Soon

## Dataset Structure
The dataset initial came as an [Excel workbook](https://github.com/papir805/ElectroniCart-Sales-Analysis/blob/master/data/electronicart_data_cleaned.xlsx) containing 108,127 records with order ID as the table grain and each record represents a unique order. although it should be noted that each order ID contains a single item only.  The fields relevant to the analysis are as follows:

| Field Label | Data Type | Example | 
|---|---|---|
| order_id | string | 5f87a27686c1
| purchase_ts, <br> ship_ts, <br> delivery_ts, <br> refund_ts | date | 2020-04-28
| product_name | string | Thinkpad Laptop
| usd_price | float | 434.05
| country_code | string | JP
| region | string | APAC
| loyalty | boolean | loyalty = 1 <br> regular = 0

## Data Quality
The dataset required cleaning prior to analysis as there were several data quality issues relating to inconsistent formatting, missing values, and more.  These issues and how they were resolved have been documented [here INSERT LINK LATER](www.google.com_).

## Insights Summary

### Overall Sales Trends:
**Overview**: ElectroniCart experienced staggering annual sales growth in 2020 (163%), when the pandemic started and more people were at home placing orders.  Sales slowly started to decrease in 2021 (10%) and dropped more sharply in 2022 (46%) as lockdowns were eased and people progressively returned back to normalcy.

**Table 1)** *Minimum and Maximum Annual sales*
| Year | Lowest Monthly Total Sales | Highest Monthly Total Sales
|:------:|:-----:|:-----:
| 2019 | $247,000 | $458,000
| 2020 | $460,000 | $1,252,000 
| 2021 | $632,000 | $1,030,000
| 2022 | $178,000 | $705,000

#### Seasonality
##### Total Sales:
![sales_by_year](./images/sales_by_year.png)
* Sales tend to fall slowly from January until May or June, then pick up until reaching their maximum at the end of the year.  The only exception is 2020, when COVID lockdowns were in full effect.
* All years exhibit a drop in sales from September to October ranging anywhere from 18-55%.
* Sales were highest in 2020 and 2021, likely due to the increased number of people being home when COVID lockdowns were in full effect.  Sales before COVID, in 2019, and after COVID, in 2022, show similar sales levels, indicating consumer purchasing behavior may have returned to normal levels.
* Unfortunately for ElectroniCart, the most recent data shows sales are at an all time low.

##### Sales Volume:
!['sales_volume_heatmap'](./images/sales_volume_heatmap.png)
* Sales volume in 2020 reached its highest point in December and experienced continued growth throughout 2020.  Sales volume slowly declined throughout 2021 and 2022 and **is now lower than pre-pandemic levels**.
    * **October and November 2022 have the lowest sales volume since the company was established**.

##### Average Order Value (AOV):
!['aov_heatmap'](./images/aov_heatmap.png)
* AOV was consistently high throughout 2020 and much of 2021.  A combination of high AOV and high sales volume made these two years extremely successful.

#### Segmentation Analysis
ADD STUFF HERE LATER<br>
ADD STUFF HERE LATER<br>
ADD STUFF HERE LATER<br>

#### Loyalty Program:

!['loyalty_hist_total_sales_and_aov'](./images/loyalty_hist_total_sales_and_sales_volume.png)

**Overview**: Since the loyalty program was first implemented in 2019, performance across total sales and sales volume mirrors the general trends established earlier. They both increase at first and then gradually decrease for regular and loyalty customers.  

Overall, 2019 and 2020 see stronger performance for regular customers, although this switches in 2021 and carries into 2022, where loyalty customers have higher total sales and more sales volume.

!['loyalty_hist_aov'](./images/loyalty_hist_aov.png)

AOV experiences the same trend, increasing at first and then gradually decreasing, but loyalty customers are more resilient.  From 2020 to 2021, AOV decreased by 24% for regular customers yet increased by 10% for loyalty customers.  Between 2021 and 2022, AOV decreased by 24% more for regular customers, whereas it only dropped by 2% for loyalty customers.


## Recommendations
Based on the insights listed above, the company should consider the following recommendations:

### First Team
* rec1
* rec2

### Second Team
* rec1
* rec2



