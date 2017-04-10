all:
	pandoc --section-divs -t revealjs -s --template template.revealjs -o index.html talk.md
clean:
	rm talk.html
open: all # osx only sorry
	open talk.html
.PHONY: clean all open tildes
