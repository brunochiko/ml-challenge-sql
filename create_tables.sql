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
