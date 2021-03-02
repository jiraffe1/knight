from __future__ import annotations
from knight import Value, Stream, RunError
from typing import Union, Dict
import re

class Identifier(Value):
	"""
	Represents an identifier within Knight.

	Because all identifiers in Knight are global---and don't go out of
	scope---we have a single dict that keeps track of _all_ identifiers.
	"""

	REGEX: re.Patterm = re.compile(r'[a-z_][a-z0-9_]*')
	_ENV: Dict[str, Value] = {}
	name: str

	@classmethod
	def parse(cls, stream: Stream) -> Union[None, Identifier]:
		"""
		Parses an Identifier out from the stream.

		This returns `None` if the stream doesn't start with a lowercase
		letter, or an underscore.
		"""
		if match := stream.matches(Identifier.REGEX):
			return cls(match)
		else:
			return None

	def __init__(self, name: str):
		""" Creates a new Identifier associated with the given `name`. """
		self.name = name

	def __repr__(self):
		""" Gets a debugging mode representation of this identifier. """
		return f"Identifier({self.name})"

	def run(self) -> Value:
		"""
		Fetches the value associated with this identifier from the list
		of known identifiers.

		If the identifier has not been assigned yet (cf `assign`), then a
		`RunError` will be raised.
		"""
		if self.name not in Identifier._ENV:
			raise RunError(f"unknown identifier '{self.name}'")
		else:
			return Identifier._ENV[self.name]


	def assign(self, value: Value):
		"""
		Associated the Value `value` with this identifier.

		Any previously associated value with this identifier is discarded.
		"""
		Identifier._ENV[self.name] = value

Value.TYPES.append(Identifier)
