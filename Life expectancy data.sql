

Create Database portfolio_project2;
Use portfolio_project2;
Select * From life_expectancy_data;

/*Finding total number of countries included in the dataset for the analysis*/

Select count(distinct(country)) As total_countries
	From life_expectancy_data;

/*Fetching details regarding the maximum life expectancy dividing the output on the basis of status of the countries*/

Select status,life_expectancy,max(life_expectancy) as max_life_expectancy
	From life_expectancy_data
	Group By status;

/*Fetchning details various details regarding the adult mortality like min,max,avg,differnce it will provide us the complete 
	summary regarding the attribute and grouping the data on the basis of status (ie.developed or developing) */

Select status,
	min(adult_mortality) As lowest_adult_mortality,
	round(avg(adult_mortality),2) As avg_adult_mortality,
	round(max(adult_mortality),2) As max_adult_mortality,
	(max(adult_mortality)-min(adult_mortality)) As difference_adult_mortality
	From life_expectancy_data
	Group By status;
    
/* Creating a SQL Pivot for representing the under five deaths over the period of time from 2000-2015 grouping the data on the basis
	of status of the countries */ 

Select status,
	sum(case when year=2000 then under_five_deaths else null end) As "2000",
    sum(case when year=2001 then under_five_deaths else null end) As "2001",
    sum(case when year=2002 then under_five_deaths else null end) As "2002",
    sum(case when year=2003 then under_five_deaths else null end) As "2003",
    sum(case when year=2004 then under_five_deaths else null end) As "2004",
    sum(case when year=2005 then under_five_deaths else null end) As "2005",
    sum(case when year=2006 then under_five_deaths else null end) As "2006",
    sum(case when year=2007 then under_five_deaths else null end) As "2007",
    sum(case when year=2008 then under_five_deaths else null end) As "2008",
    sum(case when year=2009 then under_five_deaths else null end) As "2009",
	sum(case when year=2010 then under_five_deaths else null end) As "2010",
	sum(case when year=2011 then under_five_deaths else null end) As "2011",
	sum(case when year=2012 then under_five_deaths else null end) As "2012",
	sum(case when year=2013 then under_five_deaths else null end) As "2013",
    sum(case when year=2014 then under_five_deaths else null end) As "2014",
    sum(case when year=2015 then under_five_deaths else null end) As "2015",
    sum(under_five_deaths) as Under_five_total_deaths
    From life_expectancy_data
    Group By 1;
    
    
    select * from life_expectancy_data;
    
    
/*Calculating the avg infant death all over world on year basis and then fetching the details regarding the countries which are having
	higher than the avg infant deaths for this I'm using Cte */

With cte_avginfant_deaths As(
	Select *,avg(infant_deaths) over(partition by year) As avg_infant_deaths
	From life_expectancy_data)
	Select a.country, a.year, a.infant_deaths, a.avg_infant_deaths
	From  cte_avginfant_deaths as a
	Where a.infant_deaths>a.avg_infant_deaths;

/*Using SQL pivot to the total number of polio case in each year again we are dividing the data into two categories 
 (ie developed and developing) */

Select status,
	sum(case when year=2000 then polio else null end) As "2000",
    sum(case when year=2001 then polio else null end) As "2001",
    sum(case when year=2002 then polio else null end) As "2002",
    sum(case when year=2003 then polio else null end) As "2003",
    sum(case when year=2004 then polio else null end) As "2004",
    sum(case when year=2005 then polio else null end) As "2005",
    sum(case when year=2006 then polio else null end) As "2006",
    sum(case when year=2007 then polio else null end) As "2007",
    sum(case when year=2008 then polio else null end) As "2008",
    sum(case when year=2009 then polio else null end) As "2009",
	sum(case when year=2010 then polio else null end) As "2010",
	sum(case when year=2011 then polio else null end) As "2011",
	sum(case when year=2012 then polio else null end) As "2012",
	sum(case when year=2013 then polio else null end) As "2013",
    sum(case when year=2014 then polio else null end) As "2014",
    sum(case when year=2015 then polio else null end) As "2015",
    sum(Polio) as Total_polio_case
    From life_expectancy_data
    Group By 1;
    
/* Creating a SQL Pivot for representing the under five deaths over the period of time from 2000-2015 grouping the data on the basis
	of status of the countries */     
    
Select status,
	ROUND(AVG(case when year=2000 then BMI else null end),2) As "2000",
    ROUND(AVG(case when year=2001 then BMI else null end),2) As "2001",
    ROUND(AVG(case when year=2002 then BMI else null end),2) As "2002",
    ROUND(AVG(case when year=2003 then BMI else null end),2) As "2003",
    ROUND(AVG(case when year=2004 then BMI else null end),2) As "2004",
    ROUND(AVG(case when year=2005 then BMI else null end),2) As "2005",
    ROUND(AVG(case when year=2006 then BMI else null end),2) As "2006",
    ROUND(AVG(case when year=2007 then BMI else null end),2) As "2007",
    ROUND(AVG(case when year=2008 then BMI else null end),2) As "2008",
    ROUND(AVG(case when year=2009 then BMI else null end),2) As "2009",
	ROUND(AVG(case when year=2010 then BMI else null end),2) As "2010",
	ROUND(AVG(case when year=2011 then BMI else null end),2) As "2011",
	ROUND(AVG(case when year=2012 then BMI else null end),2) As "2012",
	ROUND(AVG(case when year=2013 then BMI else null end),2) As "2013",
    ROUND(AVG(case when year=2014 then BMI else null end),2) As "2014",
    ROUND(AVG(case when year=2015 then BMI else null end),2) As "2015",
    ROUND(AVG(BMI),2) as AVG_BMI
    From life_expectancy_data
    Group By 1;


/*To check wheather having high GDP or expenditure on healthcare creates any difference for the countries */
/*For this I'm using a temporary table to segregate this monetary data seprated from the medical data */

Create Temporary Table countries_gdp(
	country varchar(50),
	Yearly_data Year(4),
	status varchar(20),
	Gdp int,
	percentage_expenditure int
	);

Insert Into countries_gdp
	Select country,year,status,gdp,percentage_expenditure
	From life_expectancy_data;


Select x.*,a.life_expectancy 
	From life_expectancy_data as a      					 /* Joining this temporary table with our main table */
	Join
	(Select *,max(gdp) Over(Partition By country ) As maximum_gdp,
	max(percentage_expenditure) Over(Partition By country) As max_expenditure
	From countries_gdp) As x
	On a.country=x.country;


/*Comparing the percentage change in life expectancy data for the most recent year (i.e 2015) as per the data 
	for this I'll be using a temporary table which only having data for the year 2015 */

Create Temporary Table data_2015(
	country varchar(100),
	Year_2015 year(4),
	life_expectancy_2015 double
	);

Insert Into data_2015 
	Select country,year,life_expectancy 
	From life_expectancy_data
	Where year=2015;

With cte_percentage_change As
	(Select *, Lead(life_expectancy_2015) Over(Order By life_expectancy_2015) As next_country_data
	From data_2015)
	Select country,year_2015,life_expectancy_2015,next_country_data,
	cast((life_expectancy_2015-next_country_data)/life_expectancy_2015 as float) As percentage_change
	From cte_percentage_change;
    
/* Fetching details regarding the difference in income composition resource of developed and developing countries using SQL Pivot
	for this to get a complete summary over the period of time (2000-2015) */
    
Select status,
	ROUND(AVG(case when year=2000 then income_composition_resources else null end),2) As "2000",
    ROUND(AVG(case when year=2001 then income_composition_resources else null end),2) As "2001",
    ROUND(AVG(case when year=2002 then income_composition_resources else null end),2) As "2002",
    ROUND(AVG(case when year=2003 then income_composition_resources else null end),2) As "2003",
    ROUND(AVG(case when year=2004 then income_composition_resources else null end),2) As "2004",
    ROUND(AVG(case when year=2005 then income_composition_resources else null end),2) As "2005",
    ROUND(AVG(case when year=2006 then income_composition_resources else null end),2) As "2006",
    ROUND(AVG(case when year=2007 then income_composition_resources else null end),2) As "2007",
    ROUND(AVG(case when year=2008 then income_composition_resources else null end),2) As "2008",
    ROUND(AVG(case when year=2009 then income_composition_resources else null end),2) As "2009",
	ROUND(AVG(case when year=2010 then income_composition_resources else null end),2) As "2010",
	ROUND(AVG(case when year=2011 then income_composition_resources else null end),2) As "2011",
	ROUND(AVG(case when year=2012 then income_composition_resources else null end),2) As "2012",
	ROUND(AVG(case when year=2013 then income_composition_resources else null end),2) As "2013",
    ROUND(AVG(case when year=2014 then income_composition_resources else null end),2) As "2014",
    ROUND(AVG(case when year=2015 then income_composition_resources else null end),2) As "2015",
    ROUND(AVG(income_composition_resources),2) As Avg_income_composition
    From life_expectancy_data
    Group By 1;
    

/*In this I'm creating a stored procedure named as (country_details)  this will provide all the details about the country once
	we enter the name of country and the year for which we wanted to fetch the data */

DELIMITER //

CREATE PROCEDURE Country_details(
	IN p_country varchar(100),
    In p_year int
)
BEGIN
	SELECT * 
 	FROM life_expectancy_data
	WHERE country = p_country and year=p_year;
END ;

DELIMITER //

Call country_details("india",2001);





