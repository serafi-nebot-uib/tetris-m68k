all: sprites tilify tile tilemap

sprites:
	./tool/resize.py 2 img/sprites-16.png img/sprites-32.png

tilify:
	./tool/tilify.py 16 img/sprites-16.png img/tiles-16.png
	./tool/tilify.py 32 img/sprites-32.png img/tiles-32.png

tile:
	./tool/tile.py 16 img/tiles-16.png src/tile-table-16.x68
	./tool/tile.py 32 img/tiles-32.png src/tile-table-32.x68

# TODO: remove error ignore
tilemap:
	-./tool/tilemap.py map/bg-game-16.csv src/bg/game-16.x68 bggame
	-./tool/tilemap.py map/bg-game-32.csv src/bg/game-32.x68 bggame

	-./tool/tilemap.py map/bg-home-16.csv src/bg/home-16.x68 bghome
	-./tool/tilemap.py map/bg-home-32.csv src/bg/home-32.x68 bghome

	-./tool/tilemap.py map/bg-mode-16.csv src/bg/mode-16.x68 bgmode
	-./tool/tilemap.py map/bg-mode-32.csv src/bg/mode-32.x68 bgmode

	-./tool/tilemap.py map/bg-score-16.csv src/bg/score-16.x68 bgscore
	-./tool/tilemap.py map/bg-score-32.csv src/bg/score-32.x68 bgscore
