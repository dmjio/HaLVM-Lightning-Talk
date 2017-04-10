all:
	pandoc --section-divs -t revealjs -s --template template.revealjs -o index.html talk.md
clean:
	rm index.html
open: all # osx only sorry
	open index.html
.PHONY: clean all open tildes
