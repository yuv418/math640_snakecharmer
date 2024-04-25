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

if k>n then
 RETURN(FAIL):
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
	words:=ENG()[n];	
	for word in words do:
		if word[..nops(startL)] = startL and word[(nops(word) - nops(endL) + 1)..] = endL then:
			outWords := outWords union {word};
		fi:
	od:

	return outWords;
end:

# Potential TODO:

# Choose a starter word -> generate a puzzle of N words
# Maybe call it GeneratePuzzle(StarterWord, N), or something like that.

# Draw the puzzle
