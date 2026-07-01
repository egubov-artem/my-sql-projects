/* Проект "Анализ вакансий аналитика на hhru"
 * Автор: Егубов Артем
*/

-- Диапазон заработных плат:
SELECT
    ROUND(AVG(salary_from), 0) AS avg_salary_from,
    ROUND(AVG(salary_to), 0) AS avg_salary_to,
    MIN(salary_from) AS min_salary_from,
    MIN(salary_to) AS min_salary_to,
    MAX(salary_from) AS max_salary_from,
    MAX(salary_to) AS max_salary_to
FROM public.parcing_table
WHERE salary_from > 50
AND name LIKE '%Аналитик%' OR name LIKE '%аналитик%';

-- Средняя зарплата в категории «от» составляет около 103769 рублей, а  
-- в категории «до» — около 144391 рублей. Это указывает на то, что работодатели готовы платить
-- аналитикам данных и системным аналитикам в среднем около 120000 рублей. 
-- Минимальная предлагаемая зарплата начинается с 25000 рублей, а максимальная достигает 467500 рублей.

-- Регионы по кол-ву вакансий:
SELECT
    area,
    COUNT(*) AS total_vacancies
FROM public.parcing_table
WHERE name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
GROUP BY area
ORDER BY total_vacancies DESC;

-- Москва и Санкт-Петербург — лидеры по количеству вакансий. 
-- Это неудивительно, учитывая, что это крупнейшие города 
-- с развитой инфраструктурой и большим количеством компаний. 
-- В Екатеринбурге, Нижнем Новгороде, Владивосток, Казань и Новосибирск также значительное 
-- количество вакансий — это указывает на развитый рынок труда для аналитиков данных в этих регионах.

-- Компании по кол-ву вакансий:
SELECT
    employer,
    COUNT(*) AS total_vacancies
FROM public.parcing_table
WHERE name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
GROUP BY employer
ORDER BY total_vacancies DESC;

-- СБЕР предлагает 135 вакансий и является крупнейшим работодателем для аналитиков данных и 
-- системных аналитиков. Это может говорить о значительных инвестициях в аналитику и технологические решения
-- в компании. К тому же в банковской среде всегда нужны аналитики. Ozon, ВТБ
-- и другие крупные компании также активно ищут специалистов в области данных, 
-- что говорит о высоком спросе на аналитиков в крупных корпорациях. Вдруг и вы захотите не только
-- покупать на маркетплейсах, но и проанализировать, что другие покупают.

-- График работы по кол-ву вакансий:
SELECT
    schedule,
    COUNT(*) AS total
FROM public.parcing_table
WHERE name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
GROUP BY schedule
ORDER BY total DESC;

-- Большинство вакансий (1157) предлагают работу с полным днём. 
-- Однако значительное количество вакансий (229) также позволяет 
-- удалённую работу. Это указывает на то, что работодатели готовы быть
-- гибкими в современных условиях.

-- Тип занятости по кол-ву вакансий:
SELECT
    employment,
    COUNT(*) AS total
FROM public.parcing_table
WHERE name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
GROUP BY employment
ORDER BY total DESC;

-- Подавляющее большинство вакансий (1395) предлагают полную занятость.
-- Это указывает на то, что работодатели предпочитают нанимать 
-- аналитиков данных и системных аналитиков на постоянные позиции.
-- Возможно, дело в необходимости глубоко погружаться в проекты и
-- долго в них участвовать.

-- Распределение грейдов и средние данные по ним:
SELECT
    experience,
    COUNT(*) AS total_vacancies,
    ROUND(AVG(salary_from), 0) AS avg_salary_from,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_from) AS median_salary_from,
    ROUND(AVG(salary_to), 0) AS avg_salary_to,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_to) AS median_salary_to,
    MODE() WITHIN GROUP(ORDER BY schedule) AS most_common_schedule,
    MODE() WITHIN GROUP(ORDER BY employment) AS employment
FROM public.parcing_table
WHERE name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
GROUP BY experience
ORDER BY experience;

-- Наибольшее количество вакансий предназначено для специалистов с опытом от 1 до 3 лет (Junior+), 
-- что свидетельствует о высоком спросе на специалистов уже продвинутого уровня. 
-- Вакансий для Middle-специалистов (3–6 лет) также много, в то время как спрос 
-- на Senior-специалистов (6+ лет) крайне низкий, возможно, из-за узкого круга
-- специалистов с таким уровнем опыта или предпочитаемых долгосрочных позиций.
-- Однако важно понимать, что Senior-аналитиков могут чаще искать по другим каналам.
-- Также достаточно мало вакансий для специалистов без опыта (Junior), что говорит о сдержаном
-- спросе на таких претендентов. Возможно есть иные каналы для их привлечения, в том числе через стажировки.

-- Заметен четкий рост зарплаты исходя из опыта специалиста: Junior+ в среднем имеет зарплату на 25%
-- выше, чем Junior, а Middle почти в 2 раза выше, чем Junior+.
-- При этом, исходя из медианных значений, средние арифметические значения несколько завышены небольшим 
-- кол-вом выбросов вакансий с зарплатной заметно выше рынка. Вплоть до того, что может создаться 
-- впечатление, будто Middle-специалист зарабатывает больше Senior. По медианным значениям это,
-- очевидно, не так.

-- Основные работодатели и средние данные по ним:
SELECT
    employer,
    COUNT(*) AS total_vacancies,
    ROUND(AVG(salary_from), 0) AS avg_salary_from,
    ROUND(AVG(salary_to), 0) AS avg_salary_to,
    employment,
    schedule
FROM public.parcing_table
WHERE name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
GROUP BY employer, employment, schedule
ORDER BY total_vacancies DESC
LIMIT 20;

-- СБЕР выделяется как основной работодатель для аналитиков данных и системных аналитиков 
-- с 131 вакансиями и средней зарплатой от 110583 рублей до 73333 рублей. 
-- Средняя зарплата «до» ниже средней зарплаты «от» — скорее всего, СБЕР часто пишет сумму «до», не указываю сумму «от». 
-- Основной тип занятости в СБЕР — полная занятость с полным рабочим днём. Значит, компания предпочитает длительное сотрудничество с сотрудниками.
-- Банк ВТБ (ПАО) и Ozon также предлагают достаточно вакансий с аналогичными условиями занятости.
-- Это подтверждает тенденцию крупных компаний нанимать аналитиков данных на полную занятость с фиксированным рабочим графиком.
-- Если вам подходят такие условия, то потенциальных работодателей для вас будет много.

-- Навыки для Junior:
SELECT
  key_skills,
  COUNT(*) AS demand_count
FROM (
  SELECT key_skills_1 AS key_skills FROM public.parcing_table WHERE experience = 'Junior (no experince)' AND name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
  UNION ALL
  SELECT key_skills_2 AS key_skills FROM public.parcing_table WHERE experience = 'Junior (no experince)' AND name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
  UNION ALL
  SELECT key_skills_3 AS key_skills FROM public.parcing_table WHERE experience = 'Junior (no experince)' AND name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
  UNION ALL
  SELECT key_skills_4 AS key_skills FROM public.parcing_table WHERE experience = 'Junior (no experince)' AND name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
) AS t
WHERE key_skills IS NOT NULL AND key_skills != ''
GROUP BY key_skills
ORDER BY demand_count DESC;

-- Основные хард-навыки для Junior специалиста это SQL, Анализ данных и Python.
-- Исходя из этого, работодатели ожидают увидеть начинающих специалистов,
-- которые уже умеют добывать данные из базы данных, очищать их и превращать
-- в полезные инсайты, а не просто работать с уже готовой сводкой.

-- Навыки для Junior+:
SELECT
  key_skills,
  COUNT(*) AS demand_count
FROM (
  SELECT key_skills_1 AS key_skills FROM public.parcing_table WHERE experience = 'Junior+ (1-3 years)' AND name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
  UNION ALL
  SELECT key_skills_2 AS key_skills FROM public.parcing_table WHERE experience = 'Junior+ (1-3 years)' AND name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
  UNION ALL
  SELECT key_skills_3 AS key_skills FROM public.parcing_table WHERE experience = 'Junior+ (1-3 years)' AND name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
  UNION ALL
  SELECT key_skills_4 AS key_skills FROM public.parcing_table WHERE experience = 'Junior+ (1-3 years)' AND name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
) AS t
WHERE key_skills IS NOT NULL AND key_skills != ''
GROUP BY key_skills
ORDER BY demand_count DESC;

-- Для специалиста Junior+ основные требования к хард-навыкам такие же, как и для Junior.

-- Навыки для Middle:
SELECT
  key_skills,
  COUNT(*) AS demand_count
FROM (
  SELECT key_skills_1 AS key_skills FROM public.parcing_table WHERE experience = 'Middle (3-6 years)' AND name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
  UNION ALL
  SELECT key_skills_2 AS key_skills FROM public.parcing_table WHERE experience = 'Middle (3-6 years)' AND name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
  UNION ALL
  SELECT key_skills_3 AS key_skills FROM public.parcing_table WHERE experience = 'Middle (3-6 years)' AND name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
  UNION ALL
  SELECT key_skills_4 AS key_skills FROM public.parcing_table WHERE experience = 'Middle (3-6 years)' AND name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
) AS t
WHERE key_skills IS NOT NULL AND key_skills != ''
GROUP BY key_skills
ORDER BY demand_count DESC;

-- Для специалиста уровня Middle уже чаще упоминают Python, нежели просто Анализ данных.

-- Навыки для Senior:
SELECT
  key_skills,
  COUNT(*) AS demand_count
FROM (
  SELECT key_skills_1 AS key_skills FROM public.parcing_table WHERE experience = 'Senior (6+ years)' AND name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
  UNION ALL
  SELECT key_skills_2 AS key_skills FROM public.parcing_table WHERE experience = 'Senior (6+ years)' AND name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
  UNION ALL
  SELECT key_skills_3 AS key_skills FROM public.parcing_table WHERE experience = 'Senior (6+ years)' AND name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
  UNION ALL
  SELECT key_skills_4 AS key_skills FROM public.parcing_table WHERE experience = 'Senior (6+ years)' AND name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
) AS t
WHERE key_skills IS NOT NULL AND key_skills != ''
GROUP BY key_skills
ORDER BY demand_count DESC;

-- Аналогичная ситуация и для специалиста уровня Senior.

-- Софт-навыки для аналитика:
SELECT
  soft_skills,
  COUNT(*) AS demand_count
FROM (
  SELECT soft_skills_1 AS soft_skills FROM public.parcing_table WHERE name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
  UNION ALL
  SELECT soft_skills_2 AS soft_skills FROM public.parcing_table WHERE name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
  UNION ALL
  SELECT soft_skills_3 AS soft_skills FROM public.parcing_table WHERE name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
  UNION ALL
  SELECT soft_skills_4 AS soft_skills FROM public.parcing_table WHERE name LIKE '%Аналитик%' OR name LIKE '%аналитик%'
) AS t
WHERE soft_skills IS NOT NULL AND soft_skills != ''
GROUP BY soft_skills
ORDER BY demand_count DESC;

-- Наиболее часто упоминаемые софт-навыки для аналитика это документация, коммуникация и аналитическое мышление.
-- Здесь прослеживается желание работодателей найти универсального специалиста, который сможет легко встроится в
-- рабочий процесс, работать в условиях неопределенности и который послужит мостом между данными и бизнесом.




