#include <stdio.h>
#include "ast.h"

int main() {
	const char *string = "O I '' 2 3";
	// const char *string = "; = a 3 : O + 'a*4=' * a 4";
	kn_ast_t *ast = kn_ast_parse(&string);
	kn_ast_dump(ast);
	kn_value_t tmp = kn_ast_run(ast);

	kn_ast_free(ast);
	// kn_ast_dump(ast);
	// kn_ast_free(ast);
	// printf("[%d]\n", ast->kind);
}
