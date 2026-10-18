-- Берлов Марк Валерьевич, группа 223-322, вариант 6.
-- ЛР №2. Вариант 6. Учебный график дисциплин факультета.
-- PostgreSQL 14+. Выполнять в отдельной учебной БД.
-- Повторный запуск удаляет только учебные схемы berlov6_3nf и berlov6_dv.
BEGIN;
DROP SCHEMA IF EXISTS berlov6_dv CASCADE;
DROP SCHEMA IF EXISTS berlov6_3nf CASCADE;
CREATE SCHEMA berlov6_3nf;
CREATE SCHEMA berlov6_dv;
SET search_path=berlov6_3nf;

-- Справочники. Код является устойчивым бизнес-ключом.
CREATE TABLE faculty (
 faculty_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 code text NOT NULL UNIQUE, name text NOT NULL
);
CREATE TABLE study_group (
 group_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 code text NOT NULL UNIQUE, faculty_id bigint NOT NULL REFERENCES faculty,
 admission_year integer NOT NULL CHECK(admission_year BETWEEN 2000 AND 2100)
);
CREATE TABLE discipline (
 discipline_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 code text NOT NULL UNIQUE, name text NOT NULL
);
CREATE TABLE academic_term (
 term_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 code text NOT NULL UNIQUE, starts_on date NOT NULL, ends_on date NOT NULL,
 CHECK(ends_on > starts_on)
);
-- Зерно учебного графика: одна дисциплина одной группы в одном семестре.
CREATE TABLE study_plan (
 plan_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 group_id bigint NOT NULL REFERENCES study_group,
 discipline_id bigint NOT NULL REFERENCES discipline,
 term_id bigint NOT NULL REFERENCES academic_term,
 lecture_hours integer NOT NULL CHECK(lecture_hours>=0),
 practice_hours integer NOT NULL CHECK(practice_hours>=0),
 assessment text NOT NULL CHECK(assessment IN ('Экзамен','Зачёт')),
 UNIQUE(group_id,discipline_id,term_id),
 CHECK(lecture_hours+practice_hours>0)
);
COMMENT ON TABLE study_plan IS 'Учебная нагрузка группы по дисциплине за семестр';

INSERT INTO faculty(code,name) VALUES ('FIT','Факультет информационных технологий');
INSERT INTO study_group(code,faculty_id,admission_year)
 VALUES ('223-322',1,2022),('223-323',1,2022);
INSERT INTO discipline(code,name) VALUES
 ('DWH','Хранилища данных'),('DB','Базы данных'),('IS','Проектирование информационных систем'),
 ('NET','Компьютерные сети'),('ALG','Алгоритмы и структуры данных'),('SEC','Информационная безопасность');
INSERT INTO academic_term(code,starts_on,ends_on) VALUES
 ('2026-AUT','2026-09-01','2027-01-31'),('2027-SPR','2027-02-01','2027-06-30');
INSERT INTO study_plan(group_id,discipline_id,term_id,lecture_hours,practice_hours,assessment)
 SELECT g.group_id,d.discipline_id,CASE WHEN d.discipline_id<=3 THEN 1 ELSE 2 END,
  CASE WHEN d.code IN ('DWH','DB','ALG') THEN 36 ELSE 18 END,
  36,CASE WHEN d.code IN ('DWH','DB','ALG') THEN 'Экзамен' ELSE 'Зачёт' END
 FROM study_group g CROSS JOIN discipline d;

SET search_path=berlov6_dv;
-- Hub: бизнес-ключ, суррогатный ключ, время загрузки, источник.
-- Satellite: описательные атрибуты и полная история версий.
-- Link: устойчивые связи между бизнес-ключами.
CREATE TABLE hub_faculty (
 faculty_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 business_key text NOT NULL UNIQUE,
 load_dts timestamptz NOT NULL DEFAULT clock_timestamp(),
 record_source text NOT NULL
);
CREATE TABLE sat_faculty (
 faculty_id bigint NOT NULL REFERENCES hub_faculty,
 load_dts timestamptz NOT NULL,
 record_source text NOT NULL, name text NOT NULL,
 PRIMARY KEY(faculty_id,load_dts)
);
CREATE TABLE hub_group (
 group_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 business_key text NOT NULL UNIQUE,
 load_dts timestamptz NOT NULL DEFAULT clock_timestamp(),
 record_source text NOT NULL
);
CREATE TABLE sat_group (
 group_id bigint NOT NULL REFERENCES hub_group,
 load_dts timestamptz NOT NULL,
 record_source text NOT NULL, admission_year integer NOT NULL,
 PRIMARY KEY(group_id,load_dts)
);
CREATE TABLE hub_discipline (
 discipline_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 business_key text NOT NULL UNIQUE,
 load_dts timestamptz NOT NULL DEFAULT clock_timestamp(),
 record_source text NOT NULL
);
CREATE TABLE sat_discipline (
 discipline_id bigint NOT NULL REFERENCES hub_discipline,
 load_dts timestamptz NOT NULL,
 record_source text NOT NULL, name text NOT NULL,
 PRIMARY KEY(discipline_id,load_dts)
);
CREATE TABLE hub_term (
 term_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 business_key text NOT NULL UNIQUE,
 load_dts timestamptz NOT NULL DEFAULT clock_timestamp(),
 record_source text NOT NULL
);
CREATE TABLE sat_term (
 term_id bigint NOT NULL REFERENCES hub_term,
 load_dts timestamptz NOT NULL,
 record_source text NOT NULL, starts_on date NOT NULL, ends_on date NOT NULL,
 PRIMARY KEY(term_id,load_dts)
);
CREATE TABLE link_group_faculty (
 link_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 group_id bigint NOT NULL REFERENCES hub_group,
 faculty_id bigint NOT NULL REFERENCES hub_faculty,
 load_dts timestamptz NOT NULL, record_source text NOT NULL,
 UNIQUE(group_id,faculty_id)
);
CREATE TABLE link_study_plan (
 link_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 group_id bigint NOT NULL REFERENCES hub_group,
 discipline_id bigint NOT NULL REFERENCES hub_discipline,
 term_id bigint NOT NULL REFERENCES hub_term,
 load_dts timestamptz NOT NULL, record_source text NOT NULL,
 UNIQUE(group_id,discipline_id,term_id)
);
CREATE TABLE sat_study_plan (
 link_id bigint NOT NULL REFERENCES link_study_plan,
 load_dts timestamptz NOT NULL, record_source text NOT NULL,
 lecture_hours integer NOT NULL CHECK(lecture_hours>=0),
 practice_hours integer NOT NULL CHECK(practice_hours>=0),
 assessment text NOT NULL CHECK(assessment IN ('Экзамен','Зачёт')),
 PRIMARY KEY(link_id,load_dts), CHECK(lecture_hours+practice_hours>0)
);

-- Демонстрационная загрузка 3NF -> Data Vault.
INSERT INTO hub_faculty(business_key,load_dts,record_source)
 SELECT code,'2026-10-18 10:00:00+03','berlov6_3nf.faculty' FROM berlov6_3nf.faculty ORDER BY faculty_id;
INSERT INTO sat_faculty(faculty_id,load_dts,record_source,name)
 SELECT h.faculty_id,'2026-10-18 10:00:00+03','berlov6_3nf.faculty',s.name
 FROM berlov6_3nf.faculty s JOIN hub_faculty h ON h.business_key=s.code;
INSERT INTO hub_group(business_key,load_dts,record_source)
 SELECT code,'2026-10-18 10:00:00+03','berlov6_3nf.study_group' FROM berlov6_3nf.study_group ORDER BY group_id;
INSERT INTO sat_group(group_id,load_dts,record_source,admission_year)
 SELECT h.group_id,'2026-10-18 10:00:00+03','berlov6_3nf.study_group',s.admission_year
 FROM berlov6_3nf.study_group s JOIN hub_group h ON h.business_key=s.code;
INSERT INTO hub_discipline(business_key,load_dts,record_source)
 SELECT code,'2026-10-18 10:00:00+03','berlov6_3nf.discipline' FROM berlov6_3nf.discipline ORDER BY discipline_id;
INSERT INTO sat_discipline(discipline_id,load_dts,record_source,name)
 SELECT h.discipline_id,'2026-10-18 10:00:00+03','berlov6_3nf.discipline',s.name
 FROM berlov6_3nf.discipline s JOIN hub_discipline h ON h.business_key=s.code;
INSERT INTO hub_term(business_key,load_dts,record_source)
 SELECT code,'2026-10-18 10:00:00+03','berlov6_3nf.academic_term' FROM berlov6_3nf.academic_term ORDER BY term_id;
INSERT INTO sat_term(term_id,load_dts,record_source,starts_on,ends_on)
 SELECT h.term_id,'2026-10-18 10:00:00+03','berlov6_3nf.academic_term',s.starts_on,s.ends_on
 FROM berlov6_3nf.academic_term s JOIN hub_term h ON h.business_key=s.code;
INSERT INTO link_group_faculty(group_id,faculty_id,load_dts,record_source)
 SELECT hg.group_id,hf.faculty_id,'2026-10-18 10:00:00+03','berlov6_3nf.study_group'
 FROM berlov6_3nf.study_group g JOIN berlov6_3nf.faculty f USING(faculty_id)
 JOIN hub_group hg ON hg.business_key=g.code JOIN hub_faculty hf ON hf.business_key=f.code;
INSERT INTO link_study_plan(group_id,discipline_id,term_id,load_dts,record_source)
 SELECT hg.group_id,hd.discipline_id,ht.term_id,'2026-10-18 10:00:00+03','berlov6_3nf.study_plan'
 FROM berlov6_3nf.study_plan p JOIN berlov6_3nf.study_group g USING(group_id)
 JOIN berlov6_3nf.discipline d USING(discipline_id) JOIN berlov6_3nf.academic_term t USING(term_id)
 JOIN hub_group hg ON hg.business_key=g.code JOIN hub_discipline hd ON hd.business_key=d.code
 JOIN hub_term ht ON ht.business_key=t.code ORDER BY p.plan_id;
INSERT INTO sat_study_plan(link_id,load_dts,record_source,lecture_hours,practice_hours,assessment)
 SELECT l.link_id,'2026-10-18 10:00:00+03','berlov6_3nf.study_plan',p.lecture_hours,p.practice_hours,p.assessment
 FROM berlov6_3nf.study_plan p JOIN berlov6_3nf.study_group g USING(group_id)
 JOIN berlov6_3nf.discipline d USING(discipline_id) JOIN berlov6_3nf.academic_term t USING(term_id)
 JOIN hub_group hg ON hg.business_key=g.code JOIN hub_discipline hd ON hd.business_key=d.code
 JOIN hub_term ht ON ht.business_key=t.code
 JOIN link_study_plan l ON l.group_id=hg.group_id AND l.discipline_id=hd.discipline_id AND l.term_id=ht.term_id;

-- Представление текущих версий спутников для удобного чтения графика.
CREATE VIEW current_study_plan AS
 SELECT g.business_key AS group_code,d.business_key AS discipline_code,
 sd.name AS discipline_name,t.business_key AS term_code,
 s.lecture_hours,s.practice_hours,s.assessment
 FROM link_study_plan l JOIN hub_group g USING(group_id)
 JOIN hub_discipline d USING(discipline_id) JOIN hub_term t USING(term_id)
 JOIN LATERAL (SELECT * FROM sat_discipline s WHERE s.discipline_id=d.discipline_id
  ORDER BY load_dts DESC LIMIT 1) sd ON true
 JOIN LATERAL (SELECT * FROM sat_study_plan s WHERE s.link_id=l.link_id
  ORDER BY load_dts DESC LIMIT 1) s ON true;
COMMIT;
