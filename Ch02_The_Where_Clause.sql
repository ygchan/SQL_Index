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

-- SQL Server new tip!
-- You can add a computed column on the table that can be indexed
alter table employees add last_name_up as upper(last_name);
create index emp_up_name on employees (last_name_up);

-- Documentation: Specify Computed Columns in a Table
-- https://learn.microsoft.com/en-us/sql/relational-databases/tables/specify-computed-columns-in-a-table?view=sql-server-ver16
-- Not physically stored in the table

-- Parameterized queries
-- Bind parameters - dynamic parameters are an alternative way to
-- pass data to the database. Instead of putting the values
-- you just use a placeholder like ?, :name or @name
-- and provide the actual values using separate API call.

-- Benefit #1: Prevent SQL Injection
-- Benefit #2: Performance (cache execution plan for SQL Server!)

-- 99 rows selected
select first_name, last_name
from employees
where subsidiary_id = 20;

-- Question: is it better to index all columns, or single index for all
-- columns? Author suggested to use one index for all columns
-- but pay a lot of care to the order.

-- Example Query
select first_name, last_name, date_of_birth
from employees
where upper(last_name) < ?
  and date_of_birth < ?;
  
-- An index can only support 1 range condition as access predicates
-- Supporting 2 independent range requires a second axis.
-- Like a chessboard.
-- This index should have the more selective column first

-- So it will be "business unit" and than "year" :) 

-- Data warehouse use a special purpose index type to
-- solve that type of problem: bitmap index.
-- Adv: they can be combined easily.
-- but if you know the query in advance, you can create
-- a TAILORED multi-column B-tree index.

-- ** Bitmap indexes are very weak (not usable) for OLTP.
-- online transactional processing
-- Many database offer a hybrid solution: to convert the results
-- of several Btree scans into bitmap in memory. But the problem
-- is this will consume a lot of memory (???).

-- FILTERED INDEX (SQL SERVER)!
-- You can only specify the rows that are indexed.

select message
from messages
where processed = 'N'
  and receiver = ?;
  
-- Fetching all (only) unprocessed messages for a specific recipient.
-- Messages that are already processed are rarely needed.

create index messages_todo on messages(receiver)
where processed = 'N';

-- The index only contains the rows that satisfy the where clause.
-- SQL Server does not allow function nor OR operator.

-- The section about NULL indexing was confusing.
-- To create an index to filter for Null, need to add a contraints of 
-- not null. otherwise it will do a full table scan.

-- Obfuscated condition (anti-patterns)
-- Date type: Do this instead.
create index index_name on table_name (trunc(sale_date));
-- but if you use it inconsistently, then you will need 2 indexed :(

create function quarter_begin (@dt datetime)
returns datetime
begin
  return dateadd (qq, datediff (qq, 0, @dt), 0)
end
go

create function quarter_end (@dt datetime)
returns datetime
begin
  return dateadd
  (
    ms, -3, dateadd(mm, 3, dbo.quarter_begin(@dt))  
  );
end
go

-- Tip: Write query for continuous period as explicit range condition
select *
from dbo.employee
where join_date >= trunc(sysdate)
  and join_date <  trunc(sysdate + interval '1' day);
  
-- Numeric Strings
-- Numerics strings are numbers that are stored in text colums. Although it is a very
-- bad practice, it does not render index useless if you treat it as string

select *
from dbo.employee
where numeric_string = '42';

-- However, if you compare it to a number, the index will fail...

select *
from dbo.employee
where numeric_string = 42;

-- On other words, if the column is a numeric type, make sure use int to store it.
-- Unless it is very large number range, then use bigint.

select *
from dbo.employee
where numeric_string = '42';

-- The dtabase will always transfer this string to a number.
-- If you have an important column, index both string and number?

-- There was mention of date/date time index logic and its approach
-- But I didn't fully understand that part in Chapter 2.

-- Smart Logic: query optimizer (panner) works at runtime.
-- it analyzes each statement when received and generates a reasonable
-- execution plan immediately. The overhead introduced by runtime
-- optimization can be minimized with bind variable. 
