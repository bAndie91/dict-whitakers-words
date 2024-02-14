
BASENAME = whitakers-latin-english


all: $(BASENAME).dict.dz $(BASENAME).index
.PHONY: all

$(BASENAME).dict.dz: %.dict.dz: %.dict
	dictzip --keep $<

$(BASENAME).dict $(BASENAME).index &: headers dict.txt
	cat $^ | dictfmt -f --utf8 -s "William A. Whitaker's WORDS Latin-English Dictionary" $(BASENAME)

dict.txt: headwords.txt whitakers-words/bin/words whitakers-words/WORD.MOD data
	cd whitakers-words && ../gen-dict $$(wc -l < ../$<) bin/words < ../$< > ../$@~
	mv $@~ $@

headwords.txt: whitakers-words/CHECKEWD.
	cat $< | cut -c 25-44 | sort -u > $@

whitakers-words/CHECKEWD.: whitakers-words/bin/makeewds
	cd whitakers-words && echo g | bin/makeewds

whitakers-words/bin/makeewds: | whitakers-words
	cd whitakers-words && make makeewds

whitakers-words/bin/words: | whitakers-words
	cd whitakers-words && make words

data: whitakers-words/bin/words | whitakers-words
	set -e; \
	cd whitakers-words; \
	bin/words "" || $(MAKE)
.PHONY: data

whitakers-words/WORD.MOD: WORD.MOD | whitakers-words
	cp $< $@

whitakers-words:
	git clone https://github.com/mk270/whitakers-words



clean:
	rm $(BASENAME).dict $(BASENAME).dict.dz $(BASENAME).index
.PHONY: clean


PREFIX = /usr/share/dictd

install: $(PREFIX)/$(BASENAME).dict.dz $(PREFIX)/$(BASENAME).index
	dictdconfig -w
.PHONY: install

$(PREFIX)/$(BASENAME).dict.dz $(PREFIX)/$(BASENAME).index: $(PREFIX)/%: %
	install --compare -m 0644 $< $@
