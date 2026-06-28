vim9script

if has('patch-9.1.0850') == 0
	finish
endif

if !exists('*supraconfig#RegisterMany')
	finish
endif

import autoload '../autoload/scrollbar/scrollbar.vim' as Scrollbar

supraconfig#RegisterGroup('scrollbar', 'Options for the scrollbar plugin')

supraconfig#RegisterMany([
	# --- SCROLLBAR ---
	{
		id: 'scrollbar/enabled',
		type: 'bool',
		default: true,
		lore: 'Enable the scrollbar on startup',
		handler: (v) => {
			g:scrollbar_enabled = v
			if v
				Scrollbar.Enable()
			else
				Scrollbar.Disable()
			endif
		}
	},
	{
		id: 'scrollbar/width',
		type: 'number',
		default: 1,
		lore: 'Width of the scrollbar in columns',
		handler: (v) => {
			g:scrollbar_width = v
			Scrollbar.Refresh()
		}
	},
	{
		id: 'scrollbar/highlight',
		type: 'string',
		default: 'PmenuThumb',
		lore: 'Highlight group of the draggable thumb',
		handler: (v) => {
			g:scrollbar_highlight = v
			if !empty(prop_type_get('scrollbar_thumb'))
				prop_type_change('scrollbar_thumb', {highlight: v})
			endif
			Scrollbar.Refresh()
		}
	},
	{
		id: 'scrollbar/track_highlight',
		type: 'string',
		default: 'PmenuSbar',
		lore: 'Highlight group of the rail behind the thumb',
		handler: (v) => {
			g:scrollbar_track_highlight = v
			Scrollbar.Refresh()
		}
	},
	{
		id: 'scrollbar/zindex',
		type: 'number',
		default: 100,
		lore: 'Stacking order (zindex) of the scrollbar popup',
		handler: (v) => {
			g:scrollbar_zindex = v
			Scrollbar.Refresh()
		}
	}
])
