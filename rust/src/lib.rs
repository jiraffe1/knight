#![deny(unsafe_code)]

#[cfg(all(feature="pretty-errors", any(feature="reckless", feature="fatal-errors")))]
compile_error!("'pretty-errors' cannot be enabled with either 'reckless' or 'fatal-errors'!");


mod value;
mod error;
mod function;
mod rcstr;
mod stream;
pub mod env;


pub type Number = i64;
pub use rcstr::RcStr;
pub use value::Value;
pub use function::Function;
pub use error::{ParseError, RuntimeError};

pub fn run_str<S: AsRef<str>>(input: S) -> Result<Value, RuntimeError> {
	Value::parse_str(input)?.run()
}

pub fn run<I: Iterator<Item=char>>(input: I) -> Result<Value, RuntimeError> {
	Value::parse(input)?.run()
}