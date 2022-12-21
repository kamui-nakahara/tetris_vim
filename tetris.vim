function! Loop(timer)
  if g:gamestate=="playing"
    if g:key=="Up"
      call Rotate(0)
    elseif g:key=="Down"
      call Rotate(1)
    elseif (g:key=="Left" || g:key=="Right")
      call Move(g:key)
    endif
    let g:key=""
    let g:count=g:count+1
    call Put_blocks()
    if g:count%30==0
      let g:y=g:y+1
      call Redraw()
      call Check()
    endif
    call setline(g:height+1,"score:".g:score)
    call timer_start(g:s,function("Loop"))
  elseif g:gamestate=="gameover"
    for y in range(1,g:height)
      let str=""
      for x in range(1,g:width)
	if Find(g:frame,x,y)
	  let str=str."🟥"
	else
	  let str=str."⬛️"
	endif
      endfor
      call setline(y,str)
    endfor
    call setline(g:height+2,"gameover")
  elseif g:gamestate=="gameclear"
    for y in range(1,g:height)
      let str=""
      for x in range(1,g:width)
	let str=str.(["🟥","⬜️","🟧","🟩","🟨","🟦","🟪","🟫"][Rand(7)])
      endfor
      call setline(y,str)
    endfor
    call setline(g:height+2,"gameclear")
  endif
endfunction

function! Check()
  let f=0
  for i in g:block
    if (i%1000==g:height-1 || Find(g:put_blocks,i/1000,i%1000+1))
      let f=1
    endif
  endfor
  if f
    for i in g:block
      let g:put_blocks=add(g:put_blocks,i)
    endfor
    let g:blocktype=Rand(len(g:blocks)-1)
    let g:rotate=0
    let g:x=5
    let g:y=-2
    call Redraw()
    let b=[]
    for i in g:put_blocks
      let b=add(b,i%1000)
    endfor
    let mib=min(b)
    let mab=max(b)
    if mib<=2
      let g:gamestate="gameover"
      let g:block=[]
      let g:count=0
      call Put_blocks()
      return
    endif
    for y in range(mib,mab)
      let int=0
      for x in range(2,g:width-1)
	if Find(g:put_blocks,x,y)
	  let int=int+1
	endif
      endfor
      if int==g:width-2
	let g:score=g:score+1
	for i in range(2,g:width-1)
	  call remove(g:put_blocks,index(g:put_blocks,i*1000+y))
	endfor
	for i in range(2,g:width-1)
	  for j in range(y,mib,-1)
	    if Find(g:put_blocks,i,j)
	      call remove(g:put_blocks,index(g:put_blocks,i*1000+j))
	      let g:put_blocks=add(g:put_blocks,i*1000+j+1)
	    endif
	  endfor
	endfor
	if len(g:put_blocks)==0
	  let g:gamestate="gameclear"
	  return
	endif
      endif
    endfor
  endif
endfunction

function! Put_blocks()
  for y in range(1,g:height)
    let str=""
    for x in range(1,g:width)
      let a="　"
      if Find(g:frame,x,y)
	let a="⬜️"
      endif
      if Find(g:block,x,y)
	let a="🟥"
      endif
      if Find(g:put_blocks,x,y)
	let a="🟩"
      endif
      let str=str.a
    endfor
    call setline(y,str)
  endfor
endfunction

function! Find(b,x,y)
  let c=match(a:b,a:x*1000+a:y)
  if c==-1
    return 0
  endif
  return a:b[c]==a:x*1000+a:y
endfunction

function! Read()
  let f=readfile("blocks.json")
  let string=""
  for i in f
    let string=string.i
  endfor
  return json_decode(string)
endfunction

function! Change()
  if g:gamestate=="playing"
    let g:gamestate="pause"
  elseif g:gamestate=="pause"
    let g:gamestate="playing"
    call timer_start(g:s,function("Loop"))
  endif
endfunction

function! Start()
  nnoremap <silent> <ENTER> :call Change()<CR>
  call timer_start(g:s,function("Loop"))
endfunction

function! Rand(n)
  for i in range(5)
    let l:match_end=matchend(reltimestr(reltime()),'\d\+\.')+1
    let l:rand=reltimestr(reltime())[l:match_end:]%(a:n+1)
  endfor
  return l:rand
endfunction

function! Redraw()
  let g:block=[]
  for i in g:blocks[g:blocktype][g:rotate]
    let g:block=add(g:block,i+g:x*1000+g:y)
  endfor
endfunction

function! Rotate(f)
  if a:f
    let f=1
    for i in g:blocks[g:blocktype][(g:rotate+1)%len(g:blocks[g:blocktype])]
      if Find(g:put_blocks,i/1000,i%1000)
	let f=0
      endif
    endfor
    if f
      let g:rotate=(g:rotate+1)%len(g:blocks[g:blocktype])
    endif
    call Redraw()
  else
    let f=1
    for i in g:blocks[g:blocktype][(g:rotate-1)%len(g:blocks[g:blocktype])]
      if Find(g:put_blocks,i/1000,i%1000)
	let f=0
      endif
    endfor
    if f
      let g:rotate=(g:rotate-1)%len(g:blocks[g:blocktype])
    endif
    call Redraw()
  endif
endfunction

function! Move(f)
  if a:f=="Left"
    let f=1
    for i in g:block
      if Find(g:put_blocks,i/1000-1,i%1000)
	let f=0
      endif
    endfor
    if (g:block[1]>3000 && f)
      let g:x=g:x-1
    endif
  elseif a:f=="Right"
    let f=1
    for i in g:block
      if Find(g:put_blocks,i/1000+1,i%1000)
	let f=0
      endif
    endfor
    if (g:block[len(g:block)-1]<g:width*1000-1000 && f)
      let g:x=g:x+1
    endif
  endif
  call Redraw()
endfunction

let g:gamestate="playing"
let g:s=1
let g:count=0
let g:width=12
let g:height=22
let g:blocks=Read()
let g:frame=[]
let g:blocktype=Rand(len(g:blocks)-1)
let g:rotate=0
let g:put_blocks=[]
let g:key=""
for y in range(1,g:height)
  for x in range(1,g:width)
    if (x==1 || y==1 || x==g:width || y==g:height)
      let g:frame=add(g:frame,x*1000+y)
    endif
  endfor
endfor
let g:x=5
let g:y=-2
let g:score=0
call Redraw()

tabnew
call setline(1,"開始するにはENTERを押してください")
nnoremap <silent> <ESC> :qall!<CR>
nnoremap <silent> <ENTER> :call Start()<CR>
nnoremap <silent> <Up> :let g:key="Up"<CR>
nnoremap <silent> <Down> :let g:key="Down"<CR>
nnoremap <silent> <Left> :let g:key="Left"<CR>
nnoremap <silent> <Right> :let g:key="Right"<CR>
