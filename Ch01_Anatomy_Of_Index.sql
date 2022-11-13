-- Chapter 01 Anatomy Of An Index

-- "An Index makes the query fast". But often people and book just knows about
-- that and doesn't understand details.

-- An Index is a new structure in the database that is built using the 
-- create index statement. It requires its own hard disk space and hold an 
-- indexed version of the data. 

-- Searching an index is like searching in a phone book, or back of the 
-- book for list of dictionary. It is fast because they are organzied, instead
-- of giving a big messy data, that you have to look through it one by one. 

-- But a database's index is different from a printed phone book, because
-- when new data are added. You don't have room to "add" or "remove" entry.
-- Therefore it uses 2 data structure to solve this problem.
-- 1. Doubly linked list and a search tree.

-- The Index Leaf Nodes!
-- Author mentioned it isn't possible to store the data sequentially.
-- Because it will consume too much room. Instead the system uses a doubly
-- linked list to store the precending and following node. It enable the
-- database to read index forward / backward and easily insert a new record.

-- Root Node > Branch Nodes > Leaf Nodes.
-- The leaf nodes can go up and down using linked list.
