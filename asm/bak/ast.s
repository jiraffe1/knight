# RDI, RSI, RDX, RCX, R8, R9
.data
	.asciz "arg = %c\n"
.equ STREAM, %r12

.macro peek where:req
	movzbl (STREAM), \where
.endm
.macro advance
	inc STREAM
.endm


.text

strip_stream_strip:
	advance
strip_stream:
	peek %ecx
# check to see if it is whitespace, if so just start over from the top.
# TODO: ignore parens and colon
	cmp $' ', %cl
	je strip_stream_strip
	cmp $'\t', %cl # 
	jl strip_stream_strip
	cmp $0x0d, %cl # \r
	jle strip_stream_strip
	cmp $'(', %cl
	je strip_stream_strip
	cmp $')', %cl
	je strip_stream_strip
	cmp $'[', %cl
	je strip_stream_strip
	cmp $']', %cl
	je strip_stream_strip
	cmp $'{', %cl
	je strip_stream_strip
	cmp $'}', %cl
	je strip_stream_strip
	cmp $':', %cl
	je strip_stream_strip
# check to see if we are at a comment, if so strip it.
strip_stream_comment:
	cmp $'#', %ecx
	jne done_stripping
0:
	advance
	peek %ecx
	cmp $'\n', %ecx
	je strip_stream_strip
	cmp $'\0', %ecx
	jne 0b
	jmp done_stripping


# parse a number
# we assume we have already `peek`ed this code is executed.
# `rax` should already be zeroed out before this is run too.
parse_number:
	xor %edi, %edi
0:
	sub $'0', %ecx
	imul $10, %rdi
	add %rcx, %rdi
	advance
	peek %ecx
	cmp $'0', %ecx
	jl 1f
	cmp $'9', %ecx
	jle 0b
1:
	call kn_value_new_int
	jmp done_parsing

# parse an ident
# we assume we have already `peek`ed this code is executed.
parse_ident:
	mov %r12, %r13
0:
	advance
	peek %ecx
	cmp $'_', %rcx
	je 0b
	cmp $'a', %rcx
	jl 1f
	cmp $'z', %rcx
	jle 0b
1:
	mov %r12, %r14
	sub %r13, %r14
	mov %r14, %rdi
	inc %rdi # b/c of trailing `\0`.
	call _malloc
	mov %rax, %rdi
	mov %r13, %rsi
	mov %r14, %rdx
	call _strncat
	mov %rax, %rdi
	call kn_value_new_ident
	jmp done_parsing


# parse a string
# we assume we have already `peek`ed this code is executed.
parse_string:
	advance
	mov %r12, %r13 # store the quote start.
0:
	peek %eax
	advance
	cmp $0, %eax
	je unterminated_quote
	cmp %eax, %ecx
	jne 0b
	mov %r12, %r14
	sub %r13, %r14
	mov %r14, %rdi
	call _malloc
	mov %rax, %rdi
	mov %r13, %rsi
	dec %r14
	mov %r14, %rdx
	call _strncat
	mov %rax, %rdi
	call kn_value_new_str
	jmp done_parsing

unterminated_quote_msg:
	.asciz "unterminated quote encountered: %s\n"
unterminated_quote:
	dec %r13
	lea unterminated_quote_msg(%rip), %rdi
	mov %r13, %rsi
	call _printf
	jmp die

foo: .asciz "stream='%s'\n"
parse_function:
	mov %rcx, %rdi
	mov %rcx, %r13
	advance
0:
	cmp $'A', %rcx
	jl 1f
	cmp $'Z', %rcx
	jg 1f
	advance
	peek %ecx
	jmp 0b
1:
	call get_function
	cmp $0, %eax
	je unknown_function
	mov %rax, %rdi
	call kn_value_new_func
	jmp done_parsing

unknown_function_msg:
	.asciz "unknown function '%c' encountered.\n"
unknown_function:
	lea unknown_function_msg(%rip), %rdi
	mov %r13, %rsi
	call _printf
	jmp die


.globl parse_ast
parse_ast:
	push %r12
	push %r13
	push %r14
	mov %rdi, %r12

# strip stream of whitespace
	jmp strip_stream
done_stripping:
	xor %eax, %eax
	peek %ecx

# stream was striped:
	cmp $'0', %ecx
	jl not_a_digit
	cmp $'9', %ecx
	jle parse_number
not_a_digit:
	cmp $'_', %rcx
	je parse_ident
	cmp $'a', %rcx
	jl not_an_ident
	cmp $'z', %rcx
	jle parse_ident
not_an_ident:
	cmp $''', %rcx #'
	je parse_string
	cmp $'"', %rcx
	je parse_string
not_a_string:
	jmp parse_function

done_parsing:
	mov %r12, %rdi # this _needs_ to be here for `parse_next_argument`.
	pop %r14
	pop %r13
	pop %r12
	ret
