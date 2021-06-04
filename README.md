Akin
=======

Akin is a collection of string comparison algorithms for Elixir. This solution was born of a [Record Linking](https://en.wikipedia.org/wiki/Record_linkage) project. It combines and modifies [The Fuzz](https://github.com/smashedtoatoms/the_fuzz) and [Fuzzy Compare](https://github.com/patrickdet/fuzzy_compare). Algorithms can be called independently or in total to return a map of metrics. This library was built to facilitiate the disambiguation of names but can be used to compare any two binaries.

## Installation

Add a dependency in your mix.exs:

```elixir
deps: [{:akin, "~> 1.0"}]
```

## Examples

### All Algortithms

Compare two strings using all of the available algorithms. The return value is a map of scores for each algorithm.


Comparing the two names: "Oscar-Claude Monet" and "Monet, Claude"
```elixir
Akin.compare("Oscar-Claude Monet", "Monet, Claude")
%{
  bag_distance: 0.6666666666666667,
  chunk_set: 0.95,
  dice_sorensen: nil,
  hamming: nil,
  jaccard: nil,
  jaro_winkler: 0.6032763532763533,
  levenshtein: 13,
  metaphone: true,
  n_gram: nil,
  overlap: 0.15384615384615385,
  sorted_chunks: 0.8510416666666667,
  tversky: 0.2222222222222222
}
```

Comparing the two names: "Oscar-Claude Monet" and "Edouard Manet"
```elixir
Akin.compare("Oscar-Claude Monet", "Edouard Manet")
%{
  bag_distance: 0.6111111111111112,
  chunk_set: 0.6518055555555556,
  dice_sorensen: nil,
  hamming: nil,
  jaccard: nil,
  jaro_winkler: 0.6749287749287749,
  levenshtein: 11,
  metaphone: true,
  n_gram: nil,
  overlap: 0.5384615384615384,
  sorted_chunks: 0.6518055555555556,
  tversky: 0.4375
}
```

Comparing the two words: "tomato" and "tomahto"
```elixir
Akin.compare("tomato", "tomahto")
%{
  bag_distance: 0.8571428571428572,
  chunk_set: 0.9047619047619048,
  dice_sorensen: nil,
  hamming: nil,
  jaccard: nil,
  jaro: 0.9523809523809524,
  jaro_winkler: 0.9714285714285714,
  levenshtein: 1,
  metaphone: false,
  n_gram: nil,
  overlap: 1.0,
  sorted_chunks: 0.9047619047619048,
  tversky: 0.8571428571428571
}
```

### One Algorithm

Use a single algorithm to comparing two names: "Oscar-Claude Monet" and "Monet, Claude". The return value is a float or a binary depending on the algorithm.
```elixir
a = "Oscar-Claude Monet"
b = "Monet, Claude"
opts = %{}
Akin.compare_using(:jaro_winkler, a, b, opts)
0.6032763532763533

Akin.compare_using(:levenshtein, a, b, opts) 
13

Akin.compare_using(:metaphone, a, b, opts)
true

Akin.compare_using(:chunk_set, a, b, opts)
0.95

Akin.compare_using(:sorted_chunks, a, b, opts)
0.8510416666666667

Akin.compare_using(:tversky, a, b, opts)
0.22222222222222\
```

# Algorithms

## Bag Distance

_Return: float_
The bag distance is a cheap distance measure which always returns a distance smaller or equal to the edit distance. It's meant to be an efficient approximation of the distance between two strings to quickly rule out strings that are largely different.  

## Chunk Set

_Return: float_
Splits the strings on spaces, sorts, re-joins, and then determines Jaro-Winkler distance. Best when the strings contain irrelevent substrings. 

## Sørensen–Dice 

_Return: float_

Sørensen–Dice coefficient is calculated using bigrams. The equation is `2nt / nx + ny` where nx is the number of bigrams in string x, ny is the number of bigrams in string y, and nt is the number of bigrams in both strings. For example, the bigrams of `night` and `nacht` are `{ni,ig,gh,ht}` and `{na,ac,ch,ht}`. They each have four and the intersection is `ht`. 

``` (2 · 1) / (4 + 4) = 0.25 ```

## Hamming Distance

_Return: int | nil_

The Hamming distance between two strings of equal length is the number of positions at which the corresponding letters are different. Returns nil if the words are not the same length.

## Jaccard Similarity

_Return: float_

Calculates the similarity of two strings as the size of the intersection divided by the size of the union. Default ngram: 2.

## Jaro-Winkler Similarity

_Return: float | nil_

Jaro-Winkler calculates the edit distance between two strings. A score of one denotes equality. Unlike the Jaro Similarity, it modifies the prefix scale to gives a more favorable rating to strings that match from the beginning.

## Levenshtein Distance

_Return: int_

Compares two strings by calculating the minimum number of single-character edits needed to change one string into the other. 

## Metaphone Algorithm

_Return: true | false_

Compares two strings by converting each to an approximate phonetic representation in ASCII and then comparing those phoenetic representations.

## N-Gram Similarity

_Return: float_

Calculates the ngram distance between two strings. Default ngram: 2.

## Overlap Metric

_Return: float_

Uses the Overlap Similarity metric to compare two strings by tokenizing the strings and measuring their overlap. Default ngram: 1.

## Sorted Chunks

_Return: float_

Sorts substrings by words, compares the sorted strings in pairs, and returns the maximum ratio. If one strings is signficantly longer than the other, this method will compare matching substrings only. 

## Tversky 

_Return: float_

A generalization of Sørensen–Dice and Jaccard Similarity.

# In Progress

### Double Metaphone (converting from [python](https://github.com/oubiwann/metaphone/blob/master/metaphone/metaphone.py))
