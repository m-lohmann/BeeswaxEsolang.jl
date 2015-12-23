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
    a::Array
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


        beeswax("buzz.bswx") runs the program buzz.bswx up to a default limit of 1000 ticks.
        Equivalent to beeswax("buzz.bswx",0,0.0,1000).


"""
function beeswax(name::AbstractString)
    beeswax(name,0,0.0,1000)
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
`beeswax(name::ASCIIString,debug::Int,limit::Int)`  

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
`beeswax(name::ASCIIString,debug::Int,pause::Int,limit::Int)`  

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
`beeswax(name::ASCIIString,debug::Int,pause::Float64,limit::Int)`  

        beeswax("buzz.bswx",2,0.5,200) runs buzz.bswx in debug mode 2 up to a maximum of 200 ticks.
        New steps are displayed every 0.5 seconds.

    Debug modes

    
 *   0     no debug output.
 *   1     console output of the local stacks of all instruction pointers for every tick.
 *   2     console output of the program, instrution pointer locations and local stack contents.


"""
function beeswax(name::AbstractString,debug::Int,pause::Float64,limit::Int)

    # generate IP list
    # generate global stack
    list=Pointer[]
    gstack=UInt64[]
    ticks=Time(0)
    deb=Debugstate(debug)

    # read program file
    deb.d>2 ? println("reading program file..."):nothing
    prog=open(name)
    code=readlines(prog)
    close(prog)
    
    #check if it’s a valid program
    ismatch(r"[\*_\\/]",readall(name))==true ? nothing : error("No starting point found. Not a valid beeswax program.")

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
    for c=1:cols
        for r=1:rows
            arena.a[r,c]=code[r][c]
        end
    end
    rows=maximum(length(arena.a[:,1]))
    cols=maximum(length(arena.a[1,:]))

    # generate IPs
    #ticks.t=ticks.t+1
    deb.d>2 ? println("generating bees..."):nothing
    for c=1:cols
        for r=1:rows
            arena.a[r,c] == ('*') ? pointer_all(list,r,c):
            arena.a[r,c] == ('\\')? pointer_diag1(list,r,c):
            arena.a[r,c] == ('/') ? pointer_diag2(list,r,c):
            arena.a[r,c] == ('_') ? pointer_horiz(list,r,c):nothing
        end
    end

    ticks.t+=1
    debugger(arena,gstack,list,deb,ticks)
    #move new pointers
    deb.d>2 ? println("moving new bees..."):nothing
    for ind=1:length(list)
       move(list,ind)
    end
    deb.d>2 ? println("cleaning up bees..."):nothing
    cleanupip(list,rows,cols)

    ticks.t+=1
    debugger(arena,gstack,list,deb,ticks)
    deb.d>2 ? println("running program..."):nothing

    while length(list)>0 && ticks.t<=limit
        cleanupip(list,rows,cols)

        for ind=length(list):-1:1
            r=list[ind].loc[1]
            c=list[ind].loc[2]
            if list[ind].wait>0
                list[ind].wait=list[ind].wait-1
            elseif arena.a[r,c]==';'
                list=Pointer[];break
            elseif arena.a[r,c]==' ' && list[ind].printstate==false
                move(list,ind)
                cleanupip(list,rows,cols)
            elseif arena.a[r,c]=='X' && list[ind].printstate==false
                pointer_spread(list,ind,r,c)
                for n=length(list):-1:length(list)-4
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
                move(list,ind)
            end
            cleanupip(list,rows,cols)
            rows=maximum(length(arena.a[:,1]))
            cols=maximum(length(arena.a[1,:]))
        end
        sleep(pause)
        debugger(arena,gstack,list,deb,ticks)
        ticks.t+=1
    end
    terminate()
end



function cleanupip(list,rows,cols)
    len=length(list)
    for ind=1:len
        list[ind].loc[1] < 1    ? list[ind].alive=false :
        list[ind].loc[1] > rows ? list[ind].alive=false :
        list[ind].loc[2] < 1    ? list[ind].alive=false :
        list[ind].loc[2] > cols ? list[ind].alive=false : nothing
    end
    for ind=len:-1:1
        list[ind].alive == false ? deleteat!(list,ind) : nothing
    end
end


function move(list,ind)
    list[ind].dir == 0 ? list[ind].loc=list[ind].loc+[0,1]:
    list[ind].dir == 1 ? list[ind].loc=list[ind].loc+[-1,0]:
    list[ind].dir == 2 ? list[ind].loc=list[ind].loc+[-1,-1]:
    list[ind].dir == 3 ? list[ind].loc=list[ind].loc+[0,-1]:
    list[ind].dir == 4 ? list[ind].loc=list[ind].loc+[1,0]:
    list[ind].dir == 5 ? list[ind].loc=list[ind].loc+[1,1]:nothing
end


function slide(list,ind,m)
    list[ind].loc=list[ind].loc+m
end


function instruct(list,ind,gstack,arena,r,c)
    if list[ind].printstate==false
#Pointer redirection
        arena.a[r,c] == '>' ? redir_r(list,ind):
        arena.a[r,c] == 'q' ? redir_dr(list,ind):
        arena.a[r,c] == 'p' ? redir_dl(list,ind):
        arena.a[r,c] == '<' ? redir_l(list,ind):
        arena.a[r,c] == 'b' ? redir_ul(list,ind):
        arena.a[r,c] == 'd' ? redir_ur(list,ind):
        arena.a[r,c] == 'a' ? rotate_cw(list,ind):
        arena.a[r,c] == 'x' ? rotate_ccw(list,ind):
#Pointer mirroring
        arena.a[r,c] == 's' ? mirror_main1(list,ind):
        arena.a[r,c] == 't' ? mirror_main2(list,ind):
        arena.a[r,c] == 'u' ? mirror_main3(list,ind):
        arena.a[r,c] == 'j' ? mirror_half1(list,ind):
        arena.a[r,c] == 'k' ? mirror_half2(list,ind):
        arena.a[r,c] == 'l' ? mirror_half3(list,ind):
        arena.a[r,c] == 'O' ? mirror_all(list,ind):
#Pointer catching
        arena.a[r,c] == 'm' ? catch_diag1(list,ind):
        arena.a[r,c] == 'n' ? catch_diag2(list,ind):
        arena.a[r,c] == 'o' ? catch_diag3(list,ind):
        arena.a[r,c] == '#' ? catch_all(list,ind):
#Pointer spreading
        #arena.a[r,c] == 'X' ? pointer_spread(list,ind):
#conditionals
        arena.a[r,c] == '\'' ? iftopzero(list,ind):               # a==0 ? jump : move
        arena.a[r,c] == '"' ? iftopgrtzero(list,ind):             # a> 0 ? jump : move
        arena.a[r,c] == 'K' ? iftopeqsec(list,ind):               # a==b ? jump : move
        arena.a[r,c] == 'L' ? iftopgrtsec(list,ind):              # a> b ? jump : move
#Pointer pause
        arena.a[r,c] == 'v' ? wait1(list,ind):                    # wait=1
        arena.a[r,c] == '^' ? wait2(list,ind):                    # wait=2
#Pointer teleport
        arena.a[r,c] == 'J' ? jumpto(list,ind):                   # row,col=a,b
#stack manipulations
        arena.a[r,c] == 'g' ? globalgetfirst(list,ind,gstack):    # a=A
        arena.a[r,c] == 'f' ? localfirst2global(list,ind,gstack): # A=a
        arena.a[r,c] == 'e' ? localflush2global(list,ind,gstack): # A,B,C=c,b,a
        arena.a[r,c] == '~' ? localflip12!(list,ind):              # a=b, b=a
        arena.a[r,c] == '@' ? localflip13!(list,ind):              # a=c, c=a
        arena.a[r,c] == 'F' ? localallfirst!(list,ind):            # a,b,c=a
        arena.a[r,c] == 'z' ? localallzero!(list,ind):             # a,b,c=0
        arena.a[r,c] == 'y' ? globalrotdown!(list,ind,gstack):     
        arena.a[r,c] == 'h' ? globalrotup!(list,ind,gstack):
        arena.a[r,c] == '=' ? globalduptop!(gstack):               # A,B,C,...  -> A,A,B,C,...
        arena.a[r,c] == '?' ? globalpop!(gstack):                  # A,B,C,D,... -> B,C,D,...
        arena.a[r,c] == 'A' ? globalstacklen!(gstack):             #length(A,B,C,...)
#code manipulation
        arena.a[r,c] == 'D' ? adropto(list,ind,arena):
        arena.a[r,c] == 'G' ? agetfrom(list,ind,arena):
        arena.a[r,c] == 'Y' ? rdropto(list,ind,arena):
        arena.a[r,c] == 'Z' ? rgetfrom(list,ind,arena): 
#arithmetic
        arena.a[r,c] == '+' ? add(list,ind):                  # a = a+b
        arena.a[r,c] == '-' ? sub(list,ind):                  # a = a-b
        arena.a[r,c] == '.' ? mul(list,ind):                  # a = a*b
        arena.a[r,c] == ':' ? intdiv(list,ind):               # a = a/b
        arena.a[r,c] == '%' ? mod(list,ind):                  # a = a%b
        isdigit(arena.a[r,c]) ? setnum(list,ind,arena):       # a = digit
        arena.a[r,c] == 'P' ? increment(list,ind):            # a = a+1
        arena.a[r,c] == 'M' ? decrement(list,ind):            # a = a-1
#bitwise operations
        arena.a[r,c] == '&' ? bitand(list,ind):               # a = a&b
        arena.a[r,c] == '|' ? bitor(list,ind):                # a = a|b
        arena.a[r,c] == '\$' ? bitxor(list,ind):              # a = a$b
        arena.a[r,c] == '!' ? bitnot(list,ind):               # a = ~a
        arena.a[r,c] == '(' ? bitshiftleft(list,ind):         # a = a<<1
        arena.a[r,c] == ')' ? bitshiftright(list,ind):        # a = a>>>1
        arena.a[r,c] == '[' ? bitrollleft(list,ind):          # a = a<<1+a>>>63
        arena.a[r,c] == ']' ? bitrollright(list,ind):         # a = a>>>1+a<<63
#I/O
        arena.a[r,c] == 'c' ? ginputchar(gstack):             # A = Char(STDIN) 
        arena.a[r,c] == 'V' ? ginputstring(gstack):           # A,B,C,D,... = "S,T,R,I,N,G,..."
        arena.a[r,c] == 'i' ? ginputint(gstack):              # A = UInt64(STDIN)
        arena.a[r,c] == 'C' ? goutputchar(gstack):            # STDOUT='A'
        arena.a[r,c] == 'I' ? goutputint(gstack):             # STDOUT=Int(A)
        arena.a[r,c] == ',' ? linputchar(list,ind):           # a = Char(STDIN)
        arena.a[r,c] == 'T' ? linputint(list,ind):            # a = UInt64(STDIN)
        arena.a[r,c] == '}' ? loutputchar(list,ind):          # STDOUT='a'
        arena.a[r,c] == '{' ? loutputint(list,ind):           # STDOUT=Int(a)
        arena.a[r,c] == '`' ? toggleoutput(list,ind):
        arena.a[r,c] == 'N' ? newline():                      # STDOUT='\n'
        arena.a[r,c] == 'r' ? readfile(list,ind,gstack):      #to global stack
        arena.a[r,c] == 'w' ? writefile(list,ind,gstack):nothing            #from global stack

    elseif list[ind].printstate==true
        if arena.a[r,c] =='`'
            toggleoutput(list,ind)
        #=elseif arena.a[r,c]==' '=#
        #=    print(" ")=#
        else
            print("$(arena.a[r,c])")
            #print_with_color(:green,"$(arena.a[r,c])")
        end
    end
end
