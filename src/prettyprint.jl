"""
`prettyprint(name::ASCIIString)`  

        prints simple a hexagonal layout view of the rectangular grid layout of the beeswax
        program "name" for more comfortable viewing.

        Equivalent to 'prettyprint(name,1)'.


"""

function prettyprint(name::AbstractString)
    prettyprint(name,1)
end

"""
`prettyprint(name::ASCIIString,style::Int)`  

        prints either a simple hexagonal layout of the beeswax program "name" or a full
        hexagonal layout with grid overlay to make following the code easier.

    Available styles

 *   1     simple hexagonal layout.
 *   2     advanced hexagonal layout with overlay.


"""

function prettyprint(name::AbstractString,style::Int)
    prog=open(name)
    code=readlines(prog)
    close(prog)
    rows=length(code)
    cols=0
    for i=1:rows
        code[i]=chomp(code[i])
        cols=maximum([cols,strwidth(code[i])])
    end

    if style == 1
        for row=1:rows
            print(" "^(rows-row))
            code[row]=replace(code[row]," ","•")
            code[row]=rpad(code[row],cols,"•")
            for i in code[row]
                print("$i ")
            end 
            println()
        end
    elseif style == 2
        for row=1:rows
            print(" "^(2*(rows-row)))
            code[row]=replace(code[row]," ","•")
            code[row]=rpad(code[row],cols,"•")
            for i=1:endof(code[row])
                try
                    i < endof(code[row]) ? print("$(code[row][i]) — ") : print("$(code[row][i])")
                catch
                end
            end
            println()
            row<rows ? print(" "^(2*(rows-row)-2)) : nothing
            row<rows ? print(" / \\"^(cols-1)*" /\n") : nothing
        end
    end
end
