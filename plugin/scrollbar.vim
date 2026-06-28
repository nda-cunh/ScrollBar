vim9script

# Scrollbar is a plugin to create a real scrollbar on vim.

import autoload '../autoload/scrollbar/scrollbar.vim' as Scrollbar

g:scrollbar_enabled = get(g:, 'scrollbar_enabled', 1)
g:scrollbar_width = get(g:, 'scrollbar_width', 1)
g:scrollbar_highlight = get(g:, 'scrollbar_highlight', 'PmenuThumb')
g:scrollbar_track_highlight = get(g:, 'scrollbar_track_highlight', 'PmenuSbar')
g:scrollbar_zindex = get(g:, 'scrollbar_zindex', 100)

if empty(prop_type_get('scrollbar_thumb'))
	prop_type_add('scrollbar_thumb', {highlight: g:scrollbar_highlight})
endif

if g:scrollbar_enabled
	autocmd VimEnter * ++once call Scrollbar.Enable()
endif

command! ScrollbarEnable  call Scrollbar.Enable()
command! ScrollbarDisable call Scrollbar.Disable()
