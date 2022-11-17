-- The where clause
-- Chapter 1 described the structure of index and why it might cause poor index performance.
-- 1) Index not unquie, 2) The data aren't stored in the same "page" (not sorted?).
-- There are 3 operations with index lookup, 1) index unique scan, 2) index range scan
-- table access by index rowid.

-- The where clause defines the search condition of an SQL statement.
-- It falls into the core functional domain of index: find data quickly.
-- But many of us write them very carelessly, so that the database has to 
-- scan a large part of the index. This chapter will teach us how to spot them.
-- How many write where statement to use as much of the index as possible.
-- Some standard anti-patterns and present alternative ways to do better.

-- Last thing about slow index from Chapter 1.
-- When your index is unique, then there are no risk on trigger more than
-- one table access. George: so, how to design a database with our project
-- in mind that will use only a unquie index?

-- Concatenated indexes
-- Note when you have a concatenated index (composite index).
-- The column order of it has huge impact on its usability.

create unique index employee_pk 
  on employees (employee_id, subsidiary_id);
  
select *
from employees
where employee_id = 123
  and subsidiary_id = 30;
  
-- This query is instant. Because it is using an unique index scan
-- But if we don't use the complete index, only subsidiary_id
-- then it will be doing a full table scan!

-- This will be table access full
select *
from employees
where subsidiary_id = 30;

-- Table Access Full: sometimes can be the most efficient operation
-- when retrieving a large part of the table
-- This because when index lookup happens, it has overhead, but when
-- the index lookup is using 1 block, nothing else is being read.
-- whereas, a full table scan read larger chunk at a time (multi-block
-- read). 

-- Important: A Concatenated index is one index across multiple columns
-- If you don't have the left most column, you CAN'T use it.
-- The doubly linked list link to the next round, but in that employee
-- example, it doesn't link to the next subsidiary with id = 20.

-- Functions
-- When a string has upper case/lower case. You indexed on either/or.
-- How to get around this limiation of the last name = upper case?
-- Author said: you can try to do this.

select first_name, last_name, phone_number
from employees
where upper(last_name) = upper('george');

-- George: However, in SQL Server, case insensitive by default
-- So this does not matter at my current team :)

-- But if you take a look at the execution plan, it goes back to full table
-- scan again. Because the search is NOT on last_name, rather on 
-- upper(last_name). From database perspective, this is entirely different.

-- From the SQL Optimizer point of view 
select first_name
from employees
where blackbox(...) = 'george';

-- Tip: Replace the function name with BLACKBOX to understand how the optimizer
-- point of view.

-- To solve this:
-- We need an index that covers the actual search term.

create index emp_up_name
on employees (upper(last_name));

-- Reminder: what does index range range scan mean?
-- Answer: The database traverses the B-tree and follows the leaf node chain.

-- Instruction on how to update index statistics
-- https://www.sqlshack.com/sql-server-statistics-and-how-to-perform-update-statistics-in-sql
