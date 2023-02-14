use delivery_and_sales;

/* Question 1: Find the top 3 customers who have the maximum number of orders */
select customer_name,cnt as count_orders,rnk as rank_ from(
select *,row_number()over(order by cnt desc) rnk from (
select  customer_name,cd.Cust_id,count( distinct Ord_id) cnt from cust_dimen cd
left join market_fact mf on mf.Cust_id=cd.Cust_id
group by 1,2)t)y
where rnk <=3

/* Question 2: Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date.*/

select *,datediff(str_to_date(Ship_Date,'%d-%m-%y'),str_to_date(Order_Date,'%d-%m-%y')) DaysTakenForDelivery 
from 
orders_dimen od join shipping_dimen sd
on od.Order_ID=sd.Order_ID


/* Question 3: Find the customer whose order took the maximum time to get delivered.*/
select * from (
select *,dense_Rank()over(order by DaysTakenForDelivery desc) rnk from (
select customer_name,od.order_id,Prod_id,Ship_Date,Order_Date,datediff(str_to_Date(Ship_Date,'%d-%m-%Y'),
str_to_date(Order_Date,'%d-%m-%Y')) DaysTakenForDelivery from orders_dimen od 
left join market_fact mf on mf.Ord_ID=od.Ord_ID
left join shipping_dimen sd on sd .Ship_id=mf.ship_id
 join cust_dimen cd on cd.Cust_id=mf.Cust_id
order by 1,2
)t)i where rnk=1


/* Question 4: Retrieve total sales made by each product from the data (use Windows function) */

select distinct mf.Prod_id,sum(Sales)over(partition by mf.Prod_id) avg_sales from market_fact mf
order by avg_sales

/* Question 5: Retrieve the total profit made from each product from the data (use windows function)*/


select distinct mf.Prod_id,sum(Profit)over(partition by mf.Prod_id) total_profit from market_fact mf
order by total_profit

/* Question 6: Count the total number of unique customers in January and how many of them 
came back every month over the entire year in 2011 */
select 'count of repetition' as Descirption,count(*) from (
(select 'count' as Descirption,count(distinct month) cnt from (
select customer_name,cd.Cust_id,year(str_to_date(Order_Date,'%d-%m-%Y')) year ,
month(str_to_date(Order_Date,'%d-%m-%Y')) month from cust_dimen cd 
left join market_fact  mf on mf.Cust_id=cd.Cust_id
left join orders_dimen od on od.Ord_id=mf.Ord_id
order by 1,2,3,4
)t
where year=2011
group  by  customer_name,Cust_id
having cnt>=12
order by 1)

)y
union all
(select 'total in january', count(distinct cust_id) from market_fact
where Ord_id in (select Ord_id from orders_dimen where year(str_to_date(Order_Date,'%d-%m-%Y'))=2011 and 
month(str_to_date(Order_Date,'%d-%m-%Y'))=1 
))





* Question 1: - We need to find out the total visits to all restaurants under all alcohol categories available. */

select g.placeID,alcohol,count(userID) from 
geoplaces2 g join rating_final rf
on g.placeID=rf.placeID
where alcohol <> 'No_Alcohol_Served'
group by g.placeID,alcohol


/* Question 2: -Let's find out the average rating according to alcohol and price so that
 we can understand the rating in respective price categories as well. */
 
 select g.alcohol,g.price,avg(rf.rating)rtr from
 geoplaces2 g join rating_final rf
 on g.placeID=rf.placeID
 group by g.alcohol,g.price
 order by rtr desc
 
 /* Question 3:  Let’s write a query to quantify that what are the parking availability as well 
 in different alcohol categories along with the total number of restaurants */
 
 select  g.placeID,g.alcohol,count(g.placeID)over(partition by alcohol) ,cp.parking_lot
 from geoplaces2 g  join chefmozparking cp
 on g.placeID=cp.placeID
 
 /* Question 4: -Also take out the percentage of different cuisine in each alcohol type. */
 
 select *,(available_cuisine/sum_each)*100 percentage from
 (select *,sum(available_cuisine)over(partition by alcohol)sum_each from 
(select alcohol,c.Rcuisine,count( c.Rcuisine) available_cuisine from
 geoplaces2 g 
  join chefmozcuisine c on g.placeID=c.placeID 
 group by alcohol,Rcuisine)t1)t2
 
 /* Questions 5: - let’s take out the average rating of each state. */
 
 select g.state,avg(rf.rating)rat from 
 geoplaces2 g join rating_final rf
 on g.placeID=rf.placeID
 group by g.state
 order by rat
 
/*  Questions 6: -' Tamaulipas' Is the lowest average rated state. 
Quantify the reason why it is the lowest rated by providing the summary on the basis of State, alcohol, and Cuisine. */

 select state,(select count(alcohol) from geoplaces2 gp2 where alcohol<>'No_Alcohol_Served' and gp2.state=gp.state ) ct_alcohol_serverd_places,
 count(distinct Rcuisine) ct_cuisine_available_in_places ,
 avg(rating) ,avg(service_rating),avg(food_rating) from geoplaces2 gp
 left join chefmozcuisine cc on cc.placeid=gp.placeID
 left join rating_final rf on rf.placeID=gp.placeID
group by 1
order by 1,2,3

-- based on number of restaurant serving alcohol and number of cuisines avilable in that state, we came to
-- the conclusion that in the given state there is no restaurant with alcohol and also food rating for the available cusines are
-- comparatively lower


/* Question 7:  - Find the average weight, food rating, and service rating of the customers who have visited KFC 
and tried Mexican or Italian types of cuisine, and also their budget level is low.
We encourage you to give it a try by not using joins. */

select up.userID,avg(weight),
(select avg(food_rating) from rating_final rf1  where rf1.userID=up.userid
and placeID in (select placeid from  geoplaces2 where name='KFC')) food_rating,

(select avg(service_rating) from rating_final rf1  where rf1.userID=up.userid
and placeID in (select placeid from  geoplaces2 where name='KFC')
) service_rating 

from userprofile up

  where up.userid in (select userID from rating_final where placeID in (select placeid from  geoplaces2 where name='KFC')) 
  and up.userid in (select userid from usercuisine where Rcuisine in ('Mexican' ,'italian') )
  and up.budget='low'
group by 1



-- Trigger
create database trigger_2;
use trigger_2;
create table Student_details 
(
Student_id int primary key, 
Student_name varchar(20), 
mail_id  varchar(40) unique, 
mobile_no bigint )

create table Student_details_backup 
(
Student_id int primary key, 
Student_name varchar(20), 
mail_id  varchar(40) unique, 
mobile_no bigint )

insert into Student_details values
(1,'sherin','sherinpaul012@gmail.com',9562733462),
(2,'rahul','rahul@gmail.com',9562733464),
(3,'lathik','lathik@gmail.com',9562733465),
(4,'nirangan','nirangan@gmail.com',95627334628),
(5,'anamika','anamika@gmail.com',9562733467)


delimiter //
CREATE TRIGGER stud_backup_1 BEFORE DELETE
ON student_details
FOR EACH ROW
INSERT INTO student_details_backup (Student_id, Student_name,mail_id,mobile_no)
VALUES (old.Student_id, old.Student_name,old.mail_id,old.mobile_no); //
delimiter ;



 