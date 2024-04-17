# ml-challenge-sql

Este repositório foi criado para a resposta ao desafio (Challenge Engineer - Primera Parte - SQL) de analytics engineer do mercado livre

A seguir seguem os passos que foram feitos para resolver o desafio 

## Modelagem 

Dada as descrições das entidades gerei o seguinte modelo na ferramenta https://dbdiagram.io/

![screenshot](Meli-DB%20Diagram.png)

Abaixo encontra-se também o código DBML que gerou o modelo. O diagrama pode ser acessado em [https://dbdiagram.io/d/Meli-DB-Diagram-66200db903593b6b6142795c](https://dbdiagram.io/d/Meli-DB-Diagram-66200db903593b6b6142795c)


````
// Use DBML to define your database structure
// Docs: https://dbml.dbdiagram.io/docs

//This diagram was created by Bruno de Souza Francisco for meli data & analytics challenge

Table customer {
  id integer [primary key]
  email varchar
  firstname varchar
  lastname varchar
  gender varchar
  address varchar
  birthdate varchar
  telephone varchar
  created_at date 
  updated_at date 
}

Table item {
  id integer [primary key]
  name varchar
  price decimal(10,2)
  description varchar
  category integer
  status varchar
  cancelled_at timestamp
  created_at date 
  updated_at date 
}

Table category {
  id integer [primary key]
  name varchar
  description varchar
  address varchar
  created_at date 
  updated_at date 
}

Table order {
  id integer [primary key]
  date timestamp
  item integer
  quantity decimal(10,2)
  totalammount decimal(10,2)
  seller integer
  buyer integer
  created_at date 
  updated_at date 
}

// Creates an one-to-many relationship. An item belongs to only one category and one category can have 0, one or more items
Ref: category.id < item.category 

//creates two one to many relationships. An customer can have many orders as buyer or as seller 
Ref: customer.id < order.seller
Ref: customer.id < order.buyer

//Creates an one to many relationship as we can have many orders of an item 
Ref: item.id < order.item
````

## DDL 
Os seguintes comandos foram executados e testados no mySQL community edition 8.0.36.  O código está na raiz do repositório com o nome [create_tables.sql](create_tables.sql)

Nota: Em um ambiente produtivo seria uma boa prática incluir os comentários em cada uma das colunas do MySQL 

```
CREATE TABLE `customer` (
  `id` integer PRIMARY KEY,
  `email` varchar(255),
  `firstname` varchar(255),
  `lastname` varchar(255),
  `gender` varchar(255),
  `address` varchar(255),
  `birthdate` varchar(255),
  `telephone` varchar(255),
  `created_at` date,
  `updated_at` date
);

CREATE TABLE `item` (
  `id` integer PRIMARY KEY,
  `name` varchar(255),
  `price` decimal(10,2),
  `description` varchar(255),
  `category` integer,
  `status` varchar(255),
  `cancelled_at` timestamp,
  `created_at` date,
  `updated_at` date
);

CREATE TABLE `category` (
  `id` integer PRIMARY KEY,
  `name` varchar(255),
  `description` varchar(255),
  `address` varchar(255),
  `created_at` date,
  `updated_at` date
);

CREATE TABLE `order` (
  `id` integer PRIMARY KEY,
  `date` timestamp,
  `item` integer,
  `quantity` decimal(10,2),
  `totalammount` decimal(10,2),
  `seller` integer,
  `buyer` integer,
  `created_at` date,
  `updated_at` date
);

ALTER TABLE `item` ADD FOREIGN KEY (`category`) REFERENCES `category` (`id`);

ALTER TABLE `order` ADD FOREIGN KEY (`seller`) REFERENCES `customer` (`id`);

ALTER TABLE `order` ADD FOREIGN KEY (`buyer`) REFERENCES `customer` (`id`);

ALTER TABLE `order` ADD FOREIGN KEY (`item`) REFERENCES `item` (`id`);

```

## Consultas 

###Problema 1

Para solucionar o problema criei uma query simples que faz joim entre a tabela de clientes e a tabela de pedidos. A query filtra os clientes em que o mês e o dia do aniversário coincide com o mês e dia atuais para selecionar os aniversariantes. Também filtro na query os pedidos do mês de janeiro e somo valor de todos os pedidos por cliente. a Cláusula 'HAVING' no final da query é responsável por filtrar apenas os clientes com o total de pedidos acima de 1500

```
SELECT 
	C.ID,
	C.EMAIL,
	C.BIRTHDATE,
	C.FIRSTNAME,
	C.LASTNAME,
	SUM(O.TOTALAMMOUNT) AS TOTAL
FROM 
	MELI.CUSTOMER C
	INNER JOIN MELI.ORDER O ON C.ID = O.SELLER 
WHERE 
	MONTH(C.BIRTHDATE) = MONTH(CURDATE()) AND DAY(C.BIRTHDATE) = DAY(CURDATE()) #CUSTOMERS CELEBRATING BIRTHDAY TODAY 
	AND MONTH(O.DATE) = 1 AND year(O.DATE) = 2024 #ONLY 202401 ORDERS 
GROUP BY 
	C.ID,
	C.EMAIL,
	C.FIRSTNAME,
	C.LASTNAME
HAVING SUM(O.TOTALAMMOUNT) >= 1500; # TOTAL ORDERS OVER 1500
```

###Problema 2

Para a solução do problema utilizei uma common table expression (CTE) para organizar a query. A CTE tem uma estrutura parecida com a query do problema 1 com algumas diferenças prinicipais 
  - Foi feito Join com as tabelas de item e categoria para que fosse possível filtrar a categorias 'CELULARES'
  - Utilizei a window function 'Rank' para calcular a posicao de cada cliente de acordo com o montante gasto no mês
Por fim é executada uma query sobre a CTE para filtrar os 5 maiores clientes do mês utilizando o campo de ranking calculado na CTE


```
WITH CUSTOMER_RANK AS(
	SELECT 
		MONTH(O.DATE) AS MONTH,
		YEAR(O.DATE) AS YEAR,
		C.ID,
		C.FIRSTNAME,
		C.LASTNAME,
		COUNT(O.ID) AS ORDERS,
		COUNT(DISTINCT I.ID) AS ITEMS,
		SUM(O.TOTALAMMOUNT) AS TOTAL,
		RANK() OVER (  
			PARTITION BY MONTH(O.DATE)
			ORDER BY SUM(O.TOTALAMMOUNT) DESC
		) POSICAO # RANK OVER THE TOTAL AMOUNT OF ALL ORDERS OF THE SELLER AND RESET THE RANK WHEN THE MONTH CHANGES
	FROM 
		MELI.CUSTOMER C
		INNER JOIN MELI.ORDER O ON C.ID = O.SELLER 
		INNER JOIN MELI.ITEM I  ON O.ITEM = I.ID
		INNER JOIN MELI.CATEGORY CAT ON I.CATEGORY = CAT.ID
	WHERE 
		YEAR(O.DATE) = 2020
		AND CAT.NAME = 'CELULARES'
	GROUP BY 
		MONTH(O.DATE) ,
		YEAR(O.DATE) ,
		C.ID,
		C.FIRSTNAME,
		C.LASTNAME
)
SELECT * FROM CUSTOMER_RANK WHERE POSICAO <= 5;
```

###Problema 3

Para solucionar o problema 3 criei uma stored procedures que recebe como parâmetro a data que se deseja processar e realiza os seguintes passos:
  - O primeiro passo da procedure elimina as linhas com a data de parâmetro caso aquela data já tenha sido processada no passado
  - o segundo comando utiliza os campos created_at (data de criação do item) e cancelled_at (data de cancelamento do item) para checar se na data que estamos processando o item estava ativo ou não e criar o campo STATUS
  - O resultado é gravado na tabela EOD_ITEMS que gardará o status de cada itens na data que estamos processando

A procedure pode ser chamada uma vez para cada dia do histórico que se desejar. Caso algum dia precise ser reprocessado basta executar a procedure novamente com a data que se deseja recalcular



```

delimiter //
CREATE PROCEDURE LOAD_EOD_ITEMS(IN PROCESS_DATE  DATE)
BEGIN
	DELETE FROM EOD_ITEMS WHERE DATE = PROCESS_DATE;
	INSERT INTO EOD_ITEMS 
	SELECT 
		PROCESS_DATE AS DATE,
		ID,
		NAME,
		PRICE,
		CASE WHEN PROCESS_DATE BETWEEN CREATED_AT AND coalesce(CANCELLED_AT, CURDATE()) THEN 'ATIVO' ELSE 'CANCELADO' END AS STATUS
	FROM 
		ITEM;
END //
CALL LOAD_EOD_ITEMS('2024-04-09');

```
