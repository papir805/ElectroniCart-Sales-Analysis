# ElectroniCart Sales Analysis
## Objective and Background
ElectroniCart is an online electronics retailer. The company has collected a wealth of data from 100k+ orders since being established in 2019.  So far, the dataset is underutilized, and this project aims to provide insights and recommendations on the following key areas:

1) **Sales**
    * North Star Metrics (NSM)
        * Total sales
        * Sales volume
    * Product Mix
        * Which items contribute most to total sales?
        * Which items are purchased most frequently?
    * Seasonality
        * How do the NSMs change over time?
        * Which month(s) see the highest or lowest NSMs?
    * Loyalty Program Performance
        * How do the NSMs compare for loyalty vs. non-loyalty customers?
2) **Refunds**
    * North Star Metrics (NSM)
        * Dollars refunded
        * Refund rate
        * Average order value (AOV)
    * How do the NSMs change for each product?
        * Which products have the highest return rates?
        * Which products are returned most frequently?
    * How do dollars refunded affect ElectroniCart's bottom line?


## Data Quality
The dataset required cleaning before analysis.  There were data quality issues relating to inconsistent formatting, missing values, and more.  Documentation on these issues and their resolution is [here INSERT LINK LATER](www.google.com_).

## Dataset Structure
The dataset initially came as an [Excel workbook](https://github.com/papir805/ElectroniCart-Sales-Analysis/blob/master/data/electronicart_data_cleaned_final.xlsx) containing 108,127 records with order ID as the table grain, and each record represents a unique order.  **Note: each unique order only contains a single item**.


| Field Label | Data Type | Example | 
|---|---|---|
| order_id | string | 5f87a27686c1
| purchase_ts | date | 2020-04-28
| ship_ts | date | 2021-09-04
| delivery_ts | date | 2019-03-07
| refund_ts | date | 2022-05-21
| product_name | string | Thinkpad Laptop
| usd_price | float | 434.05
| loyalty | boolean | loyalty = 1 <br> non-loyalty = 0

# Sales Insights
## Overview
 **ElectroniCart experienced staggering annual sales growth in 2020 (+163%)** when the pandemic started, and more people were placing orders from home. **Sales decreased in 2021 (-10%) and dropped sharply in 2022 (-46%)** as lockdowns eased and people progressively returned to normalcy ([figure 1](./images/overview_total_sales_and_sales_volume.png)).

## Product Mix
Between 2019 and 2022, **four items constitute 96% of all sales**: 
* 27in 4K Gaming Monitor (35%)
* Apple Airpods Headphones (28%)
* Macbook Air Laptop (22%)
* Thinkpad Laptop (11%)

**The Bose Soundsport Headphones is the worst performing, only selling ~$3,000** ([figure 2](./images/product_mix.png)).

## Seasonality
Starting in January, **sales fall until reaching their lowest point in May/June**, and then pick up **until September to October, when they drop anywhere between 18 to 55%.**  Sales rebound in the remaining months and finish the year strong.  

**These patterns were more volatile in 2020 and 2021**, likely due to the increased number of people being home when COVID lockdowns were in full effect, but **sales before COVID-19 in 2019 and after COVID-19 in 2022 show similar sales levels, indicating that consumer purchasing behavior may have returned to normal** ([figure 3](./images/sales_by_year.png)).

## Sales Volume
Sales volume grew steadily throughout 2020, reaching its highest point in December 2020, but declined throughout 2021 and 2022 and is now lower than most pre-pandemic levels. **Two out of three of the most recent months have the lowest sales volume since the company was established** ([figure 4](./images/sales_volume_heatmap.png)).

## Loyalty Program
When first being introduced in 2019, loyalty program customers underperformed compared to non-loyalty customers, although this switches in 2021 and carries into 2022.  Now, **loyalty customers have higher total sales and more sales volume than non-loyalty customers**  ([figure 5](./images/loyalty_hist_total_sales_and_sales_volume.png)).

Although total sales and sales volume dropped from 2021 to 2022 for both types of customer, loyalty customer's AOV has been more resilient to change. **From 2020 to 2021, AOV decreased by 24% for non-loyalty customers, yet increased by 10% for loyalty customers, and between 2021 and 2022, AOV decreased an additional 24% for non-loyalty customers, while only dropping by 2% for loyalty customers** ([figure 6]((./images/loyalty_hist_aov.png))).

# Refund Insights

## Refund Rates
On average, ~5% of orders get refunded. However, several items have much higher refund rates: 
* Thinkpad Laptop (12%)
* Macbook Air Laptop (11%)
* Apple iPhone (8%) 

Despite a high refund rate, the Apple iPhone represents a tiny chunk of ElectroniCart's sales (~1%) and returns have a negligible impact on dollars refunded ([figure 7](./images/refunds_refund_rate_total_sales_aov.png)).

## Dollars Refunded
Four items make up nearly all (99%) of dollars refunded:
* Macbook Air Laptop (33%)
* 27in 4K Gaming Monitor (29%)
* Apple Airpods Headphones (19%)
* Thinkpad Laptop (17%)

Because **the Thinkpad and Macbook Air Laptop have high AOVs and high refund rates**, their returns represent a significant threat to ElectroniCart's revenue. **The 27in 4K Gaming Monitor and Apple Airpods Headphones** had low refund rates, but **have a high refund frequency**, also making them dangerous.  

**Returns of the Macbook Air Laptop, the Apple Airpods Headphones, the Thinkpad Laptop, and the 27in 4K Gaming Monitor constitute 8% of all sales and represent $2.2 million in dollars refunded between 2019 and 2022**
([figure 8](./images/refunds_percent_dollars_refunded_and_refund_count.png)).

# Recommendations
Based on the insights listed above, the company should consider the following recommendations:

## Sales Team
* Increase promotions during late spring and summer to increase sales during slower times.
* Investigate why sales consistently dive during Sept to Oct.  
* Collaborate with the loyalty team to identify why spending and AOV for loyalty customers has eclipsed non-loyalty customers. Use the findings to boost AOV for non-loyalty customers. 


## Loyalty Team
* Continue the loyalty program and expand its offerings to increase the number of participating users and AOV.

## Inventory Team
* Start tracking reasons for customer returns and identify why certain products get returned more frequently.  Fix those issues to minimize return rates for certain items with high AOV, like the Macbook Air Laptop and Thinkpad Laptop, or other items with high return frequencies, like the Apple Airpods Headphones and 27in 4K Gaming Monitor.
* Phase out the sale of the Samsung Charging Cable Pack, the Samsung Webcame, the Apple Iphone, and the Bose Soundsport Headphones.  Investigate reasons for their poor sales performance and select new product offerings that are more likely to perform well.   


# Technical Analysis
All pivot tables used to generate the figures in this analysis are contained within the Excel workbook found in this repository.