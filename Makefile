#
#  Makefile for Osmium manuals.
#

PANDOC := pandoc

LIBOSMIUM_MD_FILES := \
    src/libosmium/introduction.md \
    src/libosmium/compiling.md \
    src/libosmium/basic-types.md \
    src/libosmium/osm-objects.md \
    src/libosmium/buffers.md \
    src/libosmium/input-and-output.md \
    src/libosmium/iterators.md \
    src/libosmium/visitors-and-handlers.md \
    src/libosmium/collectors.md \
    src/libosmium/geom.md \
    src/libosmium/storage.md \
    src/libosmium/exceptions.md \
    src/libosmium/invalid_data.md \
    src/libosmium/config.md

OPL_MD_FILES := \
    src/opl-file-format/introduction.md \
    src/opl-file-format/format.md \
    src/opl-file-format/encoding.md \
    src/opl-file-format/overview.md \
    src/opl-file-format/examples.md

CONCEPTS_MD_FILES := \
    src/osmium-concepts/introduction.md \
    src/osmium-concepts/entities.md \
    src/osmium-concepts/files.md \
    src/osmium-concepts/buffers.md \
    src/osmium-concepts/handlers.md \
    src/osmium-concepts/indexes.md

HTML_FILES := $(patsubst src/%.md,html/%.html,$(CONCEPTS_MD_FILES) $(LIBOSMIUM_MD_FILES) $(OPL_MD_FILES))

all: html singlehtml

# -----------------------------------------------------

.PHONY: docbook docbookhtml epub html singlehtml pdf

docbook: tmp/libosmium-manual.xml tmp/opl-file-format-manual.xml tmp/osmium-concepts-manual.xml

docbookhtml: docbookhtml/libosmium/index.html docbookhtml/opl-file-format/index.html docbookhtml/osmium-concepts/index.html docbookhtml/libosmium/manual.css docbookhtml/opl-file-format/manual.css docbookhtml/osmium-concepts/manual.css

html: $(HTML_FILES) html/libosmium/manual.css html/opl-file-format/manual.css html/osmium-concepts/manual.css

epub: out/libosmium-manual.epub out/opl-file-format-manual.epub out/osmium-concepts-manual.epub

singlehtml: out/libosmium-manual.html out/opl-file-format-manual.html out/osmium-concepts-manual.html out/manual.css

pdf: out/libosmium-manual.pdf out/opl-file-format-manual.pdf out/osmium-concepts-manual.pdf

# -----------------------------------------------------

# Concatenation of all markdown files
tmp/libosmium-manual.md: src/libosmium/header.md $(LIBOSMIUM_MD_FILES)
	mkdir -p tmp
	cat $^ >$@

tmp/opl-file-format-manual.md: src/opl-file-format/header.md $(OPL_MD_FILES)
	mkdir -p tmp
	cat $^ >$@

tmp/osmium-concepts-manual.md: src/osmium-concepts/header.md $(CONCEPTS_MD_FILES)
	mkdir -p tmp
	cp src/osmium-concepts/*.png tmp/
	sed -e 's/(\(.*\)\.png)/(tmp\/\1.png)/' $^ >$@

# PDF version
out/%-manual.pdf: tmp/%-manual.md
	mkdir -p out
	$(PANDOC) --number-sections --toc --standalone -V geometry:margin=1.5cm -o $@ $<

# EPUB version
out/%-manual.epub: tmp/%-manual.md
	mkdir -p out
	$(PANDOC) --number-sections --toc --standalone --epub-metadata=metadata.xml -o $@ $<

# Single HTML file
out/%-manual.html: tmp/%-manual.md
	mkdir -p out
	$(PANDOC) --template=templates/default --number-sections --standalone --toc --css=manual.css -o $@ $<

# Docbook version
tmp/%-manual.xml: tmp/%-manual.md
	mkdir -p tmp
	$(PANDOC) --standalone -t docbook -o $@ $<

# Chunked HTML via Docbook
docbookhtml/%/index.html: tmp/%-manual.xml
	mkdir -p docbookhtml/libosmium docbookhtml/opl-file-format docbookhtml/osmium-concepts
	xmlto xhtml -m custom-html-chunk.xsl $< -o docbookhtml/$*

docbookhtml/%/manual.css: docbookhtml.css
	mkdir -p docbookhtml
	cp $< $@

# Multiple HTML files
html/%.html: src/%.md
	mkdir -p html/libosmium html/opl-file-format html/osmium-concepts
	$(PANDOC) --template=templates/default --standalone --css=manual.css -o $@ $<

html/%/manual.css: manual.css
	mkdir -p html/libosmium html/opl-file-format html/osmium-concepts
	cp $< $@

out/manual.css: manual.css
	mkdir -p out
	cp $< $@

clean:
	rm -fr docbookhtml/* html/* out/* tmp/*

