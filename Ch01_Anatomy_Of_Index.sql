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

-- Tree Traversal is a very efficient operation, it works almost instantly
-- even on very large dataset. Primary becasue of tree balancing. Secondly
-- is because of the logarithmic growth of the tree depth.

-- Why is an index slow?
-- 1. When the lookup entry is not uquie, it must read additional entries
-- 2. A leaf node might contain hundreds of hit and they can scattered across
-- many table blocks.

-- The following of leaf node chain and fetching of table data are the main 
-- reasons of the slow index lookup.

-- Logarithmic Scalability
-- Definition: The logarithm of a number to given base is the power or exponent
-- to which the base must be raised in order to produce the number.
-- Example: 3 = log_7 of x
-- 7^3 = x
-- y = log_b of x means b^y = x
-- Author mentioned, the higher the basis, the shallower the tree, the faster
-- the traversal.

-- There are 3 distinct operations that describe a basic index lookup.

-- 1. Index unique scan. The database requires a unique constraint to ensure
-- that the search criteria will match no more than one entry. It performs
-- the tree traversal only.

-- 2. Index range scan. This is the fallback operation if multiple entries
-- possibly match the search criteria. It performs the tree traversal
-- and follow the leaf node chain to find all matching entries.

-- 3. Table access by index rowid. This is often performed for every matched
-- record from a preceding index scan operation. It retrieves the row from
-- the table.
