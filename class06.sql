#class06
use sakila;

#List all the actors that share the last name. Show them in order
SELECT first_name, last_name
FROM actor
WHERE last_name IN (
    SELECT last_name
    FROM actor
    GROUP BY last_name
    HAVING COUNT(*) > 1
)
ORDER BY last_name;


#Find actors that don't work in any film   / 		i!=n
SELECT first_name, last_name
FROM actor
WHERE NOT EXISTS (
        SELECT *
        FROM film_actor
        WHERE
            actor.actor_id = film_actor.actor_id
    );
   

#Find customers that rented only one film
SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id IN (
  SELECT customer_id
  FROM rental
  GROUP BY customer_id
  HAVING COUNT(*) = 1
);


#Find customers that rented more than one film
SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id IN (
  SELECT customer_id
  FROM rental
  GROUP BY customer_id
  HAVING COUNT(*) > 1
);


#List the actors that acted in 'BETRAYED REAR' or in 'CATCH AMISTAD'
SELECT actor.actor_id, actor.first_name, actor.last_name
FROM actor
WHERE actor.actor_id IN (
  SELECT film_actor.actor_id
  FROM film_actor
  JOIN film ON film_actor.film_id = film.film_id
  WHERE film.title IN ('BETRAYED REAR', 'CATCH AMISTAD')
);


#List the actors that acted in 'BETRAYED REAR' but not in 'CATCH AMISTAD'
SELECT actor.actor_id, actor.first_name, actor.last_name
FROM actor
WHERE actor.actor_id IN (
  SELECT film_actor.actor_id
  FROM film_actor
  JOIN film ON film_actor.film_id = film.film_id
  WHERE film.title = 'BETRAYED REAR'
)
AND actor.actor_id NOT IN (
  SELECT film_actor.actor_id
  FROM film_actor
  JOIN film ON film_actor.film_id = film.film_id
  WHERE film.title = 'CATCH AMISTAD'
);


#List the actors that acted in both 'BETRAYED REAR' and 'CATCH AMISTAD'
SELECT actor.actor_id, actor.first_name, actor.last_name
FROM actor
WHERE actor.actor_id IN (
  SELECT film_actor.actor_id
  FROM film_actor
  JOIN film ON film_actor.film_id = film.film_id
  WHERE film.title = 'BETRAYED REAR'
)
AND actor.actor_id IN (
  SELECT film_actor.actor_id
  FROM film_actor
  JOIN film ON film_actor.film_id = film.film_id
  WHERE film.title = 'CATCH AMISTAD'
)


#List all the actors that didn't work in 'BETRAYED REAR' or 'CATCH AMISTAD'
SELECT actor.actor_id, actor.first_name, actor.last_name
FROM actor
WHERE actor.actor_id NOT IN (
  SELECT film_actor.actor_id
  FROM film_actor
  JOIN film ON film_actor.film_id = film.film_id
  WHERE film.title = 'BETRAYED REAR'
  OR film.title = 'CATCH AMISTAD'
);


