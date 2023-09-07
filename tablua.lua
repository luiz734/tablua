-- lines is an table of tables containing string. line: { {"a", "b", "c"}} for
-- each string in the internal tables, append the "padding" amount of spaces
-- before and after the string. returns a copy of the lines with the
-- modifications
local add_padding         = function(lines, padding)
    local spaces = string.rep(" ", padding)
    local copy = {}
    for i = 1, #lines do
        local line = lines[i]
        copy[i] = {}
        for j = 1, #lines[1] do
            local value = tostring(line[j]) or "nil"
            copy[i][j] = spaces .. value .. spaces
        end
    end
    return copy
end
-- calculate the maximun value of each column this is used to set the table
-- column width the largest element should determine the size, so all of them
-- can fit
local calc_max_col_length = function(lines)
    local cols_max_length = {}
    for i = 1, #lines[1] do cols_max_length[i] = 0 end
    for _, line in pairs(lines) do
        for i = 1, #line do
            local curr_len = cols_max_length[i]
            local head_len = #line[i]
            if head_len > curr_len then cols_max_length[i] = head_len end
        end
    end
    return cols_max_length
end
-- line: a table containing string elements:line = {"a", "b", "c"} go on each
-- element appeding spaces to fill all the remaining spaces until reaches the
-- width of the the elementh with the biggest width in the column
local add_line            = function(line, cols_max_length)
    local entry = "│"
    for i = 1, #line do
        local line_len = cols_max_length[i] - #line[i]
        local spaces_after = line_len // 2
        local spaces_before = spaces_after + (line_len % 2)
        entry = entry .. string.rep(" ", spaces_after)
        entry = entry .. line[i]
        entry = entry .. string.rep(" ", spaces_before)
        entry = entry .. "│"
    end
    entry = entry .. "\n"
    return entry
end
-- adds a simple divisor. it's used to split the header from the data
local add_divisor         = function(cols_max_length)
    local div = "├"
    for i = 1, #cols_max_length do
        local top_middle_edge = string.rep("─", cols_max_length[i])
        div = div .. top_middle_edge .. "┼"
    end
    div = div:sub(1, -4) .. "┤\n"
    return div
end
-- adds the top part of the table (above the first line)
local add_cover           = function(cols_max_length)
    local cover = "╭"
    for i = 1, #cols_max_length do
        local top_middle_edge = string.rep("─", cols_max_length[i])
        cover = cover .. top_middle_edge .. "┬"
    end
    -- byte has length 3
    cover = cover:sub(1, -4) .. "╮\n"
    return cover
end
-- adds the bototm part of the table (bellow the last line)
local add_bottom          = function(cols_max_length)
    local bottom = "╰"
    for i = 1, #cols_max_length do
        local top_middle_edge = string.rep("─", cols_max_length[i])
        bottom = bottom .. top_middle_edge .. "┴"
    end
    -- byte has length 3
    bottom = bottom:sub(1, -4) .. "╯\n"
    return bottom
end

-- methodos exposed to the user
local tablua              = {
    -- Spaces in each side of column elements. Returns the caller.
    padding = function(self, value)
        self.options.padding = value
        self.table = nil
        return self
    end,
    -- The first line will be split from the rest.
    first_line_header = function(self)
        self.options.first_line_header = true
        self.table = nil
        return self
    end,
    -- The first line is just data (no split).
    first_line_data = function(self)
        self.options.first_line_header = false
        self.table = nil
        return self
    end,
    -- Append a line to the table.
    add_line = function(self, line, index)
        assert(type(line) == "table", "argument \"line\" must be a table")
        index = index or #self.lines + 1

        local copy = {}
        for i = 1, index do
            copy[i] = self.lines[i]
        end
        copy[index] = line
        for i = index + 1, #self.lines + 1 do
            copy[i] = self.lines[i - 1]
        end

        self.lines = copy

        -- Everytime a new line is added, clears the cache
        -- Necessary because the new entry may have items with
        -- length greater than the current, so just concatenating
        -- to the old cache may break the formatting
        self.table = nil
    end,
    -- Remove the line in the position index.
    remove_line = function(self, index)
        index = index or #self.lines
        self.lines[index] = nil
        local copy = {}
        local j = 1
        for i = 1, #self.lines do
            if self.lines[i] then
                copy[j] = self.lines[i]
                j = j + 1
            end
        end
        self.lines = copy
        self.table = nil
    end,
    -- Shows the table.
    __tostring = function(t)
        -- try return the cached table
        if t.table then return t.table end

        -- if there is no cached table, regenerates the cache
        local lines = add_padding(t.lines, t.options.padding)
        local cols_max_length = calc_max_col_length(lines)

        local table = ""
        table = table .. add_cover(cols_max_length)
        -- header
        local first_line_index = 1
        if t.options.first_line_header then
            -- lines[#lines + 1] = self.lines[1]
            table = table .. add_line(lines[1], cols_max_length)
            table = table .. add_divisor(cols_max_length)
            first_line_index = first_line_index + 1
        end

        -- lines
        for i = first_line_index, #lines do
            local line = lines[i]
            lines[#lines + 1] = line
            table = table .. add_line(line, cols_max_length)
        end

        t.table = table .. add_bottom(cols_max_length)

        return t.table
    end
}

-- Allows the creations on new tabular by calling tabular()
setmetatable(tablua, {
    __call = function(t, lines)
        local obj = {}
        -- defaults
        obj.lines = lines or { { "<empty>" } }
        obj.table = nil
        obj.options = {
            padding = 1,
            first_line_header = true
        }
        obj.cols_max_length = {}
        setmetatable(obj, t)
        t.__index = t
        return obj
    end,
})

return tablua
