# todo_list
## Commands written on PostgreSQL to:
### 1. Create tables:
 - users, with columns:
   - id (primary key)
   - username
   - email
   - created_at
  - category, with columns:
    - id (primary key)
    - label
    - description
  - todo_list, with columns:
    - id (primary key)
    - title
    - summary
    - user_id (foreigner key to table users, column id)
    - category_id (foreigner key to table category, column id) 
  - entry, with columns:
    - id (primary key)
    - description
    -  is_complete
    -  created_at
    -  updated_at
    -  create_user_id (foreigner key to table users, column id)
    -  update_user_id (foreigner key to table users, column id)
    -  todo_list_id (foreigner key to table todo_list, column id)
### 2. Insert data into each table
### 3. Write quary statements, in order to:
 - Show the entries for a single todo_list with the information (for example todo_list with id = 1): todo_list.title, todo_list.summary , category.label, description ,is_complete, timestamp of creation, timestamp of last update, user.username (the creator), user.email (the creator), user.username (the one who has last updated it), user.email (the one who has last updated it)
 - Get the percentage of category for each todo_list
 - Get the count of todo_list for each user
 - Get count of every entry marked as completed for each todo_list
