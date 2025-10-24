#include<stdio.h>
#include<math.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
FILE *code, *handler, *IM;
int i, handlerBegin = 1121;
char line[50];

int main()
{
	code = fopen("code.txt", "r");
	handler = fopen("handler.txt", "r");
	IM = fopen("IM.coe", "w");
	
	
	fprintf(IM, "memory_initialization_radix=16;\n");
	fprintf(IM, "memory_initialization_vector=\n");
	
	i = 1;
	while (fgets(line, 50, code) != NULL) {
		line[strlen(line)-1] = 0;
		fprintf(IM, line);
		fprintf(IM, ",\n");
		++i;
	}
	while (i != handlerBegin) {
		fputs("00000000,\n",IM);
		++i;
	}
	if (fgets(line, 50, handler) != NULL) {
		line[strlen(line)-1] = 0;
		fprintf(IM, line);
	}
	while (fgets(line, 50, handler) != NULL) {
		line[strlen(line)-1] = 0;
		fprintf(IM, ",\n");
		fprintf(IM, line);
	}
	fprintf(IM, ";");
	fclose(code), fclose(handler), fclose(IM);
	return 0;
}

