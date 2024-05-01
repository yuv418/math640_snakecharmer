import pygame as pg
import asyncio
import math
import json
import sys

# rendering parameters
RESOLUTION = (1100, 1100)  # aspect ratio of a sheet of paper
PUZZLE_CENTER = (RESOLUTION[0] * 0.5, RESOLUTION[1] * 0.33)
PUZZLE_OUTER_RAD = 350
PUZZLE_INNER_RAD = 250
PUZZLE_LINE_WIDTH = 10
PUZZLE_LABEL_RAD = 320

HINT_START_POS = (RESOLUTION[0] * 0.025, RESOLUTION[1] * 0.7)
HINT_VERTICAL_STRIDE = 35


async def main(puzzleLen, wordPositions, hints, words, solution):
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
    highlightRegion = 0

    currentGuess = " " * len(solution)

    # load font:
    font = pg.font.Font(pg.font.get_default_font(), 24)
    solutionFont = pg.font.Font(pg.font.get_default_font(), 36)

    # main render loop:
    while running:
        for event in pg.event.get():  # handle window closing
            if event.type == pg.QUIT:
                running = False

            if event.type == pg.KEYUP:
                if event.key == pg.K_SPACE and solution != currentGuess:
                    displaySolutions = not displaySolutions
                elif event.key == pg.K_LEFT:
                    highlightRegion = (highlightRegion - 1) % puzzleLen
                elif event.key == pg.K_RIGHT:
                    highlightRegion = (highlightRegion + 1) % puzzleLen
                elif event.key == pg.K_BACKSPACE and not displaySolutions:
                    currentGuess = currentGuess[:highlightRegion] + " " + currentGuess[(highlightRegion + 1) :]
                elif not displaySolutions and event.key != pg.K_SPACE and event.unicode != "":
                    currentGuess = currentGuess[:highlightRegion] + event.unicode + currentGuess[(highlightRegion + 1) :]

        screen.fill("white")  # clear screen

        if highlightRegion >= 0:  # highlighted box for typing (looks really bad)
            startAngle = -((highlightRegion + 1) / puzzleLen) * 2.0 * math.pi + math.pi * 0.5
            endAngle = -(highlightRegion / puzzleLen) * 2.0 * math.pi + math.pi * 0.5
            width = PUZZLE_OUTER_RAD - PUZZLE_INNER_RAD

            pos = (PUZZLE_CENTER[0] - PUZZLE_OUTER_RAD, PUZZLE_CENTER[1] - PUZZLE_OUTER_RAD)
            size = (PUZZLE_OUTER_RAD * 2, PUZZLE_OUTER_RAD * 2)

            pg.draw.arc(screen, (150, 150, 255), pg.Rect(pos, size), startAngle, endAngle, width=width)

        pg.draw.circle(screen, (0, 0, 0), PUZZLE_CENTER, PUZZLE_INNER_RAD, width=PUZZLE_LINE_WIDTH)  # inner circle
        pg.draw.circle(screen, (0, 0, 0), PUZZLE_CENTER, PUZZLE_OUTER_RAD, width=PUZZLE_LINE_WIDTH)  # outer circle

        for i in range(puzzleLen):  # spokes
            angle = (i / puzzleLen) * 2.0 * math.pi - math.pi * 0.5
            pos = (math.cos(angle), math.sin(angle))

            startPos = tuple(map(lambda p, c: PUZZLE_INNER_RAD * p + c, pos, PUZZLE_CENTER))
            endPos = tuple(map(lambda p, c: PUZZLE_OUTER_RAD * p + c, pos, PUZZLE_CENTER))

            pg.draw.line(screen, (0, 0, 0), startPos, endPos, width=PUZZLE_LINE_WIDTH)

        for i in range(len(wordPositions)):  # word positions
            textSurface = font.render(str(i + 1), True, (0, 0, 0))

            angle = ((wordPositions[i] + 0.5) / puzzleLen) * 2.0 * math.pi - math.pi * 0.5
            pos = (
                PUZZLE_LABEL_RAD * math.cos(angle) + PUZZLE_CENTER[0] - 0.5 * textSurface.get_size()[0],
                PUZZLE_LABEL_RAD * math.sin(angle) + PUZZLE_CENTER[1] - 0.5 * textSurface.get_size()[1],
            )

            screen.blit(textSurface, dest=pos)

        for i in range(len(hints)):  # hints
            textSurface = font.render("{0}. ".format(i + 1) + hints[i] + f" ({len(words[i])} letters)", True, (0, 0, 0))

            pos = (HINT_START_POS[0], HINT_START_POS[1] + i * HINT_VERTICAL_STRIDE)

            screen.blit(textSurface, dest=pos)

        for i in range(len(solution)):
            renderColor = (0, 0, 0) if currentGuess != solution else (0, 255, 0)
            onscreenChar = currentGuess[i]

            print(currentGuess, solution)
            if displaySolutions and currentGuess[i] != solution[i]:
                renderColor = (255, 0, 0)
                onscreenChar = solution[i]

            textSurface = solutionFont.render(onscreenChar.upper(), True, renderColor)

            angle = ((i + 0.5) / puzzleLen) * 2.0 * math.pi - math.pi * 0.5
            rad = PUZZLE_INNER_RAD * 0.75 + PUZZLE_OUTER_RAD * 0.25
            pos = (
                rad * math.cos(angle) + PUZZLE_CENTER[0] - 0.5 * textSurface.get_size()[0],
                rad * math.sin(angle) + PUZZLE_CENTER[1] - 0.5 * textSurface.get_size()[1],
            )

            screen.blit(textSurface, dest=pos)

        pg.display.flip()  # present
        pg.display.update()  # present

        await asyncio.sleep(0)  # Very important, and keep it 0
        clock.tick(60)  # limit framerate


if __name__ == "__main__":
    pass
    # MUST INPUT:
    # - total length of the puzzle (number of letters)
    # - list of starting positions of each individual word
    # - list of hints
    # - final solution string

    if len(sys.argv) < 2:
        print("Usage: python main.py puzzle_file.json")
        exit(1)

    puzzleRead = None
    #puzJson = '{"generatedHints": true, "puzzleLength": 23, "puzzleString": "platentyrantsarsonstomp", "puzzleWord": ["plat", "latent", "tenty", "tyrant", "ants", "tsar", "arsons", "stomp"], "startingPositionsOfWords": [0, 1, 3, 6, 9, 11, 13, 18], "hints": ["Solid base of a foundation or floor plan.", "Unexpressed potential waiting to emerge fully.", "Fingers extended on either side of the palm", "Ruthless leader known for oppression.", "Insects that march in lines often", "Autocratic ruler of Russia\'s imperial era.", "Incendiary criminal activities often involve these perpetrators", "Energetic footwork often accompanies loud music"]}'

    with open(sys.argv[1]) as puzzleFile:
        puzzleRead = json.load(puzzleFile)
    puzzleRead = json.loads(puzJson)

    # We messed up the puzzleString so we have to do this:
    off = 1
    while puzzleRead["puzzleWord"][-1].endswith(puzzleRead["puzzleWord"][1][:off]):
        off += 1
    print(off)
    asyncio.run(
        main(
            puzzleRead["puzzleLength"] - off,
            puzzleRead["startingPositionsOfWords"],
            puzzleRead["hints"],
            puzzleRead["puzzleWord"],
            puzzleRead["puzzleString"][:-off],
        )
    )
