create database uber;
use uber;
show tables;
select * from uber_data limit 5;

-- creating first dimension table

create table datetime_dim
select row_number() over() as datetime_id,
tpep_pickup_datetime,
tpep_dropoff_datetime
from uber_data;

-- setting datetime_id as the primary key for the table
alter table datetime_dim modify datetime_id int primary key;

alter table datetime_dim modify tpep_pickup_datetime datetime;
alter table datetime_dim modify tpep_dropoff_datetime datetime;


-- Second dimension table
create table pickup_location_dm
select row_number() over() as pickup_location_id,
pickup_longitude,
pickup_latitude
from uber_data;

alter table pickup_location_dm modify pickup_location_id int primary key;

-- Third dimension table
create table drop_location_dm
select row_number() over() as drop_location_id,
dropoff_longitude,
dropoff_latitude
from uber_data;

alter table drop_location_dm modify drop_location_id int primary key;

-- Fourth dimension
create table rate_code_dm
select row_number() over() as rate_code_id,
ratecodeid
from uber_data;

-- Here in this table there is one very import key that is missing that is the discription about this rate code that what each rate code signifies.
-- For now I'm just creating an additional column here later on we will update this column values as well.

alter table rate_code_dm add column rate_code_name varchar(20);
alter table rate_code_dm modify rate_code_id int primary key;


-- Updating the rate code name column by the provied values

update rate_code_dm
set rate_code_name='Standard Rate' where ratecodeid=1;

update rate_code_dm
set rate_code_name='JFK' where ratecodeid=2;

update rate_code_dm
set rate_code_name='Newark' where ratecodeid=3;

update rate_code_dm
set rate_code_name='Nassu Or Westchester' where ratecodeid=4;

update rate_code_dm
set rate_code_name='Negotiated Fare' where ratecodeid=5;    

update rate_code_dm
set rate_code_name='Group Ride' where ratecodeid=6;


-- Fifth dimension table
create table payment_type_dm
select row_number() over() as payment_type_id,
payment_type
from uber_data;

-- creating one more column which provide us the payment type name which was assinged to those payment_type code
alter table payment_type_dm add column payment_type_name varchar(20);
alter table payment_type_dm modify payment_type_id int primary key;

-- Updating the payment type name for the better understanding as per the information available.

update payment_type_dm
set payment_type_name = 'Credit Card'
where payment_type=1;

update payment_type_dm
set payment_type_name = 'Cash'
where payment_type=2;


update payment_type_dm
set payment_type_name = 'No Charge'
where payment_type=3;

update payment_type_dm
set payment_type_name = 'Dispute'
where payment_type=4;

update payment_type_dm
set payment_type_name = 'Unknown'
where payment_type=5;

update payment_type_dm
set payment_type_name = 'Voided Tip'
where payment_type=6;

select * from payment_type_dm;

-- creating fact table

create table fact_table
select vendorid,
row_number() over() as datetime_id,
row_number() over() as pickup_location_id,
row_number() over() as drop_location_id,
row_number() over() as rate_code_id,
row_number() over() as payment_type_id,
passenger_count,
trip_distance,
fare_amount,
extra,
mta_tax,
tip_amount,
tolls_amount,
improvement_surcharge,
payment_type,
total_amount
from uber_data;

alter table fact_table add column payment_type int;


select payment_type from uber_data;
select * from uber_data;

select * from payment_type_dm;

select * from fact_table limit 5;








-- average tax rate overs the years
-- find the top 10 pickup locations based on the number of trips
-- find the total number of trips by the passenger counts


-- average fare amount on the basis of each vendor

select vendorid,round(avg(fare_amount),2) as Average_fare
from fact_table
group by vendorid;

-- average fare amount per hour

select hour(a.tpep_pickup_datetime) as Hour,round(avg(b.fare_amount),2) as average_hourly_fee
from datetime_dim as a
join fact_table as b
on a.datetime_id=b.datetime_id
group by 1
order by 1;

-- most preffered payment methods by the customers

select payment_type_name,count(payment_type_name) as total_transactions
from payment_type_dm
group by 1;

-- average distance customers travel using ubers
select vendorid ,round(avg(trip_distance),2) avg_ride_distance
from fact_table
group by 1;

select * from fact_table limit 4;

-- average tip amount recived by the drivers is there any connecting with the payment method

select passenger_count,round(avg(tip_amount),2)
from fact_table
group by 1
order by 1; 

-- let's find what is the average count of the customers while taking rides with uber with percentage
select passenger_count,sum(passenger_count) as total,
concat(round(sum(passenger_count)/(select sum(passenger_count) from fact_table)*100,2),'%') as Total_Percentage
from fact_table
group by 1
having passenger_count>0 
order by 1;

use uber;
show tables;

-- Total fare rate that's applied on all the rides with the total percentage in the overall rides

with cte as
(select rate_code_name,count(*) as Total 
from rate_code_dm
group by 1)
select *,concat(round(total/(select count(*) from rate_code_dm) *100,2),'%')  total_percentage
from cte
order by 3 desc;

-- Top 10 longest ride taken by the customers recently

create view max_time as
(select *,timediff(tpep_dropoff_datetime,tpep_pickup_datetime) as total_time from datetime_dim
order by 3 desc
limit 10);

-- let's try to fect more details for these rides

select a.*,b.passenger_count,b.trip_distance,b.fare_amount,b.extra,b.tip_amount,b.tolls_amount,b.improvement_surcharge,b.total_amount
from max_time as a 
join fact_table as b
on a.datetime_id=b.datetime_id
order by 4 desc;

-- let's find the maximum and minimum fare amount

select max(fare_amount) as maximum_fare,min(fare_amount)as minimum_fare
from fact_table;

select hour(a.tpep_pickup_datetime) as hour,max(b.fare_amount),min(b.fare_amount) 
from fact_table as b
join datetime_dim as a
on b.datetime_id=a.datetime_id
group by 1;

use uber;

select * from fact_table;

-- let's fetch the number of trips which are above the average distance
select count(trip_distance) as total_trips from
fact_table
where trip_distance >
(select avg(trip_distance) as avg_distance from fact_table); 

-- Let's fetch details regarding the number of store and forward regarding trip is it happening more often or it has some connectioon with a particular time frame or
-- not.

/* This flag indicates whether the trip record was held in vehicle
memory before sending to the vendor, aka “store and forward,”
because the vehicle did not have a connection to the server 

Y= store and forward trip
N= not a store and forward trip

-- for this I'll be using the raw data table (uber_data table)
*/

-- using sql pivot for this 

select store_and_fwd_flag,
count(case when vendorid=1 then store_and_fwd_flag else null end)as '1',
count(case when vendorid=2 then store_and_fwd_flag else null end) as '2'
from uber_data
group by 1;

-- let's check is there any specific time frame were drivers getting disconnected from system very often.

-- for this I have to fix datattype for the datetime columns
alter table uber_data modify tpep_pickup_datetime datetime;
alter table uber_data modify tpep_dropoff_datetime datetime; 

select hour(tpep_pickup_datetime),
store_and_fwd_flag,
count(store_and_fwd_flag) 
from uber_data
group by 1,2
order by 1;

select 
store_and_fwd_flag,
count(case when hour(tpep_pickup_datetime)=0 then store_and_fwd_flag else null end) as '0',
count(case when hour(tpep_pickup_datetime)=1 then store_and_fwd_flag else null end) as '1',
count(case when hour(tpep_pickup_datetime)=2 then store_and_fwd_flag else null end) as '2',
count(case when hour(tpep_pickup_datetime)=3 then store_and_fwd_flag else null end) as '3',
count(case when hour(tpep_pickup_datetime)=4 then store_and_fwd_flag else null end) as '4',
count(case when hour(tpep_pickup_datetime)=5 then store_and_fwd_flag else null end) as '5',
count(case when hour(tpep_pickup_datetime)=6 then store_and_fwd_flag else null end) as '6',
count(case when hour(tpep_pickup_datetime)=7 then store_and_fwd_flag else null end) as '7',
count(case when hour(tpep_pickup_datetime)=8 then store_and_fwd_flag else null end) as '8',
count(case when hour(tpep_pickup_datetime)=9 then store_and_fwd_flag else null end) as '9',
count(case when hour(tpep_pickup_datetime)=10 then store_and_fwd_flag else null end) as '10',
count(case when hour(tpep_pickup_datetime)=11 then store_and_fwd_flag else null end) as '11',
count(case when hour(tpep_pickup_datetime)=12 then store_and_fwd_flag else null end) as '12',
count(case when hour(tpep_pickup_datetime)=13 then store_and_fwd_flag else null end) as '13',
count(case when hour(tpep_pickup_datetime)=14 then store_and_fwd_flag else null end) as '14'
from uber_data
group by 1
order by 1;

-- Now in this step I'm creating an stored procedure we will be providing a detailed summary of the rides details as per the date and time provided.

 delimiter //
create procedure ride_summary (in p_date1 datetime, in p_date2 datetime)
 BEGIN
select vendorid,tpep_pickup_datetime,passenger_count,trip_distance,store_and_fwd_flag,total_amount
from uber_data
where tpep_pickup_datetime between p_date1 and pdate2;
END //
delimiter ;

call ride_summary('2016-03-01 00:00:00','2016-03-01 11:00:00');
