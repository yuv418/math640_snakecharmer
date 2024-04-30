# Homework 23: We set up a communication means and began planning the project, and updated the 
# file with our names and project information

# Project 3: Snake Charmer
# Members: Ramesh Balaji, Daniel Elwell, Nuray Kutlu

# The following is adapted from Dr. Z's template.

Help:=proc(): print(` Followers(w,k,n)`):end:

read `ENGLISH.txt`:

#Followers(w,k,n): inputs a word w outputs all the words of length n that start with the last k letters of w. Try:
#Followers([d,o,r,o,n],2,5);
Followers:=proc(w,k,n) local S,G,w1,v:

print(w,k,n);
if k>n then
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
	if nops(n) < nops(startL) or nops(n) < nops(endL) then
		return {};
	fi:

	words:=ENG()[n];	
	for word in words do:
		if word[..nops(startL)] = startL and word[(nops(word) - nops(endL) + 1)..] = endL then:
			outWords := outWords union {word};
		fi:
	od:

	return outWords;
end:

# GeneratePuzzle(starterWord, minLength, maxWordOverlap, minWordLength, maxWordLength)
# Generate a snake charmer puzzle that has a starter word, then uses Followers (where the k value is randomly chosen between 1 and maxWordOverlap) to repeatedly 
# generate words until minLength is hit, then try to keep choosing words until there exists one that overlaps with the first word (currently only 1 letter overlap).
# Every word in the puzzle has length bounded by [minWordLength, maxWordLength]

AppendFollowerToPuzzle := proc(puzzle, overlapRand, wordLenRand):
	followers := {};
	overlapCurrentRand := overlapRand();
	while followers = {} do:
		followers := Followers(puzzle[-1], overlapCurrentRand, wordLenRand());
		if overlapCurrentRand > 1 then:
			overlapCurrentRand--;
		fi:
	od:
	chosenAddition := puzzle[1]; 	
	while member(chosenAddition, puzzle) do:
		chosenAddition := followers[rand(1..nops(followers))()];
	od:
	puzzleMod := [op(puzzle), chosenAddition];
	return puzzleMod;
end:

GeneratePuzzle := proc(starterWord, minLength, minWordOverlap, maxWordOverlap, minWordLength, maxWordLength):
	puzzle := [starterWord];

	wordsLeft := minLength;	
	overlapRand := rand(minWordOverlap..maxWordOverlap);
	wordLenRand := rand(minWordLength..maxWordLength);
	while wordsLeft <> 1 do:
		puzzle := AppendFollowerToPuzzle(puzzle, overlapRand, wordLenRand);
		wordsLeft -= 1;
	od:

	# Keep adding words until we complete the puzzle.
	finishingWords := {};
	# The last word must begin with a subset of the end of the current last word
	lastPuzzleSlice := puzzle[-1][(nops(puzzle[-1])-rand(minWordOverlap..maxWordOverlap)()+1)...nops(puzzle[-1])];
	# The last word must end with a subset of the beginning of the first word
	firstPuzzleSlice := puzzle[1][1..rand(minWordOverlap..maxWordOverlap)()];
	while finishingWords = {} do:

		print(lastPuzzleSlice, firstPuzzleSlice);

		# TODO: How do we choose how many letters the last puzzle word should have as overlap
		# with the first puzzle word?

		finishingWords := SubsetWords(wordLenRand(), lastPuzzleSlice, firstPuzzleSlice);

		removeFrom := rand(1..2)();
		oldLastNops := nops(lastPuzzleSlice);
		oldFirstNops := nops(firstPuzzleSlice);

		if removeFrom = 1 and oldLastNops > 1 then:
			lastPuzzleSlice := lastPuzzleSlice[2..nops(lastPuzzleSlice)];
		elif oldFirstNops > 1 then:
			firstPuzzleSlice := firstPuzzleSlice[1..nops(firstPuzzleSlice)-1];
		end:

		print(oldLastNops, oldFirstNops);

		if oldLastNops = minWordOverlap and oldFirstNops = minWordOverlap and finishingWords = {} then:
			puzzle := AppendFollowerToPuzzle(puzzle, overlapRand(), wordLenRand());

			lastPuzzleSlice := puzzle[-1][(nops(puzzle[-1])-rand(minWordOverlap..maxWordOverlap)()+1)...nops(puzzle[-1])];
			firstPuzzleSlice := puzzle[1][1..rand(minWordOverlap..maxWordOverlap)()];
		fi:
	od:

	puzzle := [ op(puzzle), finishingWords[rand(1..nops(finishingWords))()] ];
	return puzzle;
end:

# Potential TODO:

# Choose a starter word -> generate a puzzle of N words
# Maybe call it GeneratePuzzle(StarterWord, N), or something like that.

# Draw the puzzle
