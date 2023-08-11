--------------------- CREATE/INSERT TABLES ----------------------------
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	username VARCHAR(50) NOT NULL,
	email VARCHAR (140) NOT NULL,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE category (
	id SERIAL PRIMARY KEY,
	label VARCHAR(50) NOT NULL,
	description VARCHAR (140)
);

CREATE TABLE entry (
	id SERIAL PRIMARY KEY,
	description VARCHAR(140),
	is_complete BOOL DEFAULT FALSE,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	create_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	update_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	todo_list_id INTEGER NOT NULL REFERENCES todo_list(id) ON DELETE CASCADE,
);

CREATE TABLE todo_list (
	id SERIAL PRIMARY KEY,
	title VARCHAR(60) NOT NULL,
	summary VARCHAR(160),
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	category_id INTEGER NOT NULL REFERENCES category(id) ON DELETE CASCADE
);

INSERT INTO users(username, email)
VALUES ('Emily345', 'emily@gmail.com'),
		('Mike777', 'mike@gmail.com'),
		('Kevin546', 'kevin@gmail.com');

INSERT INTO category(label, description)
VALUES ('Shopping', 'A shoppong list'),
		('Bills', 'Bills to pay for the month'),
		('Study', 'A study to do list');

INSERT INTO todo_list (title, summary, user_id, category_id)
VALUES ('Shopping list', 'what needs to be gotten at the supermarket', 1, 1),
		('Study list', 'things that need to be studied', 2, 3),
		('Wallmart list', 'things to buy at wallmart', 2, 1),
		('Paying bills', 'bills to pay for this month', 3, 2);

INSERT INTO entry(description, updated_at,
				 create_user_id, update_user_id, todo_list_id)
VALUES ('buy banananas', CURRENT_TIMESTAMP + INTERVAL '1' day, 1, 1, 1),
		('buy apples', CURRENT_TIMESTAMP + INTERVAL '2' day, 1, 1, 1);

INSERT INTO entry(description, is_complete ,updated_at,
				 create_user_id, update_user_id, todo_list_id)
VALUES ('buy strawberries',BOOL(TRUE),CURRENT_TIMESTAMP + INTERVAL '1' day, 1, 2, 3),
	   ('study for maths final', BOOL(True),CURRENT_TIMESTAMP + INTERVAL '1' day, 2, 2, 2);

INSERT INTO entry(description,
				 create_user_id, update_user_id, todo_list_id)
VALUES ('Pay the electricity bills', 3, 1, 4),
		('buy apples', 3, 2, 3);


--------------------- QUARIES ----------------------------

-- join all table
SELECT td.title, td.summary, c.label, e.description, e.is_complete, e.created_at,
e.updated_at, u1.username as creator_username, u1.email as creator_email,
u2.username as updater_username, u2.email as updater_email
FROM entry AS e
JOIN todo_list AS td on td.id = e.todo_list_id
JOIN users AS u1 on u1.id = e.create_user_id
JOIN users AS u2 on u2.id = e.update_user_id
JOIN category AS c on c.id = td.category_id
WHERE td.id = 1;

-- get the percentage of category for each todo lists
with cnt_todo_lists as (select count(*) as cnt from todo_list)

SELECT c.label, count(td.id) as todo_list_cnt, 
((count(td.id)::float / (select cnt from cnt_todo_lists)::float) * 100) as percent_category_of_todo_list
FROM category AS c
JOIN todo_list AS td on c.id = td.category_id
GROUP BY label;

-- get count of todo_list for each user
SELECT count(td.id), username
FROM users AS u
JOIN todo_list AS td on u.id = td.user_id
GROUP BY u.id;

-- count each entry marked as completed for each list
SELECT td.title, count(is_complete) as completed_tasks
FROM entry AS e
JOIN todo_list AS td on e.todo_list_id = td.id
where is_complete = true
GROUP BY td.id;