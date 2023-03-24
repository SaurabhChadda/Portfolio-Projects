use portfolio_project3;

select * from store_data;

Select  distinct year(str_to_date(order_date,"%d-%m-%Y")) as Year
	From store_data
	Order By Year;

/*Let's fetch details regarding the different shipping methods and most prefered one by the customers*/

Select ship_mode,count(distinct order_id) as total_orders
	From store_data
	Group By ship_mode
	Order By total_orders desc;

/*Let's find the summary of orders from each segment of customers during the period*/

Select segment,
	count(distinct order_id) as total_orders,
    round(max(sales),2) as highest_sales,
    round(min(sales),2) as minimum_sales,
    round((max(sales)-min(sales)),2) as difference
	From store_data
    Group By segment;
    
/*let's fetch details regarding from which region we are getting the maximum flow of sales */    
 
 Select region,round(sum(sales),2) as total_sales
	From store_data
    Group By region
    Order By total_sales Desc;
    
/*creating a pivot table in SQL to compare the total sales each segment for all four years in one glimpse */

Select segment, 
	round(sum(case when Year(str_to_date(order_date,"%d-%m-%Y"))=2014 then sales else null end),2) as "2014" ,
    round(sum(case when Year(str_to_date(order_date,"%d-%m-%Y"))=2015 then sales else null end),2) as "2015",
    round(sum(case when Year(str_to_date(order_date,"%d-%m-%Y"))=2016 then sales else null end),2) as "2016",
    round(sum(case when Year(str_to_date(order_date,"%d-%m-%Y"))=2017 then sales else null end),2) as "2017",
    round(sum(sales),2) as total_sales
    From store_data
    Group by segment
    Order By total_sales DESC;
    
/*creating a pivot table to analyse the profit that store is generating from each segment of customers */

Select segment,
	round(sum(case when Year(str_to_date(order_date,"%d-%m-%Y"))=2014 then profit else null end),2) as "2014", 
	round(sum(case when Year(str_to_date(order_date,"%d-%m-%Y"))=2015 then profit else null end),2) as "2015",	
    round(sum(case when Year(str_to_date(order_date,"%d-%m-%Y"))=2016 then profit else null end),2) as "2016",
	round(sum(case when Year(str_to_date(order_date,"%d-%m-%Y"))=2017 then profit else null end),2) as "2017",
	round(sum(profit),2) as total_profit
    From store_data
    Group By Segment
    Order By total_profit;
    
/*Let's fetch details regarding the best performing category of product on basis of total sales for this I'm using pivot*/
 
Select category,
	round(sum(case when Year(str_to_date(order_date,"%d-%m-%Y"))=2014 then sales else null end),2) as "2014",
    round(sum(case when Year(str_to_date(order_date,"%d-%m-%Y"))=2015 then sales else null end),2) as "2015",
    round(sum(case when Year(str_to_date(order_date,"%d-%m-%Y"))=2016 then sales else null end),2) as "2016",
    round(sum(case when Year(str_to_date(order_date,"%d-%m-%Y"))=2017 then sales else null end),2) as "2017",
    round(sum(sales),2) as total_sales
    From store_data
    Group By Category
    Order By total_sales Desc;
   
/*Calculating the percentage change in profit over the period of time for this I've used temporary table with Cte table */

Create Temporary Table profit_analysis
	Select Year(str_to_date(order_date,"%d-%m-%Y")) as Year,
	round(sum(profit),2) as total_profit
	From store_data
	Group By Year
	Order By year;
    
With cte_percentage_change as(
	select Year,total_profit,
	lead(total_profit) over() as next_year_revnue
    from profit_analysis
    ) Select *,
		case when round((next_year_revnue-total_profit)/total_profit*100,2) is not null then 
		concat(round((next_year_revnue-total_profit)/total_profit*100,2),"%") else null
        end as percentage_change_revenue
		From cte_percentage_change;
        
/*Calculating profit margin of the store after deducting the discount offered by the store to each segment of customer*/

Select segment,round(sum(profit),2) as total_sales,
		round(sum(discount),2) as total_discount,
        round(sum(profit-discount),2) as margin
        From store_data
        Group By Segment
        Order By margin Desc;
        
/*Using CTE table to find the total number of orders on monthly basis */

with cte_2014 as (
select year(str_to_date(order_date,"%d-%m-%Y")) as Year14,
	month(str_to_date(order_date,"%d-%m-%Y")) as months14,
    count(order_id) as total_orders
    from store_data
    where year(str_to_date(order_date,"%d-%m-%Y"))=2014
    group by months14
    order by months14
    ),
cte_2015 as(
  select year(str_to_date(order_date,"%d-%m-%Y")) as Year15,
	month(str_to_date(order_date,"%d-%m-%Y")) as months15,
    count(order_id) as total_orders
    from store_data
    where year(str_to_date(order_date,"%d-%m-%Y"))=2015
    group by months15
    order by months15),
cte_2016 as(
  select year(str_to_date(order_date,"%d-%m-%Y")) as Year16,
	month(str_to_date(order_date,"%d-%m-%Y")) as months16,
    count(order_id) as total_orders
    from store_data
    where year(str_to_date(order_date,"%d-%m-%Y"))=2016
    group by months16
    order by months16),
cte_2017 as(
  select year(str_to_date(order_date,"%d-%m-%Y")) as Year17,
	month(str_to_date(order_date,"%d-%m-%Y")) as months17,
    count(order_id) as total_orders
    from store_data
    where year(str_to_date(order_date,"%d-%m-%Y"))=2017
    group by months17
    order by months17) 
     select cte_2014.year14,cte_2014.months14,cte_2014.total_orders,
			cte_2015.year15,cte_2015.months15,cte_2015.total_orders,
            cte_2016.year16,cte_2016.months16,cte_2016.total_orders,
            cte_2017.year17,cte_2017.months17,cte_2017.total_orders
            from cte_2014 
            join cte_2015
            on cte_2014.months14=cte_2015.months15
            join cte_2016
            on cte_2014.months14=cte_2016.months16
            join cte_2017
            on cte_2014.months14=cte_2017.months17;
            
    




 


    
    
    
 


	



  

	
   
    
        
		
        