--
--	rownum
--

-- 	postgresql 에는 rownum 이 없다
--	rownum 이 없으므로 직접 구현해야 한ㄷ	
--
-- 	앞에서 배운 row_number 를 사용하여 각 순서를 지정하고
--	limit 을 사용하여 원하는 개수만큼 자른다

SELECT 
	ROW_NUMBER() OVER() AS rownum, 
	e.employee_id,
	e.name,
	e.dept_name
FROM emp e
LIMIT 5;

--
--	Simple TOP-n Queries
--

--	연봉이 높은 사원 순으로 사원 번호, 이름, 직업, 연봉을 4개의 행으로 
--	제한해서 출력

SELECT
	ROW_NUMBER () over() AS num,
	e.employee_id, 
	e.name,
	e.dept_name,
	e.amount
FROM emp e
ORDER BY e.amount DESC FETCH FIRST 4 ROWS ONLY;

--	SQL 의 TOP-N Query 라고 한다
--	정렬된 결과로 부터 위쪽 또는 아래쪽의 N 개의 행을 반환하는 쿼리이다
--	
--	단순하게 limit 을 하면 되지 않을까 싶은데 다음의 쿼리도 사용가능하다
--
--	월급이 높은 사원들중 20% 에 해당하는 사원만 출력

SELECT 
	ROW_NUMBER () over() AS num,
	e.employee_id, 
	e.name,
	e.dept_name,
	e.amount
FROM emp e
ORDER BY e.amount DESC
	FETCH FIRST 20 PERCENT ROWS ONLY;
	-- SQL Error [42601]: ERROR: syntax error at or near "PERCENT"

--	위의 에러가 난다
--	postgresql 에서는 percent 사용이 안된다.
--	같은 상황을 구현하려면 다음처럼 해야한다

SELECT 
	ROW_NUMBER () over() AS num,
	em.pct_rank,
	em.employee_id, 
	em.name,
	em.dept_name,
	em.amount
FROM (
	SELECT
		percent_rank() OVER (ORDER BY e.amount) AS pct_rank,
		e.employee_id, 
		e.name,
		e.dept_name,
		e.amount
	FROM
		emp e
) AS em
WHERE  
	pct_rank >= 0.80;

--	percent_rank 를 사용하여 e.amount 를 오름차순으로 기준으로,
--	값의 퍼센트를 구한다
--
--	그리고 where 절에서 구한 퍼센트가 0.8 보다 크거나 같으면 상위 20% 임을 알 수 있다
--
-- with ties 옵션을 사용하면, N 번째 행의 값과 동일하면 같이 출력된다

SELECT 
	e.employee_id, 
	e."name",
	e.dept_name ,
	e.amount
FROM
	emp e
ORDER BY e.amount
	FETCH FIRST 2 ROWS WITH TIES; 

--	offset 을 사용하여 출력이 되는 행의 위치를 고정한다

SELECT 
	ROW_NUMBER () over() AS num,
	e.employee_id, 
	e."name",
	e.dept_name ,
	e.amount
FROM
	emp e
ORDER BY e.amount DESC
	OFFSET 9 ROWS; 

-- 	num 이 10 부터 있는것을 볼 수있다	
--
--	10 번째 행부터 끝까지 출력하므로, FETCH 를 사용하여 10 번째 행부터 2 개행을 출력해본다

SELECT 
	ROW_NUMBER () OVER () AS num,
	e.employee_id, 
	e."name",
	e.dept_name ,
	e.amount
FROM
	emp e
ORDER BY e.amount DESC
	OFFSET 9
	FETCH FIRST 2 ROWS ONLY;
	
--
--	10 과 11 번째 행을 출력한다

--
--	EQUI JOIN
--
--	department_employee 와 employee, department 를 조인하여
--	부서 명과 직원 명을 출력하라

SELECT 
	e.first_name || ' ' || e.last_name name,
	d.dept_name 
FROM department_employee de, employee e , department d
WHERE
	de.employee_id = e.id AND  de.department_id = d.id;

--	서로 다른 테이블에 있는 컬럼들을 하나의 결과로 
--	출력하려면 JOIN 을 사용한다
--
--	조인조건을 충족하기 위해 where 절을 사용하여 조인해 준다 
--	만약 조인조건이 맞지 않다면, 데카르트 곱에 의해 모든 경우의 수를 처리한다
--
--	다음은 직원과 모든 부서의 쌍으로 출력된다

SELECT 
	e.first_name || ' ' || e.last_name name,
	d.dept_name 
FROM employee e , department d;

--	원래 조인하는 방식과는 약간 다르게 처리된다
--	이러한 조인을 EQUI JOIN 이라고 한다
--	조인 조건이 equal(같다면) 이는 EQUI JOIN 이다.
--	다음은 모든 개발자 사원을 출력한다

SELECT 
	e.first_name || ' ' || e.last_name name,
	d.dept_name 
FROM department_employee de, employee e , department d
WHERE
	de.employee_id = e.id AND
	de.department_id = d.id AND
	d.dept_name = 'Development';

--
--	NON EQUI JOIN
--

--	employyes 테이블과 salary 테이블을 조인하고, 이름, 연봉 을 출력한다
--	마땅한 테이블이 없다
--	일단 NON EQUI JOIN 같은경우, 조인될수 있는 조건이 없지만, 같은 이름의 컬럼이 존재한다면
--	같은 이름의 컬럼을 사용하여, 조인한다

--
--	OUTER JOIN
--

--	여러 테이블을 조인하지만, NULL 같이 포함되는 테이블도 같이 출력된다

-- 	아래는 FULL OUTER JOIN 이다
--	모든 ns1 과 ns2 를 포함하는 합집합니다	

SELECT 
	*
FROM 
	(
		SELECT 1 AS n	
		UNION ALL
		SELECT 2 AS n	
		UNION ALL
		SELECT 3 AS n
		UNION ALL
		SELECT null AS n	
	) AS ns1
FULL OUTER JOIN (
		SELECT 1 AS n	
		UNION ALL
		SELECT 2 AS n	
		UNION ALL
		SELECT 3 AS n	
		UNION ALL
		SELECT 4 AS n
) AS ns2 ON ns1.n = ns2.n; 

--	다음은 right outer join 이다
--	오른쪽의 집합과 교집합을 포함한다

SELECT 
	*
FROM 
	(
		SELECT 1 AS n	
		UNION ALL
		SELECT 2 AS n	
		UNION ALL
		SELECT 3 AS n
		UNION ALL
		SELECT null AS n	
	) AS ns1
RIGHT OUTER JOIN (
		SELECT 1 AS n	
		UNION ALL
		SELECT 2 AS n	
		UNION ALL
		SELECT 3 AS n	
		UNION ALL
		SELECT 4 AS n
) AS ns2 ON ns1.n = ns2.n; 

--
--	다음은 left outer join 이다
--	왼쪽의 집합과, 교집합만을 나타낸다

SELECT 
	*
FROM 
	(
		SELECT 1 AS n	
		UNION ALL
		SELECT 2 AS n	
		UNION ALL
		SELECT 3 AS n
		UNION ALL
		SELECT null AS n	
	) AS ns1
LEFT OUTER JOIN (
		SELECT 1 AS n	
		UNION ALL
		SELECT 2 AS n	
		UNION ALL
		SELECT 3 AS n	
		UNION ALL
		SELECT 4 AS n
) AS ns2 ON ns1.n = ns2.n; 

--	4 는 포함되지 않는다

--
--	SELF JOIN
--

--	현재 제공되는 테이블에는 관리자를 관리하는 테이블이 없다
--	직원의 관리자를 조인한다고 가정하자
--	그럼 직원과 관리자 역시 employee 에 존재한다
--
--	직원과 관리자의 id 를 employee 를 self 조인하여, 가져오고
--	직원의 관리자 id 와 관리자 id 가 같다면 출력되도록 한다

--
--	ON 절
--

--	직원의 이름과 부서를 출력한다

SELECT
	e.first_name || ' ' || e.last_name, 
	d.dept_name
FROM department_employee de
JOIN employee e  
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id;

--	사실 EQUI JOIN, NON EQUI JOIN, OUTER JOIN, SELF JOIN 은 표준이 아니다
--	표준은 다음과 같다

--	ON 절을 사용한 JOIN
--	LEFT/RIGHT/FULL OUTER JOIN
--	USING 절을 사용한 JOIN
--	NATURAL JOIN
--	CROSS JOIN

--
--	USING 절
--

--	USING 절은 조인할 테이블의 공통된 ID 컬럼명을 가지면
--	해당 컬럼명만 입력하여 조인해준다
--	
--	JOIN target_table
--		USING(common_column_name)
--
--	안타깝게도 현재 내가 사용하는 테이블에는 같은 테이블 컬럼 명이 없어서
--	글로 작성한다

--
--	NATURAL JOIN
--

--	NATURAL 조인은 USING 과 비슷하지만, 더 단순하게 표한된다
--
--	SELECT 
--		...
--	FROM emp e NATURAL JOIN dept d
--
-- 	이는 DB 자체가 dept 와 emp 테이블의 공통되는 컬럼을 찾아서
--	알아서 조인해준다.
--
--	앞써서 이야기했든 현재 제공되는 테이블중 공통되는 컬럼이 없어서 글로 처리한다
--	중요한점은 공통되는 컬럼은 별칭없이 작성해야 한다는거다
--
--	SELECT 
--		...
--	FROM emp e NATURAL JOIN dept d
--	WHERE 
--		e.job = 'SALESMAN' AND deptno = 30
--
--	여기서 deptno 은 공통되는 컬럼이다
--	deptno 앞에 e.deptno 혹은 d.deptno 을 붙이면 에러가 난다

--
--	LEFT/RIHGT OUTER JOIN
--

--	이미 앞에서 설명했다.
--

--
--	FULL OUTER JOIN
--

--	이미 앞에서 설명했다.
--

--
--	UNION ALL
--

--	부서번호별 토탈 월급을 출력하는데, 맨 아래쪽행에 토탈 월급을 출력하라

SELECT 
	e.dept_name AS dept_name,
	sum(e.amount) AS amount
FROM 
	emp e
GROUP BY e.dept_name 
UNION ALL
SELECT 
	NULL AS dept_name,
	sum(e2.amount) AS amount
FROM 
	emp e2;
	
--	UNION ALL 연산자는 위 아래의 쿼리 결과를 하나의 결과로 출력하는 집합 연산자이다
--	위의 예제는 UNION ALL 집합 연산자를 사용하여 부서 번호와 부서별 토탈 월급을 출력한다
--	
--	제약사항
--	UNION ALL 위쪽 쿼리와 아래쪽 쿼리 컬럼의 개수가 동일해야한다
--	UNION ALL 위쪽 쿼리와 아래쪽 쿼리 컬럼의 데이터 타입이 동일해야한다
--	결과로 출력되는 컬럼명은 위쪽 쿼리의 컬럼명으로 출력된다
--	ORDER BY 절은 제일 아래쪽 쿼리에만 작성할수 있다
--
--	중복되는 교집합의 원소를 하나로 합쳐서 처리하지 않고, 각 집합의 원소는 그대로 유지된다는 것이다

--
--	UNION
--

--	부서 번호와 부서 번호별 월급을 출력하는데 맨 아래행에 토탈 월급을 출력
SELECT 
	e.dept_name AS dept_name,
	sum(e.amount) AS amount
FROM 
	emp e
GROUP BY e.dept_name 
UNION
SELECT 
	NULL AS dept_name,
	sum(e2.amount) AS amount
FROM 
	emp e2
ORDER BY amount NULLS LAST

--	UNION ALL 과 다른점은 내림차순으로 정렬하고,
--	합집합이지만, 중복되는 원소를 하나로 합치는 것이다

--
--	INTERSECT
--

--	중복되는 교집합만 출력한다

(
	SELECT 1 AS n	
	UNION ALL
	SELECT 2 AS n	
	UNION ALL
	SELECT 3 AS n
	UNION ALL
	SELECT null AS n	
)
INTERSECT
(
		SELECT 1 AS n	
		UNION ALL
		SELECT 2 AS n	
		UNION ALL
		SELECT 3 AS n	
		UNION ALL
		SELECT 4 AS n
)

--
--	MINUS
--

--	Postgresql 에서는 EXCEPT 이다
--	상단의 테이블에서, 하단의 테이블의 공통되지 않는 원소값을 반환한다	
--	기준은 상단 테이블이다

(
	SELECT 1 AS n	
	UNION ALL
	SELECT 2 AS n	
	UNION ALL
	SELECT 3 AS n
	UNION ALL
	SELECT 4 AS n	
)
EXCEPT
(
		SELECT 1 AS n	
		UNION ALL
		SELECT 2 AS n	
		UNION ALL
		SELECT 3 AS n	
		UNION ALL
		SELECT null AS n
)

--	위는 4 가 쿼리된다
