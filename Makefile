.PHONY: default clean
TARGETS := tkl-1.stl tkl-2.stl tkl-3.stl tkl-4.stl tkl-1.svg tkl-2.svg
default: $(TARGETS)
clean:
	rm -f $(TARGETS)


tkl-%.stl: tkl.scad cherryplate.scad
	openscad -o $@ -Dpart=$* $<

tkl-%.svg: tkl.scad cherryplate.scad
	openscad -o $@ -Dpart=-$* $<
