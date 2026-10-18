// Берлов Марк Валерьевич, группа 223-322, вариант 6.
// Проверка минимального размера графа (только индивидуальная часть).
MATCH (n:Berlov6) RETURN count(n) AS nodes;
MATCH (:Berlov6)-[r]->(:Berlov6) RETURN count(r) AS relationships;
MATCH (n:Berlov6) RETURN [label IN labels(n) WHERE label<>'Berlov6'][0] AS node_type,count(*) AS amount ORDER BY node_type;
MATCH (:Berlov6)-[r]->(:Berlov6) RETURN type(r) AS relationship_type,count(*) AS amount ORDER BY relationship_type;
MATCH (p:Berlov6:Person)-[:MEMBER_OF]->(c:Community) RETURN p.name AS person,p.role AS role,c.name AS community ORDER BY person;
MATCH (p:Berlov6:Person)-[:ATTENDS]->(e:Event) RETURN e.name AS event,count(p) AS participants ORDER BY participants DESC,event;
MATCH (p:Berlov6:Person {uid:'P01'})-[r]-(neighbor) RETURN p.name,type(r),neighbor.name ORDER BY neighbor.name;
MATCH (a:Berlov6:Person {uid:'P01'}),(b:Berlov6:Person {uid:'P05'}),
 p=shortestPath((a)-[:KNOWS*..7]-(b)) RETURN [n IN nodes(p)|n.name] AS shortest_path,length(p) AS hops;
MATCH (a:Berlov6:Person {uid:'P01'}),(b:Berlov6:Person {uid:'P05'}),
 p=allShortestPaths((a)-[:KNOWS|MENTORS*..7]-(b))
 RETURN [n IN nodes(p)|n.name] AS paths_with_selected_types;
MATCH (n:Berlov6) WHERE NOT (n)--() RETURN count(n) AS isolated_nodes;
MATCH (p:Berlov6:Person) RETURN p.uid,p.name,p.goal,p.photo ORDER BY p.uid;
// Запрос визуализации для Neo4j Browser:
// MATCH p=(:Berlov6)-[]->(:Berlov6) RETURN p;
