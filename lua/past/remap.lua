vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")


-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<C-h>", 
    function()
        vim.cmd("wincmd h")
    end
)
vim.keymap.set("n", "<C-l>", 
    function()
        vim.cmd("wincmd l")
    end
)
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
vim.keymap.set("n", "<leader>vs", function()
    vim.cmd(":vs");
    vim.cmd(":vertical resize 100");
end)

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])


vim.keymap.set("n", "<leader>x", function()
    local presentBuffer = vim.api.nvim_get_current_buf()
    vim.cmd("wincmd h")
    local buffer = vim.api.nvim_get_current_buf()
    if presentBuffer == buffer
    then
        vim.cmd("vnew")
        vim.cmd("wincmd h")
        vim.cmd("setlocal buftype=nofile")
        buffer = vim.api.nvim_get_current_buf()
        vim.cmd(":vertical resize 80");
    end
    vim.api.nvim_buf_set_lines(buffer,0,-1,false,{"output of: build.sh"})
    vim.fn.jobstart({"./build.sh"},{
        stdout_buffered = true,
        on_stdout = function(_,data)
            if data then
                vim.api.nvim_buf_set_lines(buffer,-1,-1,false,data)
            end
        end,
        on_stderr = function(_,data)
            if data then
                vim.api.nvim_buf_set_lines(buffer,-1,-1,false,data)
            end
        end,
    })
    vim.cmd("wincmd l")
end)

local function find_executables()
    -- List all files in the 'build' directory
    local files = vim.fn.readdir("build")
    local executables = {}

    -- Iterate through the files and collect those without an extension
    for _, file in ipairs(files) do
        if file:match("^[^%.]+$") then  -- Match files without an extension
            table.insert(executables, file)  -- Add to the executables list
        end
    end

    -- Return the list of executables (empty if none found)
    return executables
end

vim.keymap.set("n", "<leader>r", function()
    vim.cmd("wincmd h");
    local executables = find_executables()

    local executable = executables[1]
    if executable then
        -- Print the name of the executable to debug
        print("Found executable: " .. executable)

        local executable_path = vim.fn.expand("%:p:h") .. "/build/" .. executable
        -- Split window to the left
        vim.cmd("wincmd h")

        -- Get the current buffer number
        local buffer = vim.api.nvim_get_current_buf()

        -- Set initial lines in the buffer (e.g., placeholder text for the output)
        vim.api.nvim_buf_set_lines(buffer, -1, -1, false, {"Output of executable:"})

        -- Start the job to run the executable
        vim.fn.jobstart({"" .. executable_path}, {
            stdout_buffered = true,  -- Ensure output is buffered for easier reading
            on_stdout = function(_, data)
                if data then
                    -- Append output to the buffer
                    vim.api.nvim_buf_set_lines(buffer, -1, -1, false, data)
                end
            end,
            on_stderr = function(_, data)
                if data then
                    -- Handle error output similarly
                    vim.api.nvim_buf_set_lines(buffer, -1, -1, false,data)
                end
            end,
            on_exit = function(_, data)
                -- Optionally handle exit code if needed
                if data then
                    vim.api.nvim_buf_set_lines(buffer, -1, -1, false,data)
                end
            end,
        })
    else
        print("No executable found in the 'build' directory.")
    end  
    vim.cmd("wincmd l")
end)

vim.keymap.set("n", "<leader>D", function()
    local presentBuffer = vim.api.nvim_get_current_buf()
    vim.cmd("wincmd h")
    local buffer = vim.api.nvim_get_current_buf()
    if presentBuffer == buffer
    then
        vim.cmd("vnew")
        vim.cmd("wincmd h")
        vim.cmd("setlocal buftype=nofile")
        buffer = vim.api.nvim_get_current_buf()
        vim.cmd(":vertical resize 80");
    end
    local executables = find_executables()
        for i, exec in ipairs(executables) do
            vim.api.nvim_buf_set_lines(buffer, -1, -1, false, {i .. "." .. exec})
            vim.cmd("redraw")
        end
        local choice = tonumber(vim.fn.input("Enter the number of the executable you want to run: "))

        if choice and choice >= 1 and choice <= #executables 
        then
            local executable = executables[choice]
            local executable_path = vim.fn.expand("%:p:h") .. "/build/" .. executable
            vim.cmd("!gf2 " .. executable)
        else
            print("Invalid choice. Please enter a valid number.")
        end
end)

vim.keymap.set("n", "<leader>=", function()
    vim.cmd("vertical resize 220")
end)

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("noh")
end)


