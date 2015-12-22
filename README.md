# BeeswaxEsolang

beeswax esoteric programming language

[![Build Status](https://travis-ci.org/m-lohmann/BeeswaxEsolang.jl.svg?branch=master)](https://travis-ci.org/m-lohmann/BeeswaxEsolang.jl)

For instructions about how to use the program, please [scroll down](https://github.com/m-lohmann/BeeswaxEsolang.jl#use-of-beeswaxjl).

## Introduction

*beeswax* is a stack-based/cell-based 2-dimensional self-modifiable esoteric programming language drawing inspiration from bees moving around on a honeycomb, and partly drawing inspiration from languages like [Cardinal](http://esolangs.org/wiki/Cardinal). The instruction pointers (bees) move around on a 2D hexagonal grid (the honeycomb). beeswax programs can manipulate their own source code, change the program size, and can read and write files.

### Honeycomb structure and source code layout

The programming language draws inspiration from bees and honeycombs, so the instruction pointers (`bees`) travel through the program (`honeycomb`) along a hexagonal grid. Every honeycomb location has 6 neighbors.

#### Honeycomb structure

```
a — b — c — d
 \ / \ / \ / \
  e — f — g — h
   \ / \ / \ / \
    i — j — k — l
```
Beeswax programs are stored in a rectangular format. A program using the layout of the grid above would look like this:

#### Program storage layout

```
abcd
 efgh
  ijkl
```

#### Movement directions

Bees (IPs) can move in one of 6 directions that are determined like shown below:

(`β` marks the IP/bee)

```
  2 — 1
 / \ / \
3 — β — 0
 \ / \ /
  4 — 5
```

The analogous neighborhood layout in a beeswax program looks like this:

```
21
3β0
 45
```

## Stack layout and types of stacks

### Local stacks

Every bee has a “personal” fixed size stack, carrying three ```UInt64``` values, called local stack or ```lstack```. Every local stack is initialized to ```[0,0,0]•``` at the start of the program. ```•``` marks the top of the stack.

### Global stacks

To store bigger amounts of data there is also a global stack (```gstack```) available where bees can drop values onto and pick up values from.
`In the final version of the program this stack may be implemented as an independent 2-dimensional honeycomb.`

The global stack is *not limited in size* and only allows basic stack operations, but no other forms of data manipulation.
All arithmetic, bit manipulation and other operations have to be executed by bees on their local “personal” stacks.
So, before any data on the global stack can be used for calculations etc. a bee has to pick up values from the global stack. After executing the instructions the resulting values can be put back onto the global stack.

## Source code manipulations, self modification, coodrinate system

Bees can also drop values anywhere in the source code, and can pick up values from anywhere (analogous to flying to a location and manipulating certain cells in the honeycomb). So, self-modifying source code can be realized.

## Source code coordinate system

The origin of the coordinate system [row,column] = [1,1] is in the upper left corner. beeswax uses 1-based indexing.
Bees that step outside the given honeycomb area are deleted, unless they are dropping values to cells that lie outside the current area of the honeycomb, which would let the honeycomb grow to the proper dimensions.

### Examples of self modification

#### Positive growth of the honeycomb

```
_PP(F((((D
```
When the bee is at `D`, its local stack is `[4,4,64]•`, so the value 64 is dropped at (row,column)=(4,4). So, the source code gets extended to a rectangle encompassing all code:

```
_PP(F((((D


   @
```

### “Negative” growth of honeycomb, coordinate system reset

Because the coordinate indices of the honeycomb are 1-based, growth in negative direction (‘up’ and ‘left’ in the source code) is only possible if the 2nd and/or 3rd local stack values are set to zero. Growth in negative direction can only be realized by steps of 1.
The coordinate origin of the resulting source code is reset to (row,column) = (1,1) again:

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

### Initial pointer creation

These instructions only get active at the beginning of the program

```
*      Create bees in all directions 0,1,2,3,4,5

\      Create bees moving along the main direction 2/5.
/      Create bees moving along the main direction 1/4.
_      Create bees moving along the main direction 0/3.
```

### Program termination
```
;      Terminate program.
```

### Movement and redirection related instructions:

```
>,d,b,<,p,q     Redirect bee to direction according to the diagram below:

        b   d
         \ /
      < — β — >
         / \
        p   q

a               Turn direction 1 step clockwise.
x               Turn direction 1 step counterclockwise.
s               Mirror direction along the main diagonal 2/5. Bees moving along the mirror axis are not affected.
t               Mirror direction along the main diagonal 1/4. Bees moving along the mirror axis are not affected.
u               Mirror direction along the main diagonal 0/3. Bees moving along the mirror axis are not affected.

    inc.│mirr.     inc.│mirr.     inc.│mirr.
    ────┼─────     ────┼─────     ────┼─────
  s   0 │ 4      t   0 │ 2      u   0 │ 0
      1 │ 3          1 │ 1          1 │ 5
      2 │ 2          2 │ 0          2 │ 4
      3 │ 1          3 │ 5          3 │ 3
      4 │ 0          4 │ 4          4 │ 2
      5 │ 5          5 │ 3          5 │ 1
 
j               Mirror direction along the half axis │ between 1/4 and 2/5.
k               Mirror direction along the half axis / between 0/3 and 1/4.
l               Mirror direction along the half axis \ between 0/3 and 2/5.

    inc.│mirr.     inc.│mirr.     inc.│mirr.
    ────┼─────     ────┼─────     ────┼─────
  j   0 │ 3      k   0 │ 1      l   0 │ 5
      1 │ 2          1 │ 0          1 │ 4
      2 │ 1          2 │ 5          2 │ 3
      3 │ 0          3 │ 4          3 │ 2
      4 │ 5          4 │ 3          4 │ 1
      5 │ 4          5 │ 2          5 │ 0
  
O               Mirror direction of bee coming from any direction to the opposite direction.

    inc.│mirr. 
    ────┼───── 
  O   0 │ 3    
      1 │ 2    
      2 │ 1    
      3 │ 0    
      4 │ 5    
      5 │ 4

J               Jump to [row,column] = [top, 2nd] local stack value,
                keep direction of movement.
```

### Cloning and deleting bees

```
m               Catch and delete bees coming from the 2/5 direction. Bees coming from other directions are not affected.
n               Catch and delete bees coming from the 1/4 direction. Bees coming from other directions are not affected.
o               Catch and delete bees coming from the 0/3 direction. Bees coming from other directions are not affected.
#               Catch bees coming from any direction.
X               Spread identical copies of incoming bee in all directions, except in the direction the bee came from.
E               Spread identical copies of incoming bee in 0/3 direction, except the direction the bee came from.
H               Spread identical copies of incoming bee in 1/4 direction, except the direction the bee came from.
W               Spread identical copies of incoming bee in 2/5 direction, except the direction the bee came from.
```

### Program flow control/conditional operations

```
'               if lstack top value = 0 then skip next instruction, otherwise don’t skip next instruction.
"               if lstack top value > 0 then skip next instruction, otherwise don’t skip next instruction.
K               if lstack top value = 2nd value then skip next instruction, otherwise don’t skip next instruction.
L               if lstack top value > 2nd value then skip next instruction, otherwise don’t skip next instruction.
v               Pause movement for 1 tick.
^               Pause movement for 2 ticks.
```

### Pick up/drop values in the honeycomb (code manipulation)

  [r,c] describes the [row,column] of a honeycomb cell.

#### Absolute addressing

```
D               Drop local stack top value to honeycomb[r,c]=[2nd,3rd]
                Extend honeycomb if needed to suit the requirement.
G               Get value from honeycomb[r,c]=[2nd,3rd] and put it as top value on local stack.
                If r,c outside honeycomb, then local stack top value=0
```

#### Relative addressing

```
Y               Drop local stack top value to cell at relative [r,c]=[2nd,3rd].
                If relative [r,c] are lower than absolute [1,1], nothing is dropped.

Z               Get value from cell at relative [a,b]=[2nd,3rd] and put it as top value on local stack.
                If relative [r,c] are lower than absolute [1,1], then local stack top value=0.
```
As everyone knows, bees don’t have a concept of negative numbers, but they discovered that they can use the most significant bit of an address to get around that. Thus, coordinates relative to a bee’s position are realized by the [two’s complements](https://en.wikipedia.org/wiki/Two's_complement)
of the coordinates. This way, half of the 64-bit address space is available for local addressing without wraparound in each direction.

The maximum positve 64-bit two’s complement address is `9223372036854775807` or `0x7fffffffffffffff` in 64 bit hex.
All values from 0 up to this value translate identically to the same 64 bit value.
All values `n` in the opposite (negative) direction translate to `2^64-n`
For example
`n=-1` is addressed by `18446744073709551615`,
`n=-9223372036854775808` is addressed by `9223372036854775808`.

Always keep the `UInt64` wrap-around in mind!


### Local and global stack manipulations (global stack may be subject to change):
`•` marks the top of the stack.

#### Local stack (lstack) instructions

```
~               Flip top and 2nd lstack values.     [3,2,1]• becomes [3,1,2]•
@               Flip top and bottom lstack values.  [3,2,1]• becomes [1,2,3]•
F               Set all lstack values to top value. [3,2,1]• becomes [1,1,1]•
z               Set all lstack values to zero.      [3,2,1]• becomes [0,0,0]•
```

#### Global stack (gstack) instructions

```
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
```

#### Local/global stack interaction

```
e               Flush all lstack values on the gstack. lstack [a,b,c]• ends up on gstack as [...,c,b,a]•
f               Fetch top value from lstack and push it on top of gstack.
g               Fetch top value from gstack and set it as top value of lstack.
```

### Arithmetic operations

```
+               top=top+2nd     [3,2,1]• becomes [3,2,3]•
-               top=top-2nd     [3,2,1]• becomes [3,2,18446744073709551615]• (due to wrap-around)
.               top=top*2nd     [3,2,1]• becomes [3,2,2]•
:               top=top/2nd     [3,2,1]• becomes [3,2,0]• (integer division)
%               top=top%2nd     [3,2,5]•becomes [3,2,1]• (mod operator)
0 (1,2,...,8,9) top=digit       push integer on top of lstack. For example '7':  [3,2,1]• becomes [3,2,7]•
P               top=top+1       [3,2,1]• becomes [3,2,2]•
M               top=top-1       [3,2,1]• becomes [3,2,18446744073709551615]• (due to wrap-around)
```

### Bitwise operations

```
&               top=top AND 2nd [3,2,1]• becomes [3,2,0]•
|               top=top OR 2nd  [3,2,1]• becomes [3,2,3]•
$               top=top XOR 2nd [3,2,1]• becomes [3,2,3]•
!               top=NOT top     [3,2,1]• becomes [3,2,18446744073709551614]• (due to wrap-around)
(               top=top<<1      [3,2,1]• becomes [3,2,2]• (arithmetic shift left)
)               top=top>>>1     [3,2,1]• becomes [3,2,0]• (logical shift right)
[               top=top<<1+top>>>63 (roll bits left) [3,2,8646629796688953342]• becomes [3,2,17293259593377906684]•
]               top=top>>>1+top<<63 (roll bits right) [3,2,8646629796688953342]• becomes [3,2,4323314898344476671]•
```

### Local/global I/O operations

#### Local stack related I/O

```
,               top=Int(STDIN)   Read character from STDIN and push its value on top of lstack.
T               top=(STDIN)      Read integer from STDIN and push its value on gstack.
{               STDOUT=top       Return lstack top value as integer to STDOUT.
}               STDOUT=Char(top) Return lstack top value as character(UTF8) to STDOUT.
```

#### Global stack related I/O

```
c               top=Int(STDIN)   Read character from STDIN and push its value on gstack.
i               top=(STDIN)      Read integer from STDIN and push its value on gstack.
I               STDOUT=top       Return gstack top value as integer to STDOUT.
C               STDOUT=Char(top) Return lstack top value as character(UTF8) to STDOUT.
`               Toggle STDOUT    Return all following encountered symbols as characters(UTF8) directly to STDOUT. The next ` switches back to normal mode again.

N               STDOUT=newline   Output newline character to STDOUT.
```

#### File related I/O

```
r               Read file from disk.
                Local stack setup: lstack[-,-,namebytes]•
                  namebytes: number of bytes to take from gstack to determine the file name.
                The file bytes are reinterpreted as UInt64 words (big-endian).
                If the bye count of the file does not add up to full 64-bit words, the end of the file is padded to the next full 64-bit word length, using 8-length%8 zero bytes.
                The UInt8 stream is reinterpreted as UInt64 words and pushed on top of gstack, 64-bit word by 64-bit word.

w               Write file to disk.
                Local stack setup: lstack[-,filebytes,namebytes]•
                  namebytes: number of bytes taken from gstack to determine the file name.
                  filebytes: number of bytes (after the name bytes) taking from gstack to determine the file content.                          The 64 bit words are reinterpreted as groups of 8 bytes in big-endian order.
                UInt64[0x11000000000000ff] is reinterpreted as UInt8[0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x11]•
```

## Use of beeswax.jl

Start Julia and enter `using BeeswaxEsolang` in the console. The first run should take a few seconds for precompiling.

*Normal program execution*

Run any program with `beeswax("program_name")`. Without further parameters the program runs until a limit of *1e6 ticks* to prevent lockup if there are errors in the code.

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
#### Write to disk
Writes a file named “A” to diske, with the hex content `0x41414141414141` (ASCII: `AAAAAAA`)

```
_8F.PF((((((((+F((((((((((((((((+F((((((((((((((((((((((((((((((((+fz5F1w
```
