all: sprites tilify tile tilemap

sprites:
	./tool/resize.py 2 img/sprites-16.png img/sprites-32.png

tilify:
	./tool/tilify.py 16 img/sprites-16.png img/tiles-16.png
	./tool/tilify.py 32 img/sprites-32.png img/tiles-32.png

tile:
	./tool/tilebin.py 16 img/tiles-16.png src/tile-table-16.bin
	./tool/tilebin.py 32 img/tiles-32.png src/tile-table-32.bin

tilemap:
	rm -rf src/bg/*
	./tool/tilemap.py map/bg-game.csv src/bg/game.x68 bggame
	./tool/tilemap.py map/bg-home.csv src/bg/home.x68 bghome
	./tool/tilemap.py map/bg-mode.csv src/bg/mode.x68 bgmode
	./tool/tilemap.py map/bg-type-a.csv src/bg/type-a.x68 bgtypea
	./tool/tilemap.py map/bg-type-b.csv src/bg/type-b.x68 bgtypeb
	./tool/tilemap.py map/bg-success-type-b.csv src/bg/success-type-b.x68 bgsuccesstypeb
	./tool/tilemap.py map/bg-congratulations-a.csv src/bg/congratulations-a.x68 bgcongratulationsa
	./tool/tilemap.py map/bg-congratulations-b.csv src/bg/congratulations-b.x68 bgcongratulationsb
