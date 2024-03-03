--
--	rank
--

-- 	데이터 분석 함수로 순위 출력
--
-- 	rank 는 순위를 출력하는 데이터 분석 함수이며,
--	rank() 뒤 over 다음에 나오는 관호 안에 출력하고 싶은 데이터를 정렬하는
--	SQL 문장을 넣으면 그 컬럼 값에 대한 데이터의 순위가 출력된다

SELECT 
	first_name || ' ' || last_name 사원명,
	RANK() OVER (ORDER BY s.amount DESC) 순위
FROM 
	employee e
JOIN salary s
	ON s.employee_id = e.id
WHERE
	s.to_date = '9999-01-01';

--	직업별로 월급이 높은 순서대로 순위를 부여해서 각각 출력

SELECT 
	first_name || ' ' || last_name 사원명,
	dept_name 부서명,
	RANK() OVER (PARTITION BY d.dept_name ORDER BY s.amount DESC) 순위
FROM 
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01' AND d.dept_name = 'Development';

--	직업별로 묶어서 순위를 부여하기 위해 order by 앞에 partition by 를 사용한다

--	현재 이 쿼리 상에서 나오지는 않지만
--	RANK 는 1 등이 2명이면 순위상 1 이 두번나오고, 2등은 없고 그 다음으로 3 부터 나온다
--	만약 2등을 출력하기 원한다면 DENSE_RANK 를 사용한다

--
--	DESNE_RANK
--

-- 	직업이 Development, Marketing 인 사원의 이름, 직업, 연봉, 연봉순위를 출력하라
--	순위가 1 위인 직원이 두명이라도 그다음은 2위로 출력되도록 한다

SELECT 
	first_name || ' ' || last_name 사원명,
	dept_name 부서명,
	DENSE_RANK() OVER (ORDER BY s.amount DESC) 순위
FROM 
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01' AND d.dept_name in ('Development', 'Marketing');
	
--	현재 쿼리상 연봉이 같은 직원이 없다..
--	일단 다음의 쿼리를 보자

SELECT 
	nums,
	DENSE_RANK () OVER (ORDER BY nums ASC),
	RANK () OVER (ORDER BY nums ASC)
FROM (
	SELECT 1 AS nums
	UNION ALL
	SELECT 1 AS nums
	UNION ALL
	SELECT 2 AS nums
	UNION ALL
	SELECT 3 AS nums
)

--	이 쿼리를 보면 쉽게 알수 있다
--	다음은 85 년도 입사한 직원의 직업, 이름, 월급, 
--	순위를 출력하는데, 직업별로 월급이 높은 순위로 부여한 쿼리이다	

SELECT 
	first_name || ' ' || last_name 사원명,
	dept_name 부서명,
	hire_date 입사일,
	s.amount  연봉,
	DENSE_RANK() OVER (ORDER BY s.amount DESC) 순위
FROM 
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01' AND EXTRACT (YEAR from e.hire_date::date) = '1985';

--	다음은 연봉이 155190 인 사원의 순위가 몇인지 출력한다
--	dense_rank 에 값을 입력하면 그 값이 있는 데이터를 전체 순위에서 몇 순위인지 찾는다
--	그러려면, 어디에서 찾는지 지정해야 하는데, within group 을 통해 해당 group 내에서 찾도록 한다
--	within group 의 group 은 다음 괄호 안에 나타나는 그룹을 뜻한다
--	이는 월급이 내림차순으로 정렬되어진 그룹을 뜻한다

SELECT 
	DENSE_RANK(155190) WITHIN GROUP (ORDER BY s.amount DESC) 순위
FROM 
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01' AND EXTRACT (YEAR from e.hire_date::date) = '1985';
	
--	월급이 아닌 날짜로도 처리 가능하다

SELECT 
	DENSE_RANK('1981-02-18') WITHIN GROUP (ORDER BY e.hire_date ASC) 순위
FROM 
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01' AND EXTRACT (YEAR from e.hire_date::date) = '1985';
	
--	전체 사원중 몇번째로 입사한지 찾을 수 있다
--	현재 1981-02-18 은 첫번째로 입사한 사원의 날짜이다	

--
--	NTLE
--

--	이름과 월급, 직업, 월급의 등급을 출력한다
--	월급의 등급은 4등급으로 나눠 1 등급(0 ~ 25%), 2등급 (25% ~ 50%), 3등급 (50% ~ 70%), 4등급 (70% ~ 100%)로 출력한다

SELECT 
	first_name || ' ' || last_name,
	d.dept_name,
	s.amount,
	NTILE (4) OVER (ORDER BY s.amount DESC NULLS LAST) 등급
FROM
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01';
	
--	ntile(num) 을 사용하여 몇등급으로 나눌지 결정한다
--	위는 4 등급으로 나눈다
--	그리고 order by s.amount desc 에서
--	null 값들을 마지막에 출력되도록 정렬한다
--

--
--	순위의 비율 출력하기
--

-- 	이름과 월급, 원급의 순위, 월급의 순의 비율을 출력한다
--	cumulative_dsitribution 의 약자로 누적 분포를 말한다	
--	이는 누적된 amount 의 분포 비율을 나타낸다

SELECT 
	first_name || ' ' || last_name,
	d.dept_name,
	s.amount,
	RANK() OVER (ORDER BY s.amount DESC),
	DENSE_RANK() OVER (ORDER BY s.amount DESC),
	CUME_DIST() OVER (ORDER BY s.amount DESC)
FROM
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01';
	
--	다음은 직업별 누적 분포를 알아본다

SELECT 
	first_name || ' ' || last_name,
	d.dept_name,
	s.amount,
	RANK() OVER (PARTITION  BY d.dept_name ORDER BY s.amount DESC),
	CUME_DIST() OVER (PARTITION BY d.dept_name ORDER BY s.amount DESC)
FROM
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01';
	
--
--	가로로 출력하기
--

-- 부서번호 옆에 해당 부서에 속하는 사원들의 이름을 가로로 출력

SELECT 
	d.id,
	array_to_string(array_agg(first_name || ' ' || last_name || '(' || s.amount || ')' ORDER BY first_name || ' ' || last_name), ',')
FROM
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01'
GROUP BY d.id;

--
--	데이터 분석 함수로 바로 전행과 다음행 출력
--

--	사원 번호, 이름, 월급을 출력하고 그 옆에 바로 전행의 월급을 출력, 또 옆에 바로 다음 행의 월급을 출력

SELECT 
	d.id,
	first_name || ' ' || last_name,
	s.amount,
	LAG(s.amount, 1) OVER (ORDER BY s.amount ASC) "전 행",
	LEAD(s.amount, 1) OVER (ORDER BY s.amount ASC) "다음 행"
FROM
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01'
	
--	사원들의 사원번호, 이름, 입사일, 바로 전 입사일, 바로 다음의 입사일을 출력	
	
SELECT 
	d.id,
	first_name || ' ' || last_name,
	hire_date "입사일",
	LAG(e.hire_date, 1) OVER (ORDER BY e.hire_date ASC) "전 행",
	LEAD(e.hire_date, 1) OVER (ORDER BY e.hire_date ASC) "다음 행"
FROM
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01'
	
--	부서 번호, 사원 번호, 이름, 입사일, 바로전 입사한 사원의 입사일을 출력하고
--	바로 다음에 입사한 사원의 입사일을 출력하는데, 부서 번호별로 구분해서 쿼리
	
SELECT 
	d.id,
	e.id,
	first_name || ' ' || last_name,
	hire_date "입사일",
	LAG(e.hire_date, 1) OVER (PARTITION BY d.id ORDER BY e.hire_date ASC) "전 행",
	LEAD(e.hire_date, 1) OVER (PARTITION BY d.id ORDER BY e.hire_date ASC) "다음 행"
FROM
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01'

--
--	COLUMN 을 ROW 로 출력
--
	
--	부서 번호, 부서 번호별 토탈 월급을 출력
	
SELECT 
	SUM(
		CASE 
			WHEN d.id = 'd001' THEN s.amount
			ELSE null
		END
	) AS "d001", 
	SUM(
		CASE 
			WHEN d.id = 'd002' THEN s.amount
			ELSE null
		END
	) AS "d002", 
	SUM(
		CASE 
			WHEN d.id = 'd003' THEN s.amount
			ELSE null
		END
	) AS "d003"
FROM
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01'
	
--	'Development', 'Sales' 월급을 출력	
	
SELECT
	SUM(
		CASE 
			WHEN d.dept_name = 'Development' THEN s.amount
			ELSE null
		END
	) AS "Development",
	SUM(
		CASE 
			WHEN d.dept_name = 'Sales' THEN s.amount
			ELSE null
		END
	) AS "Sales"
FROM
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01';

--
--	분석함수로 누적 데이터 출력		
--

SELECT
	d.id,
	e.first_name || ' ' || e.last_name,
	s.amount, 
	sum(s.amount) OVER (
		ORDER BY d.id
		ROWS
		BETWEEN UNBOUNDED PRECEDING
		AND 
		CURRENT ROW
	) 누적치
FROM
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01';
	
--	over 다음의 괄호 안에는 값을 누적할 윈도우를 지정할 수 있다
--	order by d.id 를 통해 사원 번호를 오름차 순으로 정렬하고
--	정렬된 것을 기준으로 월급의 누적치를 출력한다

--	윈도우 기준: ROW
--	윈도우 방식: UNBOUNDED PRECEDING - 맨 첫번째 행을 가리킨다
--				UNBOUNDED FOLLOWIND - 맨 마지막 행을 가리킨다
--				CURRENT ROW			- 현재 행을 가리킨다
--
-- 	BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW 는
--	제일 첫번째 행에서 부터 현재 행까지의 값을 말한다
--
--	즉 첫번째 부터 현재 행까지의 합을 구한다.
--

--
--	비율을 출력
--

-- 	RATIO_TO_REPORT 는 해당 컬럼을 해당하는 컬럼의 모든 합계로 나눈 비율이다 
--	postgresql 에는 해당 기능이 없다
--	직접 구현해야 한다

SELECT
	d.id,
	e.first_name || ' ' || e.last_name,
	s.amount, 
	d.dept_name, 
	sum(s.amount) OVER (PARTITION BY d.dept_name),
	s.amount / NULLIF(sum(s.amount) OVER(PARTITION BY d.dept_name ORDER BY d.dept_name), 0)
FROM
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01';
	
--	위의 nullif 는 0 과 같다면 null 값을 반환한다
--	null 로 나누면 값이 null 이 된다
--

--
--	집계 결과 출력
--

SELECT 
	d.dept_name dept_name,
	sum(s.amount) amount
FROM
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01'
GROUP BY ROLLUP(d.dept_name)
ORDER BY d.dept_name  ASC;

--	이는 sum 의 토탈 월급을 출력한다
--	
--	ROLLUP 은 직업과 직업별 토탈 월급을 출력하고 전체 토탈 월급을
--	출력한다
--
--	직업과 직업별 토탈 월급을 출력하는 쿼리에 ROLLUP 을
--	붙여주면 전체 토탈 월급을 추가적으로 볼 수 있다
--

--
--	CUBE
--

--	직업, 직업별 토탈 월급을 출력하는데, 첫번째 행에 토탈 월급을 출력해보자

SELECT 
	d.dept_name dept_name,
	sum(s.amount) amount
FROM
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01'
GROUP BY CUBE (d.dept_name)

--	왜인지 모르겠으나 ROLLUP 과 CUBE 가 똑같다..
--	JOIN 문 때문인가?
--	이유를 찾지 못해서 일단은 넘긴다

--
--	GROUPING SETS
--

--	부서 번호, 직업, 부서 번호별 토탈 월급, 전체 토탈 월급을 출력

SELECT 
	d.id,
	d.dept_name, 
	sum(s.amount) amount
FROM
	department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s
	ON s.employee_id = de.employee_id 
WHERE
	s.to_date = '9999-01-01'
GROUP BY GROUPING SETS ((d.id), (d.dept_name), ());

--	GROUPING SETS 는 ROLLUP, CUBE 보다 집계된 결과를 예상하기 더 쉽다
--	이는 집계하고 싶은 컬럼들을 기술하면 그대로 출력되기 때문이다
--
--	GROUPING SETS 괄호안에 다음과 같이 집계하고 싶은 컬럼명을 기술하면,
--	기술한 대로 결과를 출력해주면 된다
--

--
--	ROW_NUMBER
--

SELECT 
	nums,
	RANK () OVER (ORDER BY nums ASC),
	DENSE_RANK () OVER (ORDER BY nums ASC), 
	ROW_NUMBER () OVER (ORDER BY nums ASC)
FROM
	(
		SELECT 1 AS nums	
		UNION ALL
		SELECT 1 AS nums	
		UNION ALL
		SELECT 2 AS nums	
		UNION ALL
		SELECT 3 AS nums	
	);

--
-- row_number 는 번호 순서대로 번호를 매긴다
-- rank 나 dense_rank 와는 다르다
