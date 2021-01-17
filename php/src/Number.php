<?php
namespace Knight;

require_once 'Value.php';
use \Knight\Value;

class Number extends Value
{
	public static function parse(string &$stream): ?Value
	{
		if (!preg_match('/\A\d+/', $stream, $match)) {
			return null;
		}

		$stream = substr($stream, strlen($match[0]));

		return new self((int) $match[0]);
	}

	private $data;

	function __construct(int $val)
	{
		$this->data = $val;
	}

	function __toString(): string
	{
		return (string) $this->data;
	}

	public function toInt(): int
	{
		return $this->data;
	}

	public function toBool(): bool
	{
		return (bool) $this->data;
	}

	protected function dataEql(self $rhs): bool
	{
		return $this->data === $rhs->data;
	}

	public function add(Value $rhs): Value
	{
		return new self($this->data + $rhs->toInt());
	}

	public function sub(Value $rhs): Value
	{
		return new self($this->data - $rhs->toInt());
	}

	public function mul(Value $rhs): Value
	{
		return new self($this->data * $rhs->toInt());
	}

	public function div(Value $rhs): Value
	{
		$rhs = $rhs->toInt();

		if ($rhs === 0) {
			throw new \Exception("Cannot divide by zero");
		}

		return new self(intdiv($this->data, $rhs));
	}

	public function mod(Value $rhs): Value
	{
		$rhs = $rhs->toInt();

		if ($rhs === 0) {
			throw new \Exception("Cannot modulo by zero");
		}

		return new self($this->data % $rhs);
	}

	public function pow(Value $rhs): Value
	{
		return new self($this->data ** $rhs->toInt());
	}

	protected function cmp(Value $rhs): int
	{
		return $this->data <=> $rhs->toInt();
	}

	public function eql(Value $rhs): bool
	{
		return get_class($this) === get_class($rhs) && $this->_dataEql($rhs);
	}
}

