import ollama
import sys
import json
import asyncio


# https://stackoverflow.com/questions/9786102/how-do-i-parallelize-a-simple-python-loop
def background(f):
    def wrapped(*args, **kwargs):
        return asyncio.get_event_loop().run_in_executor(None, f, *args, **kwargs)

    return wrapped


def get_hint(word):
    prompt = f'Imagine that you are writing a crossword puzzle. As the writer of the crossword puzzle, you must come up with a coherent, thoughtful, and clear hint to help the person playing the puzzle guess a word. Use the most common interpretation of the word when writing your hint. Do not interpret words as company names. For example, the word "dane" could be interpreted as "Dane," and a good hint for the word "dane" would be "A native of Denmark." However, the word "stat" could be interpreted as the UNIX command "stat," but this interpretation is too esoteric. Interpreting "stat" as "an abbreviation of the word statistic" is okay. The hint must be at least 6 words and at most 10 words. You cannot use the word in your hint. Do not say anything other than the hint. Please provide me with a hint for the word "{word}."'
    print(prompt)
    resp = ollama.chat(
        model="llama3",
        messages=[
            {
                "role": "user",
                "content": prompt,
            }
        ],
    )
    hint = resp["message"]["content"]
    if hint.startswith('"') and hint.endswith('"'):
        hint = hint[1:-1]

    return hint


@background
def handle_file(puz_file):
    print(f"Handling {puz_file}")
    with open(puz_file, "r+") as pz_fd:
        puzzle = json.load(pz_fd)
        if not puzzle["generatedHints"]:
            hints = []
            for word in puzzle["puzzleWord"]:
                hints.append(get_hint(word))

            puzzle["hints"] = hints
            puzzle["generatedHints"] = True

            pz_fd.seek(0)

            json.dump(puzzle, pz_fd)

            pz_fd.truncate()

            print(f"\tSuccessfully added hints for {puz_file}, hints: {hints}")
        else:
            print(f"\tAlready handled hints for {puz_file}, skipping")


files_to_read = sys.argv[1:]

eloop = asyncio.get_event_loop()
tasks = asyncio.gather(*[handle_file(puz_file) for puz_file in files_to_read])
results = eloop.run_until_complete(tasks)
print("Finished.")
