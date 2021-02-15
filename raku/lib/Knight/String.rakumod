use Knight::TypedValue;
use Knight::Value;

#| The String class in Knight.
unit class Knight::String does Knight::TypedValue[Str, * cmp *, * eq *];

#| Converts `self` to an integer by stripping leading whitespace, then taking as many sequential digits as possible.
#|
#| An empty string, or a string that doesn't begin with digits, is zero.
method Int(--> Int) is pure {
	$!value ~~ /^ \d* /;
	$<>.Int
}

#| Concatenates `$rhs` to `self`, returning a new String.
method add(Knight::Value $rhs, --> ::?CLASS) {
	::?CLASS.new: $!value ~ $rhs
}

#| Duplicates `self` by `$rhs` times.
method mul(Knight::Value $rhs, --> ::?CLASS) {
	::?CLASS.new: $!value x $rhs
}

