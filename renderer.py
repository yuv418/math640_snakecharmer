import pygame as pg
import math

# rendering parameters
RESOLUTION = (850, 1100) # aspect ratio of a sheet of paper
PUZZLE_CENTER = (RESOLUTION[0] * 0.5, RESOLUTION[1] * 0.33)
PUZZLE_OUTER_RAD = 350
PUZZLE_INNER_RAD = 250
PUZZLE_LINE_WIDTH = 10
PUZZLE_LABEL_RAD = 320

HINT_START_POS = (RESOLUTION[0] * 0.025, RESOLUTION[1] * 0.7)
HINT_VERTICAL_STRIDE = 35

def run(puzzleLen, wordPositions, hints, solution):
	# simple error checking:
	if len(wordPositions) != len(hints):
		print("input error")
		return

	if puzzleLen != len(solution):
		print("input error")
		return

	# initialize pygame:
	pg.init()
	screen = pg.display.set_mode(RESOLUTION)
	clock = pg.time.Clock()
	running = True

	displaySolutions = False
	highlightRegion = 3

	# load font:
	font = pg.font.Font(pg.font.get_default_font(), 24)
	solutionFont = pg.font.Font(pg.font.get_default_font(), 36)

	# main render loop:
	while running:
		for event in pg.event.get(): # handle window closing
			if event.type == pg.QUIT:
				running = False
			
			if event.type == pg.KEYUP:
				if event.key == pg.K_SPACE:
					displaySolutions = not displaySolutions
		
		screen.fill("white") # clear screen

		if highlightRegion >= 0: # highlighted box for typing (looks really bad)
			startAngle = -((highlightRegion + 1) / puzzleLen) * 2.0 * math.pi + math.pi * 0.5
			endAngle   = -(highlightRegion       / puzzleLen) * 2.0 * math.pi + math.pi * 0.5
			width = PUZZLE_OUTER_RAD - PUZZLE_INNER_RAD

			pos = (PUZZLE_CENTER[0] - PUZZLE_OUTER_RAD, PUZZLE_CENTER[1] - PUZZLE_OUTER_RAD)
			size = (PUZZLE_OUTER_RAD * 2, PUZZLE_OUTER_RAD * 2)

			pg.draw.arc(screen, (150, 150, 255), pg.Rect(pos, size), startAngle, endAngle, width=width)

		pg.draw.circle(screen, (0,0,0), PUZZLE_CENTER, PUZZLE_INNER_RAD, width=PUZZLE_LINE_WIDTH) # inner circle
		pg.draw.circle(screen, (0,0,0), PUZZLE_CENTER, PUZZLE_OUTER_RAD, width=PUZZLE_LINE_WIDTH) # outer circle

		for i in range(puzzleLen): # spokes
			angle = (i / puzzleLen) * 2.0 * math.pi - math.pi * 0.5
			pos = (math.cos(angle), math.sin(angle))

			startPos = tuple(map(lambda p, c: PUZZLE_INNER_RAD * p + c, pos, PUZZLE_CENTER))
			endPos   = tuple(map(lambda p, c: PUZZLE_OUTER_RAD * p + c, pos, PUZZLE_CENTER))

			pg.draw.line(screen, (0,0,0), startPos, endPos, width = PUZZLE_LINE_WIDTH)

		for i in range(len(wordPositions)): # word positions
			textSurface = font.render(str(i+1), True, (0,0,0))
			
			angle = ((wordPositions[i] + 0.5) / puzzleLen) * 2.0 * math.pi - math.pi * 0.5
			pos = (PUZZLE_LABEL_RAD * math.cos(angle) + PUZZLE_CENTER[0] - 0.5 * textSurface.get_size()[0],
			       PUZZLE_LABEL_RAD * math.sin(angle) + PUZZLE_CENTER[1] - 0.5 * textSurface.get_size()[1])

			screen.blit(textSurface, dest=pos)

		for i in range(len(hints)): # hints
			textSurface = font.render("{0}. ".format(i+1) + hints[i], True, (0,0,0))

			pos = (HINT_START_POS[0], HINT_START_POS[1] + i * HINT_VERTICAL_STRIDE)

			screen.blit(textSurface, dest=pos)

		if displaySolutions: # answers
			for i in range(len(solution)):
				textSurface = solutionFont.render(solution[i].upper(), True, (255, 0, 0))

				angle = ((i + 0.5) / puzzleLen) * 2.0 * math.pi - math.pi * 0.5
				rad = PUZZLE_INNER_RAD * 0.75 + PUZZLE_OUTER_RAD * 0.25
				pos = (rad * math.cos(angle) + PUZZLE_CENTER[0] - 0.5 * textSurface.get_size()[0],
				       rad * math.sin(angle) + PUZZLE_CENTER[1] - 0.5 * textSurface.get_size()[1])
				
				screen.blit(textSurface, dest=pos)

		pg.display.flip() # present
		clock.tick(60) # limit framerate

if __name__ == "__main__":

	# MUST INPUT:
	# - total length of the puzzle (number of letters)
	# - list of starting positions of each individual word
	# - list of hints
	# - final solution string

	run(10, [0, 5], ["greeting", "globe"], "helloworld")