.PHONY : all clean

all:
	pdflatex svtut.tex
#	bibtex svtut.aux
	htlatex svtut.tex

clean:
	rm -f svtut.[1-9a-su-z]* svtut.t[a-df-z]* texput.log