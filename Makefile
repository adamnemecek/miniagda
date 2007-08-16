# Makefile for miniagda

files=Tokens Lexer Parser Abstract ScopeChecker SizeChecker TypeChecker Value Signature Termination
hsfiles=$(foreach file,$(files),$(file).hs)

default : Main

Main : Main.hs $(hsfiles)
	ghc $< --make -o $@

Lexer.hs : Lexer.x
	alex $<

Parser.hs : Parser.y
	happy $<


# EOF
