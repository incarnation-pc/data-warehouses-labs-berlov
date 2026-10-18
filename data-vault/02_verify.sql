-- Берлов Марк Валерьевич, группа 223-322, вариант 6.
-- Контроль структуры, данных и восстановления графика из Data Vault.
SELECT table_schema,count(*) AS tables FROM information_schema.tables
 WHERE table_schema IN ('berlov6_3nf','berlov6_dv') AND table_type='BASE TABLE'
 GROUP BY table_schema ORDER BY table_schema;
SELECT * FROM berlov6_dv.current_study_plan ORDER BY group_code,term_code,discipline_code;
WITH source AS (
 SELECT g.code AS group_code,d.code AS discipline_code,d.name AS discipline_name,t.code AS term_code,
 p.lecture_hours,p.practice_hours,p.assessment FROM berlov6_3nf.study_plan p
 JOIN berlov6_3nf.study_group g USING(group_id) JOIN berlov6_3nf.discipline d USING(discipline_id)
 JOIN berlov6_3nf.academic_term t USING(term_id)
), differences AS (
 (SELECT * FROM source EXCEPT SELECT * FROM berlov6_dv.current_study_plan)
 UNION ALL
 (SELECT * FROM berlov6_dv.current_study_plan EXCEPT SELECT * FROM source)
) SELECT count(*) AS differences_3nf_vs_dv FROM differences;
SELECT group_code,term_code,sum(lecture_hours+practice_hours) AS total_hours
 FROM berlov6_dv.current_study_plan GROUP BY group_code,term_code ORDER BY 1,2;
-- Изменение атрибутов записывается новой строкой, старая версия сохраняется.
BEGIN;
INSERT INTO berlov6_dv.sat_study_plan(link_id,load_dts,record_source,lecture_hours,practice_hours,assessment)
 SELECT link_id,'2026-10-18 11:00:00+03','history_demo',lecture_hours,practice_hours+18,assessment
 FROM berlov6_dv.sat_study_plan WHERE link_id=1;
SELECT link_id,load_dts,lecture_hours,practice_hours,record_source
 FROM berlov6_dv.sat_study_plan WHERE link_id=1 ORDER BY load_dts;
ROLLBACK; -- Возвращаем исходный учебный набор после демонстрации истории.
