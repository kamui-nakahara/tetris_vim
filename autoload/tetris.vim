let s:width=0
let s:height=0
let s:winconf={"style":"minimal","relative":"editor","width":,"height":s:height/2,"row":s:height/4,"col":s:width/4,"focusable":v:false}

function tetris#start()
  let s:width=nvim_get_option("columns")
  let s:height=nvim_get_option("lines")
endfunction
