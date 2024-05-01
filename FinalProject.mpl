# Project 3: Snake Charmer
# Members: Ramesh Balaji, Daniel Elwell, Nuray Kutlu

# The following is adapted from Dr. Z's template.

with(StringTools):

Help:=proc(): print(` Followers(w,k,n)`):end:

MAX_ITERS := 100;

read `ENGLISH.txt`:

#Followers(w,k,n): inputs a word w outputs all the words of length n that start with the last k letters of w. Try:
#Followers([d,o,r,o,n],2,5);
Followers:=proc(w,k,n) local S,G,w1,v:

#print(w,k,n);
if k>n or nops(w) <= k then
 RETURN({}):
fi:

w1:=[op(nops(w)-k+1..nops(w),w)]:

S:=ENG()[n]:

G:={}:

for  v in S do
 if [op(1..k,v)]=w1 then
  G:=G union {v}:
 fi:
od:

G:

end:

# SubsetWords(n, startL, endL): 
# Outputs all words of length n, starting with 
# letters startL and ending with letters endL. 
#
# startL and endL are arrays. If you have an empty array,
# it won't check start or end for anything
SubsetWords := proc(n, startL, endL) local words, outWords, word:
	outWords := {};
	if n < nops(startL) or n < nops(endL) then
		print("hi");
		return {};
	fi:

	words:=ENG()[n];	
	for word in words do:
		if word[..nops(startL)] = startL and word[(nops(word) - nops(endL) + 1)..] = endL then:
			outWords := outWords union {[word, nops(startL)]};
		fi:
	od:

	return outWords;
end:

# GeneratePuzzle(starterWord, minLength, minWordOverlap, maxWordOverlap, minWordLength, maxWordLength)
# Generate a snake charmer puzzle that has a starter word, then uses Followers (where the k value is randomly chosen between minWordOverlap and maxWordOverlap) 
# to repeatedly generate words until minLength is hit, then try to keep choosing words until there exists one that overlaps with the first word (currently only 
# 1 letter overlap). Every word in the puzzle has length bounded by [minWordLength, maxWordLength].

AppendFollowerToPuzzle := proc(puzzle, minWordOverlap, overlapRand, wordLenRand):
	followers := {};
	overlapCurrentRand := overlapRand();
	wordOverlap        := overlapCurrentRand;
	iters := 0;
	while followers = {} do:
		if iters = MAX_ITERS then:
			return FAIL;
		fi:
		followers   := Followers(puzzle[-1], overlapCurrentRand, wordLenRand());
		wordOverlap := overlapCurrentRand;

		if overlapCurrentRand > minWordOverlap then:
			overlapCurrentRand--;
		fi:
		iters++;
	od:
	chosenAddition := puzzle[1]; 	
	while member(chosenAddition, puzzle) do:
		chosenAddition := followers[rand(1..nops(followers))()];
	od:
	puzzleMod := [op(puzzle), chosenAddition];
	return puzzleMod, wordOverlap;
end:

CalculateFinishingWords := proc(puzzle, minWordLength, maxWordLength, minWordOverlap1, maxWordOverlap1, minWordOverlap2, maxWordOverlap2):
	return {seq(seq(seq(op(SubsetWords(i1 + 1, puzzle[-1][-j1..], puzzle[1][..k1])), k1=maxWordOverlap2..minWordOverlap2, -1),
				j1=maxWordOverlap1..minWordOverlap1, -1), i1=maxWordLength..minWordLength, -1) };
end:

GeneratePuzzle := proc(starterWord, minLength, minWordOverlap, maxWordOverlap, minWordLength, maxWordLength, loosenConstraintsForLastWord := true):
	if minWordOverlap > minWordLength or maxWordOverlap > minWordLength then:
		return FAIL:
	fi:
	puzzle        := [starterWord];
	startingPos   := [0]:
	puzzleString  := [op(starterWord)];

	wordsLeft := minLength;	
	overlapRand := rand(minWordOverlap..maxWordOverlap);
	wordLenRand := rand(minWordLength..maxWordLength);
	while wordsLeft <> 1 do:
		update:= AppendFollowerToPuzzle(puzzle, minWordOverlap, overlapRand, wordLenRand);
		if update = FAIL then:
			return FAIL;
		fi:

		puzzle := update[1];
		overlap:= update[2];

		print(cat("overlap between " , puzzle[-1] , " and " , puzzle[-2] , " is ", overlap));
		startingPos  := [op(startingPos), startingPos[-1] + nops(puzzle[-2]) - overlap];
		puzzleString := [op(puzzleString), op(puzzle[-1][(overlap + 1)..])];
		wordsLeft -= 1;
	od:

	# Find all possible terminating with the constraints given
	finishingWords := CalculateFinishingWords(puzzle, minWordLength, maxWordLength, minWordOverlap, maxWordOverlap, 
							minWordOverlap, maxWordOverlap);
	print(finishingWords);
	# If there were no words, then we can loosen the constraints a little bit.
	if finishingWords = {} and loosenConstraintsForLastWord then:
		for l1 from minWordLength to 1 by -1 do:
			for m1 from l1 to 1 by -1 do:
				finishingWords := CalculateFinishingWords(puzzle, minWordLength, maxWordLength, l1, maxWordOverlap, m1, maxWordOverlap);
				#update startingPos arr
				if finishingWords <> {} then:
					wordAndOverlap := finishingWords[rand(1..nops(finishingWords))()];

					finishingWord  := wordAndOverlap[1];
					overlap        := wordAndOverlap[2];

					puzzle         := [ op(puzzle), finishingWord ];
					startingPos    := [ op(startingPos), startingPos[-1] + nops(puzzle[-2]) - overlap ];

					puzzleString   := [ op(puzzleString), op(puzzle[-1][(overlap + 1)..]) ];

					return puzzle, startingPos, puzzleString;
				fi:
			od:
		od:

		return FAIL;
	elif finishingWords <> {} then:
		#update startingPos arr
		wordAndOverlap := finishingWords[rand(1..nops(finishingWords))()];

		finishingWord  := wordAndOverlap[1];
		overlap        := wordAndOverlap[2];

		puzzle         := [ op(puzzle), finishingWord ];
		startingPos    := [ op(startingPos), startingPos[-1] + nops(puzzle[-2]) - overlap ];

		puzzleString   := [ op(puzzleString), op(puzzle[-1][(overlap + 1)..]) ];

		return puzzle, startingPos, puzzleString;

	else:
		return FAIL;
	fi:

end:

# PuzzleToStringArray(puzzle)
# Given a puzzle in the form [[w,o,r,d], [d,o,w]], it will convert this
# to the string form: ["word", "dow"].
PuzzleStringArrayToString := proc(puzzle):
	return Join([ seq(convert(puzzle[i], string), i=1..nops(puzzle)) ], "");
end:

# PuzzleToJSON(puzzle, constraintsFile, outputFile):
# Uses https://www.maplesoft.com/support/help/maple/view.aspx?path=Formats%2FJSON
# Given an input constraintsFile in the following format
# { "starterWordMinLength": 0 
#   "starterWordMaxLength": 0,
#   "minLength"           : 0, 
#   "minWordOverlap"      : 0, 
#   "maxWordOverlap"      : 0, 
#   "minWordLength"       : 0, 
#   "maxWordLength"       : 0, 
#   "puzzlesToGenerate"   : 0 
#   "loosenConstraintsForLastWord": true } 
# Outputs a file to outputFile in the following format (for the Python program):
# { "startingPositionsOfWords": [0, 5],
#   "puzzleString": "helloworld",  
#   "puzzleLength": 10,
#   "hints": ["greeting", "globe"] }
PuzzlesToJSON := proc(constraintsFile, outputDir):
	puzzles:= []:
	constraints       := Import(constraintsFile);

	minLength         := constraints["minLength"]:

	minWordOverlap    := constraints["minWordOverlap"]:
	maxWordOverlap    := constraints["maxWordOverlap"]:

	minWordLength     := constraints["minWordLength"]:
	maxWordLength     := constraints["maxWordLength"]:

	puzzlesToGenerate := constraints["puzzlesToGenerate"]:

	for i from 1 to puzzlesToGenerate do
		# The starter word for every puzzle is different.
	        starterWordPool   := ENG()[rand(constraints["starterWordMinLength"]..constraints["starterWordMaxLength"])()];
	        starterWord       := starterWordPool[rand(1..nops(starterWordPool))()];

		puzzle 		  := FAIL;

		while puzzle = FAIL do:
			puzzle := GeneratePuzzle(starterWord, minLength, minWordOverlap, maxWordOverlap, minWordLength, maxWordLength):
		od:

		puzzleFile:= table([ "startingPositionsOfWords" = puzzle[2], 
			             "puzzleString"             = PuzzleStringArrayToString(puzzle[3]), 
				     "puzzleLength"             = nops(puzzle[3]), 
			             "generatedHints"           = false ]):
		print(op(puzzleFile));

		fileName:= cat("puzzle", convert(i, string), ".json"):
		path:= cat(outputDir, "/", fileName):
		Export(path, puzzleFile, "JSON"):
	od: 
end:
