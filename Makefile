.PHONY: default
default: tkl-1.stl tkl-2.stl tkl-3.stl tkl-4.stl

tkl-%.stl: tkl.scad
	openscad -o $@ -Dpart=$* $<
