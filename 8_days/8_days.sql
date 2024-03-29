--
--	Primary KEY
--

CREATE TABLE dept2
(
	deptno	int GENERATED BY DEFAULT AS IDENTITY  PRIMARY KEY,
	dname	varchar(14),
	loc 	varchar(10)
);

--	Postgresql 에서 해당 테이블의 PRIMARY KEY 를 확인하는 쿼리 

SELECT *
FROM information_schema.table_constraints
WHERE table_name = 'dept2'
AND constraint_type = 'PRIMARY KEY';

--	삭제하고 ALTER TABLE 을 사용하여 primary key 적용	

DROP TABLE IF EXISTS dept2;

CREATE TABLE dept2
(
	deptno	int GENERATED BY DEFAULT AS IDENTITY ,
	dname	varchar(14),
	loc 	varchar(10)
);

--	primary key 생성이 없어서 검색이 안됨

SELECT *
FROM information_schema.table_constraints
WHERE table_name = 'dept2'
AND constraint_type = 'PRIMARY KEY';

--	primary key 생성

ALTER TABLE dept2
ADD PRIMARY KEY(deptno);

--	dept2_pkey 가 생성된것을 볼 수 있음

SELECT *
FROM information_schema.table_constraints
WHERE table_name = 'dept2'
AND constraint_type = 'PRIMARY KEY';

--	primary key 는 db 가 알아서 명칭을 생성해준다
--	볼때, 테이블명_pkey 방식으로 주키를 생성해주는듯하다
--	명칭을 적용하려면 다음처럼 한다

--	prmary key 를 삭제한다
ALTER TABLE dept2
DROP CONSTRAINT dept2_pkey;

--	primary key 를 dept2_primary_key 로 생성
ALTER TABLE dept2
ADD CONSTRAINT dept2_primary_key PRIMARY KEY(deptno);

--	constraint_name 이 dept2_primary_key 가 된것을 볼 수 있다
SELECT *
FROM information_schema.table_constraints
WHERE table_name = 'dept2'
AND constraint_type = 'PRIMARY KEY';

--	테이블 생성시에도 primary key 처리가 가능하다
--	테이블 생성시 constraint 다음 primary key 이름을 만들수 있다
CREATE TABLE dept3 (
	deptno	int GENERATED BY DEFAULT AS IDENTITY,
	dname	varchar(10),
	d_loc	varchar(10),
	CONSTRAINT dept3_pkey PRIMARY KEY (deptno)
);

--	확인해보면 dept3_pkey 가 생성된것을 볼수 있다
SELECT *
FROM information_schema.table_constraints
WHERE 
	table_name = 'dept3' AND constraint_type = 'PRIMARY KEY';

--	두 테이블 모두 삭제한다
DROP TABLE IF EXISTS dept2;
DROP TABLE IF EXISTS dept3;

--
--	UNIQUE
--

--	테이블 컬럼 중에는 중복된 데이터가 있어서는 안되는 컬럼이 있다
--	이럴때는 `UNIQUE` 제약을 사용하여 테이블의 특정 컬럼에 중복된 데이터가 입력되지 않게 
--	제약을 걸수 있다
--
--	DNAME 컴ㄹ럼에 UNIQUE KEY 제약을 걸어 생성한다

CREATE TABLE dept2
(
	id	int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY ,
	dname	varchar(50) UNIQUE ,
	dloc	varchar(255)
);

--	unique key 로 dept2_dname_key 가 생성된것을 볼 수 있다

SELECT *
FROM information_schema.table_constraints
WHERE
	table_name = 'dept2' AND
	constraint_type = 'UNIQUE';

--	dname 이 development 인 row를 생성한다
INSERT INTO dept2 (dname, dloc)
VALUES (
	'Development',
	'New York'
);

--	dname 이 development 인 row를 다시 생성한다

INSERT INTO dept2 (dname, dloc)
VALUES (
	'Development',
	'Seoule'
);
--	ERROR: duplicate key value violates unique constraint "dept2_dname_key"
--  Detail: Key (dname)=(Development) already exists
--	중복된 columne 이기에 에러를 내뿜는다

--
--	위 같은경우 문제가 심각하다, unique 키를 dname 과 dloc 을 함께 묶어서 처리가능하다
--	기존에 생성된 dept2_dname_key 를 drop 한다

ALTER TABLE dept2
DROP CONSTRAINT dept2_dname_key;

--
--	dname 과 dloc 을 유니크키로 처리한다

ALTER TABLE dept2
ADD UNIQUE (dname, dloc);

--
-- dept2_dname_dloc_key 인 constraint_name 이 생성된것을 볼 수 있다

SELECT *
FROM information_schema.table_constraints
WHERE 
	table_name = 'dept2' AND 
	constraint_type = 'UNIQUE';
	
--	이전과 다르게 insert 되는것을 볼 수 있다

INSERT INTO dept2 (dname, dloc)
VALUES (
	'Development',
	'Seoule'
);

SELECT * FROM dept2;

--	다시 같은 컬럼을 insert 해본다
INSERT INTO dept2 (dname, dloc)
VALUES (
	'Development',
	'Seoule'
);
--  ERROR: duplicate key value violates unique constraint "dept2_dname_dloc_key"
--  Detail: Key (dname, dloc)=(Development, Seoule) already exists.	

--	중복된 키가 있다며, Error 를 내뿜는다

DROP TABLE IF EXISTS dept2;

--
--	NOT NULL
--

CREATE TABLE dept3
(
	id	int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY ,
	dname	varchar(255),
	loc		varchar(255) NOT NULL
)

--	loc 을 not null 처리한다
--	이 역시 constraint key 로 등록된다
--	이때 constraint_type 은 CHECK 이다 

SELECT *
FROM information_schema.table_constraints
WHERE
	table_name = 'dept3' AND 
	constraint_type = 'CHECK'
	
--	총 2개의 constraint_name 이 생성되는데, 하나는 primary key 이며	
--	하나는 loc 에 대한 not_null 이다
	
--	다음처럼 not null 삭제처리도 가능하다	
	
ALTER TABLE dept3
ALTER COLUMN loc DROP NOT NULL;

--	총 2개였던 constraint_name 이 하나로 된것을 볼 수 있다 (Primary key)

SELECT *
FROM information_schema.table_constraints
WHERE
	table_name = 'dept3' AND 
	constraint_type = 'CHECK'

--	다시 not null 을 처리해본다	
	
ALTER TABLE dept3
ALTER COLUMN loc SET NOT NULL;

--	1개였던 constraint_name 이 2개로 된것을 볼 수 있다 
--	새로운 not null 제약조건이 생긴것이다

SELECT *
FROM information_schema.table_constraints
WHERE
	table_name = 'dept3' AND 
	constraint_type = 'CHECK'
	
--	Oracle 하고는 약간 문법이 다르다
--
--	alter table dept6
--	modify loc constraint dept6_loc_nn not null;
--
--	이렇게 처리하는것을 볼 수 있는데,
--	ADD 가 아니라 MODIFY 로 NOT NULL 제약사항을 생성한다고 한다
--
	
DROP TABLE IF EXISTS dept2;
	
--
--	CHECK
--
	
--	다음은 테이블 생성시 sal 값이 0 ~ 6000 사이의 값임을 보장한다

CREATE TABLE emp2
(
	id	int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY , 
	ename	varchar(50),
	sal		NUMERIC(10) CHECK (sal BETWEEN 0  AND 6000 )
);

--	
--	emp2_sal_check 가 생성된것을 볼 수 있다

SELECT *
FROM
	information_schema.table_constraints
WHERE 
	table_name = 'emp2' AND 
	constraint_type = 'CHECK';

--
--	sal 을 5000 을 입력해본다

INSERT INTO emp2 (ename, sal)
VALUES (
	'Mark',
	5000
);

--
--	sal 을 9000 을 입력해본다

INSERT INTO emp2 (ename, sal)
VALUES (
	'Tom',
	9000
);
--ERROR: new row for relation "emp2" violates check constraint "emp2_sal_check"
--  Detail: Failing row contains (2, Tom, 9000).

--	emp2_sal_check 제약조건으로 인해 생성이 불가능하다고 한다
--	

--	6000 이상으로 하려면 해당 제약조건을 삭제해야 한다

ALTER TABLE emp2
DROP CONSTRAINT emp2_sal_check;

--	emp2_sal_check 제약조건을 삭제했으므로 insert 된다

INSERT INTO emp2 (ename, sal)
VALUES (
	'Tom',
	9000
);

--다시 제약조건을 걸어보자

ALTER TABLE emp2
ADD CONSTRAINT emp2_sal_check CHECK (sal BETWEEN 0 AND 6000);

-- ERROR: check constraint "emp2_sal_chekc" of relation "emp2" is 
--	violated by some row

--	이는 옳바르지 않은 row 가 있다고 말한다
--	0 ~ 6000 사이의 sal 값이 있어야 하는데 `Tom` 이 9000 이니
--	해당 제약조건을 생성할수 없다고 한다

UPDATE emp2
SET sal = 6000
WHERE ename = 'Tom';

--	'Tom' 의 월급을 6000 으로 업데이트하고 다시 check 제약조건을 걸어본다 
	
ALTER TABLE emp2
ADD CONSTRAINT emp2_sal_check CHECK (sal BETWEEN 0 AND 6000);

--	제대로 작동한다

SELECT * FROM emp2;

--	constraint_name 이 emp2_sal_check 가 생성된것을 볼수 있다

SELECT *
	FROM information_schema.table_constraints
	WHERE 	table_name = 'emp2'
	AND 	constraint_type = 'CHECK';	

DROP TABLE IF EXISTS emp2;
	
--
--	Foreign key
--

--	사원테이블과 부서 번호에 데이터를 입력할때 부서 테이블에 존재하는 부서 번호만
--	입력 될수 있도록 제약을 생성한다

CREATE TABLE dept2
(
	id 		int	GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY ,
	dname	varchar(50) ,
	loc		varchar(50)
);

CREATE TABLE emp2
(
	id		int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY ,
	ename	varchar(50),	
	sal		int,
	deptno	int REFERENCES dept2(id)
);

--	emp2 에 dept2 에 대한 foreign key 제약조건이 생성된것을 볼수 있다

SELECT *
FROM information_schema.table_constraints
WHERE 
	table_name = 'emp2' AND 
	constraint_type = 'FOREIGN KEY';

--	emp2_deptno_fkey 가 생성되었다
--	dpet2 의 id 인 primary key 값을 삭제해보자

ALTER TABLE dept2
DROP CONSTRAINT dept2_pkey;

-- cannot drop constraint dept2_pkey 
-- on table dept2 because other objects depend on it

--	에러를 보면 dept2 는 다른 객체와 관계가 있기때문에 drop 할수 없다고 한다
--	이는 emp2.deptno 와 dep2.id 값이 foreign key 로 연관지어져 있기 때문에
--	primary key 삭제가 불가능하다

--	이를 처리하려면, emp2 의 foreign key 를 제거한후
--	삭제하거나, cascade 를 사용하여 처리가능하다

--	cascade 옵션을 붙혀본다

ALTER TABLE dept2
DROP CONSTRAINT dept2_pkey CASCADE;

--	cascade 옵션을 붙히면 해당 dept2_pkey 에 연결된 모든
--	컬럼이 삭제된다
--
--	emp2 의 forien key 역시 사라진것을 볼 수 있다

SELECT *
FROM information_schema.table_constraints
WHERE 
	table_name = 'emp2' AND 
	constraint_type = 'FOREIGN KEY';

--	궁금한것이, foreign key 가 삭제되는것을 알겠는데,
--	실제 테이블 데이터도 사라지나?
--
--	다시 dept2_pkey 를 생성후, emp2 에 foreign key 를 생성해보낟

ALTER TABLE dept2
ADD CONSTRAINT dept2_pkey PRIMARY KEY(id); 

ALTER TABLE emp2
ADD CONSTRAINT emp2_deptno_fkey FOREIGN KEY (deptno) REFERENCES dept2 (id)

--	dept2_pkey 와 emp2_deptno_fkey 생성된것을 볼수 있다

SELECT *
FROM information_schema.table_constraints
WHERE 
	table_name = 'dept2' AND 
	constraint_type = 'PRIMARY KEY';

SELECT *
FROM information_schema.table_constraints
WHERE 
	table_name = 'emp2' AND 
	constraint_type = 'FOREIGN KEY';
	
--	insert into 해본다

INSERT INTO dept2
(
	dname,	
	loc
)
VALUES(
	'Development',
	'Soule'
);

INSERT INTO emp2
(
	ename,
	sal,
	deptno 
)
VALUES (
	'Jim',
	2000,
	1
);

ALTER TABLE dept2
DROP CONSTRAINT dept2_pkey CASCADE;

--	데이터는 삭제되지 않고 존재한다

SELECT * FROM emp2;

--	foreign key 제약조건이 없으므로, deptno 에 2 를 생성해본다	
--	dept2 테이블에는 2 id 를 가진 row 가 없다	

INSERT INTO emp2
(
	ename,
	sal,
	deptno 
)
VALUES (
	'Jim',
	2000,
	2
);

--	데이터가 insert 된것을 볼 수 있다

SELECT * FROM emp2;

--
--	WITH AS
--

--	with 절을 이용하여 직업과 직업별 토탈 연봉을 출력하는데,
--	직업별 토탈 연봉들의 평균값보다 더 큰 값들만 출력해본다

EXPLAIN ANALYZE WITH total 
AS (
	SELECT 
		e.dept_name,
		sum(e.amount) AS total_amount
	FROM 
		emp e
	GROUP BY
		e.dept_name
)
SELECT dept_name, total_amount
	FROM total t
	WHERE t.total_amount > (
		SELECT
			avg(total_amount) 
		FROM 
			total
	)
	
--	SQL 내에서 반복되어 사용될때 성능을 높이기 위한 방법으로 
--	with 절을 사용한다	
--
--	위의 예제는 직업과 직업별 토탈 월급을 출력하는 SQL 이
--	두번 반복되는 것을 with 절로 수행한 예이다
--
--	with 절의 동작원리는 temporary tablespace 에 테이블명을 total 로
--	명명 지어서 저장한다
--
--	이 저장된 total 을 불러와서 직업별 토탈 연봉의 평균값보다 높은
--	토탈 연봉을 출력한다
--
--	with 절은 매번 새로 생성하지 않고 저장한 temporary tablespace 에서
--	만들어놓은 테이블을 가져와 비교처리 하기 때문에, 시간을 반으로 
--	줄여 준다고 한다
--
--	위의 결과를 내기위한 서브쿼리는 아래와 같다
--
	
EXPLAIN ANALYZE SELECT 
	e.dept_name,
	sum(e.amount) AS total_amount 
FROM 
	emp e
GROUP BY e.dept_name 
HAVING sum(e.amount) > (
	SELECT
		avg(total_amount)
	FROM 
		(
			SELECT sum(e2.amount) AS total_amount
			FROM emp e2
			GROUP BY e2.dept_name
		)
)

--	책과는 다르고 avg(sum(e2.amount)) 를 하려 하니,
--	aggregtaion function 은 중첩되서는 안된다며 에러를 뿜뿜 한다
--	그래서 본의아니게 subquery 가 2번 중첩되었다
--
--	subquery 실행시 1006.516 ms 가 걸린것을 보면 1 초가 넘는다
--	with 절 사용시 490.936 ms 로 대략 절반정도 시간이 절약된것을 볼 수 있다

--
--	SUBQUERY FACTORING
--

WITH
dept_name_sum_amount AS (
	SELECT 
		dept_name,
		sum(amount) AS total
	FROM 
		emp
	GROUP BY 
		dept_name
),
dept_id_sum_amount AS (
	SELECT
		department_id,
		sum(amount) AS total
	FROM 
		emp
	GROUP BY
		department_id
	HAVING
		sum(amount) > (
			SELECT
				avg(total) + 2000000000
			FROM
				dept_name_sum_amount
		)
)
SELECT department_id, total 
	FROM dept_id_sum_amount;

--	위는 직업별 토탈 평균값에 2000000000 을 더한 값보다 큰
--	부서의 부서 아이디와 토탈 연봉을 출력한다
--	with 절을 사용하면 임시 저장 영역의 임시 테이블에서 참조하므로
--	dept_name_sum_amount 를 참조하여, dept_id_sum_amount 가 사용되고
--	select 문에서는 dept_id_sum_amount 를 참조하여 값을 사용한다
--
--	이렇게 임시 테이블로 생성하는것을 SUBQUERY_FACTORING 이라 한다
--

--
--	구구단 2단 출력하라
--

--	ORACLE 에서는 CONNECT BY LEVEL <= 9 를 사용하는데
--	PostgreSQL 에서는 generate_series(start, end) 
--	를 사용하여 1 부터 9 까지 생성한후 select 로 반복한다

WITH
	loop_table AS (
		SELECT lev AS num 	
			FROM generate_series(1, 9) AS lev 
	)
SELECT '2' || ' x ' || NUM || ' = ' || 2 * num AS "2단"
	FROM loop_table;
	
--	각 row 마다 num 이 1 부터 9까지 생성되는것을 볼 수 있다
--

SELECT lev AS num 	
	FROM generate_series(1, 9) AS lev 
	
--
--	1단 ~ 9단 출력	
--
	
WITH
	loop_num AS (
		SELECT level AS num	
			FROM pg_catalog.generate_series(1, 9) AS level 
	),
	loop_level AS (
		SELECT dan AS dan
			FROM pg_catalog.generate_series(2, 9) AS dan 
	),
	loop_table AS (
		SELECT *
		FROM loop_level
		CROSS JOIN loop_num
	)
SELECT 
	dan || ' x ' || num || ' = ' || dan * num AS 구구단
FROM loop_table;

--
--	직각삼각형
--

WITH loop_table AS (
	SELECT num
	FROM pg_catalog.generate_series(1, 9) AS num
)
SELECT 
	repeat('*', num)
FROM
	loop_table;
	
--	책에서는 repeat 을 사용하지 않고 lpad 를 사용했다

WITH loop_table AS (
	SELECT num
	FROM pg_catalog.generate_series(1, 9) AS num
)
SELECT 
	lpad('*', num, '*')
FROM
	loop_table;
	
--	동일하다
--	lpad 는 num 의 개수자리수만큼 생성하는데 첫번째 자리에 '*' 을 넣고
--	시작하라는 뜻이다. 나머지 자리들은 num 의 개수 - 1 만큼 집어넣는다
--

--
--	삼각형 출력
--

WITH 
loop_table AS (
	SELECT num AS num
	FROM pg_catalog.generate_series(1, 4) AS num 
)
SELECT	lpad(' ', 4 - num, ' ') || lpad('★', num, '★')
	FROM loop_table;
	
--
--	마름모 출력
--

SELECT
	lpad(' ', :p_num - level, ' ') ||
	rpad('★', level, '★') AS star
FROM pg_catalog.generate_series(1, :p_num + 1) level 
UNION ALL
SELECT
	lpad(' ', level, ' ') ||
	rpad('★', :p_num - level, '★') AS star
FROM pg_catalog.generate_series(0, :p_num) level 


