type Pointer
    lstack::Array{UInt64,1}
    loc::Array{Int,1}
    dir::Int
    wait::Int
    printstate::Bool
    alive::Bool
    Pointer(lstack,loc,dir,wait,printstate,alive) = new(lstack,loc,dir,wait,printstate,alive)
end

type Honeycomb
    a::Array{Char,2}
    Honeycomb(a)=new(a)
end

type Time
    t::Int
    Time(t)=new(t)
end

type Debugstate
    d::Int
    Debugstate(d)=new(d)
end


"""
`beeswax(name::ASCIIString)`  


        beeswax("buzz.bswx") runs the program buzz.bswx up to a default limit of 1 million ticks.
        Equivalent to beeswax("buzz.bswx",0,0.0,1000000).


"""
function beeswax(name::AbstractString)
    beeswax(name,0,0.0,1000000)
end


"""
`beeswax(name::ASCIIString,limit::Int)`  


        beeswax("buzz.bswx",1e6) runs the program buzz.bswx up to a maximum of 1 million ticks.
        Equivalent to beeswax("buzz.bswx",0,0.0,1e6).


"""
function beeswax(name::AbstractString,limit::Int)
    beeswax(name,0,0.0,limit)
end


"""
`beeswax(name::ASCIIString,debug::Debugstate,limit::Int)`  

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
`beeswax(name::ASCIIString,debug::Debugstate,pause::Int,limit::Int)`  

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
`beeswax(name::ASCIIString,debug::Debugstate,pause::Float64,limit::Int)`  

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
    deb.d>2&&deb.d<9? println("reading program file..."):
    deb.d>=9? println("one-liner test mode....") : nothing
    if deb.d<9
        prog=open(name)
        code=readlines(prog)
        close(prog)
    elseif deb.d>=9
        code=split(name,"\n")
    end

    #check if it’s a valid program
    if deb.d<9
        if ismatch(r"[\*_\\/]",readstring(name))==false
            error("No starting point found. Not a valid beeswax program.")
        end
    elseif deb.d>=9
        start=0
        for i=1:length(code)
            ismatch(r"[\*_\\/]",code[i])==true ? start+=1 : nothing
        end
        start==0 ? error("No starting point found. Not a valid beeswax program.") : nothing
        deb.d==9 ? deb=Debugstate(2) : deb=Debugstate(0)
    end

    # create arena
    deb.d>2 ? println("creating honeycomb..."):nothing
    rows=length(code)
    cols=0
    for i =1:length(code)
        code[i]=chomp(code[i])
        cols=maximum([cols,strwidth(code[i])])
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
    deb.d>2 ? println("generating bees..."):nothing
    @inbounds for c=1:cols
        @inbounds for r=1:rows
            arena.a[r,c] == ('*') ? pointer_all(list,r,c):
            arena.a[r,c] == ('\\')? pointer_diag1(list,r,c):
            arena.a[r,c] == ('/') ? pointer_diag2(list,r,c):
            arena.a[r,c] == ('_') ? pointer_horiz(list,r,c):nothing
        end
    end

    debugger(arena,gstack,list,deb,ticks)
    ticks.t+=1
#=    #move new pointers
    deb.d>2 ? println("moving new bees..."):nothing
    for ind=1:length(list)
       move(list,ind)
    end
    deb.d>2 ? println("cleaning up bees..."):nothing
    cleanupip(list,rows,cols)

    ticks.t+=1
    debugger(arena,gstack,list,deb,ticks)=#
    deb.d>2 ? println("running program..."):nothing

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
                arena.a[r,c]=='^' && list[ind].printstate==false ? nothing: move(list,ind)
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
    @match list[ind].dir begin
        0 => list[ind].loc=list[ind].loc+[0,1]
        1 => list[ind].loc=list[ind].loc+[-1,0]
        2 => list[ind].loc=list[ind].loc+[-1,-1]
        3 => list[ind].loc=list[ind].loc+[0,-1]
        4 => list[ind].loc=list[ind].loc+[1,0]
        5 => list[ind].loc=list[ind].loc+[1,1]
        _ => nothing
    end
end


function slide(list::Array{Pointer,1},ind::Int,m::Array{Int,1})
    list[ind].loc=list[ind].loc+m
end


function instruct(list::Array{Pointer,1},ind::Int,gstack::Array{UInt64,1},arena::Honeycomb,r::Int,c::Int)
    if list[ind].printstate==false

        @match arena.a[r,c] begin
    #Pointer redirection
            '>' => redir_r(list,ind)
            'q' => redir_dr(list,ind)
            'p' => redir_dl(list,ind)
            '<' => redir_l(list,ind)
            'b' => redir_ul(list,ind)
            'd' => redir_ur(list,ind)
            'a' => rotate_cw(list,ind)
            'x' => rotate_ccw(list,ind)
    #Pointer mirroring
            's' => mirror_main1(list,ind)
            't' => mirror_main2(list,ind)
            'u' => mirror_main3(list,ind)
            'j' => mirror_half1(list,ind)
            'k' => mirror_half2(list,ind)
            'l' => mirror_half3(list,ind)
            'O' => mirror_all(list,ind)
    #Pointer catching
            'm' => catch_diag1(list,ind)
            'n' => catch_diag2(list,ind)
            'o' => catch_diag3(list,ind)
            '#' => catch_all(list,ind)
    #conditionals
            '\''=> iftopzero(list,ind)               # a==0 ? jump  move
            '"' => iftopgrtzero(list,ind)             # a> 0 ? jump  move
            'K' => iftopeqsec(list,ind)               # a==b ? jump  move
            'L' => iftopgrtsec(list,ind)              # a> b ? jump  move
    #unconditional skip
            'Q' => skipnext(list,ind)                 #skip next
    #Pointer pause
            'v' => wait1(list,ind)                    # wait=1
            '^' => wait2(list,ind)                    # wait=2
    #Pointer teleport
            'J' => jumpto(list,ind)                   # row,col=a,b
    #stack manipulations
            'g' => globalgetfirst(list,ind,gstack)    # a=A
            'f' => localfirst2global(list,ind,gstack) # A=a
            'e' => localflush2global(list,ind,gstack) # A,B,C=c,b,a
            'U' => globalflush2local(list,ind,gstack)
            '~' => localflip12!(list,ind)              # a=b, b=a
            '@' => localflip13!(list,ind)              # a=c, c=a
            'F' => localallfirst!(list,ind)            # a,b,c=a
            'z' => localallzero!(list,ind)             # a,b,c=0
            'y' => globalrotdown!(list,ind,gstack)     
            'h' => globalrotup!(list,ind,gstack)
            '=' => globalduptop!(gstack)               # A,B,C,...  -> A,A,B,C,...
            '?' => globalpop!(gstack)                  # A,B,C,D,... -> B,C,D,...
            'A' => globalstacklen!(gstack)             #length(A,B,C,...)
    #code manipulation
            'D' => adropto(list,ind,arena)
            'G' => agetfrom(list,ind,arena)
            'Y' => rdropto(list,ind,arena)
            'Z' => rgetfrom(list,ind,arena) 
    #arithmetic
            '+' => add(list,ind)                  # a = a+b
            '-' => sub(list,ind)                  # a = a-b
            '.' => mul(list,ind)                  # a = a*b
            ':' => intdiv(list,ind)               # a = a/b
            '%' => mod(list,ind)                  # a = a%b
            '0' => setnum(list,ind,arena)         # a = 0
            '1' => setnum(list,ind,arena)         # a = 1
            '2' => setnum(list,ind,arena)
            '3' => setnum(list,ind,arena)
            '4' => setnum(list,ind,arena)         # ....
            '5' => setnum(list,ind,arena)
            '6' => setnum(list,ind,arena)
            '7' => setnum(list,ind,arena)
            '8' => setnum(list,ind,arena)
            '9' => setnum(list,ind,arena)
            'P' => increment(list,ind)            # a = a+1
            'M' => decrement(list,ind)            # a = a-1
            'B' => pow(list,ind)                  # a = a^b
    #bitwise operations
            '&' => bitand(list,ind)               # a = a&b
            '|' => bitor(list,ind)                # a = a|b
            '\$'=> bitxor(list,ind)              # a = a$b
            '!' => bitnot(list,ind)               # a = ~a
            '(' => bitshiftleft(list,ind)         # a = a<<b
            ')' => bitshiftright(list,ind)        # a = a>>>b
            '[' => bitrollleft(list,ind)          # a = a<<b%64+a>>>(64-b)%64
            ']' => bitrollright(list,ind)         # a = a>>>b%64+a<<(64-b)%64
    #I/O
            'c' => ginputchar(gstack)             # A = Char(STDIN) 
            'V' => ginputstring(gstack)           # A,B,C,D,... = "S,T,R,I,N,G,..."
            'i' => ginputint(gstack)              # A = UInt64(STDIN)
            'C' => goutputchar(gstack)            # STDOUT='A'
            'I' => goutputint(gstack)             # STDOUT=Int(A)
            ',' => linputchar(list,ind)           # a = Char(STDIN)
            'T' => linputint(list,ind)            # a = UInt64(STDIN)
            '}' => loutputchar(list,ind)          # STDOUT='a'
            '{' => loutputint(list,ind)           # STDOUT=Int(a)
            '`' => toggleoutput(list,ind)
            'N' => newline()                      # STDOUT='\n'
            'r' => readfile(list,ind,gstack)      #to global stack
            'w' => writefile(list,ind,gstack)     #from global stack
            _   => nothing
        end

    elseif list[ind].printstate==true
        if arena.a[r,c] =='`'
            toggleoutput(list,ind)
        else
            print(arena.a[r,c])
        end
    end
end
