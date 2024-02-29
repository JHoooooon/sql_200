-- 001 사원 번호와 이름과 월급을 출력
--
-- postgres 와 oracle 에서 제공하는 employees 가 다르다
-- join 해서 사용한다

SELECT id, concat(first_name,' ', last_name), amount
	FROM employee e
JOIN salary s
	ON s.employee_id = e.id ;

-- 002 테이블에서 모든 열 출력하기
--

SELECT *
	FROM employee e;

-- 모든 컬럼을 출력하고 맨 끝에 특정 칼럼을 한번더 출력해야 하는경우
-- 테이블 명.* 을 하고 특정 칼럼을 한번더 출력한다
-- 아래는 birth_date 가 출력된다

SELECT e.*, birth_date
	FROM employee e 
	
-- 003 컬럼 별칭을 사용하여 출력되는 컬럼명 변경하기	
	
SELECT id 사원번호, concat(first_name, last_name) "사원 이름", amount
	FROM employee e 
JOIN salary s
	ON s.employee_id = e.id;
	
-- 다음처럼 월급을 출력할수도 있다
-- amount 값이 연봉인듯 하여 / 12 로 월급을 계산한다

SELECT concat(first_name, ' ', last_name) AS "사원 이름", amount / 12 AS 월급
	FROM employee e 
JOIN salary s 
	ON s.employee_id = e.id;

-- 004 연결 연산자(concatenation operator) 사용
-- oracle 뿐만 아니라 postgres 에서도 사용가능한 연산자인듯하다
-- 두 값을 연결한다.
-- 이전에는 concat 함수를 사용했지만 이게 더 간단해 보인다

SELECT first_name || last_name
	FROM employee e;
	
-- 005 중복된 데이터를 제거해서 출력하기 + 데이터를 정렬하여 출력하기
-- DISTINCT 는 중복된 데이터를 제거한다
-- hire_date 는 같은 날에 입사한 사원이 있어서, 입사일이 겹치게 출력된다
-- 이때 각 입사일만 고유하게 출력하고 싶다면 다음처럼 하면된다
-- order by 절을 사용하여 오름차순으로 정렬한다 내림차순으로 하고 싶다면 끝에 desc를 붙인다

SELECT DISTINCT hire_date 
	FROM employee e
ORDER BY hire_date; 

-- 007 where 절
-- postgres 의 employees 는 예시와 달라 서브쿼리를 사용하여 처리한다
-- 여기서는 salary 테이블에서 from_date 부터 to_date 까지
-- 받은 연봉의 리스트를 생성한다
--
-- 그러므로, 가장 최근에 받은 연봉을 얻기 위한 쿼리이다

SELECT *
FROM employee e 
JOIN salary s
	ON s.employee_id = e.id
WHERE
	s.to_date = (
		SELECT to_date	
			FROM salary s2 
		ORDER BY to_date DESC
		LIMIT 1
	);
	
-- 가장 최근에 받은 연봉의 to_date 는 9999-01-01 로 이루어져있음을
-- 볼수 있다
--
-- 그럼 다음처럼 처리 가능하겠다

SELECT *
FROM employee e 
JOIN salary s
	ON s.employee_id = e.id
WHERE
	s.to_date = '9999-01-01';
	
-- 같은 결과이다
-- 그럼 40000 보다 작은 연봉을 가진 사람들을 출력해본다

SELECT 
	first_name || ' ' || last_name "사원 이름",
	amount 연봉
FROM employee e 
JOIN salary s
	ON s.employee_id = e.id
WHERE
	s.to_date = '9999-01-01' AND
	s.amount < 40000;
	
-- 출력되는것을 볼 수 있다
-- `Dzung` 인 first_name 을 가진 사람을 출력해본다

SELECT *
	FROM employee e 
WHERE 
	e.first_name = 'Dzung';

-- 1992-12-29 에 입사한 사원을 출력해본다

SELECT
	first_name || ' ' || last_name "사원 이름",
	hire_date 입사일
FROM employee e 
WHERE 
	e.hire_date = '1992-12-29'
	
-- 산술 연산자
-- 연봉이 40000 이상인 직원의 월급을 출력한다
	
SELECT
	e.first_name || ' ' || e.last_name "사원 이름",
	amount / 12 AS 월급
FROM employee e 
JOIN salary s
	ON s.employee_id = e.id
WHERE
	s.amount >= 40000;

-- 연봉이 50000 이하인 직원 이름, 연봉, 부서, 부서번호

SELECT 
	e.first_name || ' ' || e.last_name "사원 이름",
	s.amount 연봉,
	d.dept_name 부서,
	d.id "부서 번호"
FROM
	department_employee de 
JOIN employee e
	ON e.id = de.employee_id  
JOIN salary s 
	ON e.id = s.employee_id 
JOIN department d 
	ON d.id = de.department_id
WHERE
	s.amount <= 50000;

-- 연봉이 40000 에서 50000 인 사원의 이름, 연봉, 부서, 부서번호를 출력

SELECT 
	e.first_name || ' ' || e.last_name "사원 이름",
	s.amount 연봉,
	d.dept_name 부서,
	d.id "부서 번호"
FROM
	department_employee de 
JOIN employee e
	ON e.id = de.employee_id  
JOIN salary s 
	ON e.id = s.employee_id 
JOIN department d 
	ON d.id = de.department_id
WHERE
	s.amount BETWEEN 40000 AND 50000;

-- 이는 다음과 같다
--	s.amount >= 40000 AND s.amount <= 50000;