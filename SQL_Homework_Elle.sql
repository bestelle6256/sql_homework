-- 1a. Display the first and last names of all actors from the table `actor`.
use sakila;
SELECT DISTINCT first_name, last_name
FROM actor;


-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

SELECT CONCAT(first_name," ",last_name) AS actor_name
FROM actor;

-- 2a. Find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
describe actor;
SELECT actor_id,first_name,last_name 
FROM actor
WHERE first_name LIKE '%Joe%';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT actor_id,first_name,last_name 
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:
SELECT actor_id,first_name,last_name 
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
select country_id,country 
from country
where country IN ('Afghanistan', 'Bangladesh', 'China');


-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` and use the data type `BLOB` 
-- (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

-- BLOB = Binary Large Object; it's a pointor (handle) to the large files (i.e. videos etc.)

select * from actor; -- actor_id, first_name, last_name;
create table actor2 as select * from actor;
select * from actor2;
alter table actor2
add column description BLOB NOT NULL;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

ALTER TABLE actor2
DROP COLUMN description;
select * from actor2;


-- * 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name,count(first_name) AS num_of_actors
FROM actor
GROUP BY last_name;

-- * 4b. List last names of actors and the number of actors who have that last name, but only for names 
-- that are shared by at least two actors

SELECT last_name,count(first_name) AS num_of_actors
FROM actor
GROUP BY last_name
HAVING count(first_name)>1;

-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
-- Write a query to fix the record.

UPDATE actor2
SET first_name = "HARPO"
WHERE last_name="WILLIAMS" AND first_name = "GROUCHO";

-- check table
SELECT first_name,last_name
FROM actor2
WHERE last_name = "WILLIAMS";

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
-- It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

UPDATE actor2
SET first_name = "GROUCHO"
WHERE last_name="WILLIAMS" AND first_name = "HARPO";

-- check
SELECT first_name,last_name
FROM actor2
WHERE last_name = "WILLIAMS";

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
-- Use the tables `staff` and `address`:

select * from address; -- address_id, address, district, city_id
select * from staff; -- staff_id,first_last_name, address_id

SELECT s.first_name,s.last_name,a.address
FROM staff s
JOIN address a
ON (s.address_id=a.address_id);

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
-- Use tables `staff` and `payment`.

select * from staff; -- staff_id,first_last_name, address_id;
select * from payment; -- payment_id, customer_id, staff_id, rental_id, amount;

select p.staff_id,s.first_name,s.last_name,sum(p.amount) AS total_by_staff
from payment as p
join staff as s
on (p.staff_id=s.staff_id)
WHERE payment_date LIKE "2005-08%"
group by p.staff_id;

-- * 6c. List each film and the number of actors who are listed for that film. 
-- Use tables `film_actor` and `film`. Use inner join.

select * from film_actor; -- actor_id, film_id
select * from film; -- film_id, title

select f.film_id,f.title,count(fa.actor_id) as num_of_actors
from film as f
inner join film_actor as fa
on f.film_id = fa.film_id
group by film_id;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select * from inventory; -- inventory_id, film_id, store_id;
select * from film; -- film_id, title

select f.film_id, f.title, count(i.inventory_id) as num_of_copies
from film as f
join inventory as i
on f.film_id=i.film_id
WHERE f.title="Hunchback Impossible"
group by f.film_id;

-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
select * from payment; -- payment_id, customer_id, staff_id, rental_id, amount;
select * from customer; -- customer_id, store_id, first_name, email, address_id;

select c.last_name, c.customer_id, sum(p.amount)
from customer as c
join payment as p
on (c.customer_id = p.customer_id)
group by c.customer_id
order by c.last_name;

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

select * from film; -- title,language_id
select * from language; -- language_id, name

select title, f.language_id
from film as f
where title LIKE "K%" OR title LIKE "Q%" AND f.language_id IN 
(
	select language_id
    from language
    where name = "English"
);

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

select * from film_actor; -- actor_id, film_id
select * from film; -- film_id, title
select * from actor; -- actor_id, first_name, last_name;

select actor_id, first_name, last_name
from actor
where actor_id IN 
(
	select actor_id
	from film_actor
	where film_id IN 
	(
		select film_id
		from film
		where title = "Alone Trip"
	)
);

-- * 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

select * from customer; -- customer_id, first_name, last_name, email, address_id
select * from address; -- address_id, city_id
select * from city; -- city_id, country_id
select * from country; -- country_id, country

select customer_id,first_name,last_name,email,address_id
from customer
where address_id IN
(
	select address_id
	from address
	where city_id IN 
	(
		select city_id
		from city
		where country_id = 
		(
			select country_id -- country_id is 20
			from country
			where country = "Canada"
		)
	)
);

-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.
select * from film; -- film_id, title
select * from film_category; -- film_id, category_id
select * from category; -- category_id, name
-- film_id, title, category_id, category_name

select f.film_id, f.title, fc.category_id, c.name as category_name
from film as f
join film_category as fc
on f.film_id = fc.film_id
join category as c
on fc.category_id = c.category_id
where c.name="Family";


-- * 7e. Display the most frequently rented movies in descending order.
select * from rental; -- rental_id, inventory_id
select * from inventory; -- inventory_id, film_id;
select * from film; -- film_id, title

-- film_id, title, count_of_rentals

select f.film_id, f.title, count(r.rental_id) as num_of_rentals
from film as f
join inventory as i
on f.film_id = i.film_id
join rental as r
on i.inventory_id = r.inventory_id
group by f.film_id
order by num_of_rentals DESC;

-- * 7f. Write a query to display how much business, in dollars, each store brought in.
select * from payment; -- rental_id, amount 
select * from rental; -- rental_id, inventory_id, staff_id
select * from inventory; -- inventory_id, store_id

-- rental_id, amount, store_id
select count(p.rental_id) as num_of_rentals,sum(p.amount) as total_amt_by_store,i.store_id
from payment as p
join rental as r
on p.rental_id = r.rental_id
join inventory as i
on r.inventory_id = i.inventory_id
group by store_id;

-- select * from store; -- store_id, manager_staff_id

-- * 7g. Write a query to display for each store its store ID, city, and country.
select * from store; -- store_id, address_id
select * from address; -- address_id, address, city_id
select * from city; -- city_id, city, country_id
select * from country; -- country id, country

select s.store_id,s.address_id,a.address, a.city_id, c.city, ct.country
from store as s
join address as a
on s.address_id = a.address_id
join city as c
on a.city_id = c.city_id
join country as ct
on c.country_id = ct.country_id;


-- * 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select * from payment; -- rental_id, amount
select * from rental; -- rental_id, inventory_id,
select * from inventory; -- inventory_id, film_id
select * from film_category; -- film_id, category_id
select * from category; -- category_id, name

select c.category_id, c.name as category_name, sum(p.amount) as revenue
from payment as p
join rental as r
on p.rental_id=r.rental_id
join inventory as i
on r.inventory_id = i.inventory_id
join film_category as fc
on i.film_id = fc.film_id 
join category as c
on fc.category_id = c.category_id
group by category_name;

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.

create view top_five as 
select c.category_id, c.name as category_name, sum(p.amount) as revenue
from payment as p
join rental as r
on p.rental_id=r.rental_id
join inventory as i
on r.inventory_id = i.inventory_id
join film_category as fc
on i.film_id = fc.film_id 
join category as c
on fc.category_id = c.category_id
group by category_name;

-- * 8b. How would you display the view that you created in 8a?

select * from top_five;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

drop view top_five;