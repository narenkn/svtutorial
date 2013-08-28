TEX           = pdflatex
HTMLTEX       = htlatex
HTMLTEX_FLAGS =  "html, 2, next" ""
CUSTOMCSS     = ohtml/custom.css
AUXFILES      = $(wildcard *.aux *.tmp *.toc *.xref *.lg *.idv *.dvi *.4tc *.4ct *.out *.log)
SOURCES       = $(wildcard *.tex)
PDFS          = $(SOURCES:.tex=.pdf)
HTML          = $(SOURCES:.tex=.html)

.PHONY: rmaux pdf html clean all

all: pdf html

pdf: $(SOURCES) $(PDFS)

html: $(SOURCES) $(HTML)

clean: rmaux
	rm -f $(PDFS) $(HTML)

rmaux:
	rm -f $(AUXFILES)

%.pdf: %.tex
	$(TEX) $<

%.html: %.tex $(CUSTOMCSS)
	-rm -f ohtml/$(<:.tex=.css)
	$(HTMLTEX) $< $(HTMLTEX_FLAGS)
	cat $(<:.tex=.css) $(CUSTOMCSS) > ohtml/$(<:.tex=.css)
	for html in *.html ; do \
		ruby bin/fix_html.rb $$html > ohtml/$$html 2>&1; \
	done
