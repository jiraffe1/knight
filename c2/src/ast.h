#ifndef KN_AST_H
#define KN_AST_H

#include "value.h"

struct kn_function_t;

struct kn_ast_t {
	struct kn_function_t *func;
	unsigned refcount;
	kn_value_t *args;
	// TODO: kn_value_t args[];
};

#endif
