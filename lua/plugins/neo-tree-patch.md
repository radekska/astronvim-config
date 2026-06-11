# Neo-tree Git Status Scoping Patch

## The Problem

In a monorepo, neo-tree runs `git status` on the **entire worktree root**,
even when you only have a subdirectory open:

```
kubecast/                     <-- worktree root (git status scans ALL of this)
├── services/
│   ├── users/                <-- your cwd (you only care about this)
│   ├── billing/
│   ├── notifications/
│   └── ... (50 more services)
├── libs/
└── infrastructure/
```

**Result:** `git status` takes seconds instead of milliseconds.

## Neo-tree's Git Status Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    neo-tree.git (init.lua)                   │
│                                                             │
│  make_git_status_args()     <-- builds the actual command   │
│    │                            --porcelain=v2 is unique    │
│    │                            to this function            │
│    ▼                                                        │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ git --no-optional-locks -C <worktree_root> status     │  │
│  │     --porcelain=v2 -z --ignored=traditional           │  │
│  │     --untracked-files=normal                          │  │
│  │     [-- <pathspec>]          <-- we inject this       │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  Two code paths call make_git_status_args:                  │
│                                                             │
│  M.status()          ─── sync  ──▶ vim.fn.system()          │
│    accepts status_opts.paths                                │
│                                                             │
│  M.status_async()    ─── async ──▶ git_utils.git_job()      │
│    calls make_git_status_args        │                      │
│    internally                        ▼                      │
│                                  uv.spawn("git", args)      │
└─────────────────────────────────────────────────────────────┘
```

## The Fix: Two Wrapping Points

```
┌──────────────────────────────────────────────────────┐
│                   Our Patch                          │
│                                                      │
│  scope_dir = vim.fn.getcwd()                         │
│  (updated on BufWritePost)                           │
│                                                      │
│  Patch 1 (sync):                                     │
│  ┌────────────────────────────────────────────────┐  │
│  │ Wrap neo_tree_git.status()                     │  │
│  │   → inject status_opts.paths = { scope_dir }   │  │
│  │   → original M.status passes it to             │  │
│  │     make_git_status_args which appends          │  │
│  │     "-- <scope_dir>" to the command             │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  Patch 2 (async):                                    │
│  ┌────────────────────────────────────────────────┐  │
│  │ Wrap git_utils.git_job()                       │  │
│  │   → detect "status" in args                    │  │
│  │   → append "-- <scope_dir>" to args            │  │
│  │   → pass modified args to uv.spawn             │  │
│  └────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

## Critical Timing: Patch BEFORE setup()

This was the hardest bug to find. The patches **must** be applied
before `require("neo-tree").setup(opts)`:

```
 BROKEN (patches after setup):

   config(_, opts)
     │
     ├─ require("neo-tree").setup(opts)
     │    │
     │    ├─ setup() stores config
     │    ├─ netrw hijack detects directory
     │    ├─ neo-tree opens
     │    ├─ ensure_config() merges config
     │    ├─ filesystem source subscribes to events
     │    ├─ neo-tree renders
     │    └─ git.status_async() ◀── SPAWNS UNPATCHED !!
     │
     └─ patch git.status / git_job   ◀── TOO LATE
```

```
 WORKING (patches before setup):

   config(_, opts)
     │
     ├─ patch git.status / git_job   ◀── APPLIED FIRST
     │
     └─ require("neo-tree").setup(opts)
          │
          ├─ setup() stores config
          ├─ netrw hijack detects directory
          ├─ neo-tree opens
          ├─ ensure_config() merges config
          ├─ filesystem source subscribes to events
          ├─ neo-tree renders
          └─ git.status_async() ◀── HITS OUR WRAPPER ✓
               └─ git_utils.git_job() ◀── HITS OUR WRAPPER ✓
                    └─ uv.spawn("git", scoped_args) ✓
```

## Other Pitfalls Encountered

### 1. Wrong module name

`neo-tree.git.status` does **not exist**. The module is `neo-tree.git`
(from `neo-tree/git/init.lua`). The git directory contains:

```
neo-tree/git/
├── init.lua      ← M.status, M.status_async, M.find_worktree_info
├── utils.lua     ← M.git_job (spawns processes via uv.spawn)
├── parser.lua
├── watch.lua
├── ls-files.lua
└── diff.lua
```

### 2. Lua upvalue scoping

Local functions defined **after** a closure cannot be captured as upvalues:

```lua
local function apply_patch()
  scope_args(...)  -- scope_args is nil here!
end

local function scope_args(...)  -- defined AFTER apply_patch
  ...
end
```

### 3. AstroNvim opts override

AstroNvim uses `astro.extend_tbl(opts, { enable_git_status = true })`
where the **second argument wins** (`vim.tbl_deep_extend("force", ...)`).
A static `opts = { enable_git_status = false }` gets clobbered.
Must use an `opts` function to override after AstroNvim's runs.

### 4. Deferred config merge

`require("neo-tree").setup(opts)` does NOT merge config immediately.
It stores `new_user_config` and defers to `ensure_config()`.
This means `require("neo-tree").config` is **nil** until first use.

### 5. enable_git_status = false is not enough

Even with the flag set to `false`, the `git_status` **source**
(a separate neo-tree tab) calls `git.status()` unconditionally
in its `items.get_git_status()`. The flag only guards calls in
the `filesystem` and `buffers` sources.

## Result

```
Before:  git ... -C /kubecast status --porcelain=v2 ...
After:   git ... -C /kubecast status --porcelain=v2 ... -- /kubecast/services/users
```
