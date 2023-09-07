local tablua = require("tablua")

local data = {
    { "username", "password" },
    { "maria",    "pass123" }
}

-- basic usage
local t1 = tablua(data)
print(t1)
-- ╭──────────┬──────────╮
-- │ username │ password │
-- ├──────────┼──────────┤
-- │  maria   │ pass123  │
-- ╰──────────┴──────────╯
--

-- options
t1:padding(3)
t1:first_line_data()
print(t1)
-- ╭──────────────┬──────────────╮
-- │   username   │   password   │
-- │    maria     │   pass123    │
-- ╰──────────────┴──────────────╯

-- chaining methods
t1:padding(0):first_line_header()
print(t1)
-- ╭────────┬────────╮
-- │username│password│
-- ├────────┼────────┤
-- │ maria  │pass123 │
-- ╰────────┴────────╯

-- adding lines
t1:add_line({ "heloisa", "verylongpassword" }) -- defaults to last line
t1:add_line({ "NEW_HEADER", "NEW_HEADER" }, 1)
print(t1)
-- ╭──────────┬────────────────╮
-- │NEW_HEADER│   NEW_HEADER   │
-- ├──────────┼────────────────┤
-- │ username │    password    │
-- │  maria   │    pass123     │
-- │ heloisa  │verylongpassword│
-- ╰──────────┴────────────────╯

-- removing lines
t1:remove_line() -- defaults to last line
t1:remove_line(1)
print(t1)
-- ╭────────┬────────╮
-- │username│password│
-- ├────────┼────────┤
-- │ maria  │pass123 │
-- ╰────────┴────────╯

-- anything that implements __tostring can be used
local x = {}
setmetatable(x, { __tostring = function(v) return "it works!" end })
t1:add_line({ x, 3.1415 })
print(t1)
-- ╭─────────┬────────╮
-- │username │password│
-- ├─────────┼────────┤
-- │  maria  │pass123 │
-- │it works!│ 3.1415 │
-- ╰─────────┴────────╯

-- the first line defines the table columns
t1 = tablua({ { 10, 20, 30 } }) -- the table has 3 columns
t1:add_line({ 10, })            -- missing elements defaults to nil
t1:add_line({ 10, 20, 30, 40 }) -- extra elements are ignored
t1:remove_line(1)               -- now the table has just 1 column
print(t1)
-- ╭────╮
-- │ 10 │
-- ├────┤
-- │ 10 │
-- ╰────╯


-- calling with the wrong type of arguments will cause undefined behavior
local t2 = tablua({ 10 }) -- very bad: should be {{10}}. This will crash the program when trying to print.
t2 = tablua({ { 10 } })   -- good
t2:add_line({ { 5 } })    -- maybe bad: lines should be {col1, col2, ...}. This will print the table address.

-- WARN: The next line will crash the program
-- t2:add_line({ "Why would you", "do that?" }, -99) -- very bad: index must be positive and greater than zero

print(t2)
-- ╭───────────────────────╮
-- │          10           │
-- ├───────────────────────┤
-- │ table: 0x55b10ffc3190 │
-- ╰───────────────────────╯
