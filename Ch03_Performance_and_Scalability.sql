-- Chapter 03: Performance and Scalability

-- What is scalability?
-- a) the ability of a system, network, process to handle a growing
-- amount of work in a capable manner
-- b) its ability to be enlarged to accommodate that growth.

-- Author posted a very interested example.
select count(*)
from scale_data
where section = @my_section
  and id2 = @my_id2;
  
-- Slow index is 0.029s
-- Fast index is 0.055s
-- Any idea what might be the problem?

-- Answer: it was using a composite index, but id2 is after id1.
-- When index is used properly, correctly. It will be log time or near 
-- constant time. But when it isn't used properly, it will be linear
-- as the data grow larger.

-- The 2 ingredients of index lookup slow
-- table access and scanning a wide index range.
-- Pay attention to the predicate information.

-- create index scale_slow on scale_data(section, id1, id2);
-- create index scale_fast on scale_data(section, id2, id1);
