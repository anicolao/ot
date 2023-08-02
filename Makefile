
%.split: %.input
	cat $< | ./bin/split -b 50 > $@

%.compressed: %.input
	cat $< | ./bin/compress > $@

%.stored: %.compressed
	cat $< | ./bin/store > $@
