--1) List all the company names and countries that are incorporated outside Australia.

--   Creating a view to show the name and country from company table where country name is not Australia

create or replace view Q1(Name, Country) as 
select name,country 
from company 
where country <> 'Australia';



--2) List all the company codes that have more than five executive members on record (i.e., at least six).

--   Creating a view Q2sub to get the count of code, and then joining the Q2sub view with Q2 to get the whenever the count is greater than 5.

create or replace view Q2sub(count) as 
select count(code) 
from executive 
group by code;

create or replace view Q2(Code) as 
select code 
from executive,Q2sub s 
where s.count>5;



--3) List all the company names that are in the sector of "Technology".

--   Creating a view to show name from the company where the sector name is Technology.

create or replace view Q3(Name) as 
select name 
from company c,category c1 
where c.code=c1.code and sector ='Technology';



--4) Find the number of Industries in each Sector.

--   Creating a view to show sector and number of industry in every sector.

create or replace view Q4(Sector, Number) as 
select sector,count(industry) 
from category group by sector;



--5) Find all the executives (i.e., their names) that are affiliated with companies in the sector of "Technology". 
--   If an executive is affiliated with more than one company, 
--   he/she is counted if one of these companies is in the sector of "Technology".

-- Creating a view to show name of the person who are associated with sector name Technology.

create or replace view Q5(Name) as 
select c1.person 
from category c,executive c1 
where c.code=c1.code and c.sector = 'Technology';



--6) List all the company names in the sector of "Services" that are located in Australia with the first digit of their zip code being 2.

--   Creating a view to show the name of the company who is located in Austalia and the first digit of their zip code in starting with 2.

create or replace view Q6(Name) as 
select c.name 
from company c, category c1 
where c.code=c1.code and sector='Services' and country = 'Australia' and zip like '2%';



--7) Create a database view of the ASX table that contains previous Price, Price change (in amount, can be negative) and Price gain (in percentage, 
--   can be negative). (Note that the first trading day should be excluded in your result.) For example, if the PrevPrice is 1.00, Price is 0.85; 
--   then Change is -0.15 and Gain is -15.00 (in percentage but you do not need to print out the percentage sign).

--   I am creating view q7sub to select the code and starting date for a company.
--   Crating another view q7sub1 to show date, code , volume, current price, previous price by joining with q7sub view and table asx.
--   I am using lag keyword to take the value for the previous date and substracting it.
--   Creating q7 by joining q7sub1 to show date,code,volume,prev price, price, change and gain by calculating them accordingly. And atlast I am ignoring
--   the initial date for the particular company.

create or replace view q7sub(p_code,p_minDate) as  
select code,min("Date") 
from asx 
group by code 
order by code;

create or replace view q7sub1(p_date,p_code,p_volume,p_price,p_lag_price) as 
select a."Date", a.code, a.volume, a.price, lag(a.price,1,null) 
over (partition by a.code order by a."Date") as lag  
from asx a;

create or replace view Q7("Date", Code, Volume, PrevPrice, Price, Change, Gain) as 
select q1.p_date,q1.p_code,q1.p_volume, q1.p_lag_price,q1.p_price,  q1.p_price - q1.p_lag_price,  (q1.p_price - q1.p_lag_price)/q1.p_lag_price*100  
from q7sub q, q7sub1 q1 
where q.p_code=q1.p_code and q.p_mindate <> q1.p_date;



--8) Find the most active trading stock (the one with the maximum trading volume; 
--   if more than one, output all of them) on every trading day. Order your output by "Date" and then by Code.

--   Creating a view Q8sub to show the max count of the volume in a particular day.
--   Creating a view q8 to show date,code,volume by joining the asx table and q8sub view.

create or replace view Q8sub(max_count) as 
select max(volume) 
from asx group by "Date" 
order by "Date";

create or replace view Q8("Date", Code, Volume) as 
select "Date", code,volume 
from asx,Q8sub q  
where volume = q.max_count; 



--9) Find the number of companies per Industry. Order your result by Sector and then by Industry.

--   Creating a view q9sub to show the name and number of the code for a particular industry.
--   Creating a view q9 to show sector name, industry and the count of the comapnies per industry.

create or replace view q9sub(i_name,number) as  
select industry, count(code)as number  
from category 
group by industry;

create or replace view Q9(Sector, Industry, Number) as 
select distinct sector,industry,q.number 
from category,q9sub q 
where industry = q.i_name 
order by sector,industry;



--10) List all the companies (by their Code) that are the only one in their Industry (i.e., no competitors).

--    Creating a view to show the code of the company and industry name where the count for the company is 1 in their respective industry.

create or replace view Q10(Code, Industry) as 
select distinct code,industry 
from category,q9sub q 
where q.number=1;



--11) List all sectors ranked by their average ratings in descending order. AvgRating is calculated by 
--    finding the average AvgCompanyRating for each sector (where AvgCompanyRating is the average rating of a company).

--    Creating a view to show sector, avg rating for all the sector in descending order .

create or replace view Q11(Sector, AvgRating) as 
select c.sector, avg(r.star) as avgrating  
from category c,rating r 
where c.code=r.code 
group by sector 
order by avgrating desc;



--12) Output the person names of the executives that are affiliated with more than one company.

--    Creating a view q12sub to show the person name and its count how many time he is present in the table for any company.
--    Creating a view q12 to show the name if the person is appearing for more than 1 company.

create or replace view Q12sub(p_person,p_count) as  
select person, count(person) 
from executive 
group by person;

create or replace view Q12(Name) as 
select p_person as name  
from q12sub 
where p_count > 1;



--13) Find all the companies with a registered address in Australia, in a Sector where there are no overseas companies in the same Sector. i.e., 
--    they are in a Sector that all companies there have local Australia address.

--    Creating a view q13sub to show the code and sector where the address of the company is austalia.
--    Creating a view q13 to show the code, name ,address,zip,address and sector to check 
--    whether they are in a sector that all companies have local address.

create or replace view q13sub(p_code,p_sector) as 
select c.code, c1.sector 
from company c, category c1 
where c.code = c1.code and c.country = 'Australia';

create or replace view Q13(Code, Name, Address, Zip, Sector) as 
select c.code,c.name,c.address,c.zip,c1.sector 
from company c,category c1 
where c.code=c1.code and c1.sector not in (select distinct c1.sector from company c,category  c1 where c.code=c1.code and c.country <> 'Australia');



--14) Calculate stock gains based on their prices of the first trading day and last trading day 
--    (i.e., the oldest "Date" and the most recent "Date" of the records stored in the ASX table). 
--    Order your result by Gain in descending order and then by Code in ascending order.

--    Creating a view q14sub to show the code, min date, max date from asx table.
--    Creating q14sub2 to show the code and after price  by joining it with asx table and q14sub view.
--    Creating a view q14sub1 to show the code and prev price by joining it with asx table and q14sub view.
--    Creating a view q14 to show code,beginprice,endprice, change and gain by calculating change and gain by substracting and calculating percentage.

create or replace view q14sub(p_code,min_date,max_date) as 
select code,min("Date"), max("Date") 
from asx 
group by code 
order by code;

create or replace view q14sub2(p2_code,p2_after_price) as 
select q.p_code, a.price as after_price 
from asx a,q14sub q 
where q.p_code=a.code and q.max_date = a."Date";

create or replace view q14sub1(p1_code,p1_pre_price) as 
select q.p_code, a.price as pre_price 
from asx a,q14sub q 
where q.p_code=a.code and q.min_date = a."Date";

create or replace view Q14(Code, BeginPrice, EndPrice, Change, Gain) as 
select q1.p1_code, q1.p1_pre_price as beginprice, q2.p2_after_price as endprice,q2.p2_after_price - q1.p1_pre_price as change, (q2.p2_after_price - q1.p1_pre_price)/q1.p1_pre_price * 100 as gain 
from q14sub1 q1, q14sub2 q2 where  q1.p1_code = q2.p2_code;



--15) For all the trading records in the ASX table, produce the following statistics as a database view (where Gain is measured in percentage). 
--    AvgDayGain is defined as the summation of all the daily gains (in percentage) then divided by the number of trading days (as noted above, 
--    the total number of days here should exclude the first trading day).

--    Creating a view to show code, min price, avg price, max price, min day gain, avg day gain, max day gain by using q7 view and finding the min,max
--    avg by using aggragation functions.

create or replace view Q15(Code, MinPrice, AvgPrice, MaxPrice, MinDayGain, AvgDayGain, MaxDayGain) as 
select q.code, min(q.price), avg(q.price), max(q.price), min(q.gain), avg(q.gain), max(q.gain) 
from q7 q 
group by q.code;



--16) Create a trigger on the Executive table, 
--    to check and disallow any insert or update of a Person in the Executive table to be an executive of more than one company. 

--   Creating a function checkstate which will return a trigger  and raise a exception if a person is already present in any of the company and if not
--   it will return new.
--   Creating a trigger which will run before executing the insert or update query on executive table .

create function checkState() returns trigger as $$
begin
if exists (select * from executive e where new.person=e.person) then
RAISE exception 'Person is already an executive of one company';
return null;
end if;
return new;
end
$$
language plpgsql;

create trigger checkState before insert or update on Executive for each row execute procedure checkState();



--17) Suppose more stock trading data are incoming into the ASX table. Create a trigger to increase the stock's rating (as Star's) to 5 when the 
--    stock has made a maximum daily price gain (when compared with the price on the previous trading day) in percentage within its sector. 
--    For example, for a given day and a given sector, if Stock A has the maximum price gain in the sector, its rating should then be updated to 5. 
--    If it happens to have more than one stock with the same maximum price gain, update all these stocks' ratings to 5. Otherwise, decrease the stock's 
--    rating to 1 when the stock has performed the worst in the sector in terms of daily percentage price gain. If 
--    there are more than one record of rating for a given stock that need to be updated, update (not insert) all these records. 

--    Creating a view q17sub to show date, code,sector,min price,, avg price, max price,, mingain, avg gain, max gain for all the companies.
--    Creating a view q17sub1 to show the sector date and max gain for every company.
--    Creating a view q17sub2 to show the code,date,sector,maxgain group by every sector.
--    Creating a view q17sub3 to show sector,date and min gain for all the company.
--    Creating a view q17sub4 to show the code,date,sector and mingain for every sector and everdate.
--    Creating fucntion to update the rating to 5 for the max gain and 1 for the least gain.
--    Creating a trigger on the asx table which will be on insert statement and put the max gain and min gain to 5 and 1 respectively.

create or replace view q17sub (p_date,p_code,p_sector,p_minprice,p_avgprice,p_maxprice,p_mingain,p_avggain,p_maxgain) as select q."Date", q.code,c.sector, min(q.price), avg(q.price), max(q.price), min(q.gain), avg(q.gain), max(q.gain) from q7 q,category c where q.code=c.code  group by q.code,q."Date",c.sector order by q."Date",q.code;

create or replace view q17sub1 as select p_sector,p_date,  max(p_maxgain) from q17sub group by p_sector,p_date order by p_date;

create or replace view q17sub2 as select q.p_code,q.p_date,q.p_sector,q.p_maxgain from q17sub q, q17sub1 q1 where q.p_sector=q1.p_sector and q.p_date=q1.p_date and q.p_maxgain=q1.max;

create or replace view q17sub3 as select p_sector,p_date,  min(p_mingain) from q17sub group by p_sector,p_date order by p_date;

create or replace view q17sub4 as select q.p_code,q.p_date,q.p_sector,q.p_mingain from q17sub q, q17sub3 q1 where q.p_sector=q1.p_sector and q.p_date=q1.p_date and q.p_mingain=q1.min;

create or replace function up_rating()
	returns trigger AS
	$$
	begin
	update rating set star=5 where code in (select p_code from q17sub2 
			   where p_date=NEW."Date");  
	update rating set star=1 where code in (select p_code from q17sub4 
			   where p_date=NEW."Date");
	return new;
	end
	$$  LANGUAGE plpgsql;
	
create trigger up_t_rating
	after insert on "asx"
	for each row execute procedure up_rating();



--18) Stock price and trading volume data are usually incoming data and seldom involve updating existing data. 
--    However, updates are allowed in order to correct data errors. All such updates (instead of data insertion) are logged and stored in the 
--    ASXLog table. Create a trigger to log any updates on Price and/or Voume in the ASX table and log these updates (only for update, not inserts) 
--    into the ASXLog table. Here we assume that Date and Code cannot be corrected and will be the same as their original, old values. 
--    Timestamp is the date and time that the correction takes place. 
--    Note that it is also possible that a record is corrected more than once, i.e., same Date and Code but different Timestamp.

--    Creating a function which will check the value whether it is the updating only volume, only price or both. 
--    It will insert the old data into the asx log table.
--    Creating a trigger to automatically insert the details into the asx log table whenever there is an update in asx table .

create or replace Function updateRating() returns trigger as $$
begin
	if TG_OP = 'UPDATE' and new.price is distinct from old.price and new.volume is distinct from old.volume then 
	INSERT  into asxlog values (now(),old."Date",old.code,new.volume,new.price);
	return new;
	end if;
	if TG_OP = 'UPDATE' and new.price is distinct from old.price then 
	INSERT  into asxlog values (now(),old."Date",old.code,old.volume,new.price);
	return new;
	end if;
	if TG_OP = 'UPDATE' and new.volume is distinct from old.volume then 
	INSERT  into asxlog values (now(),old."Date",old.code,new.volume,old.price);
	return new;	
	end if;
end;
$$ language plpgsql;

create trigger updateRatingTrigger after update on asx FOR EACH ROW EXECUTE PROCEDURE updateRating();
