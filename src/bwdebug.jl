function debugger(arena,gstack,list,deb,ticks)
    if deb.d==1
        println("\nticks:$(ticks.t)")
        for ind=1:length(list)
            println("$ind  instr: $(arena.a[list[ind].loc[1],list[ind].loc[2]])  dir: $(showdir(list[ind].dir))  loc: $(list[ind].loc)  $(list[ind].lstack)•")
        end
        print("\n[")
        for n=1:length(gstack)
            print("$(Int128(gstack[n]))")
            n<length(gstack) ? print(" "):nothing
        end
        println("]•")
        print("\n")
    elseif deb.d==2
        println("\nticks:$(ticks.t)")
        gdebug(list,gstack,arena);print("\n")
    end
end

function gdebug(list,gstack,arena)
    rows=maximum(length(arena.a[:,1]))
    cols=maximum(length(arena.a[1,:]))
    comb=deepcopy(arena.a)
    for ind=1:length(list)
        comb[list[ind].loc[1],list[ind].loc[2]]=Char(ind+944)#translates IP numbers to greek letters
    end

    for ind=1:length(list)
            println("$ind  instr: $(arena.a[list[ind].loc[1],list[ind].loc[2]])  dir: $(showdir(list[ind].dir))  loc: $(list[ind].loc)  $(list[ind].lstack)•")
    end

    println("\ngstack: $(gstack)•\n\n")

    for r=1:rows
        for c=1:cols
            if Int(comb[r,c])>944 && Int(comb[r,c])<976 #greek letters UTF8 range
                c<cols ? print_with_color(:yellow,"$(comb[r,c])") : print_with_color(:yellow,"$(comb[r,c])\n")
            else c<cols ? print_with_color(:blue,"$(comb[r,c])") : print_with_color(:blue,"$(comb[r,c])\n")
            end
        end
    end
end

function showdir(dir)
    dir==0 ? (return ">") :
    dir==1 ? (return "d") :
    dir==2 ? (return "b") :
    dir==3 ? (return "<") :
    dir==4 ? (return "p") :
    dir==5 ? (return "q") : nothing
end