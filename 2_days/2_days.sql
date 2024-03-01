SELECT * FROM employee e;

-- like 에 대해서

-- 다음은 first_name 이 S 로 시작하는 사원의 연봉을 출력한다
SELECT first_name || ' ' || last_name ename, s.amount sal 
	FROM employee e 
	JOIN salary s 
		ON e.id  = s.employee_id 
	WHERE 
		s.to_date = '9999-01-01' AND
		e.first_name LIKE 'S%';
	
-- like 에서 % 는 0 개 이상의 임의 문자이며
--			_ 는 1개 문자와 일치한다
	
-- IS NULL
-- 해당 값이 NULL 인지 확인

SELECT NULL IS NULL;

-- NULL 은 데이터가 할당되지 않은 알수 없는 값이다
-- 이는 equal 연산자로 비교가 안된다
-- NULL 값을 검색하려면 반드시 IS NULL 연산자를 사용해야 한다

-- NULL 과 equal 연산자라로 비교하면 반환값은 NULL 이다
SELECT NULL != 1;
-- 알수 없다는 말이다

-- IN

-- Development, Production, Marketing 부서의 모든 사원을 찾는다
-- 사원의 이름, 연봉, 부서를 출력한다

SELECT 
	e.first_name || ' ' || e.last_name "사원이름",
	s.amount 연봉,
	d.dept_name 
FROM department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s 
	ON s.employee_id = de.employee_id 
WHERE 
	s.to_date = '9999-01-01' AND
	d.dept_name IN ('Development', 'Production', 'Marketing');

-- 이는 다음과 같다
--WHERE
--	s.to_date = '9999-01-01' AND
--	d.dept_name = 'Development' OR,
--	d.dept_name = 'Production' OR
--	d.dept_name = 'Marketgin';
	

-- IN 연산자는 이렇게 사용하는데 유용하게 사용가능하다
-- 반면 Development, Production, Marketing 에 해당하지 않은
-- 사원을 찾아보고 이름, 연봉, 부서를 출력해보자.

SELECT 
	e.first_name || ' ' || e.last_name "사원이름",
	s.amount 연봉,
	d.dept_name 
FROM department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s 
	ON s.employee_id = de.employee_id 
WHERE 
	s.to_date = '9999-01-01' AND
	d.dept_name NOT IN ('Development', 'Production', 'Marketing');
	
-- 해당하는 부서를 제외한 나머지 부서를 출력하는것을 확인할 수 있다

-- AND, OR, NOT
-- development 이고 연봉이 50000 이상의 사원들의 이름, 월급, 직업을 출력하라

SELECT 
	e.first_name || ' ' || e.last_name "사원이름",
	s.amount 연봉,
	d.dept_name 
FROM department_employee de 
JOIN employee e 
	ON e.id = de.employee_id 
JOIN department d 
	ON d.id = de.department_id 
JOIN salary s 
	ON s.employee_id = de.employee_id 
WHERE 
	s.to_date = '9999-01-01' AND
	d.dept_name = 'Development' AND 
	s.amount >= 50000;

-- OR, NOT 에 대해서는 잘 이해가 되는데,
-- SQL 에서 NULL 과 만났을때 동작원리를 이해해야 한다

-- AND 연산자는 특성상 앞의 값이 TRUE 이면 그다음 값을 반환한다
-- TRUE AND NULL = NULL
-- AND 연산자는 특성상 앞의 값이 FALSE 이면 바로 FALSE 처리한다
-- FALSE AND NULL = FALSE
-- OR 연산자는 특성상 앞의 값이 TRUE 면 TRUE 를 반환한다
-- TRUE OR NULL = TRUE
-- NOT 연산자와 NULL 처리시, NULL 은 알수없는 값이므로 NULL 을 반환한다	
-- NOT NULL = NULL

-- UPPER, LOWER, INITCAP

SELECT
	-- 대문자 변환
	upper(first_name || ' ' || last_name),
	-- 소문자 변환
	lower(first_name || ' ' || last_name),
	-- 첫글자 대문자 나머지는 소문자
	initcap(first_name || ' ' || last_name)
FROM employee e;

-- 대소문자가 섞인 문자열이 있을때, 대소문자를 구분해야 하지만
-- lower 를 사용하여 소문자로 변환후 비교하여 해당하는 사원을 찾을수도 있다

SELECT 
	first_name || ' ' || last_name
FROM
	employee e 
WHERE 
	lower(e.first_name) = 'georgi';

-- SUBSTRRING

-- substring(문자열, 시작 인덱스, 시작 인덱스 부터 추출한 인덱스)
-- 자바스크립트 substring 과는 약간 다르다
-- sql 에서는 시작 인덱스 부터 추출할 인덱스 범위까지 지정한다
-- 자바스크립트는 추출한 인덱스가 0 부터 다시시작한다..
SELECT substring('SMITH', 1, 3); -- SMI

-- LENGTH

-- 문자열 길이를 반환하다

SELECT 
	first_name || ' ' || last_name,
	length(first_name || ' ' || last_name) len
FROM
	employee e;

-- oracle 에서는 한글로 적을시 3 byte 로 인식하여 계산한다
-- 이말은 byte 단위로 문자의 개수를 계산한다는것이다
-- 하지만, postrgesql 에서는 문제없이 작동한다
-- 알아만 두자

-- POSITION

-- oracle 에서는 instr 을 사용하는듯한데,
-- postrgesql 에서는 position 함수를 사용한다 다음과 같다
-- 이는  문자열에 해당하는 단어의 인덱스를 반환한다
SELECT POSITION('M' IN 'SMITH'); -- 2 
SELECT POSITION('@' IN 'abdcef@gmail.com'); -- 7
-- 명심할건 SQL 은 인덱스의 시작은 1 부터 시작한다는 것이다

SELECT rtrim(substring('abcedf@gmail.com', POSITION('@' in 'abcedf@gmail.com') + 1), '.com');  -- gmail
-- rtrim 은 해당하는 오른쪽 문자열을 제거한다

-- REPLACE

-- oracle 에서는 숫자값도 변경처리 하던데
-- postgresql 에서는 문자열로 변경하고 처리해주어야 한다

SELECT 
	first_name || ' ' || last_name 사원이름,
	REPLACE(s.amount::varchar, '0', '*')
FROM employee e
JOIN salary s 
	ON s.employee_id = e.id 

-- 월급의 숫자 0~5 까지를 * 로 출력한다

SELECT 
	first_name || ' ' || last_name 사원이름,
	regexp_replace(s.amount::varchar, '[0-5]', '*')
FROM employee e
JOIN salary s 
	ON s.employee_id = e.id 

-- 이름을 보면 알겠지만 정규식을 사용한 replace 도 있다
	
-- LPAD, RPAD
	
-- 오른쪽 왼쪽에 * 을 채워넣어본다
SELECT 
	lpad(first_name, 10, '*'),
	rpad(first_name, 10, '*')
FROM employee e 

-- 이는 시각화 하는데 도움이 된다고 한다

SELECT 
	first_name || ' ' || last_name 사원이름,
	s.amount 연봉,
	lpad('ㅁ', round(s.amount / 10000)::INTEGER, 'ㅁ')
FROM employee e
JOIN salary s 
	ON s.employee_id = e.id 
WHERE 
	s.to_date = '9999-01-01';

-- postgersql 에서는 lpad 시 integer 값이어야 한다
-- 위 같은경우 round 를 통해 double 값으로 변환되므로 에러가 나온다
-- 그러므로 integer 로 캐스팅해주어야 작동한다

-- TRIM, RTRIM, LTRIM

-- 왼쪽, 오른쪽, 양쪽 모두에서 해당하는 문자를 자른다

SELECT 'smith', ltrim('smith', 's'), rtrim('smith', 'h'), trim('s' FROM 'smithes')  

-- ROUND

-- 소수로 나오는 수를 반올림한다

SELECT
	'876,471' 숫자,
	round(876.771, 1); -- 876.8

-- 한자리수로 반올림한다

select
	'876,771' 숫자,
	round(876.771, 0); -- 877

-- 0 의 자리수이니 876 중 6 이 7 로 올림한다

select
	'876,771' 숫자,
	round(876.771, -1); -- 880

-- -1 의 자리수이니 876 중 7 이 8 로 올림한다
-- 0 의 자리수인 6 은 0 이 된다
	
-- -n 자리수만큼 반올림되며, 나머지는 0 으로 된다고 보면된다


