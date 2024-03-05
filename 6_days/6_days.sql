--
--	단일행 서브쿼리
--

-- Adit Cullers 보다 월급이 높은 사람을 출력

SELECT 
	e.name, 
	e.amount 
FROM emp e;

SELECT 
	e.name, 
	e.amount 
FROM emp e
WHERE e.amount > (
	SELECT
		e2.amount
	FROM 
		emp e2 
	WHERE
		e2.name = 'Adit Cullers' -- 87437
);

--	다음은 Adit Cullers 와 같은 월급을 가진사람을 출력한다

SELECT 
	e.name, 
	e.amount 
FROM emp e;

SELECT 
	e.name, 
	e.amount 
FROM emp e
WHERE e.amount = (
	SELECT
		e2.amount
	FROM 
		emp e2 
	WHERE
		e2.name = 'Adit Cullers' -- 87437
);

--	'Adit Cullers' 도 포함된 결과가 있는것을 볼 수 있다
--	'Adit Cullers' 를 제외한 나머지를 출력해본다

SELECT 
	e.name, 
	e.amount 
FROM emp e;

SELECT 
	e.name, 
	e.amount 
FROM emp e
WHERE 
	e.amount = (
		SELECT
			e2.amount
		FROM 
			emp e2 
		WHERE
			e2.name = 'Adit Cullers' -- 87437
	) AND 
	e.name != 'Adit Cullers';
	
--
--	다중행 서브쿼리
--

--	다음은 Development 부서의 모든 직원의 월급의 집합중 하나라도 같은
--	월급을 가진 사원을 출력한다

SELECT
	e.name,	
	e.dept_name,
	e.amount
FROM 
	emp e
WHERE
	e.amount IN (
		SELECT 	
			e2.amount
		FROM 
			emp e2
		WHERE 
			e2.dept_name = 'Development'
	);
	

--	다중 행 서브쿼리의 연산자는 다음의 연산자를 사용해야 한다
--
--	in:	리스트 값과 동일
--	not in:	리스트 값과 동일하지 않은
--	>all:	리스트에서 가장 큰 값보다 큰	
--	<all:	리스트 에서 가장 작은 값보다 작은
--	>any:	리스트에서 가장 작은 값보다 큰
--	<any:	리스트에서 가장 큰 값보다 작은

--
--	NOT IN
--
--	부서번호가 d001, d002 만 제외한 사원들을 가져온다

SELECT
	e."name", 
	e.amount ,
	e.dept_name 
FROM
	emp e
WHERE 
	e.dept_name NOT IN (
		SELECT e2.dept_name 	
		FROM 
			emp e2 
		WHERE 	
			e2.department_id IN ('d001', 'd002')
	);

--
--	exists 와 not exists
--

--	사원이 있는 부서를 찾는 쿼리

SELECT 
	*	
FROM 
	department d 
WHERE EXISTS (
	SELECT 
		*
	FROM emp e2 
	WHERE 
		e2.department_id = d.id  
)

--	사원이 없는 부서를 찾는 쿼리	

SELECT 
	*	
FROM 
	department d 
WHERE NOT EXISTS (
	SELECT 
		*
	FROM emp e2 
	WHERE 
		e2.department_id = d.id  
)

--	사원이 없는 쿼리가 없으므로, 아무것도 출력하지 않는다

--
--	HAVING  절 서브쿼리
--

--	다음은 Sales 의 토탈 연봉보다 큰 부서를 쿼리한다

SELECT 
	e.dept_name,
	sum(e.amount)
FROM 
	emp e
GROUP BY e.dept_name 
HAVING sum(e.amount) > (
	SELECT sum(e2.amount)
	FROM emp e2 
	WHERE 
		e2.dept_name = 'Sales'
);

--	SELECT 문에서 서브 쿼리문을 사용할수 있는 절은 다음과 같다
--
--	SELECT:		가능 | 스칼라 서브 쿼리
--	FROM: 		가능 | IN LINE VIEW
--	WHERE: 		가능 | 서브 쿼리
--	GROUP BY: 	불가능
--	HAVING:		가능 | 서브 쿼리
--	ORDER BY:	가능 | 스칼라 서브 쿼리

--
--	FROM 절 서브쿼리
--

--	연봉을 제일 많이 받는 사원의 랭크와 이름, 연봉을 출력

SELECT 
	v.rank,
	v.name,
	v.amount
FROM 
	(
		SELECT 	
			e.name name,
			e.amount amount,
			RANK () OVER (
				ORDER BY e.amount DESC
			) rank
		FROM 
			emp e 
	) v
WHERE v.rank = 1;
	
	
-- 	위와 같이 FROM 절에 서브쿼리를 사용하는것을	
--	inline view 라고 한다	

--
--	select 절의 서브쿼리
--

--	Sales 사원들의 이름과 연봉을 출력하는데, Sales 사원들의 최대 연봉과 최소 연봉도 같이 출력하라

SELECT
	e.name name,
	e.amount amount, 
	(
		SELECT max(e2.amount)
			FROM
				emp e2 
			WHERE 
				e2.dept_name = 'Sales'
	) max_amount,
	(
		SELECT min(e3.amount)
			FROM
				emp e3 
			WHERE 
				e3.dept_name = 'Sales'
	) min_amount
FROM 
	emp e 
WHERE
	e.dept_name = 'Sales';
	
--	select 절의 서브쿼리는 서브 쿼리가 select 절로 확장되었다고 해서
--	스칼라 서브쿼리라고 부른다
--
--	스칼라 서브 쿼리는 출력되는 행 수만큼 반복되어 실행한다
--
--	이는 SQL 이 해당 행수 만큼 반복되면서, 같은 데이터를 출력하므로
--	성능을 최대 월급과 최소 월급을 메모리에 올려놓고
--	두번째 행에서 올려놓은 최대 월급과 최소 월급을 참조하여 가져와 재사용한다
--
--	이는 매 쿼리마다 서브쿼리를 실행하지 않도록 하는, 좋은 방식이다
--	이를 서브 쿼리 캐싱이라 한다
--

--
--	데이터 입력
--
--
--INSERT INTO employee (birth_date, first_name, last_name, hire_date, gender)
--VALUES (...)
--

--	이렇게 테이블에 데이터를 입력하고 수정하고 삭제하는 SQL 문을 DML 문이라고 한다
--	Data Manipulation Language
--
--	insert, update, delete, merge

--
--	update
--

--	다음은 사원의 월급을 업데이트하는 쿼리이다

--UPDATE salary 
--	SET to_date = current_date 
--	WHERE employee_id = ???
--
--INSERT INTO salary ( employee_id, amount, from_date, to_date) 
--	VALUES (
--		???,
--		50000,
--		current_date,
--		'9999-01-01'::date
--	);

--	모든 update 쿼리문은 서브쿼리가 가능하다
--
--	update:	서브 쿼리 가능
--	set:	서브 쿼리 가능
--	where:	서브 쿼리 가능
--

--
--	delete, truncate, drop
--

--DELETE FROM employee e
--WHERE e.first_name = '???'

--	delete 는 DML 이지만 truncate, drop 은 DDL 이다
--	delete 는 데이터만 삭제하지만,
--	truncate, drop 은 데이터, 저장공간을 삭제한다
--	반면 truncate 는 저장 구조는 남기지만,
--	drop 은 저장구조까지 삭제한ㄷ
--
--	delete 는 삭제후 취소가 가능하지만 truncate 는 그냥 삭제해 버린다
--	그러므로, 속도는 delete 보다 빠르다
--
--	drop 은 테이블 전체를 삭제하며, ROLLBACK 은 안되지만, 
--	FLASHBACK 으로 테이블 복구는 가능하다	
--
--	FLASHBACK 은 오라클에서 제공하는 데이터 원복 처리 기능이다
--	PostgreSQL 에서는 transaction 시 이를 snapshot 형식으로 처리하고 있는것 같은데,
--	이 부분은 PostgreSQL 을 좀더 공부하고 살펴봐야겠다
--
--	FLASHBACK 은 undo 기능이다.
--	간단하게 말하자면 undo_retention 이 존재하고
--	이 지정된 undo_retention 기간만큼 해당 데이터를 저장해두었다가 
--	필요시 undo 기능을 사용하여 다시 되돌린다
--
--	이는 ROLLBACK 과는 다른 개념으로, 설정한 기간만큼만 데이터를 보관하고,
--	기간이 지나면 삭제처리된다

--
--

BEGIN TRANSACTION;

INSERT INTO employee (first_name, last_name, birth_date, hire_date, gender)
VALUES ('JH', 'G', '1988-08-22', '2023-3-20', 'M');

COMMIT;

UPDATE employee 
	SET hire_date = '2023-03-10'
WHERE first_name = 'JH';

ROLLBACK;

--	트랜잭션 실행시 COMMIT 을 사용하여 해당 위치까지 이루어진 쿼리는
--	실행하지만, 그 이후 ROLLBACK 을 만나면 이전까지의 쿼리를 COMMIT 이후로
--	되돌린다
--
--	이를 TCL 이라고 한다
--	Transection Control Language
--	이 외에도 SAVEPOINT 가 있다
--	이는 특정 지점까지 변경을 취소한다

SELECT * FROM employee e WHERE first_name = 'JH';

--
--	LOCK
--

--	터미널 창1 에서 JONES 의 월급을 3000 으로 변경
--	그후 터미널 창2 에서 JONES 의 월급을 9000 으로 변경
--	터미널 창 1 에 접속한 SCOTT 세션이 JONES 행을 갱신하고
--	아직 COMMIT 이나 ROLLBACK 을 수행하지 않았기에 해당 행은 잠겨있다
--
--	UPDATE 문을 수행하면 UPDATE 대상이 되는 ROW 를 LOCKING 해 버린다
--
--	UPDATE 행 전체를 잠그기 때문에 JONES 월급 뿐만 아니라 다른 컬럼들의
--	데이터도 변경할수 없고 WAITING 하게 된다
--
--	터미널 창1 에서 COMMIT 을 수행하면, JONES 월급은 3000 으로 저장되고
--	행에 걸린 LOCK 은 해제된다
--
--	그다음, 터미널 창2 는 JONES 의 월급을 9000 으로 수정할수 있게 된다
--
--	이렇게 UPDATE 할때, LOCK 을 거는 이유는 데이터의 일관성을 보장하기 위함이다
--	터미널 창 1 은 자기가 변경한 데이터를 커밋하기 전까지 일관되게 유지되어야 한다
--	이를 LOCK 을 사용하여 이를 처리한다
--

--
-- 	SELECT FROM UPDATE 절
--

--	SELECT ... FOR UPDATE 는 검색하는 행에 락을 거는 SQL 문이다
--
--	터미널 1 에서 SELECT ... FOR UPDATE 문으로 JONES 데이터를 검색한다
--	JONES 행에 자동으로 LOCK 이 걸린다
--
--	터미널 2 에서 월급을 9000 으로 변경하면 변경이 안되고 WAITING 된다
--	터미널 1 에서 COMMIT 을 수행하면 LOCK 이 해제되고
--	터미널 2 창의 UPDATE 문이 수행된다
--
--	개념상으로 일단 이해하자.
--	데이터 일관성을 위해 SELECT 에도 락을 걸수 있다

--
--	서브 쿼리를 사용하여 데이터 입력
--

--	다음은 서브퀄리를 사용하여, insert 한다
--
INSERT INTO employee (first_name, last_name, gender, hire_date, birth_date)
SELECT 
	e.first_name , e.last_name , e.gender , e.hire_date , e.birth_date  
	FROM employee e
WHERE 
		e.first_name = 'JH';
	
SELECT * FROM employee e WHERE e.first_name = 'JH';

--	테이블 생성도 가능하다	
--
--	모든 테이블과 로우를 복사한 새로운 테이블이다
CREATE TABLE emp2
	AS
		SELECT * FROM employee e;
	
SELECT * FROM emp2;

--	다음은 테이블 구조만 생성한 새로운 테이블을 생성한다

CREATE TABLE emp3
	AS
		SELECT * FROM employee e
		WHERE 1 = 2;
	
--	생성된 data 가 없다.
SELECT * FROM emp3;
	
--	삭제한다
DROP TABLE emp2;
DROP TABLE emp3;

