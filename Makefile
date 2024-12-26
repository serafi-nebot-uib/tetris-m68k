all: sprites tilify tile tilemap

sprites:
	./tool/resize.py 2 img/sprites-16.png img/sprites-32.png

tilify:
	./tool/tilify.py 16 img/sprites-16.png img/tiles-16.png
	./tool/tilify.py 32 img/sprites-32.png img/tiles-32.png

tile:
	./tool/tile.py 16 img/tiles-16.png src/tile-table-16.x68
	./tool/tile.py 32 img/tiles-32.png src/tile-table-32.x68

tilemap:
	rm -rf src/bg/*
	./tool/tilemap.py map/bg-game.csv src/bg/game.x68 bggame
	./tool/tilemap.py map/bg-home.csv src/bg/home.x68 bghome
	./tool/tilemap.py map/bg-mode.csv src/bg/mode.x68 bgmode
	./tool/tilemap.py map/bg-type-a.csv src/bg/type-a.x68 bgtypea
	./tool/tilemap.py map/bg-type-b.csv src/bg/type-b.x68 bgtypeb
	./tool/tilemap.py map/bg-score-b.csv src/bg/score-b.x68 bgscoreb
	./tool/tilemap.py map/bg-congratulations-a.csv src/bg/congratulations-a.x68 bgcongratulationsa
