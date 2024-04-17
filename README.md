# ml-challenge-sql

Este repositório foi criado para a resposta ao desafio (Challenge Engineer - Primera Parte - SQL) de analytics engineer do mercado livre

A seguir seguem os passos que foram feitos para resolver o desafio 

## Modelagem 

Dada as descrições das entidades gerei o seguinte modelo na ferramenta https://dbdiagram.io/

![screenshot](https://github.com/brunochiko/ml-challenge-sql/blob/661f9f847d9190abe4307e2208caad53644b2698/Meli-DB%20Diagram.png)

Abaixo encontra-se também o código DBML que gerou o modelo 

````
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
  created_at timestamp 
  updated_at timestamp 
}

Table item {
  id integer [primary key]
  name varchar
  description varchar
  category integer
  created_at timestamp 
  updated_at timestamp 
}

Table category {
  id integer [primary key]
  name varchar
  description varchar
  address varchar
  created_at timestamp 
  updated_at timestamp 
}

Table order {
  id integer [primary key]
  date timestamp
  item integer
  quantity numeric
  totalammount numeric
  seller integer
  buyer integer
  created_at timestamp 
  updated_at timestamp 
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
Os seguintes comandos foram executados e testados no mySQL community edition 8.0.36

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
  `created_at` timestamp,
  `updated_at` timestamp
);

CREATE TABLE `item` (
  `id` integer PRIMARY KEY,
  `name` varchar(255),
  `description` varchar(255),
  `category` integer,
  `created_at` timestamp,
  `updated_at` timestamp
);

CREATE TABLE `category` (
  `id` integer PRIMARY KEY,
  `name` varchar(255),
  `description` varchar(255),
  `address` varchar(255),
  `created_at` timestamp,
  `updated_at` timestamp
);

CREATE TABLE `order` (
  `id` integer PRIMARY KEY,
  `date` timestamp,
  `item` integer,
  `quantity` numeric,
  `totalammount` numeric,
  `seller` integer,
  `buyer` integer,
  `created_at` timestamp,
  `updated_at` timestamp
);

ALTER TABLE `item` ADD FOREIGN KEY (`category`) REFERENCES `category` (`id`);

ALTER TABLE `order` ADD FOREIGN KEY (`seller`) REFERENCES `customer` (`id`);

ALTER TABLE `order` ADD FOREIGN KEY (`buyer`) REFERENCES `customer` (`id`);

ALTER TABLE `order` ADD FOREIGN KEY (`item`) REFERENCES `item` (`id`);

```


