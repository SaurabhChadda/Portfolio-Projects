
-- This dataset is downloaded from kaggle which consist of all the movie details from year 2006-2016

Use portfolio_project;

Select * 
	From imdb_moviedata;

/* Creating index for the Year_release column because we will be using or filtering data more often using this attribute */

Create Index Yearly_data 
	On  imdb_moviedata(year_release);

/*Lets Fetch details regarding the total number of movies produced in each year from 2006-2016 arranged in a descending order*/

Select year_release,count(title) As total_movies_per_year
	From imdb_moviedata
	Group By year_release
    Order By Total_movies_per_year Desc;

/*Fetching details regarding the highest earning movie in each year from 2006-2016 arranged in a descending order */

Select Title,Genre,Director,Year_release,max(revenue) As Highest_grosser 
	From imdb_moviedata
    Group by Year_release 
    Order By Highest_grosser Desc;

/*Fetch the details regarding the average run time movies from 2006-2016 */

Select year_release,Title,avg(runtime) As Avg_runtime
	From imdb_moviedata
	Group By year_release;


/*Calculating the percentage change among the highest revenue generating movies in each year from 2006-2016 */

Create Temporary Table Highest_grosser_percent_change
	Select Title,Genre,Director,Year_release,max(revenue) As Highest_grosser 
	From imdb_moviedata
    Group by Year_release;
								
				-- using CTE and fetching data from the temp table and then using lead window function to calculate the percentage 
                -- change.
                
With percentage_change_maxgrosser As(
	Select *,Lead(highest_grosser) Over(Order By Year_release) As nextmax_revenue
	From highest_grosser_percent_change)
	Select *,concat(round((nextmax_revenue-highest_grosser)/Highest_grosser*100,2),"%") As percentage_change_revenue
	From percentage_change_maxgrosser;    


/*Fetching the details regarding the highest and lowest rated movies only over the years */ 

Select x.* 
	From imdb_moviedata As m
	Join
	(Select serial_no,year_release,title,max(rating) Over(partition by year_release) As highest_rated,
	min(rating) Over(partition by year_release) As lowest_rated
	From imdb_moviedata) As x
	On m.serial_no=x.serial_no And 
	(m.rating=x.highest_rated Or m.rating=x.lowest_rated)
	Order By year_release;

/*Fetching details regarding the highest and least voted movies by the audience */

Select x.* 
	From imdb_moviedata As m
	Join
	(Select serial_no,year_release,title,max(votes) Over(partition by year_release) As highest_voted,
		min(votes) Over(partition by year_release) As least_voted
        From imdb_moviedata) As x
        On m.serial_no=x.serial_no And 
        (m.votes=x.highest_voted Or m.votes=x.least_voted)
        Order By year_release;
        
/* Fetching details regarding the percentage change in highest voted movies in each year to check the audience engagement*/

        
Create Temporary Table Total_votes
	Select Title,Year_release,max(Votes) As Highest_Votes 
	From imdb_moviedata
    Group by Year_release; 
							-- For this again I'm using the temporary table to store a required data and then using CTE to get
                            -- the required output.
	
With Total_votes_percentage_change As(
	Select *,Lead(highest_votes) Over(Order By Year_release) As nextmax_votes
	From Total_votes)
	Select *,concat(round((nextmax_votes-highest_votes)/Highest_votes*100,2),"%") As percentage_change_Votes
	From Total_votes_percentage_change;     
        
/*Dividing the ratings into three sections*/ 
-- 1)If the rating is higher than 8 as Awesome 
-- 2)If the rating is between 6-7 as Good
-- 3) If the rating is less than 5 as Average */

/* For this I'm using temporary table and will add category by using case statement in update query */

            
Create Temporary Table rating(
	serial_no int,
	year_release int,
	title varchar(300),
	rating float
	);        
  
Insert Into rating
	Select serial_no,year_release,title,rating 
    From imdb_moviedata;  

							--  Adding one new column for catergorising the rating as rating_category 

Alter Table rating
	Add Column rating_category varchar(200);

Update rating
	Set rating_category=Case
	When (rating>8) Then "Awesome"
	When (rating Between 6 And 7) Then "Average"
	Else "one time"
	End;

-- Lets count the awesome,average, one time movies over the year 
-- rating higher than 8 as awesome, rating between 6-7 as average ,ratings less than 5 as one time 

Select rating_category,count(rating_category) As total
	From rating
	Group By rating_category;


/*Creating a temporary table here just for the revenue comparison in which we will see 
either a certain percent of increase or decrease in toatl revenue over the years */


Create Temporary Table revenue_comparison(
	Year_release int,
	total_revenue int
	); 

With cte_revenue As(
	Select *,Lead(total_revenue) Over(order by year_release) As nextyear_revenue 
	From revenue_comparison)
	Select *,(cast(nextyear_revenue-total_revenue As float)/total_revenue)*100 As percentage_change
	From cte_revenue;



/* Fetching details about the top 10 movies in each year on the basis of top ratings*/
-- using rank window function to perform this task 

Select * 
	From
	(Select Year_release,Title,Genre,actors,rating,Dense_rank() Over(partition By year_release Order By rating Desc) As rnk
	From imdb_moviedata) As x
	Where x.rnk<10;
    
 /*Making a small procedure which will provide us all the details about the movie by just providing the name */
 
 DELIMITER //

CREATE PROCEDURE Movie_details(
	IN P_moviename varchar(200)
)
BEGIN
	SELECT * 
 	FROM Imdb_moviedata
	WHERE Title = P_moviename;
END //

DELIMITER ;

Call movie_details("The Prestige");

			