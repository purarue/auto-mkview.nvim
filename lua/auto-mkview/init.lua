local M = {}

---@class (exact) AutoMkview.CheckerOptions
---@field bufname string current buffer full path

---@class (exact) AutoMkview.Config
---@field checker? fun(checker_opts: AutoMkview.CheckerOptions):boolean additional function to be called during setup
---@field create_mappings boolean whether to save view on additional mappings
M.config = {
    checker = nil,
    create_mappings = false,
}

local did_setup = false

---@param options AutoMkview.Config?
function M.resolve_config(options)
    M.config = vim.tbl_extend("force", M.config, options or {})
    if M.config.checker ~= nil and type(M.config.checker) ~= "function" then
        vim.notify("checker should be a function that returns a boolean", vim.log.levels.WARN, { title = "mkview" })
        M.config.checker = nil
    end
end

---Check if mkview should be called
function M.mkview_check()
    if vim.wo.diff or vim.bo.buftype ~= "" then
        return false
    end

    -- if file does not exist, skip writing
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname == "" or not vim.uv.fs_stat(bufname) then
        return false
    end

    if M.config.checker ~= nil then
        return M.config.checker({ bufname = bufname })
    end

    return true
end

---@param options AutoMkview.Config?
function M.setup(options)
    --stylua: ignore
    if did_setup then return end
    did_setup = true

    M.resolve_config(options)

    if M.config.create_mappings then
        vim.keymap.set("n", "ZZ", function()
            if M.mkview_check() then
                pcall(vim.cmd.mkview)
            end
            vim.cmd("x") -- default ZZ behaviour, to close and write if modified
        end, { noremap = true, nowait = false, desc = "save view and close window" })
    end

    local group = vim.api.nvim_create_augroup("mkview_check", { clear = true })
    vim.api.nvim_create_autocmd("BufWinEnter", {
        pattern = "?*",
        callback = function()
            pcall(vim.cmd.loadview)
        end,
        group = group,
        desc = "Load view when entering a buffer window",
    })

    vim.api.nvim_create_autocmd("BufWinLeave", {
        pattern = "?*",
        callback = function()
            if M.mkview_check() then
                pcall(vim.cmd.mkview)
            end
        end,
        group = group,
        desc = "Save view when leaving a buffer window",
    })
end

return M
