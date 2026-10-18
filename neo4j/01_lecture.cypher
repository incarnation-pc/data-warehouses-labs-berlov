// Берлов Марк Валерьевич, группа 223-322, вариант 6.
// Практические примеры лекции №7, слайды 12–18, синтаксис Neo4j 5.
// Удаляются исключительно узлы примеров с меткой BerlovLecture.
MATCH (n:BerlovLecture) DETACH DELETE n;
CREATE (n:BerlovLecture:Person {name:'Mike'}) RETURN n.name AS created;
CREATE (:BerlovLecture:Person {name:'Anna'}),(:BerlovLecture:Person {name:'Alex'}),
 (:BerlovLecture:Movie {title:'Matrix'}),(:BerlovLecture:Movie {title:'The Terminator'});
MATCH (n:BerlovLecture) RETURN labels(n) AS labels,properties(n) AS attributes LIMIT 25;
MATCH (a:BerlovLecture:Person {name:'Mike'}),(b:BerlovLecture:Person {name:'Anna'})
 MERGE (a)-[:MARRIED]->(b);
MATCH (a:BerlovLecture:Person {name:'Mike'}),(b:BerlovLecture:Person {name:'Alex'})
 MERGE (a)-[:FRIENDS]->(b);
MATCH (a:BerlovLecture:Person {name:'Alex'}),(b:BerlovLecture:Movie {title:'The Terminator'})
 MERGE (a)-[:FAVORITE]->(b);
MATCH (a:BerlovLecture)-[r]->(b:BerlovLecture)
 RETURN coalesce(a.name,a.title) AS source,type(r) AS relation,coalesce(b.name,b.title) AS target;

// В лекции для следующих запросов использован словарь, но сам набор не приложен.
// Минимальный учебный набор слов позволяет выполнить те же операции.
CREATE (a:BerlovLecture:Word {name:'бежать'}),(b:BerlovLecture:Word {name:'двигаться'}),
 (c:BerlovLecture:Word {name:'парить'}),(d:BerlovLecture:Word {name:'прямой'}),
 (e:BerlovLecture:Word {name:'форма'}),(f:BerlovLecture:Word {name:'толстый'}),
 (g:BerlovLecture:Word {name:'воровать'}),(h:BerlovLecture:Word {name:'профессия'}),
 (:BerlovLecture:Word {name:'изолированный пример'}),
 (a)-[:HYPERONYMY]->(b),(c)-[:HYPERONYMY]->(b),
 (d)-[:HYPERONYMY]->(e),(f)-[:HYPERONYMY]->(e),(g)-[:RELATED_TO]->(h);
// START заменён на MATCH; поиск выполняется по полученному elementId.
MATCH (n:BerlovLecture {name:'Mike'}) WITH elementId(n) AS wanted
 MATCH (found:BerlovLecture) WHERE elementId(found)=wanted RETURN found.name,elementId(found);
MATCH (n:BerlovLecture) WHERE n.name IN ['Mike','Anna'] RETURN n.name,elementId(n);
MATCH (n:BerlovLecture) WHERE n.name='профессия' RETURN n.name;
// HAS(n.name) заменён на IS NOT NULL.
MATCH (n:BerlovLecture) WHERE n.name IS NOT NULL RETURN n.name ORDER BY n.name;
MATCH (n:BerlovLecture) WHERE EXISTS {(n)-[:HYPERONYMY]->()} RETURN n.name;
MATCH (n:BerlovLecture) RETURN count(n) AS lecture_nodes;
MATCH (:BerlovLecture)-[r]->(:BerlovLecture) RETURN count(r) AS lecture_relationships;
MATCH (n:BerlovLecture {name:'воровать'})--(a) RETURN n.name,a.name;
MATCH (n:BerlovLecture) WHERE NOT (n)--() RETURN coalesce(n.name,n.title) AS isolated;
MATCH (n:BerlovLecture) WHERE NOT (n)--() DELETE n;
MATCH (n:BerlovLecture) WHERE NOT (n)--() RETURN count(n) AS isolated_after_delete;
MATCH (a:BerlovLecture {name:'бежать'}),(b:BerlovLecture {name:'парить'}),
 p=shortestPath((a)-[*..5]-(b)) RETURN [n IN nodes(p)|n.name] AS shortest_path;
MATCH (a:BerlovLecture {name:'прямой'}),(b:BerlovLecture {name:'толстый'}),
 p=allShortestPaths((a)-[:SYNONYMY|HYPERONYMY*..5]-(b))
 RETURN [n IN nodes(p)|n.name] AS typed_shortest_paths;
// id() оставлен только для демонстрации последнего примера старой лекции.
MATCH (n:BerlovLecture) RETURN n.name,id(n) AS internal_id ORDER BY internal_id DESC LIMIT 1;
MATCH (n:BerlovLecture) DETACH DELETE n;
MATCH (n:BerlovLecture) RETURN count(n) AS lecture_nodes_after_cleanup;
