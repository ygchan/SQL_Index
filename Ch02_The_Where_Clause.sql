-- The where clause
-- Chapter 1 described the structure of index and why it might cause poor index performance.
-- 1) Index not unquie, 2) The data aren't stored in the same "page" (not sorted?).
-- There are 3 operations with index lookup, 1) index unique scan, 2) index range scan
-- table access by index rowid.

