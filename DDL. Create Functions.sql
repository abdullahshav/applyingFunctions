DROP VIEW IF EXISTS sales_revenue_by_category_qtr;

CREATE OR REPLACE VIEW sales_revenue_by_category_qtr AS
SELECT c.name AS category, SUM(p.amount) AS revenue
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE DATE_PART('quarter', p.payment_date) = DATE_PART('quarter', CURRENT_DATE)
GROUP BY c.name
HAVING SUM(p.amount) > 0;

------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(quarter DATE)
RETURNS TABLE (category VARCHAR(25), revenue NUMERIC(5,2)) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM sales_revenue_by_category_qtr;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------
-- Create the procedure language function "new_movie"
CREATE OR REPLACE FUNCTION new_movie(movie_title TEXT)
RETURNS VOID AS $$
DECLARE
    new_film_id INT;
    current_year INT;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM language WHERE name = 'Klingon') THEN
        RAISE EXCEPTION 'Language "Klingon" does not exist in the language table.';
    END IF;

    SELECT nextval('film_film_id_seq') INTO new_film_id;

    SELECT DATE_PART('year', current_date) INTO current_year;

    INSERT INTO film (film_id, title, rental_rate, rental_duration, replacement_cost, release_year, language_id)
    VALUES (new_film_id, movie_title, 4.99, 3, 19.99, current_year, (SELECT language_id FROM language WHERE name = 'Klingon'));
END;
$$ LANGUAGE plpgsql;
