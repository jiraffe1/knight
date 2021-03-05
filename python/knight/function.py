from __future__ import annotations
from knight import Value, Stream, ParseError, RunError, \
                   Identifier, Boolean, Null, String, Number
from typing import Union, Dict, List
from random import randint

import re
import subprocess

class Function(Value):
	_KNOWN: Dict[str, callable] = {}
	REGEX: re.Pattern = re.compile(r'[A-Z]+|.')

	@staticmethod
	def parse(stream: Stream) -> Union[None, Function]:
		name = stream.peek()
		if name not in Function._KNOWN:
			return None

		func = Function._KNOWN[name]
		stream.matches(Function.REGEX)

		args = []
		for arg in range(func.__code__.co_argcount):
			value = Value.parse(stream)

			if value is None:
				raise ParseError(f'Missing argument {arg} for function {name}')

			args.append(value)

		return Function(func, name, args)

	def __init__(self, func: callable, name: str, args: list[Value]):
		self.func = func
		self.name = name
		self.args = args

	def run(self) -> Value:
		return self.func(*self.args)

	def __repr__(self):
		return f'Function({self.name}, {self.args})'

Value.TYPES.append(Function)

def function(name=None):
	return lambda body: Function._KNOWN.__setitem__(
		name or body.__name__[0].upper(), body)

@function()
def prompt():
	return String(input())

@function()
def random():
	return Number(randint(0, 0xff_ff_ff_ff))

@function()
def eval_(text):
	value = Value.parse(Stream(str(text)))

	if value is None:
		raise ParseError('Nothing to parse.')
	else:
		return value.run()

@function()
def block(blk):
	return blk

@function()
def call(blk):
	return blk.run().run()

@function('`')
def system(cmd):
	proc = subprocess.run(str(cmd), shell=True, capture_output=True)

	return String(proc.stdout.decode())

@function()
def quit_(code):
	quit(int(code))

@function('!')
def not_(arg):
	return Boolean(not arg)

@function()
def length(arg):
	return Number(len(str(arg)))

@function()
def dump(arg):
	arg = arg.run()

	print(repr(arg))

	return arg

@function()
def output(arg):
	s = str(arg)

	if s[-1] == '\\':
		print(s[:-2], end='')
	else:
		print(s)

	return Null()

@function('+')
def add(lhs, rhs):
	return lhs.run() + rhs.run()

@function('-')
def sub(lhs, rhs):
	return lhs.run() - rhs.run()

@function('*')
def mul(lhs, rhs):
	return lhs.run() * rhs.run()

@function('/')
def div(lhs, rhs):
	return lhs.run() // rhs.run()

@function('%')
def mod(lhs, rhs):
	return lhs.run() % rhs.run()

@function('^')
def pow(lhs, rhs):
	return lhs.run() ** rhs.run()

@function('<')
def lth(lhs, rhs):
	return Boolean(lhs.run() < rhs.run())

@function('>')
def gth(lhs, rhs):
	return Boolean(lhs.run() > rhs.run())

@function('?')
def eql(lhs, rhs):
	return Boolean(lhs.run() == rhs.run())

@function('&')
def and_(lhs, rhs):
	return lhs.run() and rhs.run()

@function('|')
def or_(lhs, rhs):
	return lhs.run() or rhs.run()

@function(';')
def then(lhs, rhs):
	lhs.run()
	return rhs.run()

@function()
def while_(cond, body):
	while cond:
		body.run()

	return Null()

@function('=')
def assign(name, value):
	if not isinstance(name, Identifier):
		name = Identifier(str(name))

	value = value.run()
	name.assign(value)
	return value 

@function()
def if_(cond, iftrue, iffalse):
	return (iftrue if cond else iffalse).run()

@function()
def get(text, start, length):
	text = str(text)
	start = int(start)
	length = int(length)
	return String(text[start:start+length])

@function()
def substitute(text, start, length, repl):
	text = str(text)
	start = int(start)
	length = int(length)
	repl = str(repl)
	return String(text[:start] + repl + text[start+length:])