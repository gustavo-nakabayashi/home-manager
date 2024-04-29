-- Shorten function name
local keymap = vim.keymap.set
-- Silent keymap option
local opts = { silent = true }

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

keymap("n", "<C-Space>", "<cmd>WhichKey \\<space><cr>", opts)

-- keymap to open nvim config
keymap("n", "<leader>lc", ":e $MYVIMRC <CR>", opts)

keymap("n", "<leader>w", ":wa<CR>", opts)

-- Normal --
-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Move to window using the <ctrl> hjkl keys
-- keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
-- keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
-- keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
-- keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- Clear highlights
keymap("n", "<leader>h", "<cmd>nohlsearch<CR>", opts)

-- Close buffers
keymap("n", "<S-q>", "<cmd>Bdelete!<CR>", opts)

-- Better paste
keymap("v", "p", '"_dP', opts)

-- Insert --
-- Press jk fast to enter
keymap("i", "jk", "<ESC>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Plugins --

-- UndoTree
keymap("n", "<leader>u", vim.cmd.UndotreeToggle)

-- Primeagen keybindings

keymap("v", "J", ":m '>+1<CR>gv=gv")
keymap("v", "K", ":m '<-2<CR>gv=gv")

keymap("n", "J", "mzJ`z")
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")

-- greatest remap ever
keymap("x", "<leader>p", '"_dP')

-- next greatest remap ever : asbjornHaland
keymap("n", "<leader>y", '"+y')
keymap("v", "<leader>y", '"+y')
keymap("n", "<leader>Y", '"+Y')

keymap("n", "<leader>d", '"_d')
keymap("v", "<leader>d", '"_d')

keymap("n", "<C-n>", "<cmd>cnext<CR>zz")
keymap("n", "<C-p>", "<cmd>cprev<CR>zz")
keymap("n", "<leader>j", "<cmd>lnext<CR>zz")
keymap("n", "<leader>k", "<cmd>lprev<CR>zz")

keymap("n", "<leader>r", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")
