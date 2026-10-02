# Emacs settings

My Emacs configuration (Emacs 30, macOS) plus a cheat sheet for the packages it sets up.

## Setup on a new machine

```bash
git clone git@github.com:megajess/emacs-settings.git ~/.emacs.d
brew install pandoc        # Markdown previews
```

Then start Emacs. On first start, `use-package` downloads all the packages from MELPA, which takes a minute. The terminal (eat) fix for macOS is also built automatically.

### Shell setup (`~/.zshrc`)

`~/.zshrc` isn't part of this repo, so add this at the end of it by hand:

```bash
# Emacs eat terminal: shell integration (only active inside eat). Lets eat
# tell an idle shell from a running command, so closing Emacs doesn't ask
# about an idle terminal.
[ -n "$EAT_SHELL_INTEGRATION_DIR" ] && \
  source "$EAT_SHELL_INTEGRATION_DIR/zsh"
```

What it does:
- **Quitting Emacs with an idle terminal:** no "active process" prompt. It still asks if a command is running in a terminal, so you don't kill something by accident.
- **Directory tracking:** eat follows the shell's current directory as you `cd`.
- **Only active inside eat.** eat sets `EAT_SHELL_INTEGRATION_DIR` for its own shells, so normal terminals are unaffected.

Without it everything else still works, but quitting Emacs asks about every open terminal.

Optional extras:
- **SLIME (Common Lisp):** install SBCL and Quicklisp, then in SBCL run `(ql:quickload "quicklisp-slime-helper")`. `init.el` loads it if it's present and skips it if not.
- **Dracula Pro theme:** a paid theme, so it isn't in this repo. Copy `dracula-pro-blade-theme.el` into `~/.emacs.d/themes/` and enable its `load-theme` line in `init.el`.

## Config tips

| Keys / command | Action |
|---|---|
| `C-M-x` (cursor in a top-level form) | Re-run that form, e.g. after editing a `use-package` block |
| `M-x eval-buffer` (in `init.el`) | Re-run the whole config |
| `M-x disable-theme` then `M-x load-theme` | Try another theme without restarting |

Themes: the packages are installed near the top of `init.el`, followed by one `load-theme` line per theme. Keep exactly one uncommented.

---

# Cheat sheet

`C-` = Ctrl, `M-` = Option/Alt, `s-` = Cmd, `S-` = Shift.
Keys written like `C-c C-c l` are pressed one after another.

## Windows (moving between panels)

| Keys | Action |
|---|---|
| `C-S-←/→/↑/↓` | Move to the window in that direction (windmove) |
| `M-o` | 2 windows: switch. 3+: windows get numbers, type one to jump |
| `M-o x` + number | Delete that window |
| `M-o m` + number | Swap with that window |
| `M-o v` / `M-o b` + number | Split that window side-by-side / top-bottom |
| `M-o o` | Close all other windows |
| `M-o ?` | Show all `M-o` actions |
| `C-x }` / `C-x {` | Wider / narrower |
| `C-x ^` | Taller |
| `C-x +` | Make all windows equal |

## Treemacs (file tree)

The tree opens automatically on the left when Emacs starts. The cursor stays in the main window.

| Keys | Action |
|---|---|
| `C-c t` | Show / hide the tree |
| `C-c T` | Jump to the tree |
| `RET` / `TAB` | Open file / expand-collapse folder |
| `S-TAB` | Collapse everything |
| `ov` / `oh` | Open file in a side-by-side / top-bottom split |
| `oaa` | Open file in a window you pick (ace-window) |
| `u` | Go to parent folder |
| `H` | Collapse the folder you're in |
| `M-H` / `M-L` | Move the tree's root up / down |
| `cf` / `cd` | New file / new folder |
| `R` / `m` / `d` | Rename / move / delete |
| `ya` / `yr` | Copy absolute / relative path |
| `g` | Refresh |
| `C-c C-p a` | Add another folder as a project |
| `>` / `<` / `w` | Wider / narrower / set width |
| `?` | Show all keys |

## Terminal (eat)

| Keys | Action |
|---|---|
| `C-c e` | Show / hide the terminal panel (works from inside it too) |
| `M-x eat-project` | Terminal in the project root |
| `C-y` or `s-v` (Cmd+V) | Paste into the shell |
| `M-y` | Paste from earlier copies (kill ring) |
| `C-c C-c` | Send Ctrl-C (interrupt) |
| `C-c C-e` | Emacs mode: scroll, search, select & copy output |
| `C-c C-j` | Back to normal terminal mode |
| `C-x k` | Kill the terminal (next `C-c e` starts a fresh one) |

The terminal has its own colour scheme, independent of the Emacs theme. It's currently the macOS Terminal "Homebrew" profile: green on black with Terminal.app's ANSI colours. A Tokyo Night palette is also defined. To switch, set `my/eat-palette` in `init.el` to `my/eat-palette-homebrew` or `my/eat-palette-tokyo-night`, or add your own palette.

## Markdown (markdown-mode)

| Keys | Action |
|---|---|
| `C-c C-c l` | Live preview beside the source (updates on save) |
| `C-c C-c p` | Preview in your web browser |
| `C-c C-c e` | Export to .html |
| `C-c C-s b` / `i` / `c` | Insert bold / italic / inline code |
| `C-c C-s C` | Insert a ``` code block |
| `C-c C-s h` | Insert a heading |
| `C-c C-l` | Insert a link |
| `C-c C-o` | Open the link at the cursor |
| `TAB` (on a heading) | Fold / unfold the section |
| `C-c C-n` / `C-c C-p` / `C-c C-u` | Next / previous / parent heading |

## Brackets

**Colours (rainbow-delimiters):** brackets are coloured by depth (bold orange, mint, raspberry, white, then repeating). Unmatched or mismatched brackets show white on red.

**Matching bracket (show-paren):** when the cursor is on, just inside, or in the indentation before a bracket, it and its partner are highlighted in solid gold.

**Editing (smartparens, relaxed mode):** typing `(` or `"` inserts the pair, and typing `)` steps over an existing one. Unlike paredit, you can still delete or insert a single bracket. `M-x smartparens-strict-mode` turns on paredit-style strictness for the current buffer.

| Keys | Action | Example |
|---|---|---|
| `C-)` / `C-}` | Slurp / barf forward | `(a b\|) c` → `(a b c)` / `(a b c)` → `(a b) c` |
| `C-(` / `C-{` | Slurp / barf backward | `a (b\|)` → `(a b)` |
| `M-s` | Splice: remove the surrounding brackets | `(f (g\| x))` → `(f g x)` |
| `M-r` | Raise: replace the parent with the form at the cursor | `(f \|(g x))` → `(g x)` |
| `M-(` | Wrap the next form in `( )` | `\|x` → `(x)` |
| `M-S` / `M-j` | Split / join forms | `(a \|b)` → `(a) (b)` |
| `M-<up>` / `M-<down>` | Splice, killing what's before / after the cursor | |
| `C-M-f` / `C-M-b` | Forward / back over a whole form | |
| `C-M-u` / `C-M-d` | Up out of / down into a form | |
| `C-M-k` | Cut the form after the cursor | |

`|` marks the cursor. All the colours are set in `init.el`, in the `rainbow-delimiters` and show-paren sections.

## Git (Magit, diff-hl)

Lines that differ from the last commit are marked in the fringe as you type: **green** added, **blue** changed, **red** deleted. Dired shows changed files the same way.

| Keys | Action |
|---|---|
| `C-x g` | Magit status: see changes, stage, commit, push |
| `C-x v ]` / `C-x v [` | Next / previous changed block |
| `C-x v *` | Show the diff for the block at the cursor |
| `C-x v n` | Revert just that block |
| `C-x v S` | Stage just that block |

In Magit's status buffer:

| Keys | Action |
|---|---|
| `s` / `u` | Stage / unstage the file or block at the cursor |
| `c c` | Commit (write the message, then `C-c C-c`; `C-c C-k` cancels) |
| `P p` | Push |
| `F p` | Pull |
| `l l` | Log |
| `TAB` | Expand or collapse a file's diff |
| `g` | Refresh |
| `?` | Show all commands |
| `q` | Close Magit |

## Handy built-ins

| Keys | Action |
|---|---|
| `s-c` / `s-x` / `s-v` | Copy / cut / paste (Cmd keys) |
| `C-w` / `M-w` / `C-y` | Cut / copy / paste (Emacs keys; same clipboard) |
| `S-←/→/↑/↓` | Select text |
| `C-x p f` | Find a file in the project |
| `C-x p s` | Shell in the project root |
| `M-x tool-bar-mode` | Bring the tool bar back for this session |
| `M-x display-line-numbers-mode` | Toggle line numbers (on by default in code files) |
