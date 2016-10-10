# Makefile for Sphinx documentation
#

BUILDDIR      = build
BASENAME      = $(notdir $(CURDIR))

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  latexpdf   to make LaTeX files and run them through pdflatex"

clean:
	rm -rf *.aux *.bbl *.blg *.log *.out *.pyg *.toc

echo:
	@echo $(BASENAME)

pdf:
	@echo "Running LaTeX files through xelatex..."
	xelatex -shell-escape $(BASENAME).tex
	-bibtex $(BASENAME).aux
	xelatex -shell-escape $(BASENAME).tex
	xelatex -shell-escape $(BASENAME).tex
	@echo "xelatex finished; the PDF files are in $(BUILDDIR)/latex."
