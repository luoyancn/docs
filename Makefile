# Makefile for Latex source files
#

BUILDDIR      = build
BASENAME      = $(notdir $(CURDIR))

latexpdf:
	@echo "Running LaTeX files through xelatex..."
	xelatex -shell-escape -8bit $(BASENAME).tex
	-bibtex $(BASENAME).aux
	xelatex -shell-escape -8bit $(BASENAME).tex
	xelatex -shell-escape -8bit $(BASENAME).tex
	@echo "xelatex finished; the PDF files are in $(BUILDDIR)/latex."

echo:
	@echo $(BASENAME)

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  latexpdf   to make LaTeX files and run them through xelatex"

.PHONY: clean
clean:
	rm -rf *.aux *.bbl *.blg *.log *.out *.pyg *.toc *.atfi _minted* *.listing svg-inkscape *.xwm


