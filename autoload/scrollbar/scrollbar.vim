vim9script

class State
	public var popup_id: number = 0
	public var winid: number = 0
	public var draging: bool = false
	public var grab_offset: number = 0
	public var signature: string = ''
endclass

var state = State.new()

def Geometry(winid: number): dict<any>
	const info = getwininfo(winid)
	if empty(info)
		return {}
	endif
	var w = info[0]
	var height = w.height
	var total = line('$', winid)

	if total <= height || height <= 0
		return {}
	endif

	var thumb = float2nr(round(1.0 * height * height / total))
	thumb = max([1, min([height, thumb])])

	var travel = height - thumb
	var denom = total - height
	var pos = denom > 0
		? float2nr(round(1.0 * (w.topline - 1) * travel / denom))
		: 0
	pos = max([0, min([travel, pos])])

	return {
		line: w.winrow,
		col: w.wincol + w.width - g:scrollbar_width,
		pos: pos,
		thumb: thumb,
		travel: travel,
		denom: denom,
		winrow: w.winrow,
		winheight: height,
	}
enddef

def DragTo(winid: number, screenrow: number)
	var geo = Geometry(winid)
	if empty(geo)
		return
	endif

	var relrow = screenrow - state.grab_offset - geo.winrow
	relrow = max([0, min([geo.travel, relrow])])

	var topline = geo.travel > 0
		? float2nr(round(1.0 * relrow * geo.denom / geo.travel)) + 1
		: 1
	topline = max([1, min([line('$', winid) - geo.winheight + 1, topline])])

	win_execute(winid, $'call winrestview({{"topline": {topline}, "lnum": {topline}}})')
	Update()
enddef

def ElevatorFilter(id: number, key: string): number
	var mouse = getmousepos()

	if key == "\<LeftMouse>"
		if mouse.winid == id
			var geo = Geometry(state.winid)
			if !empty(geo)
				var thumbtop = geo.winrow + geo.pos
				if mouse.screenrow >= thumbtop && mouse.screenrow < thumbtop + geo.thumb
					state.grab_offset = mouse.screenrow - thumbtop
				else
					state.grab_offset = geo.thumb / 2
				endif
				state.draging = true
				DragTo(state.winid, mouse.screenrow)
			endif
			return 1
		endif
	elseif key == "\<LeftDrag>"
		if state.draging
			DragTo(state.winid, mouse.screenrow)
			return 1
		endif
	elseif key == "\<LeftRelease>"
		if state.draging
			state.draging = false
			return 1
		endif
	endif
	return 0
enddef

def Hide()
	if state.popup_id != 0
		popup_close(state.popup_id)
		state.popup_id = 0
		state.signature = ''
	endif
enddef

def Resize()
	if state.popup_id != 0
		var geo = Geometry(state.winid)
		if !empty(geo)
			popup_settext(state.popup_id, [])
			popup_move(state.popup_id, {
				line: geo.line,
				col: geo.col,
				minheight: geo.winheight,
				maxheight: geo.winheight,
			})
		endif
	endif
enddef


def Update()
	const winid = win_getid()

	if win_gettype(winid) != ''
		Hide()
		return
	endif

	var geo = Geometry(winid)
	if empty(geo)
		Hide()
		return
	endif

	state.winid = winid

	const sig = printf('%d:%d:%d:%d:%d:%d',
		winid, geo.line, geo.col, geo.pos, geo.thumb, geo.winheight)
	if sig == state.signature && state.popup_id != 0
			&& !empty(popup_getoptions(state.popup_id))
		return
	endif
	state.signature = sig

	# Build a full-height scrollbar track
	var cell = repeat(' ', g:scrollbar_width)
	var lines: list<any> = []
	for i in range(geo.winheight)
		if i >= geo.pos && i < geo.pos + geo.thumb
			lines->add({text: cell,
				props: [{col: 1, length: g:scrollbar_width, type: 'scrollbar_thumb'}]})
		else
			lines->add({text: cell})
		endif
	endfor

	if state.popup_id == 0 || empty(popup_getoptions(state.popup_id))
		state.popup_id = popup_create(lines, {
			line: geo.line,
			col: geo.col,
			minwidth: g:scrollbar_width,
			maxwidth: g:scrollbar_width,
			minheight: geo.winheight,
			maxheight: geo.winheight,
			zindex: g:scrollbar_zindex,
			wrap: false,
			filter: ElevatorFilter,
			filtermode: 'a',
			opacity: 70,
			highlight: g:scrollbar_track_highlight,
		})
	else
		popup_settext(state.popup_id, lines)
		popup_move(state.popup_id, {
			line: geo.line,
			col: geo.col,
		})
	endif
enddef

export def Enable()
	augroup scrollbar
		autocmd!
		autocmd WinScrolled,WinEnter,BufEnter,VimResized * call Update()
		autocmd CursorMoved,CursorMovedI * call Update()
		autocmd TextChanged,TextChangedI * call Update()
		autocmd WinLeave,BufWinLeave * call Hide()
		autocmd VimResized * call Resize()
	augroup END
	Update()
enddef

export def Disable()
	augroup scrollbar
		autocmd!
	augroup END
	Hide()
enddef

# Force a redraw of the bar. Used when an option that is not part of the cache
# signature changes (highlights, width, zindex), so the change shows at once.
export def Refresh()
	Hide()
	Update()
enddef
