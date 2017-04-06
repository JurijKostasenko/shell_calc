#!/bin/bash
# bygreen: keep it simple
#= a simple interactive shell calculator using perl math expressions
#= commands in the calc shell (e.g.):
#= - basic calc
#=      : 1<<10   : left shift 1 by 10 = 2^10
#=      : 5**10   : 5^10
#=      : sqrt(2) : square root of 2 = 1.414214  - use float for base
#=      : sin(0.5): sine of  0.5   - use float for base
#=      : exp(2)  : e^2
#=      : log(2)  : logarithm of 2
#= - special calc
#=      : oct("0b1111") : convert binary to decimal  - in decimal mode
#=                  note: works also in hex mode
#=      : hex(A)  : A is a hex number (same as 0xA), will output to base number
#=      : int(A)  : convert int to decimal  - in decimal mode
#=      : ~10     : bitwise not
#=      : 10 & 11 : bitwise and
#=      : 10 ^ 11 : bitwise xor
#=      : 10 | 11 : bitwise or
#=      : $a = 10 : set a varibale a
#=                : note use single char varibales [a,b,c] to avoid setting the
#=                  calc tool variables
#= - number representation:
#=                         0xa, 0xA    : hexadecimal number
#=                         0b1010      : binary number
#=                         1.10        : float number
#=                         1e-2, 1E-2  : float number with exponent
#= - commands to change the base for output (e.g. for input: 10, 10.01 , 0x10)
#=    b : bin
#=    x : unsigned integer, in hexadecimal
#=    d : a signed integer, in decimal
#=    u : an unsigned integer, in decimal
#=    f : a floating-point number, in fixed decimal notation
#=    e : a floating-point number, in scientific notation
#= - misc command
#=    help : to get this help header
#=    exit : to exit the calc tool
__complete() {
    echo $allowed_commands
}
 
shopt -qs extglob
 
fn_hide_prefix='__'
allowed_commands="$(declare -f | sed -ne '/^'$fn_hide_prefix'.* ()/!s/ ().*//p' | tr '\n' ' ')"
format="%f"
 
# time function
MYFUNC="sub tt { \$val=shift ;\$v60 = \$val%60; printf \"time: %.2f \n\",\$v60+1 + (\$val-\$v60 - 0.60)}"
complete -D -W "this should output these words when you hit TAB"
 
echo "waiting for commands"
while read -ep"+-> "; do
    history -s $REPLY
    case "$REPLY" in
        @(${allowed_commands// /|})?(+([[:space:]])*)) $REPLY ;;
        \?) __complete ;;
                q|exit|quit) exit ;;
                h|help) exec grep -P "^#=" $0 | tr -d "#=";;
                b) format="%32b"   ; echo "bin  :$format" ;;
                x) format="%#8.8x" ; echo "hex  :$format" ;;
                u) format="%u"     ; echo "unit :$format" ;;
                f) format="%f"     ; echo "float:$format" ;;
                e) format="%e"     ; echo "sci.f:$format" ;;
        *) PL_CMD="printf \"$format\n\", eval($REPLY)"; perl -e " $MYFUNC $PL_CMD" ;; # echo "invalid command: $REPLY" ;;
    esac
done
