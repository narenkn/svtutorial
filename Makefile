.PHONY : all

all:
	pdflatex svtut.tex
#	bibtex svtut.aux
	htlatex svtut.tex