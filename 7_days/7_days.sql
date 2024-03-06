--
--	서브쿼리를 사용하여 데이터 수정
--

--	id 10001 을 가진 고객의 hire_date 로 변경
--

UPDATE employee e
	SET hire_date = (
		SELECT e2.hire_date
			FROM employee e2
			WHERE id = 10001
	)
	WHERE e.first_name = 'JH';
	
SELECT * FROM employee e WHERE e.first_name = 'JH';

--
--	아래는 여러컬럼을 변경하는 쿼리이다
--

UPDATE employee e
	SET (hire_date, birth_date) = (
		SELECT e2.hire_date, e2.birth_date
			FROM employee e2
			WHERE id = 10001
	)
	WHERE e.first_name = 'JH';

SELECT * FROM employee e WHERE e.first_name = 'JH';

--
--	서브쿼리를 사용하여 데이터 삭제
--

--	다음은 fist_name 이 JH 인 고객을 삭제한ㄷ
--	굳이 이렇게 할필요는 없지만, 예시로 서브쿼리를 사용해 delete 할수 있음을 보여준다

DELETE FROM employee 
	WHERE first_name = (
		SELECT first_name	
			FROM employee 
			WHERE first_name = 'JH'
	);
	
SELECT * FROM employee e WHERE first_name = 'JH';	-- 없음

--	다음은 책의 예시이다
--
--	이 책의 예시의 목적은 부서의 평균월급보다 작은 모든 사원을 제거하는거다
--

DELETE FROM emp e1
	WHERE e1.sal > (
		SELECT avg(sal)	
			FROM emp e2
			WHERE e2.deptno = e1.deptno
	)
	
--
--	이는 e1.deptno 과 e2.deptno 을 비교하여 같은 모든 월급의
--	평균을 가져온다
--	이 비교를 통해 해당 사원과 같은 부서인 모든 직원의 평균을 가져온다
--
--	해당 평균과 e1.sal 보다 작으면 해당 직원을 삭제한다 
--

--
--	서브 쿼리를 사용하여 데이터 합치기
--
	
--MERGE INTO dept d
--USING (
--	SELECT deptno, sum(sal) sumsal
--		FROM emp
--		GROUP BY deptno
--) v
--ON (d.deptno = v.deptno)
--WHEN MATCHED THEN 
--	UPDATE SET d.sumsal = v.sumsal;

--	해당 부분 나중에 포스트그래SQL 보면서 좀 파봐야 겠다
--

--
--	계층형 질의문은 문법이 많이 다르다	
--	재귀 형식으로 질의를 하는것 같은데, 이부분은 문법을 좀더 살펴봐야겠다
--
	
--
--	create table
--
	
CREATE TABLE emp01
(
	empno 		integer,
	ename 		varchar(10),
	sal			numeric(10, 2),
	hiredate	date
);

SELECT * FROM emp01;

--	생성을 위한 데이터 타입은 다음과 같다

--
--	bigint
--	bitserial
--	bit
--	bit varying()									--	가변길이 bit
--	boolean						-	bool
--	bytea											--	이진 바이트 배열
--	character (n)				-	char			--	문자
--	character varing (n)							--	가변길이 문자
--	cidr											--	IPv4 or IPv6 네트워크 주소	
--	date											--	달력 날짜(year, month, day)
--	double precision 			- 	float			--	64 비트 부동소수점
--	inet											--	IPv4 or IPv6 host 주소
--	integer						-	int
--	interval[fields] (p)							--	time span		
--	json											--	JSON 데이터
--	jsonb											--	바이너리 JSON 데이터, 
--	macaddr											--	mac 주소
--	macaddr8										--	mac 주소 (EUI-64 format)
--	money											--	통화 금액
--	numberic [ (p, s) ]								--	선택 가능한 정밀도의 정확한 수치
--	real											--	32  비트 부동소수점
--	smallint										--	16 비트 정수
--	smallserial										--	자동증가 16 비트 정수
--	serial											--	자동증가 32 비트 정수
--	text											--	가변 문자열
--	time [ (p) ] [without time zone]				--	time zone 을 포함하지 않은 시간
--	time [ (p) ] [with time zone]					--	time zone 을 포함한 시간
--	timestamp [ (p) ] [without time zone]			--	time zone 을 포함하지 않은 날짜와 시간
--	timestamp [ (p) ] [with time zone]				--	time zone 을 포함한 날짜와 시간
--	tsqurey											--	text search query
--	tsvector										--	text search document
--	uuid											--	고유 식별자
--	xml												--	xml 데이터


--
--	임시 테이블 생성
--

--
--	임시테이블 생성을 COMMIT 할때까지만 유지한다
--	데이터 보관 주기는 다음처럼 처리가능하다

--	ON COMMIT DELETE ROWS
--	임시 테이블에 데이터를 입력하고 COMMIT 될때 데이터 보관
--	약간 글에서 오해가 있을수 있는데, 현재 postgresql 에서는
--	명시한 commit 절까지 같이 실행해야 data 가 나온다
--	commit 절을 같이 실행하지 않으면 data 가 나오지 않는다	
--
--	ON COMMIT PRESERVE ROWS
--	임시 테이블에 데이터를 입력하고 세션이 종료될때까지 데이터 보관

DROP TABLE emp37;

CREATE TEMP TABLE emp37
(
	empno	int,
	ename	varchar(10),
	sal		numeric(10, 2)
) ON COMMIT DELETE ROWS;

-- 같이 실행해야함
INSERT INTO emp37 values(1111, 'smith', 4000);
SELECT * FROM emp37;

COMMIT;
--

DROP TABLE emp38;

CREATE TEMP TABLE emp38
(
	empno	int,
	ename	varchar(10),
	sal		numeric(10, 2)
) ON COMMIT PRESERVE ROWS;

INSERT INTO emp38 values(1111, 'smith', 4000);
SELECT * FROM emp38;

COMMIT;

---	SQL > exit

SELECT * FROM emp38;	-- 없음

---
---	복잡한 쿼리를 단순하게
---

CREATE VIEW view_emp
AS
SELECT e.employee_id, e.amount, e.dept_name, e.department_id
	FROM emp e;

--
--	부서번호와 부서 번호별 평균 월급을 출력하는 VIEW 를 생성
--

CREATE VIEW view_dept_avg
AS 
SELECT
	department_id,
	round(avg(amount))
FROM 
	emp e
	GROUP BY e.department_id;

SELECT * FROM view_dept_avg;

--	복합뷰는 update 시 처리가 되지 않는다
--	이렇게 group by 절 처럼 집계함수를 사용한 뷰를 복합뷰한다

--
--	index
--

--	월급 조회시 검색 속도를 높이기 위해 연봉에 인덱스를 생성

CREATE INDEX idx_salary
ON salary(amount);

--	인덱스가 존재할 경우 검색은 FULL SCAN 이 아닌
--	인덱스를 통해 SCAN 한다
--	
--	인덱스는 컬럼값과 ROWID 값으로 구성되며, ROWID 는 데이터가 있는
--	행의 물리적 주소를 가진다
--	컬럼값은 내림차 순으로 정렬되며, 인덱스를 통해 테이블 엑세스하는 방법은
--	다음과 같다	
--
--	1. 인덱스가 월급을 내림차 순으로 정렬하고 월급 1600(인덱스된 컬럼값) 을 찾는다
--		(ROWID 와 매핑된 컬럼값)
--	2. 인덱스의 ROWID 로 테이블의 해당 ROWID 를 찾아 이름과 월급을 조회한다
--		(ROWID: 물리적 주소값) 
--

--
--	SEQUENCE
--

--	사용할 시퀀스를 생성한다

DROP TABLE emp02;
DROP SEQUENCE seq1;

CREATE SEQUENCE seq1
START WITH 1	--	1 부터 시작
INCREMENT BY 1	--	1 씩 증가
MAXVALUE 100	--	100 까지
NO CYCLE;		--	반복안됨

CREATE TABLE emp02
(
	empno int,
	ename varchar(10),
	sal numeric(10, 2)
);

SELECT * FROM emp02;	-- 데이터 없음

INSERT INTO emp02 
VALUES (
	nextval('seq1'),	--	postgresql 은 함수를 사용하여 호출
						--	oracle 에서는 객체의 프로퍼티처럼 가져온다
						--	시퀀스 값을 1씩 증가한 값을 할당
	'jack',
	3500
);

INSERT INTO emp02
VALUES (
	nextval('seq1'),	--	postgresql 은 함수를 사용하여 호출
						--	oracle 에서는 객체의 프로퍼티처럼 가져온다
						--	시퀀스 값을 1씩 증가한 값을 할당
	'james',
	4500
);

SELECT * FROM emp02;	--	squence 1, 2 까지 생성됨

--
--	실수로 지운 데이터 복구
--
--
--	postgresql 에서는 flashback 이 아닌 다른 방법을 지원한다
--	해당부분은 따로 찾아보도록 하겠다.






