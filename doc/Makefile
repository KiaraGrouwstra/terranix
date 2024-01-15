.PHONY: all
all: man-packerix_description.refsection.xml man-packerix_functions.refsection.xml man-packerix_hcl.refsection.xml man-packerix_modules.refsection.xml man-packerix_options.refsection.xml man-packerix_conditions.refsection.xml man-packerix-doc_description.refsection.xml man-packerix-doc_options.refsection.xml


%.refsection.xml: %.refsection.md
	pandoc $^ -w docbook \
		-f markdown+smart \
	  | sed -e 's|<ulink url=|<link xlink:href=|' \
	      -e 's|</ulink>|</link>|' \
	      -e 's|<sect. id=|<section xml:id=|' \
	      -e 's|</sect[0-9]>|</section>|' \
	      -e '1s| xml:id="description"| |' \
	      -e '1s| xml:id="options"| |' \
	      -e '1s| id=| xml:id=|' \
	      -e 's|<section|<refsection|' \
	      -e 's|</section>|</refsection>|' \
	| cat  > $@

%.section.xml: %.section.md
	pandoc $^ -w docbook \
		-f markdown+smart \
	  | sed -e 's|<ulink url=|<link xlink:href=|' \
	      -e 's|</ulink>|</link>|' \
	      -e 's|<sect. id=|<section xml:id=|' \
	      -e 's|</sect[0-9]>|</section>|' \
	      -e '1s| id=| xml:id=|' \
	| cat  > $@

%.chapter.xml: %.chapter.md
	pandoc $^ -w docbook \
		--top-level-division=chapter \
		-f markdown+smart \
	  | sed -e 's|<ulink url=|<link xlink:href=|' \
	      -e 's|</ulink>|</link>|' \
	      -e 's|<sect. id=|<section xml:id=|' \
	      -e 's|</sect[0-9]>|</section>|' \
	      -e '1s| id=| xml:id=|' \
	      -e '1s|\(<[^ ]* \)|\1|' \
	| cat  > $@
