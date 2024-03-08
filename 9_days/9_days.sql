--
--	사각형 출력
--

WITH loop_table AS 
	(
		SELECT square
			FROM pg_catalog.generate_series(1, 4) AS square
	)
SELECT 
	repeat('*', 5)
	FROM loop_table;
	
--
--	1 부터 10 까지의 합

WITH loop_table AS
(
	SELECT num
		FROM generate_series(1, 10) num
)
SELECT sum(num)
	FROM loop_table
	
--	e
	
	
--	1 부터 10 까지 짝수만 출력
--

SELECT 
	array_agg(n) 짝수 
	FROM pg_catalog.generate_series(1, 10) n 
	WHERE mod(n, 2) = 0;

--	1 부터 10 까지 소수만 출력
--
WITH 
loop_table AS (
	SELECT n AS n	
		FROM pg_catalog.generate_series(1, 10) n
)
SELECT 
	t1.n
FROM loop_table t1, loop_table t2
WHERE mod(t1.n, t2.n) = 0
GROUP BY t1.n
HAVING count(t1.n) = 2

--	최대 공약수
--

WITH
t1 AS (
	SELECT 16 n1, 24 n2
),
t2 AS (
	SELECT n
		FROM pg_catalog.generate_series(1, 24) n 
)
SELECT max(n) 
	FROM t1, t2
	WHERE
		mod(n1, t2.n) = 0 AND
		mod(n2, t2.n) = 0 


--	최소 공배수
--
		
WITH 
t1 AS (
	SELECT 16 n1, 24 n2
),
t2 AS (
	SELECT n
		FROM pg_catalog.generate_series(1, 24) n
)
SELECT
	n1, n2, (n1 / max(n)) * (n2 / max(n)) * max(n) 최대공약수
	FROM t1, t2
	WHERE
		mod(t1.n1, t2.n) = 0 AND 
		mod(t1.n2, t2.n) = 0
	GROUP BY n1, n2;

--	피타고라스 정리
--	직각삼각형을 구하는 공식

SELECT CASE
	WHEN power(3, 2) + power(4, 2) = power(5, 2) THEN '직각삼각형'
	ELSE '직각삼각형 아님'
END; 

--	몬테카를로 알고리즘
--	원주율 구하기
--	안된다..

SELECT 
	sum(
		CASE 
			WHEN (power(n1, 2) + power(n2, 2)) <= 1 THEN 1	
			ELSE 0
		END 
	) / 100000 * 4 AS "원주율"
FROM (
	SELECT 
		random() * 1 AS n1,
		random() * 1 AS n2
	FROM 
		generate_series(1, 100000)
)

--
--	오일러 상수 자연상수 구하기
--	이것도 안된다. 내가 수학적 지식이 부족해서 수학공부를 하면서 알아봐야겠다..

WITH loop_table AS (
	SELECT n
		FROM pg_catalog.generate_series(0, 1000000) n
)
SELECT n, RESULT
	FROM (
		SELECT n, power((1 + 1 / n), n) AS RESULT 
			FROM loop_table
	)
	WHERE
		n = 1000000;