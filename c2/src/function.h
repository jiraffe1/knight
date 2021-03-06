#ifndef FUNCTION_H
#define FUNCTION_H

#include "value.h"

struct kn_function_t {
	kn_value_t (*ptr)(const kn_value_t*);
	unsigned arity;
	char name;
};


void kn_function_initialize(void);

struct kn_function_t kn_fn_prompt;
struct kn_function_t kn_fn_random;

struct kn_function_t kn_fn_eval;
struct kn_function_t kn_fn_block;
struct kn_function_t kn_fn_call;
struct kn_function_t kn_fn_system;
struct kn_function_t kn_fn_quit;
struct kn_function_t kn_fn_not;
struct kn_function_t kn_fn_length;
struct kn_function_t kn_fn_dump;
struct kn_function_t kn_fn_output;

struct kn_function_t kn_fn_add;
struct kn_function_t kn_fn_sub;
struct kn_function_t kn_fn_mul;
struct kn_function_t kn_fn_div;
struct kn_function_t kn_fn_mod;
struct kn_function_t kn_fn_pow;
struct kn_function_t kn_fn_eql;
struct kn_function_t kn_fn_lth;
struct kn_function_t kn_fn_gth;
struct kn_function_t kn_fn_and;
struct kn_function_t kn_fn_or;
struct kn_function_t kn_fn_then;
struct kn_function_t kn_fn_assign;
struct kn_function_t kn_fn_while;

struct kn_function_t kn_fn_if;
struct kn_function_t kn_fn_get;

struct kn_function_t kn_fn_set;

#endif
