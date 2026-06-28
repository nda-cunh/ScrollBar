# ScrollBar

A real, draggable scrollbar for Vim, written in Vim9 script.

## Requirements

- Vim 9 (Vim9 script + popup windows)
- Mouse enabled (`set mouse=a`) for drag support

## Installation

With a plugin manager such as [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'nda-cunh/ScrollBar'
```

Or as a Vim 8+ package / pathogen bundle, drop the directory into
`~/.vim/bundle/ScrollBar`.

## Usage

The scrollbar is enabled automatically on `VimEnter`. Two commands are provided:

| Command            | Description              |
| ------------------ | ------------------------ |
| `:ScrollbarEnable` | Enable the scrollbar     |
| `:ScrollbarDisable`| Disable the scrollbar    |

The thumb only appears when the buffer is taller than the window. Click and drag
the thumb (or click anywhere on the track) to scroll.

## Configuration

Set these globals in your `vimrc` before the plugin loads:

| Variable                    | Default        | Description                                   |
| --------------------------- | -------------- | --------------------------------------------- |
| `g:scrollbar_enabled`       | `1`            | Enable automatically at startup               |
| `g:scrollbar_width`         | `1`            | Width of the scrollbar in columns             |
| `g:scrollbar_highlight`     | `'PmenuThumb'` | Highlight group for the thumb                 |
| `g:scrollbar_track_highlight`| `'PmenuSbar'` | Highlight group for the track                 |
| `g:scrollbar_zindex`        | `100`          | Popup z-index (stacking order)                |

Example:

```vim
g:scrollbar_width = 2
g:scrollbar_highlight = 'PmenuThumb'
g:scrollbar_track_highlight = 'PmenuSbar'
```
