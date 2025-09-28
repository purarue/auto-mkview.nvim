## auto-mkview.nvim

A simple nvim plugin to automatically save and restore window views (folds, cursor position, etc., see `:help mkview` and `:help viewoptions`) for files as you open and close them.

- sets up `autocmd`s that automatically call `mkview` and `loadview` when you open close files
- ignores `diff` mode, custom `buftype`s
- can create some mappings, or allow you to customize when this runs

## Configuration

I would recommend setting the following in your config:

```lua
-- dont save current directory or local options/mappings
vim.opt.viewoptions:remove("options")
vim.opt.viewoptions:remove("curdir")
```

To install with [`lazy.nvim`](https://github.com/folke/lazy.nvim):

```lua
{
    "purarue/mkview.nvim",
    event = "BufWinEnter",
    ---@module 'auto-mkview'
    ---@type AutoMkview.Config?
    opts = {
        -- these are the default values
        create_mappings = false, -- override the 'ZZ' mapping to mkview as well
        checker = nil,
    },
}
```

## Advanced

You can pass a `checker` function to specify when to `mkview`:

```lua
{
    create_mappings = true, -- Enable ZZ mapping to save view
    checker = function(opts)
        -- Custom logic to decide if mkview should be called
        -- e.g., only do this for my personal notes directory
        return opts.bufname:match("/notes/.*%.md$")
    end,
}
```

---

Inspired by the [make views automatic](https://vim.fandom.com/wiki/Make_views_automatic) vim fandom tips page.
