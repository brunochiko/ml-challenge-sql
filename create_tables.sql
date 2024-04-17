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
