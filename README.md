Akin
=======

Akin is a collection of string comparison algorithms for Elixir. This solution was born of a [Record Linking](https://en.wikipedia.org/wiki/Record_linkage) project. It combines and modifies [The Fuzz](https://github.com/smashedtoatoms/the_fuzz) and [Fuzzy Compare](https://github.com/patrickdet/fuzzy_compare). Algorithms can be called independently or in total to return a map of metrics. This library was built to facilitiate the disambiguation of names but can be used to compare any two binaries.

## Installation

Add a dependency in your mix.exs:

```elixir
deps: [{:akin, "~> 1.0"}]
```

## Author Name Disambiguation

_UNDER DEVELOPMENT_

Identity is the challenge of author name disambiguation (AND). The aim of AND is to match an author's name to that author when the author appears in a list of many authors. Complexity arises from homonymity (many people with the same name) and synonymity (when one person uses different forms/spellings of their name in publications). 

Given the name of an author which is divided into the given, middle, and family name parts (i.e. "Virginia", nil, "Woolf") and a list of possible matching author names (i.e. ["W Shakespeare", "L. M Montgomery", "V. Woolf", "V White", "Viginia Wolverine", "Virginia Woolfe"]), find and return the matches for the author in the list using a combination and hierarchy of string comparison algorithms.

```elixir
iex> Akin.match("Virginia Woolf", ["W Shakespeare", "L. M Montgomery", "V. Woolf", "V White", "Viginia Wolverine", "Virginia Woolfe"])
["virginia woolfe", "v woolf"]
```

## Examples
### All Algortithms Together

Compare two strings using all of the available algorithms. The return value is a map of scores for each algorithm.

Comparing the two names: "Oscar-Claude Monet" and "Monet, Claude"

```elixir
iex> Akin.compare("Oscar-Claude Monet", "Monet, Claude")
%{
  bag_distance: 0.69,
  chunk_set: 1.0,
  dice_sorensen: 0.08,
  double_metaphone: 0.0,
  double_metaphone_chunks: 1.0,
  jaccard: 0.04,
  jaro_winkler: 0.66,
  levenshtein: 0.38,
  metaphone: 0.0,
  ngram: 0.07,
  overlap: 0.1,
  sorted_chunks: 0.9,
  tversky: 0.13
}
```

Comparing the two names: "Claude Monet" and "Edouard Manet"
```elixir
iex> Akin.compare("Claude Monet", "Edouard Manet")
%{
  bag_distance: 0.75,
  chunk_set: 0.71,
  dice_sorensen: 0.19,
  double_metaphone: 0.0,
  double_metaphone_chunks: 1.0,
  jaccard: 0.11,
  jaro_winkler: 0.71,
  levenshtein: 0.42,
  metaphone: 0.0,
  ngram: 0.18,
  overlap: 0.2,
  sorted_chunks: 0.71,
  tversky: 0.11
}
```

Comparing the two words: "tomato" and "tomahto"
```elixir
iex> Akin.compare("tomato", "tomahto")
%{
  bag_distance: 0.86,
  chunk_set: 0.95,
  dice_sorensen: 0.73,
  double_metaphone: 1.0,
  double_metaphone_chunks: 1.0,
  jaccard: 0.57,
  jaro_winkler: 0.97,
  levenshtein: 0.86,
  metaphone: 0.0,
  ngram: 0.67,
  overlap: 0.8,
  sorted_chunks: 0.95,
  tversky: 0.57
}
```

```elixir
iex> Akin.compare("Hubert Łępicki", "Hubert Lepicki")
%{
  bag_distance: 0.92,
  chunk_set: 0.95,
  dice_sorensen: 0.83,
  double_metaphone: 0.0,
  double_metaphone_chunks: 1.0,
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

### Algorithms Independently

Use a single algorithm to comparing two names: "Oscar-Claude Monet" and "Monet, Claude". The return value is a float or a binary depending on the algorithm.

```elixir
iex> a = "Oscar-Claude Monet"
iex> b = "Monet, Claude"
iex> Akin.compare_using("jaro_winkler", a, b)
0.66

iex> Akin.compare_using("levenshtein", a, b) 
0.38

iex> Akin.compare_using("metaphone", a, b)
0.0

iex> Akin.compare_using("double_metaphone._chunks", a, b)
1.0

iex> Akin.compare_using("chunk_set", a, b)
1.0

iex> Akin.compare_using("sorted_chunks", a, b)
0.9

iex> Akin.compare_using("tversky", a, b)
0.13
```

The default ngram size for the algorithms is 2. You can change it for particular algorithms by requesting it in the options.

```elixir
iex> a = "Oscar-Claude Monet"
iex> b = "Monet, Claude"
iex> opts = [ngram_size: 1]
Akin.compare_using("tversky", a, b, opts)
0.17
```
TODO: add ML info
TODO: document the Double Metaphone Algo
TODO: document the chunked Double Metaphone Algo
TODO: document the match function
TODO: document the max function


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
The Hamming distance between two strings of equal length is the number of positions at which the corresponding letters are different. Returns nil if the words are not the same length.

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

[Double Metaphone in python](https://github.com/oubiwann/metaphone/blob/master/metaphone/metaphone.py)
