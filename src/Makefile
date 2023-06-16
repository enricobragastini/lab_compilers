LEX = lex
YACC = yacc
CC = gcc
CFLAGS = -lfl

TARGET = set_language

all: $(TARGET)

$(TARGET): lex.yy.c y.tab.c
	$(CC) $(CFLAGS) -o $(TARGET) lex.yy.c y.tab.c

lex.yy.c: lexer.l y.tab.h
	$(LEX) lexer.l

y.tab.c y.tab.h: parser.y
	$(YACC) -d parser.y -Wcounterexamples

clean:
	rm -f lex.yy.c y.tab.c y.tab.h $(TARGET)
