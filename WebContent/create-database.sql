﻿DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS states CASCADE;
DROP TABLE IF EXISTS cart_history CASCADE;

/**table 0: [entity] states**/
CREATE TABLE states (
    id          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL
);

INSERT INTO states (name) VALUES ('Alabama');
INSERT INTO states (name) VALUES ('Alaska');
INSERT INTO states (name) VALUES ('Arizona');
INSERT INTO states (name) VALUES ('Arkansas');
INSERT INTO states (name) VALUES ('California');
INSERT INTO states (name) VALUES ('Colorado');
INSERT INTO states (name) VALUES ('Connecticut');
INSERT INTO states (name) VALUES ('Delaware');
INSERT INTO states (name) VALUES ('Florida');
INSERT INTO states (name) VALUES ('Georgia');
INSERT INTO states (name) VALUES ('Hawaii');
INSERT INTO states (name) VALUES ('Idaho');
INSERT INTO states (name) VALUES ('Illinois');
INSERT INTO states (name) VALUES ('Indiana');
INSERT INTO states (name) VALUES ('Iowa');
INSERT INTO states (name) VALUES ('Kansas');
INSERT INTO states (name) VALUES ('Kentucky');
INSERT INTO states (name) VALUES ('Louisiana');
INSERT INTO states (name) VALUES ('Maine');
INSERT INTO states (name) VALUES ('Maryland');
INSERT INTO states (name) VALUES ('Massachusetts');
INSERT INTO states (name) VALUES ('Michigan');
INSERT INTO states (name) VALUES ('Minnesota');
INSERT INTO states (name) VALUES ('Mississippi');
INSERT INTO states (name) VALUES ('Missouri');
INSERT INTO states (name) VALUES ('Montana');
INSERT INTO states (name) VALUES ('Nebraska');
INSERT INTO states (name) VALUES ('Nevada');
INSERT INTO states (name) VALUES ('New Hampshire');
INSERT INTO states (name) VALUES ('New Jersey');
INSERT INTO states (name) VALUES ('New Mexico');
INSERT INTO states (name) VALUES ('New York');
INSERT INTO states (name) VALUES ('North Carolina');
INSERT INTO states (name) VALUES ('North Dakota');
INSERT INTO states (name) VALUES ('Ohio');
INSERT INTO states (name) VALUES ('Oklahoma');
INSERT INTO states (name) VALUES ('Oregon');
INSERT INTO states (name) VALUES ('Pennsylvania');
INSERT INTO states (name) VALUES ('Rhode Island');
INSERT INTO states (name) VALUES ('South Carolina');
INSERT INTO states (name) VALUES ('South Dakota');
INSERT INTO states (name) VALUES ('Tennessee');
INSERT INTO states (name) VALUES ('Texas');
INSERT INTO states (name) VALUES ('Utah');
INSERT INTO states (name) VALUES ('Vermont');
INSERT INTO states (name) VALUES ('Virginia');
INSERT INTO states (name) VALUES ('Washington');
INSERT INTO states (name) VALUES ('West Virginia');
INSERT INTO states (name) VALUES ('Wisconsin');
INSERT INTO states (name) VALUES ('Wyoming');


/**table 1: [entity] users**/
CREATE TABLE users (
    id          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE CHECK (name <> ''),
    role        TEXT NOT NULL,
    age         INTEGER NOT NULL,
    state       INTEGER REFERENCES states (id) NOT NULL
);
INSERT INTO users (name, role, age, state) VALUES('CSE','owner',35,3);
INSERT INTO users (name, role, age, state) VALUES('David','customer',33,12);
INSERT INTO users (name, role, age, state) VALUES('Floyd','customer',27,14);
INSERT INTO users (name, role, age, state) VALUES('James','customer',55,1);
INSERT INTO users (name, role, age, state) VALUES('Ross','customer',24,5);


/**table 2: [entity] category**/
CREATE TABLE categories (
    id          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE CHECK (name <> ''),
    description TEXT NOT NULL
);
INSERT INTO categories (name, description) VALUES('Computers','A computer is a general purpose device that can be programmed to carry out a set of arithmetic or logical operations automatically. Since a sequence of operations can be readily changed, the computer can solve more than one kind of problem.');
INSERT INTO categories (name, description) VALUES('Cell Phones','A mobile phone (also known as a cellular phone, cell phone, and a hand phone) is a phone that can make and receive telephone calls over a radio link while moving around a wide geographic area. It does so by connecting to a cellular network provided by a mobile phone operator, allowing access to the public telephone network.');
INSERT INTO categories (name, description) VALUES('Cameras','A camera is an optical instrument that records images that can be stored directly, transmitted to another location, or both. These images may be still photographs or moving images such as videos or movies.');
INSERT INTO categories (name, description) VALUES('Video Games','A video game is an electronic game that involves human interaction with a user interface to generate visual feedback on a video device..');

/**table 3: [entity] product**/
CREATE TABLE products (
    id          SERIAL PRIMARY KEY,
    cid         INTEGER REFERENCES categories (id) NOT NULL,
    name        TEXT NOT NULL,
    SKU         TEXT NOT NULL UNIQUE,
    price       INTEGER NOT NULL
);
INSERT INTO products (cid, name, SKU, price) VALUES(1, 'Apple MacBook',     '103001',   1200); /**1**/
INSERT INTO products (cid, name, SKU, price) VALUES(1, 'HP Laptop',         '106044',   480);
INSERT INTO products (cid, name, SKU, price) VALUES(1, 'Dell Laptop',       '109023',   399);/**3**/
INSERT INTO products (cid, name, SKU, price) VALUES(2, 'Iphone 5s',         '200101',   709);
INSERT INTO products (cid, name, SKU, price) VALUES(2, 'Samsung Galaxy S4', '208809',   488);/**5**/
INSERT INTO products (cid, name, SKU, price) VALUES(2, 'LG Optimus g',       '209937',  375);
INSERT INTO products (cid, name, SKU, price) VALUES(3, 'Sony DSC-RX100M',   '301211',   689);/**7**/
INSERT INTO products (cid, name, SKU, price) VALUES(3, 'Canon EOS Rebel T3',     '304545',  449);
INSERT INTO products (cid, name, SKU, price) VALUES(3, 'Nikon D3100',       '308898',   520);
INSERT INTO products (cid, name, SKU, price) VALUES(4, 'Xbox 360',          '405065',   249);/**10**/
INSERT INTO products (cid, name, SKU, price) VALUES(4, 'Nintendo Wii U ',    '407033',  430);
INSERT INTO products (cid, name, SKU, price) VALUES(4, 'Nintendo Wii',      '408076',   232);

-- should be removed for project 2.
CREATE TABLE cart_history (
    id          SERIAL PRIMARY KEY,
    uid         INTEGER REFERENCES users (id) NOT NULL
);

CREATE TABLE sales (
    id          SERIAL PRIMARY KEY,
    uid         INTEGER REFERENCES users (id) NOT NULL,
    cart_id     INTEGER REFERENCES cart_history (id) NOT NULL, -- should be removed for project 2.
    pid         INTEGER REFERENCES products (id) NOT NULL,
    quantity    INTEGER NOT NULL,
    price       INTEGER NOT NULL
);

CREATE TABLE ordered (
    id          SERIAL PRIMARY KEY,
    state       INTEGER REFERENCES states (id) NOT NULL,
    product     INTEGER REFERENCES products (id) NOT NULL,
    price       INTEGER NOT NULL
);

CREATE FUNCTION orderfunc() RETURNS TRIGGER AS $order_table$
    BEGIN
	INSERT INTO ordered(state, product, price) VALUES
	(SELECT s.id AS state, NEW.ID as product, 0 AS price
	FROM states AS s)
        RETURN NEW;
    END;
$order_table$ LANGUAGE plpgsql;

CREATE TRIGGER trg_products
    AFTER INSERT
    ON products  
    FOR EACH ROW
EXECUTE PROCEDURE orderfunc();

CREATE FUNCTION salesfunc() RETURNS TRIGGER AS $orderS_table$
    BEGIN
	INSERT INTO ordered(state, product, price) VALUES
	(SELECT s.id AS state, p.id as product, (sa.price * sa.quantity) AS price
	FROM states AS s, products AS p, sales AS sa WHERE sa.id = NEW.ID sa.pid = p.id)
        RETURN NEW;
    END;
$orderS_table$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sales
    AFTER INSERT
    ON sales
    FOR EACH ROW
EXECUTE PROCEDURE salesfunc();

CREATE TABLE totals (
    id          SERIAL PRIMARY KEY,
    state       INTEGER REFERENCES states (id) NOT NULL,
    total       INTEGER NOT NULL
);

INSERT INTO totals (state, total) VALUES ('Alabama', 0.0);
INSERT INTO totals (state, total) VALUES ('Alaska', 0.0);
INSERT INTO totals (state, total) VALUES ('Arizona', 0.0);
INSERT INTO totals (state, total) VALUES ('Arkansas', 0.0);
INSERT INTO totals (state, total) VALUES ('California', 0.0);
INSERT INTO totals (state, total) VALUES ('Colorado', 0.0);
INSERT INTO totals (state, total) VALUES ('Connecticut', 0.0);
INSERT INTO totals (state, total) VALUES ('Delaware', 0.0);
INSERT INTO totals (state, total) VALUES ('Florida', 0.0);
INSERT INTO totals (state, total) VALUES ('Georgia', 0.0);
INSERT INTO totals (state, total) VALUES ('Hawaii', 0.0);
INSERT INTO totals (state, total) VALUES ('Idaho', 0.0);
INSERT INTO totals (state, total) VALUES ('Illinois', 0.0);
INSERT INTO totals (state, total) VALUES ('Indiana', 0.0);
INSERT INTO totals (state, total) VALUES ('Iowa', 0.0);
INSERT INTO totals (state, total) VALUES ('Kansas', 0.0);
INSERT INTO totals (state, total) VALUES ('Kentucky', 0.0);
INSERT INTO totals (state, total) VALUES ('Louisiana', 0.0);
INSERT INTO totals (state, total) VALUES ('Maine', 0.0);
INSERT INTO totals (state, total) VALUES ('Maryland', 0.0);
INSERT INTO totals (state, total) VALUES ('Massachusetts', 0.0);
INSERT INTO totals (state, total) VALUES ('Michigan', 0.0);
INSERT INTO totals (state, total) VALUES ('Minnesota', 0.0);
INSERT INTO totals (state, total) VALUES ('Mississippi', 0.0);
INSERT INTO totals (state, total) VALUES ('Missouri', 0.0);
INSERT INTO totals (state, total) VALUES ('Montana', 0.0);
INSERT INTO totals (state, total) VALUES ('Nebraska', 0.0);
INSERT INTO totals (state, total) VALUES ('Nevada', 0.0);
INSERT INTO totals (state, total) VALUES ('New Hampshire', 0.0);
INSERT INTO totals (state, total) VALUES ('New Jersey', 0.0);
INSERT INTO totals (state, total) VALUES ('New Mexico', 0.0);
INSERT INTO totals (state, total) VALUES ('New York', 0.0);
INSERT INTO totals (state, total) VALUES ('North Carolina', 0.0);
INSERT INTO totals (state, total) VALUES ('North Dakota', 0.0);
INSERT INTO totals (state, total) VALUES ('Ohio', 0.0);
INSERT INTO totals (state, total) VALUES ('Oklahoma', 0.0);
INSERT INTO totals (state, total) VALUES ('Oregon', 0.0);
INSERT INTO totals (state, total) VALUES ('Pennsylvania', 0.0);
INSERT INTO totals (state, total) VALUES ('Rhode Island', 0.0);
INSERT INTO totals (state, total) VALUES ('South Carolina', 0.0);
INSERT INTO totals (state, total) VALUES ('South Dakota', 0.0);
INSERT INTO totals (state, total) VALUES ('Tennessee', 0.0);
INSERT INTO totals (state, total) VALUES ('Texas', 0.0);
INSERT INTO totals (state, total) VALUES ('Utah', 0.0);
INSERT INTO totals (state, total) VALUES ('Vermont', 0.0);
INSERT INTO totals (state, total) VALUES ('Virginia', 0.0);
INSERT INTO totals (state, total) VALUES ('Washington', 0.0);
INSERT INTO totals (state, total) VALUES ('West Virginia', 0.0);
INSERT INTO totals (state, total) VALUES ('Wisconsin', 0.0);
INSERT INTO totals (state, total) VALUES ('Wyoming', 0.0);

CREATE FUNCTION totalsfunc() RETURNS TRIGGER AS $totals_table$
    BEGIN
	UPDATE totals
        SET total = 
            (SELECT SUM(o.price) FROM ordered AS o, totals AS t, 
             WHERE o.state = t.state)
	FROM ordered AS o, totals AS t
	WHERE o.state = t.state
        RETURN NEW;
    END;
$totals_table$ LANGUAGE plpgsql;

CREATE TRIGGER trg_totals
    AFTER INSERT
    ON ordered
    FOR EACH ROW
EXECUTE PROCEDURE totalsfunc();