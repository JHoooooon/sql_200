-- TRUNC

-- 	trunc(876.567, 1) 은 소수점 첫째 자리 다음은 모두 버린다

SELECT 
	'876.567' AS 숫자,
	trunc(876.567, 1);

-- 	trunc(876.567, 0) 은 첫째 자리 다음은 모두 버린다
--	0  의 자리는 소수점 자리이므로, 소수점 이후를 전부 버린다

SELECT 
	'876.567' AS 숫자,
	trunc(876.567, 0);

-- 	trunc(876.567, -1) 은 둘째 자리 다음의 숫자를 0 으로 초기화하고
-- 	소수점은 버린다

SELECT 
	'876.567' AS 숫자,
	trunc(876.567, -1);

-- 	여기서 보면 알겠지만, 소수점 이후의 숫자를 버릴때는 
--	자신을 포함하지 않고, 그 이후의 숫자를 버리지만,	
--	수소점 이상의 숫자를 버릴때는, 자기 자신을 포함하여 나머지 소수점을 버리거나
--	소수점 이상의 정수는 0 으로 초기화한다

--
--	MOD	
--

SELECT MOD(10, 3); -- 1

-- 	이는 10 을 3 으로 나눈후 나머지 값을 반환한다
--	흔히 짝수, 홀수 판정할때도 많이 사용한다	

SELECT 
	e.id, 
	CASE 
		WHEN mod(e.id, 2) = 0 THEN '짝'
		ELSE '홀'
	END
FROM employee e 

-- 다음처럼 짝수인 사원만 출력가능하다

SELECT 
	e.id,
	CASE 
		WHEN mod(e.id, 2) = 0 THEN '짝'
		ELSE '홀'
	END
FROM employee e 
WHERE MOD(e.id, 2) = 0; 

--
--	MONTHS_BETWEEN
--

-- 아쉽게도 postgersql 에는 months_between 이 없다
-- 직접 구현해야 한다

-- postgres 에는 age 와 extract 라는 함수가 있다
-- age(start_timestamp, end_timestamp)
-- age 는 시작 날짜와 종료 날짜를 설정해주면, 시작 날짜로 부터 종료날짜까지의
-- 0 year 0 mons 0 days 를 출력해준다

SELECT 
	e.id,	-- 10001
	first_name || ' ' || last_name,
	e.hire_date,	-- 1986-06-26
	age(current_date, e.hire_date) -- 37 years 8 mons 6days
FROM employee e 
WHERE e.id = 10001;

-- age 로 산출된 값중에 year 부분만을 추출하려면 extract 를 사용한다
-- extract( field FROM source)
--
-- field 는 날짜/시간 값에서 추출할 필드명을 입력해야 한다
-- day, dow(day of week, 0 ~ 6), doy(day of year, 1 ~ 366), epoch(1970-01-01 UTC ~ 현재초 까지)
-- hour(0 ~ 23), milliseconds, minute, month, quater(1 ~ 3월, 4 ~ 6월, 7 ~ 9월, 10 ~ 12월 4분기)
-- second, week, year

-- source 는 timestamp 혹은 interval 타입의 값이며,
-- date 타입을 전달하며 자동적으로 timestamp 로 변환

SELECT 
	first_name || ' ' || last_name,
	e.hire_date,	--	1986-06-26 
	EXTRACT(year FROM age(current_date, e.hire_date))	-- 37
FROM employee e 
WHERE e.id = 10001;

-- age 의 current_date 부터 e.hire_date 까지의 year 는 37 이다
-- 이제 MONTHS_BETWEEN 을 구현하려면 다음의 계산이 필요하다
--
-- age 에서 추출한 year * 12 + age 에서 추출한 month 
--
-- year * 12 를 하면 년의 달수를 계산할수 있다
-- 그리고 나머지 month 값을 추출해서 더하면, current_date 부터 e.hire_date 까지의
-- 근무 달수를 구할 수 있다

SELECT 
	first_name || ' ' || last_name,
	e.hire_date,
	EXTRACT(year FROM age(current_date, e.hire_date) * 12) + EXTRACT(MONTH FROM age(current_date, e.hire_date)) AS 근무달수
FROM employee e 
WHERE e.id = 10001;

-- 다음은 총 일수를 구하는 공식이다

SELECT 
	first_name || ' ' || last_name,
	e.hire_date,
	current_date::date - e.hire_date::date AS date  -- 13764
FROM employee e 
WHERE e.id = 10001;

-- 이는 다음처럼도 가능하다

SELECT to_date('2019-06-01', 'yyyy-mm-dd') - to_date('2018-10-01', 'yyyy-mm-dd'); --	243
SELECT '2019-06-01'::date - '2018-10-01'::date;	--	243

-- 2018-10-1 일에서 2019-6-1 일 사이의 총주

SELECT 
	('2019-06-01'::date - '2018-10-01'::date) / 7;

--
-- 개월 수 더한 날짜 출력
--

--	oracle 에서는 add_months 가 있는데,
--	postgresql 에서는 없다
--
-- 구현해야 한다
-- 그럼 month 값을 구해본다
-- 구하기 위해서 INTERVAL 을 사용해야 한다
--
-- 100 달을 더한다

SELECT ('2019-05-01'::date + INTERVAL '100 month')::date;	-- 2027-09-01

-- 2019-05-01 부터 100일후 돌아오는 날짜는 다음과 같다

SELECT ('2019-05-01'::date + INTERVAL '100 days')::date; 	-- 2019-08-09

-- 2019-05-01 부터 1 년 3개월후 돌아오는 날짜는 다음과 같다

SELECT ('2019-05-01'::date + INTERVAL '1 year 3 month')::date;	-- 2020-08-01

--
--	특정 날짜 뒤에 오는 요일 날짜 출력
--

-- 	2019-05-22 일로 부터 바로 돌아오는 월요일의 날짜가 어떻게 되는지 출력
--
-- 	oracle 에는 next_day 가 있는데, postgresql 에는 없다
-- 	직접 구현해야 한다
--	
--		
--	이를 위해서는 dow 에 대해서 조금 알아봐야 한다
--	dow 는 day of week 인데, 0 ~ 6 까지 있다
--	이는 총 7일로, 0 은 일요일 ~ 6 은 토요일까지의 순서로 이어진다
--
--	일단 바로 돌아오는 월요일의 날짜를 알기 위해서는 extract 를 사용하여 dow 의 값을 가져온다
--

SELECT EXTRACT(dow FROM '2019-05-01'::date);	--	3

-- 	이는 2019-05-01 이 수요일임을 뜻한다
-- 	3 이 수요일이니, 일요일이 되기 위해서는 - 7 을 해주면, 일요일까지의 일수가 계산된다

SELECT (7 - EXTRACT(dow FROM '2019-05-01'::date));	-- 4

--	3 + 4 = 7 이다.
--	하지만, dow 는 0 ~ 6 까지의 정수값이다
--	이를 처리하기 위해 % 7 을 해주어 나머지 값을 계산하면 계산식은 0 ~ 6 까지의 수가 보장된다
-- 	이를 보기 위해 일시적으로 일요일을 만들겠다

SELECT (7 - EXTRACT(dow FROM '2019-05-05'::date))::int % 7;	-- 0

-- 	2019-05-05 는 일요일이므로 0 이어야 한다 하지만 7 - 0 은 7 이며,
--	7 % 7 = 0 이 되므로 dow 의 0 값과 일치하게 된다	
--	이렇게 일요일의 값을 구할수 있게 되었다. 
--	그럼 일요일에 구하길 원하는 dow 의 요일값을 더해준다
--	 월요일을 구해야 하니 + 1 을 해준다

SELECT (1 + 7 - EXTRACT(dow FROM '2019-05-05'::date))::int % 7; -- 1

--	dow 의 1 은 월요일이다.
--	월요일값이 제대로 계산되어 나오는것을 볼 수 있다
-- 	그럼 이제 2019-05-01 에서 일요일이 나오기까지의 일수를 계산해보자

SELECT ( 1 + 7 - EXTRACT(dow FROM '2019-05-01'::date))::int % 7;	-- 5

--	2019-05-01 은 수요일이므로, 다음 월요일까지는 총 5일이다.
--	위의 계산식에 의해 5 가 출력되는 것을 볼 수 있다
--	이렇게 구한 요일수를 현재 2019-05-01 에 더해주면 원하는 날짜를 만들 수 있다

SELECT '2019-05-01'::date + ( 1 + 7 - EXTRACT(dow FROM '2019-05-01'::date))::int % 7;

-- 	다음에 오는 월요일의 날짜는 2019-05-06 이다
--
--	oracle 이 편하기는 하구나.. 왜 oracle 쓰는지 알겠다	
--
--	그럼 오늘 날짜 부터 시작하여, 다음 돌아오는 수요일을 출력해보자

SELECT current_date + (3 + 7 - EXTRACT(dow FROM current_date))::int % 7;	-- 2024-03-06

--	2019-05-22 부터 100 달뒤에 돌아오는 화요일의 날짜를 출력

SELECT 
	('2019-05-22'::date + INTERVAL '100 month')::date + 
	(2 + 7 - EXTRACT(dow FROM ('2019-05-22'::date + INTERVAL '100 month')))::int % 7;

--	2 는 dow 에서 화요일이므로, 2 를 준다.
--	중요한 점은 interval 이후 타입이 timestampe 로 변경되므로, date 로 캐스팅해주어야 date + int 값이
--	제대로 이루어진다
--	timestamp + int 가 이루어질시 다음의 에러가 나온다
--	SQL Error [42883]: ERROR: operator does not exist: timestamp without time zone + integer
--  Hint: No operator matches the given name and argument types. You might need to add explicit type casts.

-- postgresql 로 처리하는데 약간의 수고스러움이 느껴진다.
--

--
--	last_day
--

--	2019-05-22 의 해당 달의 마지막 날짜를 출력
--
--	oracle 은 last_day 가 존재한다
--	하지만 postgresql 은 해당 함수가 없다.
--	이를 이용하기 위해서는 다음의 함수인 date_trunc 가 필요하다
--
--	date_trunc('field', 'timestamp')
--
--	이는 지정한 field 다음의 모든 field 를 초기화시킨다
--	다음을 보자

SELECT 
	date_trunc('month', '2019-05-22'::date);	--	2019-05-01 00:00:00.000 + 0900
	
--	이는 month 필드 다음의 day, hour, minute, miliseconds 를 전부 초기화 시킨다
--	이를 이용하면 해당 월의 첫번째 일을 가져올수 있다

SELECT 
	date_trunc('month', '2019-05-22'::date)::date;	--	2019-05-01
	
--	2019-05-01 을 가져오는것을 볼 수 있다
--	그럼 이후에 interval 을 사용하여 '1 month' 를 더한다음,
--	'1 day' 를 빼주면 2019-05 의 마지막 일이 된다

SELECT 
	'2019-05-22' AS 날짜,
	date_trunc('month', '2019-05-22'::date),
	(date_trunc('month', '2019-05-22'::date) + INTERVAL '1 month - 1 day')::date;	--	2019-05-31
	
--	이를 통해 5월은 31 일까지 있다는것을 알 수 있다
	
--	id 가 10001 인 사원의 입사일의 마지막달을 계산해본다
	
SELECT
	e.id 사원id,
	e.first_name || ' ' || e.last_name 사원이름,
	(date_trunc('month', e.hire_date) + INTERVAL '1 month - 1 day')::date "입사한 달의 마지막 날"
FROM
	employee e
WHERE
	e.id = 10001;

--
--	to_char
--

-- 	to_char(timestamp, field) 
--
--	숫자형 데이터 유형을 문자형으로 변환하거나,	
--	날짜형 데이터 유형을 문자형으로 변환할 때 to_char 사용

SELECT to_char(e.hire_date, 'day')	--	thursday
FROM
	employee e 
WHERE
	e.id = 10001;

--	위처럼 안하면 다음처럼 구현해야 할수도 있다..
	
SELECT 
	CASE 
		WHEN EXTRACT(dow FROM e.hire_date) = 0 THEN 'sunday' 
		WHEN EXTRACT(dow FROM e.hire_date) = 1 THEN 'monday'
		WHEN EXTRACT(dow FROM e.hire_date) = 2 THEN 'tuesday'
		WHEN EXTRACT(dow FROM e.hire_date) = 3 THEN 'wensday'
		WHEN EXTRACT(dow FROM e.hire_date) = 4 THEN 'thursday'
		WHEN EXTRACT(dow FROM e.hire_date) = 5 THEN 'friday'
		WHEN EXTRACT(dow FROM e.hire_date) = 6 THEN 'saturdya'
	END
FROM employee e 
WHERE 
	e.id = 10001;

--	숫자타입도 문자형으로 변환 가능한데, 출력시 천 단위를 표시하여 출력한다

SELECT
	s.amount,
	to_char(s.amount, '999,999')
FROM
	employee e 
JOIN
	salary s 
	ON
		s.employee_id = e.id
WHERE
	s.to_date = '9999-01-01' and
	id = 10001;

--	날짜를 문자로 면환해서 출력하면 년, 월, 일, 요일 등을 추출하여 출력한다

SELECT
	to_char(e.hire_date, 'yyyy') 년,	-- 1986
	to_char(e.hire_date, 'mm'  ) 월,	-- 06
	to_char(e.hire_date, 'dd') 일,	-- 26
	to_char(e.hire_date, 'w') 주,	-- 4
	to_char(e.hire_date, 'day') 요일	-- thursday
FROM
	employee e 
JOIN
	salary s 
	ON
		s.employee_id = e.id
WHERE
	s.to_date = '9999-01-01' and
	id = 10001;
	
--	1986 년도 입사한 사원의 이름과 입사일을 출력

SELECT 
	e.first_name || ' ' || e.last_name 이름,
	e.hire_date 입사일
FROM 
	employee e 
WHERE
	to_char(e.hire_date, 'yyyy') = '1986';
	
--	입사한 사원의 연도, 달, 요일을 출력하라

SELECT
	e.first_name || ' ' || e.last_name 이름,
	to_char(e.hire_date, 'yyyy') "입사 년도",	
	to_char(e.hire_date, 'mm'  ) "입사 월",
	to_char(e.hire_date, 'dd') "입사 일"
FROM
	employee e; 
	
--	숫자를 문자열로 변경할시, 자리수와 쉼표를 사용하여 천단위를 표시한다
--	다음은 천단위, 천만과 백만단위를 표시한다
--	중요한 점은 0 으로 작성시 숫자가 없을 경우 0 으로 채운다		

SELECT
	e.id,
	to_char(s.amount, '000,000,000')	--	000,088,958
FROM
	employee e 
JOIN
	salary s 
	ON
		s.employee_id = e.id
WHERE
	s.to_date = '9999-01-01' and
	id = 10001;

--	9 로 작성시 채우는것 없이 해당 숫자값을 보여준다

SELECT
	e.id,
	to_char(s.amount, '999,999,999')
FROM
	employee e 
JOIN
	salary s 
	ON
		s.employee_id = e.id
WHERE
	s.to_date = '9999-01-01' and
	id = 10001;
	
--	$ 작성시 달러부호를 출력해준다

SELECT
	e.id,
	to_char(s.amount, '$999,999,999')
FROM
	employee e 
JOIN
	salary s 
	ON
		s.employee_id = e.id
WHERE
	s.to_date = '9999-01-01' and
	id = 10001;
	
--	.  사용시 소수점 이하가 표시된다

SELECT
	e.id,
	to_char(s.amount, '999999.9')
FROM
	employee e 
JOIN
	salary s 
	ON
		s.employee_id = e.id
WHERE
	s.to_date = '9999-01-01' and
	id = 10001;
	
-- 	L 작성시 원화표시가 된다고 하는데, 안된다
--	$ 가 표시된다.

SELECT
	e.id,
	to_char(s.amount, 'L999999')
FROM
	employee e 
JOIN
	salary s 
	ON
		s.employee_id = e.id
WHERE
	s.to_date = '9999-01-01' and
	id = 10001;

--
--	to_date
--

-- 문자를 날짜로 변경해주는 함수이다

SELECT
	first_name || ' ' || last_name "사원 이름",
	hire_date "입사 일"
FROM
	employee e 
JOIN
	salary s 
	ON
		s.employee_id = e.id
WHERE
	s.to_date = '9999-01-01' AND
	hire_date = to_date('86/06/26', 'yy/mm/dd'); 

--
-- 암시적 형변환
--

SELECT 
	first_name || ' ' || last_name,
	s.amount
FROM
	employee e 
JOIN
	salary s 
	ON s.employee_id = e.id
WHERE 	
	s.amount > '50000';

--	숫자형 > 문자형 을 비교하는데 결과가 정상적으로 출력된다
--	이는 postgresql 이 알아서 문자열을 숫자값으로 암묵적인 형변환을 해주기 때문이다
--	문자형과 숫자형을 비교하면 숫자형으로 변환된다
--

EXPLAIN SELECT 
	first_name || ' ' || last_name,
	s.amount
FROM
	employee e 
JOIN
	salary s 
	ON s.employee_id = e.id
WHERE 	
	s.amount > '50000';
	
--	explain 을 보면 다음의 구문이 있다
--         Filter: (amount > '50000'::bigint)
--	이를 보면 '50000' 을 bigint 로 알아서 캐스팅해준다	

--
--	null 값 대신 다른 데이터 출력
--

-- 	oracle 에서는 nvl 이라는 함수를 사용하는데,
--	postgresql 및 여러 표준 sql 은 coalesce 를 사용하는것으로 알고 있다 

SELECT COALESCE(NULL, 1);	-- 	1

--	nvl2 는 null 이 아니면, 두번째 인자값을, 아니면 세번째 인자값을 출력한다
--	coalesce 는 마치 or 연산자 처럼 처리되어, null 이 아닌 값이 나올때까지
--	인자를 훑는다

SELECT COALESCE (NULL, NULL, 'hi');	-- 'hi'

--	if 문으로 sql 구현
--	oracle 에서 decode 를 사용하여 if 문을 구현하는듯하다
--	postgresql 은 decode 문자 그대로, 문자열을 decoding 하는 함수로 사용된다
--
--	전혀 용도가 다르며, if 문을 구현하려면
--	CASE 절을 사용해야 한다
--
--	다음은 부서명이 Development 이면 보너스 300, Research 이면 보너스 400 을
--	주는 쿼리이다

SELECT * FROM department d ;

SELECT 
	e.first_name || ' ' || e.last_name 사원이름,
	d.dept_name  부서명,
	CASE de.department_id
		WHEN 'd005' THEN 300 
		WHEN 'd008' THEN 400
		ELSE 0
	END AS 보너스
FROM 
	employee e 
JOIN 
	department_employee de
ON 
	de.employee_id = e.id
JOIN 
	department d 
ON 
	de.department_id = d.id

--
-- 최대값 출력 MAX
--
	
-- 모든 직원중 가장 높은 연봉을 받는 직원을 출력한다

SELECT 
	first_name || ' ' || last_name "직원 이름",
	s.amount "최고 연봉"
FROM
	employee e 
JOIN 
	salary s 
	ON s.employee_id = e.id 
WHERE 
	s.to_date = '9999-01-01' AND
	s.amount = (
		SELECT max(s2.amount)	
		FROM salary s2 
	);

--	개발자중 최고 높은 연봉을 받는 직원을 출력한다

SELECT 
	first_name || ' ' || last_name "직원 이름",
	d.dept_name "부서명",
	s.amount "최고 연봉"
FROM
	employee e 
JOIN salary s 
	ON s.employee_id = e.id
JOIN department_employee de 
	ON de.employee_id = e.id 
JOIN department d 
	ON d.id = de.department_id 
WHERE  
	s.to_date = '9999-01-01' AND
	d.dept_name = 'Development' AND
	s.amount = ( 
		SELECT 
			max(s2.amount)
		FROM 
			department_employee de2
		JOIN employee e2 
			ON e2.id = de2.employee_id
		JOIN department d2 
			ON d2.id = de2.department_id
		JOIN salary s2 
			ON s2.employee_id = e2.id
		WHERE 	
			s2.to_date = '9999-01-01' AND 
			d2.dept_name = 'Development'
	);

--	부서번호와 부서별 최고 연봉

SELECT 
	d.dept_name "부서명",
	max(s.amount) "최고 연봉"
FROM
	employee e 
JOIN salary s 
	ON s.employee_id = e.id
JOIN department_employee de 
	ON de.employee_id = e.id 
JOIN department d 
	ON d.id = de.department_id 
GROUP BY d.dept_name;

--
--	최소값 출력하기	
--

-- development 부서의 최저 연봉

SELECT 
	d.dept_name "부서명",
	min(s.amount) "최저 연봉"
FROM
	employee e 
JOIN salary s 
	ON s.employee_id = e.id
JOIN department_employee de 
	ON de.employee_id = e.id 
JOIN department d 
	ON d.id = de.department_id 
GROUP BY d.dept_name
HAVING 
	d.dept_name = 'Development';

--	각 직업의 최저 연봉을 내림차 순으로 출력

SELECT 
	d.dept_name "부서명",
	min(s.amount) "최저 연봉"
FROM
	employee e 
JOIN salary s 
	ON s.employee_id = e.id
JOIN department_employee de 
	ON de.employee_id = e.id 
JOIN department d 
	ON d.id = de.department_id 
GROUP BY d.dept_name
ORDER BY "최저 연봉" DESC;

--
--	평균값 출력
--

SELECT 
	avg(s.amount)::int "평균 연봉" 
FROM
	employee e 
JOIN salary s 
	ON s.employee_id = e.id
JOIN department_employee de 
	ON de.employee_id = e.id 
JOIN department d 
	ON d.id = de.department_id 
	
--
-- 	avg 계산시 주의할점은 null 값은 제외한다는것이다	
--	합산한 결과를 나눌때, 제외된 값은 포함이 안되는 경우가 발생할 수 있다	
--	이러한 부분을 고려해서 처리해야 한다
	
-- 다음은 1, 2, 3, 4 의 평균을 구한다
	
SELECT 	
	avg(nums)	-- 2.5
FROM 
	(
		SELECT 1 AS nums	
		UNION ALL
		SELECT 2	
		UNION ALL
		SELECT 3	
		UNION ALL
		SELECT 4	
	);

--	2.5 는 4로 나누었을때 계산되는 값이다	
--	다음은 1 에 null 을 넣어본다

SELECT 	
	avg(nums)	--	3
FROM 
	(
		SELECT null AS nums	
		UNION ALL
		SELECT 2	
		UNION ALL
		SELECT 3	
		UNION ALL
		SELECT 4	
	);

--	3 이출려된다
--	(2 + 3 + 4) / 3 을 하면 정확히 3 이 나오는것을 볼 수 있다
--	null 값이 평균을 구하는데 포함되야 하는경우가 있다
--	그럴때 COALESCE 를 사용하여 처리한다

SELECT 
	avg(COALESCE(nums, 0))
	FROM (
		SELECT null AS nums	
		UNION ALL
		SELECT 2	
		UNION ALL
		SELECT 3	
		UNION ALL
		SELECT 4	
	);
	
--	아까랑은 다르게 2.25 로 계산되는것을 볼 수 있다
--	(0 + 2 + 3 + 4) / 4  는 2.25 이다
--	4 로 나눈것을 볼수 있다

--
--	SUM
--

-- 각부서멸 모든 월급을 더한 값을 출력하라

SELECT 
	d.dept_name "부서명",
	sum(s.amount) "합계"
FROM
	department_employee de 
JOIN employee e 
	ON de.employee_id = e.id
JOIN department d 
	ON de.department_id  = d.id 
JOIN salary s 
	ON s.employee_id = de.employee_id
GROUP BY d.dept_name
ORDER BY "합계" DESC;

--	토탈연봉이 40000000000 이상인 부서만 출력한다

SELECT 
	d.dept_name "부서명",
	sum(s.amount) "합계"
FROM
	department_employee de 
JOIN employee e 
	ON de.employee_id = e.id
JOIN department d 
	ON de.department_id  = d.id 
JOIN salary s 
	ON s.employee_id = de.employee_id
GROUP BY d.dept_name
HAVING sum(s.amount) >= 40000000000
ORDER BY "합계" DESC;

--
--	count 
--

-- 전체 사원수를 출력하라 

SELECT count(*)
FROM
	employee e; 

--	여기서 다시한번 강조하는 부분은
--	그룹함수는 null 을 무시한다
--	그러므로 그룹함수 사용시 null 을 포함할지 안할지 생각하고 작성해야 한다

