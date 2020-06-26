mutable struct Pointer
    lstack::Array{UInt64,1}
    loc::Array{Int,1}
    dir::Int
    wait::Int
    printstate::Bool
    alive::Bool
    Pointer(lstack,loc,dir,wait,printstate,alive) = new(lstack,loc,dir,wait,printstate,alive)
end

mutable struct Honeycomb
    a::Array{Char,2}
    Honeycomb(a)=new(a)
end

mutable struct Time
    t::Int
    Time(t)=new(t)
end

mutable struct Debugstate
    d::Int
    Debugstate(d)=new(d)
end


"""
`beeswax(name::AbstractString)`


        beeswax("buzz.bswx") runs the program buzz.bswx up to a default limit of 1 million ticks.
        Equivalent to beeswax("buzz.bswx",0,0.0,1000000).


"""
function beeswax(name::AbstractString)
    beeswax(name,0,0.0,1000000)
end


"""
`beeswax(name::AbstractString,limit::Int)`


        beeswax("buzz.bswx",1e6) runs the program buzz.bswx up to a maximum of 1 million ticks.
        Equivalent to beeswax("buzz.bswx",0,0.0,1e6).


"""
function beeswax(name::AbstractString,limit::Int)
    beeswax(name,0,0.0,limit)
end


"""
`beeswax(name::AbstractString,debug::Debugstate,limit::Int)`

        beeswax("buzz.bswx",2,200) runs buzz.bswx in debug mode 2 up to a maximum of 200 ticks.
        Equivalent to beeswax("buzz.bswx",2,0.0,200).

    Debug modes


 *   0     no debug output.
 *   1     console output of the local stacks of all instruction pointers for every tick.
 *   2     console output of the program, instrution pointer locations and local stack contents.


"""
function beeswax(name::AbstractString,debug::Int,limit::Int)
    beeswax(name,debug,0.0,limit)
end


"""
`beeswax(name::AbstractString,debug::Debugstate,pause::Int,limit::Int)`

        beeswax("buzz.bswx",2,2,200) runs buzz.bswx in debug mode 2 up to a maximum of 200 ticks.
        Every 2 seconds the next step is displayed.
        Equivalent to beeswax("buzz.bswx",2,2.0,200).

    Debug modes


*    0     no debug output.
*    1     console output of the local stacks of all instruction pointers for every tick.
*    2     console output of the program, instrution pointer locations and local stack contents.


"""
function beeswax(name::AbstractString,debug::Int,pause::Int,limit::Int)
    beeswax(name,debug,Float64(pause),limit)
end


"""
`beeswax(name::AbstractString,debug::Debugstate,pause::Float64,limit::Int)`

        beeswax("buzz.bswx",2,0.5,200) runs buzz.bswx in debug mode 2 up to a maximum of 200 ticks.
        New steps are displayed every 0.5 seconds.

    Debug modes


 *   0     no debug output.
 *   1     console output of the local stacks of all instruction pointers for every tick.
 *   2     console output of the program, instrution pointer locations and local stack contents.


"""
function beeswax(name::AbstractString,debug::Int,pause::Float64,limit::Float64)
    beeswax(name,debug,pause,Int(limit))
end

function beeswax(name::AbstractString,debug::Int,pause::Int,limit::Float64)
    beeswax(name,debug,Float64(pause),Int(limit))
end

function beeswax(name::AbstractString,debug::Int,pause::Float64,limit::Int)

    # generate IP list
    # generate global stack
    list=Pointer[]
    sizehint!(list,10000)
    gstack=UInt64[]
    sizehint!(gstack,10000)
    ticks=Time(0)
    deb=Debugstate(debug)

    # read program file
    deb.d>2&&deb.d<9 ? println("reading program file...") :
    deb.d>=9 ? println("one-liner test mode....") : nothing
    if deb.d<9
        prog=open(name)
        code=readlines(prog)
        close(prog)
    elseif deb.d>=9
        code=split(name,"\n")
    end

    #check if it’s a valid program
    if deb.d<9
        if match(r"[\*_\\/]",readstring(name)) != nothing
            error("No starting point found. Not a valid beeswax program.")
        end
    elseif deb.d>=9
        start=0
        for i=1:length(code)
            match(r"[\*_\\/]",code[i]) != nothing ? start+=1 : nothing
        end
        start==0 ? error("No starting point found. Not a valid beeswax program.") : nothing
        deb.d==9 ? deb=Debugstate(2) : deb=Debugstate(0)
    end

    # create arena
    deb.d>2 ? println("creating honeycomb...") : nothing
    rows=length(code)
    cols=0
    for i =1:length(code)
        code[i]=chomp(code[i])
        cols=maximum([cols,textwidth(code[i])])
    end
    for i=1:length(code)
        code[i]=rpad(code[i],cols," ")
    end
    arena=Honeycomb(reshape(fill(' ',rows*cols),rows,cols))

    @inbounds for r=1:rows
        i=1;c=1
        @inbounds while i<endof(code[r]) || c<=length(code[r])
            try
                arena.a[r,c]=code[r][i]
            catch
            end
            i=nextind(code[r],i)
            c+=1
        end
    end

    rows=maximum(length(arena.a[:,1]))
    cols=maximum(length(arena.a[1,:]))

    # generate IPs
    deb.d>2 ? println("generating bees...") : nothing
    @inbounds for c=1:cols
        @inbounds for r=1:rows
            arena.a[r,c] == ('*')  ? pointer_all(list,r,c) :
            arena.a[r,c] == ('\\') ? pointer_diag1(list,r,c) :
            arena.a[r,c] == ('/')  ? pointer_diag2(list,r,c) :
            arena.a[r,c] == ('_')  ? pointer_horiz(list,r,c) : nothing
        end
    end

    debugger(arena,gstack,list,deb,ticks)
    ticks.t+=1

    deb.d>2 ? println("running program...") : nothing

    while length(list)>0 && ticks.t<=limit
        cleanupip(list,rows,cols)

        @inbounds for ind=length(list):-1:1
            r=list[ind].loc[1]
            c=list[ind].loc[2]
            if arena.a[r,c]==';'
                list=Pointer[];break
            elseif arena.a[r,c]==' ' && list[ind].printstate==false
                move(list,ind)
                cleanupip(list,rows,cols)
            elseif arena.a[r,c]=='X' && list[ind].printstate==false
                pointer_spread(list,ind,r,c)
                for n=length(list):-1:length(list)-3
                    move(list,n)
                end
                cleanupip(list,rows,cols)
            elseif arena.a[r,c]=='E' && list[ind].printstate==false
                pointer_spread03(list,ind,r,c)
                move(list,ind)
                move(list,length(list))
                cleanupip(list,rows,cols)
            elseif arena.a[r,c]=='H' && list[ind].printstate==false
                pointer_spread14(list,ind,r,c)
                move(list,ind)
                move(list,length(list))
                cleanupip(list,rows,cols)
            elseif arena.a[r,c]=='W' && list[ind].printstate==false
                pointer_spread25(list,ind,r,c)
                move(list,ind)
                move(list,length(list))
                cleanupip(list,rows,cols)
            else
                instruct(list,ind,gstack,arena,r,c)
                #For 'J' the jump to new location itself counts as move
                arena.a[r,c]=='J' && list[ind].printstate==false ? nothing :
                arena.a[r,c]=='J' && list[ind].printstate==true ? move(list,ind) :
                arena.a[r,c]=='v' && list[ind].printstate==true ? move(list,ind) :
                arena.a[r,c]=='v' && list[ind].printstate==false ? nothing :
                arena.a[r,c]=='^' && list[ind].printstate==true ? move(list,ind) :
                arena.a[r,c]=='^' && list[ind].printstate==false ? nothing : move(list,ind)
            end
            cleanupip(list,rows,cols)
            rows=maximum(length(arena.a[:,1]))
            cols=maximum(length(arena.a[1,:]))
        end
        pause>0.0 ? sleep(pause) : nothing
        debugger(arena,gstack,list,deb,ticks)
        ticks.t+=1
    end
    terminate()
end

function cleanupip(list::Array{Pointer,1},rows::Int,cols::Int)
    for ind=1:length(list)
        list[ind].loc[1] < 1    ? list[ind].alive=false :
        list[ind].loc[1] > rows ? list[ind].alive=false :
        list[ind].loc[2] < 1    ? list[ind].alive=false :
        list[ind].loc[2] > cols ? list[ind].alive=false : nothing
    end
    for ind=length(list):-1:1
        list[ind].alive == false ? deleteat!(list,ind) : nothing
    end
end


function move(list::Array{Pointer,1},ind::Int)
    d=list[ind].dir
    d == 0 ? list[ind].loc=list[ind].loc+[0,1] :
    d == 1 ? list[ind].loc=list[ind].loc+[-1,0] :
    d == 2 ? list[ind].loc=list[ind].loc+[-1,-1] :
    d == 3 ? list[ind].loc=list[ind].loc+[0,-1] :
    d == 4 ? list[ind].loc=list[ind].loc+[1,0] :
    d == 5 ? list[ind].loc=list[ind].loc+[1,1] : nothing
end


function slide(list::Array{Pointer,1},ind::Int,m::Array{Int,1})
    list[ind].loc=list[ind].loc+m
end

function instruct(list::Array{Pointer,1},ind::Int,gstack::Array{UInt64,1},arena::Honeycomb,row::Int,col::Int)

    if list[ind].printstate==false

        c=arena.a[row,col]

        c == '#' ? catch_all(list,ind)                :
        c == '>' ? redir_r(list,ind)                  :
        c == 'q' ? redir_dr(list,ind)                 :
        c == 'p' ? redir_dl(list,ind)                 :
        c == '<' ? redir_l(list,ind)                  :
        c == 'b' ? redir_ul(list,ind)                 :
        c == 'd' ? redir_ur(list,ind)                 :
        c == '0' ? setnum(list,ind,arena)             :
        c == '1' ? setnum(list,ind,arena)             :
        c == '2' ? setnum(list,ind,arena)             :
        c == '3' ? setnum(list,ind,arena)             :
        c == '4' ? setnum(list,ind,arena)             :
        c == '5' ? setnum(list,ind,arena)             :
        c == '6' ? setnum(list,ind,arena)             :
        c == '7' ? setnum(list,ind,arena)             :
        c == '8' ? setnum(list,ind,arena)             :
        c == '9' ? setnum(list,ind,arena)             :
        c == 'P' ? increment(list,ind)                :
        c == 'M' ? decrement(list,ind)                :
        c == '+' ? add(list,ind)                      :
        c == '-' ? sub(list,ind)                      :
        c == '.' ? mul(list,ind)                      :
        c == ':' ? intdiv(list,ind)                   :
        c == '%' ? modulus(list,ind)                  :
        c == 'B' ? pow(list,ind)                      :
        c == '&' ? bitand(list,ind)                   :
        c == '|' ? bitor(list,ind)                    :
        c == '\$' ? bitxor(list,ind)                  :
        c == '!' ? bitnot(list,ind)                   :
        c == '(' ? bitshiftleft(list,ind)             :
        c == ')' ? bitshiftright(list,ind)            :
        c == '[' ? bitrollleft(list,ind)              :
        c == ']' ? bitrollright(list,ind)             :
        c == '\'' ? iftopzero(list,ind)               :
        c == '"' ? iftopgrtzero(list,ind)             :
        c == 'K' ? iftopeqsec(list,ind)               :
        c == 'L' ? iftopgrtsec(list,ind)              :
        c == 'Q' ? skipnext(list,ind)                 :
        c == '~' ? localflip12!(list,ind)             :
        c == '@' ? localflip13!(list,ind)             :
        c == 'F' ? localallfirst!(list,ind)           :
        c == 'z' ? localallzero!(list,ind)            :
        c == 'y' ? globalrotdown!(list,ind,gstack)    :
        c == 'h' ? globalrotup!(list,ind,gstack)      :
        c == '=' ? globalduptop!(gstack)              :
        c == '?' ? globalpop!(gstack)                 :
        c == 'C' ? goutputchar(gstack)                :
        c == 'I' ? goutputint(gstack)                 :
        c == '}' ? loutputchar(list,ind)              :
        c == '{' ? loutputint(list,ind)               :
        c == '`' ? toggleoutput(list,ind)             :
        c == 'm' ? catch_diag1(list,ind)              :
        c == 'n' ? catch_diag2(list,ind)              :
        c == 'o' ? catch_diag3(list,ind)              :
        c == 'a' ? rotate_cw(list,ind)                :
        c == 'x' ? rotate_ccw(list,ind)               :
        c == 's' ? mirror_main1(list,ind)             :
        c == 't' ? mirror_main2(list,ind)             :
        c == 'u' ? mirror_main3(list,ind)             :
        c == 'j' ? mirror_half1(list,ind)             :
        c == 'k' ? mirror_half2(list,ind)             :
        c == 'l' ? mirror_half3(list,ind)             :
        c == 'O' ? mirror_all(list,ind)               :
        c == 'v' ? wait1(list,ind)                    :
        c == '^' ? wait2(list,ind)                    :
        c == 'J' ? jumpto(list,ind)                   :
        c == 'g' ? globalgetfirst(list,ind,gstack)    :
        c == 'f' ? localfirst2global(list,ind,gstack) :
        c == 'e' ? localflush2global(list,ind,gstack) :
        c == 'U' ? globalflush2local(list,ind,gstack) :
        c == 'A' ? globalstacklen!(gstack)            :
        c == 'D' ? adropto(list,ind,arena)            :
        c == 'G' ? agetfrom(list,ind,arena)           :
        c == 'Y' ? rdropto(list,ind,arena)            :
        c == 'Z' ? rgetfrom(list,ind,arena)           :
        c == 'c' ? ginputchar(gstack)                 :
        c == 'V' ? ginputstring(gstack)               :
        c == 'i' ? ginputint(gstack)                  :
        c == ',' ? linputchar(list,ind)               :
        c == 'T' ? linputint(list,ind)                :
        c == 'N' ? newline()                          :
        c == 'r' ? readfile(list,ind,gstack)          :
        c == 'w' ? writefile(list,ind,gstack)         : nothing

    else #if list[ind].printstate==true
        if arena.a[r,c] == '`'
            toggleoutput(list,ind)
        else
            print(arena.a[r,c])
        end
    end
end
