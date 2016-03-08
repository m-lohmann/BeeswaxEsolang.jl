#   *
function pointer_all(list::Array{Pointer,1},r::Int,c::Int)
    push!(list,Pointer(UInt64[0,0,0],[r,c],0,0,false,true))
    push!(list,Pointer(UInt64[0,0,0],[r,c],1,0,false,true))
    push!(list,Pointer(UInt64[0,0,0],[r,c],2,0,false,true))
    push!(list,Pointer(UInt64[0,0,0],[r,c],3,0,false,true))
    push!(list,Pointer(UInt64[0,0,0],[r,c],4,0,false,true))
    push!(list,Pointer(UInt64[0,0,0],[r,c],5,0,false,true))
end

#   \
function pointer_diag1(list::Array{Pointer,1},r::Int,c::Int)
    push!(list,Pointer(UInt64[0,0,0],[r,c],2,0,false,true))
    push!(list,Pointer(UInt64[0,0,0],[r,c],5,0,false,true))

end

#   /
function pointer_diag2(list::Array{Pointer,1},r::Int,c::Int)
    push!(list,Pointer(UInt64[0,0,0],[r,c],1,0,false,true))
    push!(list,Pointer(UInt64[0,0,0],[r,c],4,0,false,true))
end

#   _
function pointer_horiz(list::Array{Pointer,1},r::Int,c::Int)
    push!(list,Pointer(UInt64[0,0,0],[r,c],0,0,false,true))
    push!(list,Pointer(UInt64[0,0,0],[r,c],3,0,false,true))
end

#   >
function redir_r(list::Array{Pointer,1},ind::Int)
    list[ind].dir=0
end

#   d
function redir_ur(list::Array{Pointer,1},ind::Int)
    list[ind].dir=1
end

#   b
function redir_ul(list::Array{Pointer,1},ind::Int)
    list[ind].dir=2
end

#   <
function redir_l(list::Array{Pointer,1},ind::Int)
    list[ind].dir=3
end

#   p
function redir_dl(list::Array{Pointer,1},ind::Int)
    list[ind].dir=4
end

#   q
function redir_dr(list::Array{Pointer,1},ind::Int)
    list[ind].dir=5
end

#   a
function rotate_cw(list::Array{Pointer,1},ind::Int)
    list[ind].dir=(list[ind].dir+1)%6
end

#   x
function rotate_ccw(list::Array{Pointer,1},ind::Int)
    list[ind].dir=(list[ind].dir+5)%6
end

#   s
function mirror_main1(list::Array{Pointer,1},ind::Int)
    list[ind].dir==0 ? list[ind].dir=4:
    list[ind].dir==1 ? list[ind].dir=3:
    list[ind].dir==3 ? list[ind].dir=1:
    list[ind].dir==4 ? list[ind].dir=0:nothing
end

#   t
function mirror_main2(list::Array{Pointer,1},ind::Int)
    list[ind].dir==0 ? list[ind].dir=2:
    list[ind].dir==2 ? list[ind].dir=0:
    list[ind].dir==3 ? list[ind].dir=5:
    list[ind].dir==5 ? list[ind].dir=0:nothing
end

#   u
function mirror_main3(list::Array{Pointer,1},ind::Int)
    list[ind].dir==1 ? list[ind].dir=5:
    list[ind].dir==2 ? list[ind].dir=4:
    list[ind].dir==4 ? list[ind].dir=2:
    list[ind].dir==5 ? list[ind].dir=1:nothing
end

#   j
function mirror_half1(list::Array{Pointer,1},ind::Int)
    list[ind].dir==0 ? list[ind].dir=3:
    list[ind].dir==1 ? list[ind].dir=2:
    list[ind].dir==2 ? list[ind].dir=1:
    list[ind].dir==3 ? list[ind].dir=0:
    list[ind].dir==4 ? list[ind].dir=5:
    list[ind].dir==5 ? list[ind].dir=4:nothing
end

#   k
function mirror_half2(list::Array{Pointer,1},ind::Int)
    list[ind].dir==0 ? list[ind].dir=1:
    list[ind].dir==1 ? list[ind].dir=0:
    list[ind].dir==2 ? list[ind].dir=5:
    list[ind].dir==3 ? list[ind].dir=4:
    list[ind].dir==4 ? list[ind].dir=3:
    list[ind].dir==5 ? list[ind].dir=2:nothing
end

#   l
function mirror_half3(list::Array{Pointer,1},ind::Int)
    list[ind].dir==0 ? list[ind].dir=5:
    list[ind].dir==1 ? list[ind].dir=4:
    list[ind].dir==2 ? list[ind].dir=3:
    list[ind].dir==3 ? list[ind].dir=2:
    list[ind].dir==4 ? list[ind].dir=1:
    list[ind].dir==5 ? list[ind].dir=0:nothing
end

#   O
function mirror_all(list::Array{Pointer,1},ind::Int)
    list[ind].dir==0 ? list[ind].dir=3:
    list[ind].dir==1 ? list[ind].dir=4:
    list[ind].dir==2 ? list[ind].dir=5:
    list[ind].dir==3 ? list[ind].dir=0:
    list[ind].dir==4 ? list[ind].dir=1:
    list[ind].dir==5 ? list[ind].dir=2:nothing
end

#   m
function catch_diag1(list::Array{Pointer,1},ind::Int)
    list[ind].dir==2 ? list[ind].alive=false:
    list[ind].dir==5 ? list[ind].alive=false:nothing
end

#   n
function catch_diag2(list::Array{Pointer,1},ind::Int)
    list[ind].dir==1 ? list[ind].alive=false:
    list[ind].dir==4 ? list[ind].alive=false:nothing
end

#   o
function catch_diag3(list::Array{Pointer,1},ind::Int)
    list[ind].dir==0 ? list[ind].alive=false:
    list[ind].dir==3 ? list[ind].alive=false:nothing
end

#   #
function catch_all(list::Array{Pointer,1},ind::Int)
    list[ind].alive=false
end

#   X (dir 012345 spread)
function pointer_spread(list::Array{Pointer,1},ind::Int,r::Int,c::Int)
    for d=0:5
        if d==list[ind].dir
            move(list,ind)
        elseif d==(list[ind].dir+3)%6
            nothing
        else
            push!(list,Pointer(deepcopy(list[ind].lstack),[r,c],d,0,false,true))
        end
    end
end

#   E (dir 03 spread)
function pointer_spread03(list::Array{Pointer,1},ind::Int,r::Int,c::Int)
    if list[ind].dir==0 || list[ind].dir==3
        nothing
    else
        list[ind].dir=0
        push!(list,Pointer(deepcopy(list[ind].lstack),[r,c],3,0,false,true))
    end
end

#   H (dir 14 spread)
function pointer_spread14(list::Array{Pointer,1},ind::Int,r::Int,c::Int)
    if list[ind].dir==1 || list[ind].dir==4
        nothing
    else
        list[ind].dir=1
        push!(list,Pointer(deepcopy(list[ind].lstack),[r,c],4,0,false,true))
    end
end

#   W (dir 25 spread)
function pointer_spread25(list::Array{Pointer,1},ind::Int,r::Int,c::Int)
    if list[ind].dir==2 || list[ind].dir==5
        nothing
    else
        list[ind].dir=2
        push!(list,Pointer(deepcopy(list[ind].lstack),[r,c],5,0,false,true))
    end
end

#   '
function iftopzero(list::Array{Pointer,1},ind::Int)
    if list[ind].lstack[end]==0
        move(list,ind)
    end
end

#   "
function iftopgrtzero(list::Array{Pointer,1},ind::Int)
    if list[ind].lstack[end]>0
        move(list,ind)
    end
end

#   K
function iftopeqsec(list::Array{Pointer,1},ind::Int)
    if list[ind].lstack[end]==list[ind].lstack[end-1]
        move(list,ind)
    end
end

#   L
function iftopgrtsec(list::Array{Pointer,1},ind::Int)
    if list[ind].lstack[end]>list[ind].lstack[end-1]
        move(list,ind)
    end
end

#   v
function wait1(list::Array{Pointer,1},ind::Int)
    if list[ind].printstate==false
        @match list[ind].wait begin
            0 => list[ind].wait=1
            1 => (list[ind].wait=0;move(list,ind))
            _ => nothing
        end
    end
end

#   ^
function wait2(list::Array{Pointer,1},ind::Int)
    if list[ind].printstate==false
        @match list[ind].wait begin
            2 => list[ind].wait=1
            0 => list[ind].wait=2
            1 => (list[ind].wait=0;move(list,ind))
            _ => nothing
        end
    end
end

#   J
function jumpto(list::Array{Pointer,1},ind::Int)
    list[ind].loc=[list[ind].lstack[end],list[ind].lstack[end-1]]
end

#   g
function globalgetfirst(list::Array{Pointer,1},ind::Int,gstack::Array{UInt64,1})
    length(gstack)>0 ? list[ind].lstack[end]=gstack[end] : nothing
end

#   f
function localfirst2global(list::Array{Pointer,1},ind::Int,gstack::Array{UInt64,1})
    push!(gstack,list[ind].lstack[end])
end

#   e
#   push lstack to gstack and initialize lstack to [0,0,0]
function localflush2global(list::Array{Pointer,1},ind::Int,gstack::Array{UInt64,1})
    append!(gstack,reverse(list[ind].lstack))
    fill!(list[ind].lstack,0)
end

#   U
#   push top 3 gstack on lstack in reverse order and pop top 3 gstack
function globalflush2local(list::Array{Pointer,1},ind::Int,gstack::Array{UInt64,1})
    list[ind].lstack[end-2]=gstack[end]
    list[ind].lstack[end-1]=gstack[end-1]
    list[ind].lstack[end]=gstack[end-2]
    for i=1:3
        pop!(gstack)
    end
end

#   ~
function localflip12!(list::Array{Pointer,1},ind::Int)
    push!(list[ind].lstack,splice!(list[ind].lstack,length(list[ind].lstack)-1))
end

#   @
function localflip13!(list::Array{Pointer,1},ind::Int)
    list[ind].lstack=reverse(list[ind].lstack)
end

#   F
function localallfirst!(list::Array{Pointer,1},ind::Int)
    fill!(list[ind].lstack,list[ind].lstack[end])
end

#   z
function localallzero!(list::Array{Pointer,1},ind::Int)
    fill!(list[ind].lstack,0)
end

#   y
function globalrotdown!(list::Array{Pointer,1},ind::Int,gstack::Array{UInt64,1})
    if length(gstack)>0
        depth=list[ind].lstack[end]
        steps=list[ind].lstack[end-1]
        if depth > length(gstack) || depth == 0
            depth = length(gstack)
        end
        append!(gstack,splice!(gstack,length(gstack)-depth+1:length(gstack)-depth+steps%depth))
    end
end

#   h
function globalrotup!(list::Array{Pointer,1},ind::Int,gstack::Array{UInt64,1})
    depth=list[ind].lstack[end]
    steps=list[ind].lstack[end-1]
    if depth > length(gstack) || depth == 0
        depth = length(gstack)
    end
    append!(gstack,splice!(gstack,(length(gstack)-depth+1):length(gstack)-steps%depth))
end

#   =
function globalduptop!(gstack::Array{UInt64,1})
    length(gstack)>0 ? gstack=push!(gstack,gstack[end]) : nothing
end

#   ?
function globalpop!(gstack::Array{UInt64,1})
    length(gstack)>0 ? pop!(gstack) : nothing
end

#   A
function globalstacklen!(gstack::Array{UInt64,1})
    gstack=push!(gstack,length(gstack))
    
end

#code manipulation

#   D (absolute addressing)
function adropto(list::Array{Pointer,1},ind::Int,arena::Honeycomb)
    r=list[ind].lstack[end-1]
    c=list[ind].lstack[end-2]
    dropstuff(list,ind,arena,Int128(r),Int128(c))
end

function dropstuff(list::Array{Pointer,1},ind::Int,arena::Honeycomb,r::Int128,c::Int128)
    rows=maximum(length(arena.a[:,1]))
    cols=maximum(length(arena.a[1,:]))
    # Padding
    r==0 ? arena.a=cat(1,transpose(fill(' ',cols)),arena.a) :
    r>rows ? (delta=Int(r-rows);arena.a=cat(1,arena.a,reshape(fill(' ',delta*cols),delta,cols))) : nothing
    rows=maximum(length(arena.a[:,1]))
    cols=maximum(length(arena.a[1,:]))
    c==0 ? arena.a=cat(2,(fill(' ',rows)),arena.a) :
    c>cols ? (delta=Int(c-cols);arena.a=cat(2,arena.a,reshape(fill(' ',rows*delta),rows,delta))) : nothing
    m=[0,0]
    (r==0 && c!=0) ? m=[1,0] :
    (r==0 && c==0) ? m=[1,1] :
    (c==0 && r!=0) ? m=[0,1] :
    (c!=0 && r!=0) ? m=[0,0] : nothing

    arena.a[list[ind].lstack[end-1]+m[1],list[ind].lstack[end-2]+m[2]]=Char(list[ind].lstack[end])

    if m!=[UInt64(0),UInt64(0)]
        @inbounds for k=1:length(list)
            slide(list,k,m)
        end
    end
end


#   G (absolute addressing)
function agetfrom(list::Array{Pointer,1},ind::Int,arena::Honeycomb)
    rows=maximum(length(arena.a[:,1]))
    cols=maximum(length(arena.a[1,:]))
    r=list[ind].lstack[end-1]
    c=list[ind].lstack[end-2]

    if r==0 || r>rows || c==0 || c>cols
        list[ind].lstack[end]=0
    else
        list[ind].lstack[end]=arena.a[r,c]
    end
end

#   Y (relative addressing)
function rdropto(list::Array{Pointer,1},ind::Int,arena::Honeycomb)
    rows=maximum(length(arena.a[:,1]))
    cols=maximum(length(arena.a[1,:]))
    r=list[ind].lstack[end-1]
    c=list[ind].lstack[end-2]
    x=list[ind].loc[1]
    y=list[ind].loc[2]
    ro=reinterpret(Int64,r)
    co=reinterpret(Int64,c)

    if x+ro<1 || y+co<1 || x+ro>rows || y+co>cols
        list[ind].lstack[end]=0
    else
        arena.a[x+ro,y+co]=list[ind].lstack[end]
    end
end

#   Z (relative addressing)
function rgetfrom(list::Array{Pointer,1},ind::Int,arena::Honeycomb)
    rows=maximum(length(arena.a[:,1]))
    cols=maximum(length(arena.a[1,:]))
    r=list[ind].lstack[end-1]
    c=list[ind].lstack[end-2]
    x=list[ind].loc[1]
    y=list[ind].loc[2]
    ro=reinterpret(Int64,r)
    co=reinterpret(Int64,c)
    
    if x+ro<1 || y+co<1 || x+ro>rows || y+co>cols
        list[ind].lstack[end]=0
    else
        list[ind].lstack[end]=arena.a[x+ro,y+co]
    end
end


# arithmetic

#   +
function add(list::Array{Pointer,1},ind::Int)
    list[ind].lstack[end]=list[ind].lstack[end] + list[ind].lstack[end-1]
end

#   -
function sub(list::Array{Pointer,1},ind::Int)
    list[ind].lstack[end]=list[ind].lstack[end] - list[ind].lstack[end-1]
end

#   .
function mul(list::Array{Pointer,1},ind::Int)
    list[ind].lstack[end]=list[ind].lstack[end] * list[ind].lstack[end-1]
end

#   :
function intdiv(list::Array{Pointer,1},ind::Int)
    list[ind].lstack[end]=div(list[ind].lstack[end],list[ind].lstack[end-1])
end

#   %
function mod(list::Array{Pointer,1},ind::Int)
    list[ind].lstack[end]=list[ind].lstack[end] % list[ind].lstack[end-1]
end

#   0,1,2,3,4,5,6,7,8,9
function setnum(list::Array{Pointer,1},ind::Int,arena::Honeycomb)
    list[ind].lstack[end]=parse(UInt64,arena.a[list[ind].loc[1],list[ind].loc[2]])
end

#   P
function increment(list::Array{Pointer,1},ind::Int)
    list[ind].lstack[end]+=1
end

#   M
function decrement(list::Array{Pointer,1},ind::Int)
    list[ind].lstack[end]-=1
end

#   B
function pow(list::Array{Pointer,1},ind::Int)
    list[ind].lstack[end]=list[ind].lstack[end]^list[ind].lstack[end-1]
end

# bitwise operations

#   &
function bitand(list::Array{Pointer,1},ind::Int)
    list[ind].lstack[end]=list[ind].lstack[end]&list[ind].lstack[end-1]
end

#   |
function bitor(list::Array{Pointer,1},ind::Int)
    list[ind].lstack[end]=list[ind].lstack[end]|list[ind].lstack[end-1]
end

#   $
function bitxor(list::Array{Pointer,1},ind::Int)
    list[ind].lstack[end]=list[ind].lstack[end]$list[ind].lstack[end-1]
end

#   !
function bitnot(list::Array{Pointer,1},ind::Int)
    list[ind].lstack[end]=~list[ind].lstack[end]
end

#   (
function bitshiftleft(list::Array{Pointer,1},ind::Int)
    list[ind].lstack[end]=list[ind].lstack[end]<<list[ind].lstack[end-1]
end

#   )
function bitshiftright(list::Array{Pointer,1},ind::Int)
    list[ind].lstack[end]=list[ind].lstack[end]>>>list[ind].lstack[end-1]
end

#   [
function bitrollleft(list::Array{Pointer,1},ind::Int)
    list[ind].lstack[end]=list[ind].lstack[end]<<(list[ind].lstack[end-1]%64)+list[ind].lstack[end]>>>(64-list[ind].lstack[end-1]%64)
end

#   ]
function bitrollright(list::Array{Pointer,1},ind::Int)
    list[ind].lstack[end]=list[ind].lstack[end]>>>(list[ind].lstack[end-1]%64)+list[ind].lstack[end]<<(64-list[ind].lstack[end-1]%64)
end

#I/O

#   c
function ginputchar(gstack::Array{UInt64,1})
    print_with_color(:green,"c")
    input=readline(STDIN)
    inp=Char(input[1])
    gstack=push!(gstack,inp)
end

#   V
function ginputstring(gstack::Array{UInt64,1})
    print_with_color(:red,"s")
    input=readline(STDIN)
    inp=input[1:end]
    for c=1:length(inp)
        gstack=push!(gstack,inp[c])
    end
end

#   i
function ginputint(gstack::Array{UInt64,1})
    print_with_color(:yellow,"i")
    input=readline(STDIN)
    gstack=push!(gstack,parse(UInt64,input))
end

#   C
function goutputchar(gstack::Array{UInt64,1})
    print(Char(gstack[end]))
end

#   I
function goutputint(gstack::Array{UInt64,1})
    print(Int128(gstack[end]))
end

#   ,
function linputchar(list::Array{Pointer,1},ind::Int)
    print_with_color(:green,"c")
    input=readline(STDIN)
    inp=(input[1])
    list[ind].lstack[end]=inp
end

#   T
function linputint(list::Array{Pointer,1},ind::Int)
    print_with_color(:yellow,"i")
    input=readline(STDIN)
    list[ind].lstack[end]=parse(UInt64,input)
end

#   }
function loutputchar(list::Array{Pointer,1},ind::Int)
    c=list[ind].lstack[end]
    print(Char(c))
end

#   {
function loutputint(list::Array{Pointer,1},ind::Int)
    outint=Int128(list[ind].lstack[end])
    print(outint)
end

#   `
function toggleoutput(list::Array{Pointer,1},ind::Int)
    list[ind].printstate= !list[ind].printstate
end

#   N
function newline()
    print("\n")
end

#   r
function readfile(list::Array{Pointer,1},ind::Int,gstack::Array{UInt64,1})
    namebytes=list[ind].lstack[end]
    if namebytes>length(gstack)
        error("$(list[ind].loc)\nAmount of file name bytes longer than gstack!")
    else
        bytearray=reinterpret(UInt8,gstack)
        namechars=collect(Char,bytearray)[end:-1:end-BigInt(namebytes)+1]
        name=AbstractString(namechars)
        f=open(name,"r")
        try
            code=readbytes(f)
        finally
            close(f)
        end
    end
    padbytesnum=8-length(code)%8
    padbytesarray=collect(zeros(UInt8,padbytesnum))
    padarray8=cat(1,padbytesarray,code)
    padarray64=reinterpret(UInt64,padarray8)
    gstack=cat(1,gstack,padarray64)
end

#   w
function writefile(list::Array{Pointer,1},ind::Int,gstack::Array{UInt64,1})
    namebytes=list[ind].lstack[end]
    filebytes=list[ind].lstack[end-1]
    bytearray=reinterpret(UInt8,gstack)
    if namebytes >= length(bytearray)
        error("$(list[ind].loc)\nFilename taking up all available bytes ($(namebytes)) in the stack ($(length(bytearray)))!")
    elseif namebytes==0
        error("$(list[ind].loc)\nZero length filename!")
    elseif namebytes+filebytes> length(bytearray)
        error("$(list[ind].loc)\nByte sum of file name and file content ($namebytes + $filebytes = $(namebytes+filebytes) bytes) bigger than the stack ($(length(bytearray)) bytes)!")
    else
        namechars=collect(Char,bytearray)[end:-1:end-BigInt(namebytes)+1]
        name=AbstractString(collect(namechars))
        filedata=collect(bytearray)[end-BigInt(namebytes):-1:end-BigInt(namebytes)-BigInt(filebytes)+1]
        f=open(name,"w")
        try
            write(f,filedata)
        finally
            close(f)
        end
    end
end

#   ;
function terminate()
    println("\nProgram finished!")
end
