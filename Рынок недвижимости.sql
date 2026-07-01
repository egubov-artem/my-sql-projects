/* Проект "Рынок недвижимости"
 * Автор: Егубов Артем
*/

-- Задача 1: Время активности объявлений
-- Определим аномальные значения (выбросы) по значению перцентилей:
WITH limits AS (
    SELECT
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats
),
-- Найдём id объявлений, которые не содержат выбросы, также оставим пропущенные данные:
filtered_id AS(
    SELECT id
    FROM real_estate.flats
    WHERE
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
    ),
 activity_categories AS(
	 SELECT *,
	     CASE
	     	WHEN days_exposition BETWEEN 1 AND 30 THEN 'до месяца'
	     	WHEN days_exposition BETWEEN 31 AND 90 THEN 'до трёх месяцев'
	     	WHEN days_exposition BETWEEN 91 AND 180 THEN 'до полугода'
	     	WHEN days_exposition > 180 THEN 'более полугода'
	     	WHEN days_exposition IS NULL THEN 'non category'
	     END AS activity_categories,
	     CASE 
	     	WHEN city = 'Санкт-Петербург' THEN 'Санкт-Петербург'
	     	ELSE 'ЛенОбл'
	     END AS category_place
	 FROM real_estate.flats
	 JOIN real_estate.advertisement USING (id)
	 JOIN real_estate.city USING (city_id)
	 JOIN real_estate.type USING (type_id)
	 WHERE id IN (SELECT * FROM filtered_id)
	 AND type  = 'город'
	 AND EXTRACT(YEAR FROM first_day_exposition) BETWEEN 2015 AND 2018
)
SELECT 
    category_place,
    activity_categories,
    COUNT(*) AS total_ads,
    ROUND(COUNT(*)::numeric / SUM(COUNT(*)) OVER(PARTITION BY category_place), 2) AS share_ads,
    ROUND(AVG(total_area::numeric), 2) AS avg_area,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_area)::numeric, 2) AS median_area,
    ROUND(AVG(last_price::numeric), 0) AS avg_price,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY last_price)::numeric, 0) AS median_price,
    ROUND(AVG(last_price::numeric / total_area::numeric), 0) AS avg_cost_meter,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY last_price::numeric / total_area::numeric)::numeric, 0) AS median_cost_meter,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rooms) AS median_num_rooms,
    ROUND(AVG(rooms::numeric), 2) AS avg_num_rooms,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY balcony) AS median_num_balconies,
    ROUND(AVG(balcony::numeric), 2) AS avg_num_balconies,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ceiling_height)::numeric, 2) AS median_ceiling_height,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY floors_total)::numeric, 2) AS median_floors_total,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY floor)::numeric, 2) AS median_floor,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY kitchen_area)::numeric, 2) AS median_kitchen_area,
    ROUND(AVG(airports_nearest::numeric), 0) AS avg_airports_nearest,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY parks_around3000) AS median_parks_around3000,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ponds_around3000) AS median_ponds_around3000
FROM activity_categories
GROUP BY category_place, activity_categories
ORDER BY category_place DESC, CASE activity_categories
        WHEN 'до месяца' THEN 1
        WHEN 'до трёх месяцев' THEN 2
        WHEN 'до полугода' THEN 3
        WHEN 'более полугода' THEN 4
        ELSE 5
    END;


-- Задача 2: Сезонность объявлений
-- Определим аномальные значения (выбросы) по значению перцентилей:
WITH limits AS (
    SELECT
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats
),
-- Найдём id объявлений, которые не содержат выбросы, также оставим пропущенные данные:
filtered_id AS(
    SELECT id
    FROM real_estate.flats
    WHERE
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
),
monthly_statistics AS (
    SELECT
        a.id,
        last_price,
        total_area,
        TO_CHAR(first_day_exposition, 'TMmon') AS month_publication,
        TO_CHAR(first_day_exposition + days_exposition::integer, 'TMmon') AS month_removal
    FROM real_estate.advertisement a
    JOIN real_estate.flats f USING (id)
    JOIN real_estate.type t USING (type_id)
    WHERE id IN (SELECT * FROM filtered_id)
	    AND type  = 'город'
	    AND EXTRACT(YEAR FROM first_day_exposition) BETWEEN 2015 AND 2018
),
publication_statistics AS (
    SELECT 
        month_publication AS month,
        COUNT(*) AS pub_total_ads,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_area)::numeric, 2) AS pub_median_area,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY last_price)::numeric, 0) AS pub_median_price
    FROM monthly_statistics
    GROUP BY month_publication
),
removal_statistics AS (
    SELECT 
        month_removal AS month,
        COUNT(*) AS rem_total_ads,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_area)::numeric, 2) AS rem_median_area,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY last_price)::numeric, 0) AS rem_median_price
    FROM monthly_statistics
    WHERE month_removal IS NOT NULL
    GROUP BY month_removal
)
SELECT
    p.month,
    RANK() OVER(ORDER BY pub_total_ads DESC) AS rank_pub,
    RANK() OVER(ORDER BY rem_total_ads DESC) AS rank_rem,
    pub_total_ads,
    ROUND(pub_total_ads / SUM(pub_total_ads) OVER() * 100, 2) AS per_pub_ads,
    rem_total_ads,
    ROUND(rem_total_ads / SUM(rem_total_ads) OVER() * 100, 2) AS per_rem_ads,
    pub_median_area,
    rem_median_area,
    pub_median_price,
    rem_median_price,
    ROUND(pub_median_price / pub_median_area::NUMERIC, 0) AS pub_median_cost_metr,
    ROUND(rem_median_price / rem_median_area::NUMERIC, 0) AS rem_median_cost_metr
FROM publication_statistics p
FULL JOIN removal_statistics r USING (month)
--ORDER BY pub_total_ads DESC 
ORDER BY rem_total_ads DESC;