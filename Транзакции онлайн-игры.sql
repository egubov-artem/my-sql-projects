/* Проект "Транзакции онлайн-игры"
 * Цель проекта: изучить влияние характеристик игроков и их игровых персонажей 
 * на покупку внутриигровой валюты «райские лепестки», а также оценить 
 * активность игроков при совершении внутриигровых покупок
 * 
 * Автор: Егубов Артем
*/

-- Часть 1. Исследовательский анализ данных
-- Задача 1. Исследование доли платящих игроков

-- 1.1. Доля платящих пользователей по всем данным:
WITH paying_users AS (  
    SELECT
        COUNT(*) AS total_users,
        COUNT(DISTINCT CASE WHEN payer = 1 THEN id END) AS total_paying_users
    FROM fantasy.users u
)
SELECT
    *,
    ROUND(total_paying_users / total_users::NUMERIC, 4) AS paying_users_share
FROM paying_users;

-- 1.2. Доля платящих пользователей в разрезе расы персонажа:
WITH user_race_data AS (
    SELECT
        r.race,
        COUNT(*) AS total_users,
        COUNT(CASE WHEN u.payer = 1 THEN u.id END) AS total_paying_users
    FROM fantasy.users u
    JOIN fantasy.race r ON u.race_id = r.race_id
    GROUP BY r.race
)
SELECT
    race,
    total_paying_users,
    total_users,
    ROUND(total_paying_users::NUMERIC / total_users, 4) AS paying_users_share
FROM user_race_data
ORDER BY paying_users_share DESC;

-- Задача 2. Исследование внутриигровых покупок
-- 2.1. Статистические показатели по полю amount:
SELECT
    COUNT(*) AS total_purchases,
    SUM(amount) AS purchase_amount,
    MIN(amount) AS min_purchase,
    MAX(amount) AS max_purchase,
    ROUND(AVG(amount)::numeric, 2) AS avg_purchase,
    PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY amount) AS median_purchase,
    ROUND(STDDEV(amount)::NUMERIC, 2) AS std_dev_purchase
FROM fantasy.events;

-- 2.2: Аномальные нулевые покупки:
WITH zero_purchases AS (
    SELECT COUNT(*) as count
    FROM fantasy.events
    WHERE amount = 0
)
SELECT 
    zp.count AS total_zero_purchases,
    ROUND(zp.count::NUMERIC / (SELECT COUNT(*) FROM fantasy.events), 4) AS zero_purchases_share
FROM zero_purchases zp;

-- 2.3: Популярные эпические предметы:
WITH total_stats AS (
    SELECT
        COUNT(*) AS total_purchases_all,
        COUNT(DISTINCT id) AS total_paying_users
    FROM fantasy.events
    WHERE amount <> 0
),
item_stats AS (
    SELECT
        i.game_items,
        COUNT(*) AS total_purchases,
        COUNT(DISTINCT e.id) AS unique_buyers
    FROM fantasy.events e
    JOIN fantasy.items i USING(item_code)
    WHERE amount <> 0
    GROUP BY i.game_items
)
SELECT
    game_items,
    total_purchases,
    ROUND(total_purchases::numeric / total_purchases_all, 4) AS percentage_share,
    ROUND(unique_buyers::numeric / total_paying_users, 4) AS percentage_paying_users
FROM item_stats, total_stats
ORDER BY total_purchases DESC;

-- Часть 2. Решение ad hoc-задачи
-- Задача: Зависимость активности игроков от расы персонажа:
WITH user_data AS (
    SELECT
        r.race,
        u.id,
        u.payer,
        e.transaction_id,
        e.amount
    FROM fantasy.users u
    JOIN fantasy.race r USING(race_id)
    LEFT JOIN fantasy.events e ON u.id = e.id AND e.amount <> 0
),
aggregated_data AS (
    SELECT
        race,
        COUNT(DISTINCT id) AS total_users,
        COUNT(DISTINCT CASE WHEN payer = 1 AND transaction_id IS NOT NULL THEN id END) AS paying_users,
        COUNT(DISTINCT CASE WHEN transaction_id IS NOT NULL THEN id END) AS purchasing_users,
        COUNT(transaction_id) AS total_purchases,
        SUM(amount) AS sum_purchases
    FROM user_data
    GROUP BY race
)
SELECT
    race,
    total_users,
    purchasing_users,
    ROUND(purchasing_users::NUMERIC / total_users, 4) AS purchasing_users_share,
    ROUND(paying_users::NUMERIC / purchasing_users, 4) AS paying_users_share_among_purchasing,
    ROUND(total_purchases::NUMERIC / purchasing_users, 0) AS avg_purchases,
    ROUND(sum_purchases::NUMERIC / total_purchases, 2) AS avg_cost,
    ROUND(sum_purchases::NUMERIC / purchasing_users, 2) AS avg_total_cost
FROM aggregated_data
ORDER BY purchasing_users DESC;
