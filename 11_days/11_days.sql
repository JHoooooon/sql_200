--
--	엑셀 데이터 DB 로드
--

--	남자가 가장 많이 걸리는 암을 찾기 위해 암발생률 관련 csv 를 가져온다
--	국립암센터_24개종 암발생률

DROP TABLE IF EXISTS cancer;

--	cancer 테이블 생성
--	csv 파일과 같은 colume 을 구성
--
CREATE TABLE cancer
(
	발생년도				varchar(20),
	성별					varchar(20),
	국제질병분류			varchar(20),
	암종					varchar(50),
	발생자수				int,
	조발생률				numeric(10, 2),
	연령표준화발생률		numeric(10, 2)
);

--	cancer 테이블에 csv 입력
--	
--	COPY tablename
--	FROM csv file paht DELIMITER 구분자 CSV HEADER;
--
--	이렇게 copy 해준다

COPY cancer	
FROM '/tmp/cancer.csv' DELIMITER ',' CSV HEADER;

--	현재 copy 된 데이터를 가진 cancer 테이블을 볼 수 있다
SELECT * FROM cancer;

-- 	1999 - 2021 년까지 통계상 남자가 가장 많이 걸린 암종은
--	위암이다	

SELECT 
	암종,	
	sum(발생자수)
FROM 
	cancer	
WHERE 
	성별 = '남자' 
	AND
	암종 <> '모든암'
GROUP BY 암종
ORDER BY sum(발생자수) DESC
LIMIT 1;

--
--	스티브 잡스 연설문에서 가장 많이 나오는 단어는?
--
--	책의 예제와는 다르다
--	책의 주소로 가보니 연설문이 없어서, 스텐포드에 해당 연설문 글귀를
--	복사해서 text 로 저장했는데, 책에서 말하는 연설문 길이가 다르다..

CREATE TABLE speech
(
	speech_text varchar(1000)
);

COPY speech
(speech_text)
FROM '/tmp/speech.txt';

SELECT * FROM speech;

SELECT count(*) FROM speech;

--	the 가 가장 많이 나온다
--	총 91 번 나오는것을 볼 있다

WITH words AS (
	SELECT regexp_split_to_table (speech_text, '[ ]') word
	FROM speech
)
SELECT 
	RANK() OVER (ORDER BY count(word) DESC),
	word,
	count(word)
FROM words
WHERE
	word IS NOT NULL
GROUP BY word
ORDER BY count(word) DESC

--
--	절도가 많이 발생하는 요일은 언제인가?
--

--	경찰청 범죄 통계 데이터를 이용하여 절도가 가장 많이 발생하는 요일을 찾아보자
--
set client_encoding to 'UTF8';
DROP TABLE IF EXISTS crime_day;

CREATE TABLE crime_day
(
	crime_type		varchar(50),	
	sun_cnt			int,	
	mon_cnt			int,	
	tue_cnt			int,	
	wed_cnt			int,	
	thu_cnt			int,	
	fri_cnt			int,	
	sat_cnt			int	
);

COPY crime_day
FROM '/tmp/crime_day.csv'
DELIMITER ',' CSV HEADER 


--	unpivot 을 사용하여 처리한다	
--	unpivot 은 가로로 정렬된 테이블을 세로로 표시한다

SELECT * FROM crime_day;

--	결과를 보면 알겠지만, 해당 테이블은 가로로 표시되어있다
--	이를 세로로 표시하기 위해서 다음과 같은 방법을 사용할수 있다
--	표시하기 위한 컬럼은 day_cnt, cnt, rank 컬럼을 만든다.
--	다음은 각 날짜별로 일어난 범죄를 전부 합친 cnt 를 쿼리한다

SELECT
	day_cnt,
	cnt,
	RANK() OVER (ORDER BY cnt DESC)
FROM (
	SELECT 
		'SUN_CNT' AS day_cnt,
		sum(sun_cnt) AS cnt
	FROM 
		crime_day cd 
	UNION ALL 
	SELECT 
		'MON_CNT' AS day_cnt,
		sum(mon_cnt) AS cnt
	FROM 
		crime_day cd 
	UNION ALL 
	SELECT 
		'TUE_CNT' AS day_cnt,
		sum(tue_cnt) AS cnt
	FROM 
		crime_day cd 
	UNION ALL 
	SELECT 
		'WED_CNT' AS day_cnt,
		sum(wed_cnt) AS cnt
	FROM 
		crime_day cd 
	UNION ALL 
	SELECT 
		'THU_CNT' AS day_cnt,
		sum(thu_cnt) AS cnt
	FROM 
		crime_day cd 
	UNION ALL 
	SELECT 
		'FRI_CNT' AS day_cnt,
		sum(fri_cnt) AS cnt
	FROM 
		crime_day cd 
	UNION ALL 
	SELECT 
		'SAT_CNT' AS day_cnt,
		sum(sat_cnt) AS cnt
	FROM 
		crime_day cd
)

--	위를 보면 알겠지만, 가로로 나열되어있는 테이블을 세로로 만들기 위해 
--	새로운 컬럼을 임의로 만들고 union all 을 사용하여 합친다
--	매우 불편한 상황이다
--	아래는 postgersql 에서 제공하는 lateral 이다
--	lateral 은 뜻으로 옆에, 옆쪽에 라는 뜻을 가지는데,
--	왼쪽 테이블의 각 행에대해 오른쪽 테이블을 사용하거나 참조할때 사용한다	
--	이는 values(...) (column1, column2) on true
--	형식으로 사용될때 unpivot 처럼 활용된다
--
--	아래를 보면 values 를 사용하여 새로운 테이블을 만드는데,
--	'sun_cnt', crime_day.sun_cnt 컬럼값을 가지는 테이블을 만든다
--	그리고 이렇게 만들어진 두개의 컬럼에 이름을 day_cnt, cnt 별칭을 붙힌다
--	

SELECT * FROM crime_day cd ;
	
SELECT *
FROM (
	SELECT 
		crime_type,
		day_cnt,
		cnt,
		RANK () OVER (ORDER BY cnt DESC)
	FROM crime_day cd 
	JOIN LATERAL (
		VALUES 
			('sun_cnt', sun_cnt), 
			('mon_cnt', mon_cnt), 
			('tue_cnt', tue_cnt), 
			('wed_cnt', wed_cnt), 
			('thu_cnt', thu_cnt), 
			('fri_cnt', fri_cnt), 
			('sat_cnt', sat_cnt) 
	) s(day_cnt, cnt) ON TRUE
	WHERE trim(crime_type) = '절도'
)
WHERE
	RANK = 1;


--	이렇게 하면 unpivot 을 구현 가능하다

--
--	우리나라에서 대학 등록금이 가장 높은 학교는 어디인가?	
--

DROP TABLE IF EXISTS university_fee;

CREATE TABLE university_fee (
	division			varchar(20),
	type			 	varchar(20),
	university			varchar(20),
	loc					varchar(20),
	admission_cnt		varchar(20),
	admission_fee		varchar(20),
	tuition_fee	 		varchar(20)
)

COPY university_fee	
FROM '/tmp/university_fee.csv' DELIMITER ',' CSV HEADER;

--	책에서 제공한 방식은 아래와 같다
--	with 문은 내가 작성했지만, 책에서는 서브쿼리를 사용했다
--	actual time 이 2.608 로 나오더라

EXPLAIN ANALYZE WITH rank_table AS (
	SELECT
		university,
		tuition_fee,
		RANK() OVER (ORDER BY tuition_fee DESC NULLS LAST) AS rank
	FROM
		university_fee u
)
SELECT
	*
FROM rank_table
WHERE
	RANK = 1;

--	아래처럼 해도 되지 않을까 싶어서 했는데, 가능은 했다
--	아래로 했을때 0.552 로 처리되었다.
--	이렇게 하는게 더 나은건가?
--

EXPLAIN ANALYZE SELECT
	university,
	tuition_fee,
	RANK () OVER (ORDER BY tuition_fee DESC NULLS LAST)
FROM 
	university_fee
WHERE 
	tuition_fee = (
		SELECT
			max(tuition_fee)
		FROM
			university_fee
	);
