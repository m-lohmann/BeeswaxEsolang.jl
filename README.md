# BeeswaxEsolang

beeswax esoteric programming language

[![Build Status](https://travis-ci.org/m-lohmann/BeeswaxEsolang.jl.svg?branch=master)](https://travis-ci.org/m-lohmann/BeeswaxEsolang.jl)

For instructions about how to use the program, please scroll down to the bottom.

## Introduction

*beeswax* is a stack oriented esoteric programming language inspired by [Cardinal](http://esolangs.org/wiki/Cardinal). *beeswax* programs can manipulate their own source code, and can read and write files.

### Honeycomb layout and program storage layout

The programming language draws inspiration from bees and honeycombs, so the instruction pointers (`bees`) travel through the program (`honeycomb`) along a hex-grid. Every honeycomb location has 6 neighbors.

#### Honeycomb layout

```
a — b — c — d
 \ / \ / \ / \
  e — f — g — h
   \ / \ / \ / \
    i — j — k — l
```
Beeswax programs are stored in a rectangular format.
The layout of the grid above would look like this:

#### Program storage layout

```
abcd
 efgh
  ijkl
```

For the following explanations directions are coded like below:

(`β` marks the IP/bee)

```
  2 — 1
 / \ / \
3 — β — 0
 \ / \ /
  4 — 5
```

The according neighborhood layout in a beeswax program looks like this:

```
21
3β0
 45
```

## Stack layout and types of stacks

###Local and global stacks

Every bee (instruction pointer, IP) carries 3 `UInt64` values with it, realized by a local stack. Every local stack is initialized to `[0,0,0]` at the program start.

To store bigger amounts of values there is also a global stack available where bees can drop and pick up values from.
`In the final version of the program this stack may be implemented as an independent 2-dimensional honeycomb.`

The global stack is *not limited in size* and only allows basic stack operations, but no other data manipulation.

*All arithmetic, bit manipulation and other operations have to be executed by bees on their local “personal” stacks.*

So, before any data on the global stack can be used for calculations etc. a bee has to pick up values from the global stack. After executing the instructions the resulting values can be put back on the global stack.

## Source code manipulations, self modification

Bees can drop values anywhere in the source code, and can pick up values from anywhere (analogous to flying to a location and manipulating certain cells in the honeycomb). So, self-modifying source code can be realized.

# Source code layout

The origin of the coordinate system [row,column] = [1,1] is in the upper left corner. beeswax uses 1-based indexing.
Bees that step outside the given honeycomb area are deleted, unless they are dropping values to cells that lie outside the current area of the honeycomb, which would let the honeycomb grow to the proper dimensions.

##Examples of self modification

### Positive growth of honeycomb

```
_PP((F(((D
```
When the bee is at `D`, its local stack is `[4,4,64]`, so the value 64 is dropped at (row,column)=(4,4). So, the source code gets extended to a rectangle encompassing all code:

```
_PP((F(((D


   @
```

### “Negative” growth of honeycomb, coordinate system reset

As the coordinate indices of the honeycomb are 1-based, growth in negative direction (‘up’ and ‘left’ in the source code) is only possible if the 2nd and/or 3rd local stack values are set to zero. Growth in negative direction can only be realized by steps of 1.
The coordinate origin of the resulting source code is set to (row,column) = (1,1) again.

```
*PP((((((D
```
results in
```
@
 PP((((((D
```
The new coordinate origin (1,1) of the honeycomb is set to the new upper left corner, where the `@` was put.

## Available instructions in `beeswax`:

#### Initial pointer creation
These instructions only get active at the beginning of the program
```

 *      Create bees in all directions 0,1,2,3,4,5

 \ / _  Create bees along main diagonals 2/5 , 1/4 , 0/3 
```

#### Program termination
```
 ;      terminate program
```

#### Movement and redirection related instructions:

```
>,d,b,<,p,q     Redirect bee to direction according to the diagram below:

                  b   d
                   \ /
                < — β — >
                   / \
                  p   q

a               Turn direction 1 step clockwise.

x               Turn direction 1 step counterclockwise.

s,t,u           Mirror direction of bee along the main diagonals \, /, -
                Bees moving along the mirror axis are not affected.

   \     in|mirr.       /   in|mirr.       u       in|mirr.
s   \    0 | 4      t  /    0 | 2       _______    0 | 0
     \   1 | 3        /     1 | 1                  1 | 5
         2 | 2              2 | 0                  2 | 4
         3 | 1              3 | 5                  3 | 3
         4 | 0              4 | 4                  4 | 2
         5 | 5              5 | 3                  5 | 1
 
j,k,l           Mirror direction of bee along the half-axes |, /, \

   |     in|mirr.        /  in|mirr.      \        in|mirr.
j  |     0 | 3      k  /    0 | 1        l  \      0 | 5
   |     1 | 2       /      1 | 0             \    1 | 4
         2 | 1              2 | 5                  2 | 3
         3 | 0              3 | 4                  3 | 2
         4 | 5              4 | 3                  4 | 1
         5 | 4              5 | 2                  5 | 0
  
O               Mirror direction of bee from all directions to the opposite direction.

         in|mirr.
         0 | 3   
         1 | 4   
         2 | 5   
         3 | 0   
         4 | 1   
         5 | 2   

m,n,o           Catch bees coming from the \, /, _ directions.
                Bees coming from other directions are not affected.

J               Jump to [row,column] = [top, 2nd] local stack value,
                keep direction of movement.
```

#### Cloning and deleting bees

```
#               Catch bees coming from any direction.

X               Spread copies of incoming bee (including its local stack)
                in all directions except the direction the bee came from.

E               Spread copies of incoming bee (including its local stack)
                in 0-3 direction — except the direction the bee came from.

H               Spread copies of incoming bee (incl. local stack) in 1-4
                direction / except the direction the bee came from.
W               Spread copies of incoming bee (incl. local stack) in 2-5
                direction \ except the direction the bee came from.
```

#### Program flow control/conditional operations

```
'               top = 0 ? skip next instruction : don’t skip next instruction

"               top > 0 ? skip next instruction : don’t skip next instruction

K               top = 2nd ? skip next instruction : don’t skip next instruction

L               top > 2nd ? skip next instruction : don’t skip next instruction

v               Pause movement for 1 tick.

^               Pause movement for 2 ticks.
```

#### Pick up/drop values in the honeycomb (code manipulation)

  [r,c] describes the [row,column] of a honeycomb cell.

```
Absolute addressing:

D               Drop local stack top value to honeycomb[r,c]=[2nd,3rd]
                Extend honeycomb if needed to suit the coordinates

G               Get value from honeycomb[r,c]=[2nd,3rd] and put it as top value on local stack.
                If r,c outside honeycomb, then local stack top value=0

Relative addressing:

Y               Drop local stack top value to cell at relative [r,c]=[2nd,3rd].
                If relative [r,c] are lower than absolute [1,1], nothing is dropped.

Z               Get value from cell at relative [a,b]=[2nd,3rd] and put it as top value on local stack.
                If relative [r,c] are lower than absolute [1,1], then local stick top value=0.
```
As everyone knows, bees don’t have a concept of negative numbers, but they discovered that they can use the most significant bit of an address to get around that. Thus, coordinates relative to a bee’s position are realized by the [two’s complements](https://en.wikipedia.org/wiki/Two's_complement)
of the coordinates. This way, half of the 64-bit address space is available for local addressing without wraparound in each direction.

The maximum positve 64-bit two’s complement address is `9223372036854775807` or `0x7fffffffffffffff` in 64 bit hex.
All values from 0 up to this value translate identically to the same 64 bit value.
All values `n` in the opposite (negative) direction translate to `2^64-n`
For example
`n=-1` is addressed by `18446744073709551615`,
`n=-9223372036854775808` is addressed by `9223372036854775808`.

Always keep the UInt64 wrap-around in mind!


#### Local and global stack manipulations (global stack may be subject to change):

  `•` marks the top of the stack.

```
local stack (lstack) instructions:

~               Flip top and 2nd lstack values.     [3,2,1]• becomes [3,1,2]•

@               Flip top and bottom lstack values.  [3,2,1]• becomes [1,2,3]•

F               Set all lstack values to top value. [3,2,1]• becomes [1,1,1]•

z               Set all lstack values to zero.      [3,2,1]• becomes [0,0,0]•

global stack (gstack) instructions:

y               Rotate global stack down by [---,steps,depth]•
                If depth > stack height or depth = 0, set depth to global stack length.
                If steps > depth, set steps to (steps % depth).
                local [-,2,4]•         global [5,4,3,2,1]• becomes [5,2,1,4,3]•
                local [-,5,4]•         global [5,4,3,2,1]• becomes [5,3,2,1,4]•
                local [-,2,7]•         global [5,4,3,2,1]• becomes [3,2,1,5,4]•

h               Rotate global stack up by [---,steps,depth]•
                If depth > stack height or depth = 0, set depth to global stack length.
                If steps > depth, set steps to (steps % depth).
                local [-,2,4]•         global [5,4,3,2,1]• becomes [5,2,1,4,3]•
                local [-,5,4]•         global [5,4,3,2,1]• becomes [5,1,4,3,2]•
                local [-,2,7]•         global [5,4,3,2,1]• becomes [2,1,5,4,3]•

=               Duplicate top value of gstack. [4,3,2,1]• becomes [4,3,2,1,1]•

?               Pop top gstack value.          [4,3,2,1]• becomes [4,3,2]•

A               Push gstack length on top of gstack.   [4,3,2,1]• becomes [4,3,2,1,4]•

local/global stack interaction:

e               Flush all lstack values on the gstack.
                Local [a,b,c]• becomes gstack [...,c,b,a]•

f               Fetch top value from lstack and push it on top of gstack.

g               Fetch top value from gstack and put it as top value of lstack.
```

Possible 2d extensions

  B  push (2d array storage version, not yet implemented)
  Q  pop  (2d array storage version, not yet implemented)
  R  rot  (2d array storage version, not yet implemented)
  S  roll (2d array storage version, not yet implemented)
  U  pack (2d array storage version, not yet implemented)


#### Arithmetic operations

```
+               top=top+2nd     [3,2,1]• becomes [3,2,3]•

-               top=top-2nd     [3,2,1]• becomes [3,2,18446744073709551615]•
                                         (due to wrap-around)

.               top=top*2nd     [3,2,1]• becomes [3,2,2]•

:               top=top/2nd     [3,2,1]• becomes [3,2,0]• (integer division)

%               top=top%2nd     [3,2,5]•becomes [3,2,1]• (mod operator)

0 (1,2,...,8,9) top=digit       push integer on top of lstack
                                e.g: '7':  [3,2,1]• becomes [3,2,7]•

P               top=top+1       [3,2,1]• becomes [3,2,2]•

M               top=top-1       [3,2,1]• becomes [3,2,18446744073709551615]•
                                         (due to wrap-around)
```

### Bitwise operations

```
&               top=top AND 2nd [3,2,1]• becomes [3,2,0]•

|               top=top OR 2nd  [3,2,1]• becomes [3,2,3]•

$               top=top XOR 2nd [3,2,1]• becomes [3,2,3]•

!               top=NOT top     [3,2,1]• becomes [3,2,18446744073709551614]•
                                         (due to wrap-around)

(               top=top<<1      [3,2,1]• becomes [3,2,2]•
                (arithmetic shift left)

)               top=top>>>1     [3,2,1]• becomes [3,2,0]•
                (logical shift right)

[               top=top<<1+top>>>63  (roll bits left)
                [3,2,8646629796688953342]• becomes [3,2,17293259593377906684]•

]               top=top>>>1+top<<63 (roll bits right)
                [3,2,8646629796688953342]• becomes [3,2,4323314898344476671]•
```

# Local/global I/O operations (not fully implemented):

```
local stack related I/O:

,               top=Int(STDIN)   Fetch character from the console and push its value on top of lstack.

T               top=(STDIN)      Fetch integer from console and push its value ont top of lstack

{               STDOUT=top       Return lstack top value to console.

}               STDOUT=Char(top) Return Char(lstack top value) to console.

global stack related I/O:

c               top=Int(STDIN)   Fetch character from the console and push its value on gstack.

i               top=(STDIN)      Fetch integer from console and push its value on gstack.

I               STDOUT=top       Return gstack top value to console.

C               STDOUT=Char(top) Return Char(gstack top value) to console.

`               Toggle output to console. Return all following encountered symbols directly to console.
                The next ` switches back to normal mode again.

N               STDOUT=newline   Output newline character to console.

r               Read file from disk.
                Local stack setup: lstack[-,-,namebytes]•
                  namebytes: number of bytes to take from gstack to determine the file name

                The file bytes are reinterpreted as UInt64 words (big-endian).
                If the bye count of the file does not add up to full 64-bit words, the end of the file
                is padded to the next full 64-bit word length, using 8-length%8 zero bytes.
                The UInt8 stream is reinterpreted as UInt64 words and pushed on top of gstack, 64-bit word by 64-bit word.

w               Write file to disk.
                Local stack setup: lstack[-,filebytes,namebytes]•
                  namebytes: number of bytes taken from gstack to determine the file name
                  filebytes: number of bytes (after the name bytes) taking from gstack to determine the file content

                The 64 bit words are reinterpreted as groups of 8 bytes in big-endian order!

                UInt64[0x11000000000000ff] is reinterpreted as

                UInt8[0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x11]•

```

## Use of beeswax.jl

Start Julia and enter `include("beeswax.jl")` in the console.

*Normal program execution*

Run program with `beeswax("program_name")`. Without further parameters the program runs until a limit of *1e6 ticks* to prevent lockup if there are errors in the code.

*Available parameters*

`beeswax("program_name",limit)` lets you determine a maximum limit of ticks the program is supposed to run.

`beeswax("program_name",debug,limit)` lets you determine a maximum limit of ticks and a debug mode.

#### Available debug modes

```
    0   No debug messages.
    1   Output of all local stack contents at every tick to STDOUT.
    2   Output of program code with locations of all bees, plust local stack contents, for every tick.
```

## Example beeswax programs

#### Cat program
```
 _,}
```

#### Hello world
```
_`Hello, World!
```

#### Infinite output of '1's
```
*P~P{J
```

#### Squaring an entered number, return the result to the console:
```
_`Enter number:`TN{` squared=`~+.{
```

#### Output numbers from 1 to 100
```
_PPP(((P((~>P{Kp
            b N<
```
#### Return n-th Fibonacci number
  clear version
```
                        #>'#{;
_`enter n: `TN`Fib(`{`)=`X  ~P~K#{;    >@{;
                         #>~P~L#MM@>+@"dM@~p
                                   d       <
```
  compact version:
```
          ;{#'<>~P~L#MM@>+@'p@{;
_`n`TN`F(`{`)=`X~P~K#{; d~@M<
  
```
#### Write file named “A” to disk, with the hex content “41414141414141“ (ASCII: AAAAAAA)
```
_8F.PF((((((((+F((((((((((((((((+F((((((((((((((((((((((((((((((((+fz5F1w
```
