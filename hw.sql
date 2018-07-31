USE sakila;

SELECT * FROM actor;
/*
1a. Display the first and last names of all actors from the table actor.
*/
SELECT first_name, last_name
FROM actor;
#1b... 
#SELECT CONCAT_WS(" ", `first_name`, `last_name`) AS `Actor Name` FROM `actor`

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?


SELECT actor_id, first_name, last_name FROM actor
WHERE first_name ='Joe';


#2b. Find all actors whose last name contain the letters GEN:


SELECT actor_id, first_name, last_name, last_update FROM actor
WHERE last_name LIKE  "%G%E%N%";

# 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name, last_update FROM actor
WHERE last_name LIKE  "%L%I%"
ORDER BY last_name, first_name;

# 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
#SELECT * FROM  country

SELECT *
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh',  'China');

# 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant)

select * From actor;




ALTER TABLE actor
Add description BLOB;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

ALTER TABLE actor
DROP  description;


# 4a. List the last names of actors, as well as how many actors have that last name.

select last_name,
Count(*) as Count
from actor
 Group by last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors


select last_name,
Count(*) as Count
from actor
 Group by last_name
 HAVING Count >=2;
 
 # 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
 

 Update   actor
 SET first_name ='HARPO'
 where first_name ='GROUCHO' ANd last_name = 'WILLIAMS';


#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
 
  Update   actor SET first_name ='HARPO' where first_name ='HARPO' ANd last_name = 'WILLIAMS';


#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
DESCRIBE  sakila.address

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT  first_name, last_name, address
 FROM  staff LEFT JOIN address ON staff.address_id = address.address_id;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.


SELECT *
FROM staff; -- staff id is coomon 

SELECT *
FROM payment; 

SELECT first_name, last_name, SUM(amount)
FROM staff s
INNER JOIN payment p
ON s.staff_id = p.staff_id
WHERE payment_date LIKE '2005%'
GROUP BY p.staff_id
ORDER BY last_name ASC;


#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, COUNT(actor_id) AS number_of_actors
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY title;


#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT *
FROM inventory;

SELECT title, COUNT(inventory_id)
FROM film f
INNER JOIN inventory i 
ON f.film_id = i.film_id
WHERE title = "Hunchback Impossible";

# 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer_id, rt.last_name, SUM(amount) 
FROM payment AS lt
JOIN customer AS rt
USING(customer_id)
GROUP BY customer_id
ORDER BY last_name;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.



SELECT title FROM film
WHERE language_id in
	(SELECT language_id 
	FROM language
	WHERE name = "English" )
AND (title LIKE "K%") OR (title LIKE "Q%");

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT last_name, first_name
FROM actor
WHERE actor_id in
	(SELECT actor_id FROM film_actor
	WHERE film_id in 
		(SELECT film_id FROM film
		WHERE title = "Alone Trip"));
        
        
#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT first_name, last_name, email
FROM customer
JOIN address
USING (address_id)
JOIN city
USING(city_id)
JOIN country
USING(country_id)
WHERE country = "Canada";

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

    
SELECT title, category
FROM film_list
WHERE category = 'Family';


# 7e. Display the most frequently rented movies in descending order.

SELECT i.film_id, f.title, COUNT(r.inventory_id)
FROM inventory i
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
INNER JOIN film_text f 
ON i.film_id = f.film_id
GROUP BY r.inventory_id
ORDER BY COUNT(r.inventory_id) DESC;


#7f. Write a query to display how much business, in dollars, each store brought in.


SELECT store_id, sum(amount) AS $rev
FROM payment
JOIN staff
using(staff_id)
GROUP BY store_id;

#7g. Write a query to display for each store its store ID, city, and country.

SELECT store_id, city, country 
FROM store
INNER JOIN address
USING(address_id)
INNER JOIN city
USING(city_id)
INNER JOIN country
USING(country_id); 

#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT category_id, category.name , sum(amount) as rev
From payment
Join rental
using(rental_id)
JOIN inventory
using(inventory_id)
JOIN film_category
USING(film_id)
JOIN category
USING (category_id)
GROUP BY category_id
ORDER BY rev DESC
LIMIT 5;

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres AS

SELECT category_id, category.name , sum(amount) as rev
From payment
Join rental
using(rental_id)
JOIN inventory
using(inventory_id)
JOIN film_category
USING(film_id)
JOIN category
USING (category_id)
GROUP BY category_id
ORDER BY rev DESC
LIMIT 5;

Select * from top_five_genres


#8b. How would you display the view that you created in 8a?
SELECT * 
FROM top_five_genres;


# 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;