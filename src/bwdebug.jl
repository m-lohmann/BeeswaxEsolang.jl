function debugger(arena::Honeycomb,gstack::Array{UInt64,1},list::Array{Pointer,1},deb::Debugstate,ticks::Time)
    if deb.d==1
        println("\nticks:",ticks.t)
        @inbounds for ind=1:length(list)
            #println(ind,"  instr: ",arena.a[list[ind].loc[1],list[ind].loc[2]],"  dir: ",showdir(list[ind].dir),"  loc: ",list[ind].loc,"  ",transpose(list[ind].lstack),"•")
            println(ind,"  instr: ",arena.a[list[ind].loc[1],list[ind].loc[2]],"  dir: ",showdir(list[ind].dir),"  loc: ",list[ind].loc,"  ",transpose(convert(Array{BigInt},list[ind].lstack)),"•")
        end
        print("\n[")
        @inbounds for n=1:length(gstack)
            print(Int128(gstack[n]))
            n<length(gstack) ? print(" "):nothing
        end
        println("]•")
        print("\n")
        println("———————")
    elseif deb.d >= 2
        println("\nticks: ",ticks.t)
        gdebug(arena,gstack,list,deb);print("\n")
        println("———————")
    end
end

function gdebug(arena::Honeycomb,gstack::Array{UInt64,1},list::Array{Pointer,1},deb::Debugstate)
    rows=maximum(length(arena.a[:,1]))
    cols=maximum(length(arena.a[1,:]))
    comb=deepcopy(arena.a)
    @inbounds for ind=1:length(list)
        comb[list[ind].loc[1],list[ind].loc[2]]=Char(ind+944)#translates IP numbers to greek letters
    end

    @inbounds for ind=1:length(list)
        #println(Char(ind+944),"  ",ind,"  instr: ",arena.a[list[ind].loc[1],list[ind].loc[2]]," wait: ",showwait(list[ind].wait)," dir: ",showdir(list[ind].dir),"  loc: ",list[ind].loc,"  ",transpose(list[ind].lstack),"•")
        println(Char(ind+944),"  ",ind,"  instr: ",arena.a[list[ind].loc[1],list[ind].loc[2]]," wait: ",showwait(list[ind].wait)," dir: ",showdir(list[ind].dir),"  loc: ",list[ind].loc,"  ",transpose(convert(Array{BigInt},list[ind].lstack)),"•")
    end

    println("\ngstack: ",transpose(convert(Array{BigInt},gstack)),"•\n\n")

    @inbounds for r=1:rows
        @inbounds for c=1:cols
            if Int(comb[r,c])>944 && Int(comb[r,c])<976 #greek letters unicode range
                if deb.d==3
                    c<cols ? print_with_color(:red,"$(comb[r,c])") : print_with_color(:red,"$(comb[r,c])\n")
                elseif deb.d==2
                    c<cols ? print(comb[r,c]) : println(comb[r,c])
                end
            else c<cols ? print(comb[r,c]) : println(comb[r,c])
            end
        end
    end
end

function showwait(wait::Int)
    wait==0 ? (return "∅") :
    wait==1 ? (return "∫") :
    wait==2 ? (return "∬") : nothing
end


function showdir(dir::Int)
    dir==0 ? (return "→") :
    dir==1 ? (return "↗") :
    dir==2 ? (return "↖") :
    dir==3 ? (return "←") :
    dir==4 ? (return "↙") :
    dir==5 ? (return "↘") : nothing
end