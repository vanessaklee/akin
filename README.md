Akin
=======

Akin is a collection of string comparison algorithms for Elixir. This solution was born of a [Record Linking](https://en.wikipedia.org/wiki/Record_linkage) project. It combines and modifies [The Fuzz](https://github.com/smashedtoatoms/the_fuzz) and [Fuzzy Compare](https://github.com/patrickdet/fuzzy_compare). Algorithms can be called independently or in total to return a map of metrics. This library was built to facilitiate the disambiguation of names but can be used to compare any two binaries.

## Installation

Add a dependency in your mix.exs:

```elixir
deps: [{:akin, "~> 1.0"}]
```

## Disambiguation using `compare/2` and `compare/3`
### All Algortithms Together

Compare two strings using all of the available algorithms. The return value is a map of scores for each algorithm.

```elixir
iex> Akin.compare("weird", "wierd")
%{
  bag_distance: 1.0,
  chunk_set: 0.23,
  dice_sorensen: 0.25,
  double_metaphone: 1.0,
  double_metaphone_chunks: 1.0,
  hamming: 0.6,
  jaccard: 0.14,
  jaro_winkler: 0.94,
  levenshtein: 0.6,
  metaphone: 1.0,
  ngram: 0.25,
  overlap: 0.25,
  sorted_chunks: 0.93,
  tversky: 0.14
}
iex> Akin.compare("beginning", "begining")
%{
  bag_distance: 0.89,
  chunk_set: 0.23,
  dice_sorensen: 0.93,
  double_metaphone: 1.0,
  double_metaphone_chunks: 1.0,
  hamming: 0.0,
  jaccard: 0.88,
  jaro_winkler: 0.95,
  levenshtein: 0.89,
  metaphone: 1.0,
  ngram: 0.88,
  overlap: 1.0,
  sorted_chunks: 1.0,
  tversky: 0.88
}
iex> Akin.compare("Duane", "Dwayne")
%{
  bag_distance: 0.67,
  chunk_set: 0.21,
  dice_sorensen: 0.22,
  double_metaphone: 1.0,
  double_metaphone_chunks: 1.0,
  hamming: 0.0,
  jaccard: 0.13,
  jaro_winkler: 0.84,
  levenshtein: 0.67,
  metaphone: 0.0,
  ngram: 0.2,
  overlap: 0.25,
  sorted_chunks: 0.82,
  tversky: 0.13
}
```

When the strings contain spaces, such as full names, you can narrow the results to only algorithms which take
substring matches into account.

```elixir
iex> Akin.smart_compare("Alice Pleasance Liddel", "Alice P. Liddel")
%{
  chunk_set: 0.64,
  double_metaphone_chunks: 0.67,
  overlap: 1.0,
  sorted_chunks: 0.85
}
iex> Akin.compare("Alice Pleasance Liddel", "Alice Liddel")
%{
  bag_distance: 0.55,
  chunk_set: 0.64,
  dice_sorensen: 0.69,
  double_metaphone: 0.0,
  double_metaphone_chunks: 1.0,
  hamming: 0.0,
  jaccard: 0.53,
  jaro_winkler: 0.89,
  levenshtein: 0.55,
  metaphone: 0.0,
  ngram: 0.53,
  overlap: 1.0,
  sorted_chunks: 0.85,
  tversky: 0.53
}
iex> Akin.smart_compare("Alice Pleasance Liddel", "Alice Liddel")
%{
  chunk_set: 0.64,
  double_metaphone_chunks: 1.0,
  overlap: 1.0,
  sorted_chunks: 0.85
}
iex> Akin.compare("Alice Pleasance Liddel", "Liddel, Alice")
%{
  bag_distance: 0.55,
  chunk_set: 0.64,
  dice_sorensen: 0.21,
  double_metaphone: 0.0,
  double_metaphone_chunks: 1.0,
  hamming: 0.0,
  jaccard: 0.12,
  jaro_winkler: 0.68,
  levenshtein: 0.35,
  metaphone: 0.0,
  ngram: 0.16,
  overlap: 0.3,
  sorted_chunks: 0.85,
  tversky: 0.21
}
iex> Akin.smart_compare("Alice Pleasance Liddel", "Liddel, Alice")
%{
  chunk_set: 0.64,
  double_metaphone_chunks: 1.0,
  overlap: 0.3,
  sorted_chunks: 0.85
}
```

When the strings contain spaces, such as full names, you can narrow the results to only algorithms which take
substring matches into account with `smart_compare/2` or `smart_compare/3`.

```elixir
iex> Akin.compare("Alice Pleasance Liddel", "Alice P. Liddel")
%{
  bag_distance: 0.6,
  chunk_set: 0.64,
  dice_sorensen: 0.73,
  double_metaphone: 0.0,
  double_metaphone_chunks: 0.67,
  hamming: 0.0,
  jaccard: 0.58,
  jaro_winkler: 0.9,
  levenshtein: 0.6,
  metaphone: 0.0,
  ngram: 0.58,
  overlap: 1.0,
  sorted_chunks: 0.85,
  tversky: 0.58 
}
iex> Akin.smart_compare("Alice Pleasance Liddel", "Alice P. Liddel")
%{
  chunk_set: 0.64,
  double_metaphone_chunks: 0.67,
  overlap: 1.0,
  sorted_chunks: 0.85
}
iex> Akin.compare("Alice Pleasance Liddel", "Alice Liddel")
%{
  bag_distance: 0.55,
  chunk_set: 0.64,
  dice_sorensen: 0.69,
  double_metaphone: 0.0,
  double_metaphone_chunks: 1.0,
  hamming: 0.0,
  jaccard: 0.53,
  jaro_winkler: 0.89,
  levenshtein: 0.55,
  metaphone: 0.0,
  ngram: 0.53,
  overlap: 1.0,
  sorted_chunks: 0.85,
  tversky: 0.53
}
iex> Akin.smart_compare("Alice Pleasance Liddel", "Alice Liddel")
%{
  chunk_set: 0.64,
  double_metaphone_chunks: 1.0,
  overlap: 1.0,
  sorted_chunks: 0.85
}
iex> Akin.compare("Alice Pleasance Liddel", "Liddel, Alice")
%{
  bag_distance: 0.55,
  chunk_set: 0.64,
  dice_sorensen: 0.21,
  double_metaphone: 0.0,
  double_metaphone_chunks: 1.0,
  hamming: 0.0,
  jaccard: 0.12,
  jaro_winkler: 0.68,
  levenshtein: 0.35,
  metaphone: 0.0,
  ngram: 0.16,
  overlap: 0.3,
  sorted_chunks: 0.85,
  tversky: 0.21
}
iex> Akin.smart_compare("Alice Pleasance Liddel", "Liddel, Alice")
%{
  chunk_set: 0.64,
  double_metaphone_chunks: 1.0,
  overlap: 0.3,
  sorted_chunks: 0.85
}
```

Comparing Words and Words with spaces (i.e. names) 
```elixir
iex> Akin.compare("Alice Pleasance Liddell", "Alice P. Liddell")
%{
  bag_distance: 0.62,
  chunk_set: 0.64,
  dice_sorensen: 0.75,
  double_metaphone: 0.0,
  double_metaphone_chunks: 0.67,
  hamming: 0.0,
  jaccard: 0.6,
  jaro_winkler: 0.91,
  levenshtein: 0.62,
  metaphone: 0.0,
  ngram: 0.6,
  overlap: 1.0,
  sorted_chunks: 0.85,
  tversky: 0.6 
}
iex> Akin.compare("Alice Pleasance Liddell", "Alice Liddell")
%{
  bag_distance: 0.57,
  chunk_set: 0.64,
  dice_sorensen: 0.71,
  double_metaphone: 0.0,
  double_metaphone_chunks: 1.0,
  hamming: 0.0,
  jaccard: 0.55,
  jaro_winkler: 0.9,
  levenshtein: 0.57,
  metaphone: 0.0,
  ngram: 0.55,
  overlap: 1.0,
  sorted_chunks: 0.85,
  tversky: 0.55
}
iex> Akin.compare("Alice Hargreaves", "Alice Liddell")
%{
  bag_distance: 0.4,
  chunk_set: 0.55,
  dice_sorensen: 0.32,
  double_metaphone: 0.0,
  double_metaphone_chunks: 0.5,
  hamming: 0.0,
  jaccard: 0.19,
  jaro_winkler: 0.78,
  levenshtein: 0.4,
  metaphone: 0.0,
  ngram: 0.29,
  overlap: 0.36,
  sorted_chunks: 0.64,
  tversky: 0.19
}
```

Comparing Words with accents
```elixir
iex> Akin.compare("Hubert Łępicki", "Hubert Lepicki")
%{
  bag_distance: 0.92,
  chunk_set: 0.65,
  dice_sorensen: 0.83,
  double_metaphone: 0.0,
  double_metaphone_chunks: 0.5,
  hamming: 0.0,
  jaccard: 0.71,
  jaro_winkler: 0.97,
  levenshtein: 0.92,
  metaphone: 0.0,
  ngram: 0.83,
  overlap: 0.83,
  sorted_chunks: 0.95,
  tversky: 0.71
}
```

## Algorithms Independently with `compare_using/2`

Use a single algorithm to comparing two names: "Oscar-Claude Monet" and "Monet, Claude". The return value is a float or a binary depending on the algorithm.

```elixir
iex> left = "Alice P. Liddel"
iex> right = "Liddel, Alice"
iex> Akin.compare_using("jaro_winkler", left, right)
0.71
iex> Akin.compare_using("levenshtein", left, right) 
0.33
iex> Akin.compare_using("metaphone", left, right)
0.0
iex> Akin.compare_using("double_metaphone", left, right)  
0.0
iex> Akin.compare_using("double_metaphone._chunks", left, right)
1.0
iex> Akin.compare_using("chunk_set", left, right)
0.74
iex> Akin.compare_using("sorted_chunks", left, right)
0.97
iex> Akin.compare_using("tversky", left, right)
0.4
```

Closer look at the Double Metaphone Chunks

```elixir
iex> left = "Alice Liddel"
iex> right = "Liddel, Alice"
iex> Akin.compare_using("double_metaphone._chunks", left, right)
1.0
iex> right = "Alice P Liddel"
iex> Akin.compare_using("double_metaphone._chunks", left, right)
1.0
iex> right = "Alice Hargreaves"
iex> Akin.compare_using("double_metaphone._chunks", left, right)
0.5
iex> right = "Alice's Adventures in Wonderland"
iex> Akin.compare_using("double_metaphone._chunks", left, right)
0.5
```

The default ngram size for the algorithms is 2. You can change by setting 
a value in opts.

```elixir
iex> left = "Alice P. Liddel"
iex> right = "Liddel, Alice"
iex> Akin.compare_using("tversky", left, right)
0.4
iex> Akin.compare_using("tversky", left, right, [ngram_size: 1])
0.8
iex> Akin.compare_using("tversky", left, right, [ngram_size: 3])
0.0
```

The default match strictness is "normal" You change it by setting 
a value in opts. Currently it only affects the outcomes of the `chunk_set` and
`double_metaphone` algorithms

```elixir
iex> left = "Alice in Wonderland"
iex> right = "Alice's Adventures in Wonderland"
iex> Akin.compare_using("chunk_set", left, right)
0.64
iex> Akin.compare_using("chunk_set", left, right, [threshold: "weak"])
0.85
iex> left = "which way"
iex> right = "whitch way"
iex> Akin.compare_using("double_metaphone", left, right, [threshold: "weak"])
1.0
iex> Akin.compare_using("double_metaphone", left, right, [threshold: "strict"])
0.0
```
TODO: add ML info

To see the metaphone results, call the phonetic algorithm directly.

```elixir
iex> Akin.Metaphone.Metaphone.compute("virginia")
"frjn"
iex> Akin.Metaphone.Metaphone.compute("woolf")
"wlf"
iex> Akin.Metaphone.Metaphone.compute("woolfe")
"wlf"
iex> Akin.Metaphone.Double.parse("virginia")
{"frjn", "frkn"}
iex> Akin.Metaphone.Double.parse("woolfe") 
{"alf", "flf"}
```

## Max scores with `max/2` 

Compare two strings using all algorithms. From the metrics returned through the comparision, return only the highest algorithm scores.

```elixir
iex> Akin.max("weird", "wierd")
[
  bag_distance: 1.0,
  double_metaphone: 1.0,
  double_metaphone_chunks: 1.0,
  metaphone: 1.0
]
iex> left = "Alice P. Liddel"
iex> right = "Alice Liddel"
iex> Akin.max(left, right)
[double_metaphone_chunks: 1.0]

## Name Disambiguation with `match/2` 

_UNDER DEVELOPMENT_

Identity is the challenge of author name disambiguation (AND). The aim of AND is to match an author's name to that author when the author appears in a list of many authors. Complexity arises from homonymity (many people with the same name) and synonymity (when one person uses different forms/spellings of their name in publications). 

Given the name of an author which is divided into the given, middle, and family name parts (i.e. "Virginia", nil, "Woolf") and a list of possible matching author names (i.e. ["W Shakespeare", "L. M Montgomery", "V. Woolf", "V White", "Viginia Wolverine", "Virginia Woolfe"]), find and return the matches for the author in the list. 

Matches are determined by `compare/3` to return the match scores of each permutation and `max/1` to find the highest of those scores. If the highest scores are greater than or equal to 0.9, they considered a match and returned in the list.

```elixir
iex> Akin.match("Virginia Woolf", ["W Shakespeare", "L. M Montgomery", "V. Woolf", "V White", "Viginia Wolverine", "Virginia Woolfe"])
["virginia woolfe", "v woolf"]
```

# Algorithms
_Return: float_

## Bag Distance

The bag distance is a cheap distance measure which always returns a distance smaller or equal to the edit distance. It's meant to be an efficient approximation of the distance between two strings to quickly rule out strings that are largely different.  

## Chunk Set

:bag_distance
Splits the strings on spaces, sorts, re-joins, and then determines Jaro-Winkler distance. Best when the strings contain irrelevent substrings. 

## Sørensen–Dice 

:dice_sorensen
Sørensen–Dice coefficient is calculated using bigrams. The equation is `2nt / nx + ny` where nx is the number of bigrams in string x, ny is the number of bigrams in string y, and nt is the number of bigrams in both strings. For example, the bigrams of `night` and `nacht` are `{ni,ig,gh,ht}` and `{na,ac,ch,ht}`. They each have four and the intersection is `ht`. 

``` (2 · 1) / (4 + 4) = 0.25 ```

## Hamming Distance

:hamming
The Hamming distance between two strings of equal length is the number of positions at which the corresponding letters are different. Returns the percentage of change needed to the left string of the comparison of one string (left) with another string (right). Returns 0.0 if the strings are not the same length. Returns 1.0 if the string are equal.

## Jaccard Similarity

:jaccard
Calculates the similarity of two strings as the size of the intersection divided by the size of the union. Default ngram: 2.

## Jaro-Winkler Similarity

:jaro_winkler
Jaro-Winkler calculates the edit distance between two strings. A score of one denotes equality. Unlike the Jaro Similarity, it modifies the prefix scale to gives a more favorable rating to strings that match from the beginning.

## Levenshtein Distance

:levenshtein
Compare two strings for their Levenshtein score. The score is determined by finding the edit distance: the minimum number of single-character edits needed to change one word into the other. The distance is substracted from 1.0 and then divided by the longest length between the two strings. 

## Metaphone 

:metaphone
Compares two strings by converting each to an approximate phonetic representation in ASCII and then comparing those phoenetic representations. Returns a 1 if the phoentic representations are an exact match.

## Double Metaphone 

Calculates the [Double Metaphone Phonetic Algorithm](https://xlinux.nist.gov/dads/HTML/doubleMetaphone.html) metric of two strings. The return value is based on the match threshold: strict, strong, normal (default), or weak. 

  * "strict": both encodings for each string must match
  * "strong": the primary encoding for each string must match
  * "normal": the primary encoding of one string must match either encoding of other string (default)
  * "weak":   either primary or secondary encoding of one string must match one encoding of other string

## Sorted Chunked Double Metaphone

Iterate over the cartesian product of the two lists sending each element through
the Double Metaphone using all strictness thresholds until a true value is found
in the list of returned booleans from the Double Metaphone algorithm. Return the 
percentage of true values found. If true is never returned, return 0. Increases  
accuracy for search terms containing more than one word.

## N-Gram Similarity

:ngram
Calculates the ngram distance between two strings. Default ngram: 2.

## Overlap Metric

:overlap
Uses the Overlap Similarity metric to compare two strings by tokenizing the strings and measuring their overlap. Default ngram: 1.

## Sorted Chunks

:sorted_chunks
Sorts substrings by words, compares the sorted strings in pairs, and returns the maximum ratio. If one strings is signficantly longer than the other, this method will compare matching substrings only. 

## Tversky 

:tversky
A generalization of Sørensen–Dice and Jaccard.

# In Development

#### Compare results to Python's FuzzyWuzzy library using [ErlPort](http://erlport.org/)
#### Author Name Disambiguation (see lib/akin/and.ex for developments)

# Resources & Credit

[Disambiguation Datasets](https://github.com/dhwajraj/dataset-person-name-disambiguation)
[Double Metaphone in python](https://github.com/oubiwann/metaphone/blob/master/metaphone/metaphone.py)
[Fuzzy Compare](https://github.com/patrickdet/fuzzy_compare)
[Python Fuzzy Wuzzy (2011)](https://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/)
[ML Authur Block Dismabiguation](https://github.com/helenamihaljevic/ads_author_disambiguation)
[ML Author Name Disambiguation](https://medium.com/ai2-blog/s2and-an-improved-author-disambiguation-system-for-semantic-scholar-d09380da30e6)
[Record Linking](https://en.wikipedia.org/wiki/Record_linkage)
[The Fuzz](https://github.com/smashedtoatoms/the_fuzz)

# To Do

* Add Damerau-Levenshtein algorithm
  * [Damerau-Levenshtein](https://en.wikipedia.org/wiki/Damerau-Levenshtein_distance)
  * [Examples](https://datascience.stackexchange.com/questions/60019/damerau-levenshtein-edit-distance-in-python)
* Add Caverphone algorithm
  * [Caverphone](https://en.wikipedia.org/wiki/Caverphone)
  * [Research](https://caversham.otago.ac.nz/files/working/ctp150804.pdf)
  * [Example](https://gist.github.com/kastnerkyle/a697d4e762fa8f53c70eea7bc712eead)
