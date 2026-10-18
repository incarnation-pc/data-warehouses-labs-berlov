// Берлов Марк Валерьевич, группа 223-322, вариант 6.
// ЛР MongoDB №1. Все примеры 9-страничной методички.
// В методичке нет индивидуальных вариантов. Номер по списку: 6.
// Современная оболочка mongosh, insertOne вместо старого insert.
db = db.getSiblingDB('berlov6_mongodb');
function step(title,fn){print('\n=== '+title+' ==='); const x=fn(); if(x!==undefined)printjson(x);}
step('1. Версии и текущая база',()=>({server:db.version(),database:db.getName()}));
step('2. Базы данных',()=>db.adminCommand({listDatabases:1,nameOnly:true}));
step('3. Подготовка учебной коллекции',()=>db.humans.deleteMany({}));
step('4. insertOne John',()=>db.humans.insertOne({name:'John',age:30}));
step('5. insertOne Mary',()=>db.humans.insertOne({name:'Mary',age:23}));
step('6. find / pretty',()=>db.humans.find({},{_id:0}).toArray());
step('7. show collections',()=>db.getCollectionNames());
step('8. insertMany — массив документов',()=>db.humans.insertMany([{name:'John',age:25},{name:'Анна',age:27}]));
step('9. Поиск по имени John',()=>db.humans.find({name:'John'},{_id:0}).toArray());
step('10. Возраст меньше 26',()=>db.humans.find({age:{$lt:26}},{_id:0}).toArray());
step('11. Возраст от 25 включительно до 28',()=>db.humans.find({age:{$gte:25,$lt:28}},{_id:0}).toArray());
step('12. John старше 28 лет',()=>db.humans.find({name:'John',age:{$gt:28}},{_id:0}).toArray());
step('13. Логическое ИЛИ',()=>db.humans.find({$or:[{name:'John'},{name:'Mary'}]},{_id:0}).toArray());
step('14. Оператор in',()=>db.humans.find({name:{$in:['John','Mary']}},{_id:0}).toArray());
step('15. Оператор nin',()=>db.humans.find({name:{$nin:['John','Mary']}},{_id:0}).toArray());
step('16. Коллекция sportsmen',()=>{db.sportsmen.deleteMany({});return db.sportsmen.insertMany([
 {name:'Dominik Hašek',clubs:[{clubName:'HC Pardubice',firstYear:1980,lastYear:1989},{clubName:'HC Spartak Moscow',firstYear:2010,lastYear:2011}]},
 {name:'Учебный спортсмен',clubs:[{clubName:'Other Club',firstYear:2005,lastYear:2009}]}]);});
step('17. Поиск по первому элементу вложенного массива',()=>db.sportsmen.find({'clubs.0.clubName':'HC Pardubice'},{_id:0}).toArray());
step('18. deleteMany',()=>db.humans.deleteMany({name:'Анна'}));
step('19. Проверка оставшихся документов',()=>db.humans.find({},{_id:0}).toArray());
step('20. drop коллекции',()=>db.humans.drop());
step('21. Коллекции после drop',()=>db.getCollectionNames());
step('22. dropDatabase на отдельной временной базе',()=>{const tmp=db.getSiblingDB('berlov6_delete_demo');tmp.example.insertOne({variant:6});return tmp.dropDatabase();});
step('23. Проверка удаления временной базы',()=>db.adminCommand({listDatabases:1,nameOnly:true}));
