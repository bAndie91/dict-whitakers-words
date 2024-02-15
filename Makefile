
BASENAME = whitakers-latin-english


all: $(BASENAME).dict.dz $(BASENAME).index
.PHONY: all

$(BASENAME).dict.dz: %.dict.dz: %.dict
	dictzip --keep $<

$(BASENAME).dict $(BASENAME).index &: headers dict.txt
	cat $^ | dictfmt -f --utf8 -s "William A. Whitaker's WORDS Latin-English Dictionary" -u "https://github.com/mk270/whitakers-words" $(BASENAME)

dict.txt: headwords.txt whitakers-words/bin/words
	WD=$$PWD; cd whitakers-words && $$WD/gen-dict $$WD/$< bin/words > $$WD/$@~
	mv $@~ $@

headwords.txt: whitakers-words/CHECKEWD.
	cat $< | cut -c 25-44 | sort -u > $@

whitakers-words/CHECKEWD.: whitakers-words/bin/makeewds
	cd whitakers-words && echo g | bin/makeewds

whitakers-words/bin/makeewds: | whitakers-words/.git/HEAD
	cd whitakers-words && $(MAKE) makeewds

whitakers-words/bin/words: whitakers-words/WORD.MOD whitakers-words/INFLECTS.SEC | whitakers-words/.git/HEAD
	cd whitakers-words && $(MAKE) words

whitakers-words/INFLECTS.SEC: whitakers-words/.git/HEAD | whitakers-words/.git/HEAD
	cd whitakers-words && $(MAKE)

whitakers-words/WORD.MOD: WORD.MOD | whitakers-words/.git/HEAD
	cp $< $@

whitakers-words/.git/HEAD:
	if cd whitakers-words && git checkout 9b11477e53f4adfb17d6f6aa563669dc71e0a680; then true; \
	else git clone https://github.com/mk270/whitakers-words; fi



clean:
	rm $(BASENAME).dict $(BASENAME).dict.dz $(BASENAME).index
.PHONY: clean


PREFIX = /usr/share/dictd

install: $(PREFIX)/$(BASENAME).dict.dz $(PREFIX)/$(BASENAME).index
	dictdconfig -w
.PHONY: install

$(PREFIX)/$(BASENAME).dict.dz $(PREFIX)/$(BASENAME).index: $(PREFIX)/%: %
	install --compare -m 0644 $< $@
