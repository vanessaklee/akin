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
iex> Akin.And.match("Virginia", nil, "Woolf", ["W Shakespeare", "L. M Montgomery", "V. Woolf", "V White", "Viginia Wolverine", "Virginia Woolfe"])
["V. Woolf", "Virginia Woolfe"]
```

Run tests against Aminer author disambiguation dataset by using:
```elixir
mix test test/similarity/and_test.exs 
```

## Examples
### All Algortithms Together

Compare two strings using all of the available algorithms. The return value is a map of scores for each algorithm.


Comparing the two names: "Oscar-Claude Monet" and "Monet, Claude"
```elixir
iex> Akin.compare("Oscar-Claude Monet", "Monet, Claude")
%{
  bag_distance: 0.6666666666666667,
  chunk_set: 1.0,
  dice_sorensen: 0.13793103448275862,
  jaccard: 0.07407407407407407,
  jaro_winkler: 0.6032763532763533,
  levenshtein: 13,
  metaphone_exact: 1,
  n_gram: 0.11764705882352941,
  overlap: 0.16666666666666666,
  sorted_chunks: 0.8958333333333334,
  string_compare: 1.0,
  tversky: 0.15384615384615385
}
```

Comparing the two names: "Claude Monet" and "Edouard Manet"
```elixir
iex> Akin.compare("Claude Monet", "Edouard Manet")
%{
  bag_distance: 0.6923076923076923,
  chunk_set: 0.7079124579124579,
  dice_sorensen: 0.2608695652173913,
  jaccard: 0.15,
  jaro_winkler: 0.6773504273504273,
  levenshtein: 7,
  metaphone_exact: 1,
  metaphone_scores: %{
    bag_distance: 0.625,
    chunk_set: 0.8333333333333334,
    jaro_winkler: 0.7130952380952381,
    levenshtein: 3,
    sorted_chunks: 0.6626984126984127
  },
  n_gram: 0.25,
  overlap: 0.2727272727272727,
  sorted_chunks: 0.7079124579124579,
  string_compare: 0.7079124579124579,
  tversky: 0.15
}
```

Comparing the two words: "tomato" and "tomahto"
```elixir
iex> Akin.compare("tomato", "tomahto")
%{
  bag_distance: 0.8571428571428572,
  chunk_set: 0.9523809523809524,
  dice_sorensen: 0.7272727272727273,
  jaccard: 0.5714285714285714,
  jaro_winkler: 0.9714285714285714,
  levenshtein: 1,
  metaphone_exact: 0,
  metaphone_scores: %{
    bag_distance: 0.75,
    chunk_set: 0.9166666666666666,
    jaro_winkler: 0.9333333333333333,
    levenshtein: 1,
    sorted_chunks: 0.9166666666666666
  },
  n_gram: 0.6666666666666666,
  overlap: 0.8,
  sorted_chunks: 0.9523809523809524,
  string_compare: 0.9714285714285714,
  tversky: 0.5714285714285714
}
```

```elixir
iex> Akin.compare("Hubert Łępicki", "Hubert Lepicki")
%{
  bag_distance: 0.8571428571428572,
  chunk_set: 0.8974358974358975,
  dice_sorensen: 0.7692307692307693,
  jaccard: 0.625,
  jaro_winkler: 0.9428571428571428,
  levenshtein: 2,
  metaphone_exact: 1,
  metaphone_scores: %{
    bag_distance: 0.625,
    chunk_set: 1.0,
    jaro_winkler: 0.925,
    levenshtein: 3,
    sorted_chunks: 0.8571428571428571
  },
  n_gram: 0.7692307692307693,
  overlap: 0.7692307692307693,
  sorted_chunks: 0.8974358974358975,
  string_compare: 0.9384615384615385,
  tversky: 0.625
}
```

### Algorithms Independently

Use a single algorithm to comparing two names: "Oscar-Claude Monet" and "Monet, Claude". The return value is a float or a binary depending on the algorithm.

```elixir
iex> a = "Oscar-Claude Monet"
iex> b = "Monet, Claude"
iex> Akin.compare_using(:jaro_winkler, a, b)
0.6032763532763533

iex> Akin.compare_using(:levenshtein, a, b) 
13

iex> Akin.compare_using(:metaphone_exact, a, b)
1

iex> Akin.compare_using(:chunk_set, a, b)
1.0

iex> Akin.compare_using(:sorted_chunks, a, b)
0.8958333333333334

iex> Akin.compare_using(:tversky, a, b)
0.15384615384615385
```

The default ngram size for the algorithms is 2. You can change it for particular algorithms by requesting it in the options.

```elixir
iex> a = "Oscar-Claude Monet"
iex> b = "Monet, Claude"
iex> opts = [ngram_size: 1]
Akin.compare_using(:tversky, a, b, opts)
0.2222222222222222
```

Currently, the metaphone scores are limited. The two words being compared must include the same number of parts when the words are split. 

```elixir
iex> a = "Oscar-Claude Monet"
iex> b = "Monet, Claude"
iex> Akin.compare_using(:metaphone_scores, a, b)
nil
iex> a = "Claude Monet"
iex> b = "Edouard Manet"
iex> Akin.compare_using(:metaphone_scores, a, b)
%{
  bag_distance: 0.625,
  chunk_set: 0.8333333333333334,
  jaro_winkler: 0.7130952380952381,
  levenshtein: 3,
  sorted_chunks: 0.6626984126984127
}
iex> a = "virginia woolfe"
iex> b = "Virginia Woolf"
iex> Akin.compare_using(:metaphone_scores, a, b)
Akin.compare_using(:metaphone_scores, a, b)   
%{
  bag_distance: 1.0,
  chunk_set: 1.0,
  jaro_winkler: 1.0,
  levenshtein: 1,
  sorted_chunks: 1.0
}
```

To see the metaphone results, call the phonetic algorithm directly.

```elixir
iex> Akin.Phonetic.MetaphoneAlgorithm.compute("virginia")
"frjn"
iex> Akin.Phonetic.MetaphoneAlgorithm.compute("woolf")
"wlf"
iex> Akin.Phonetic.MetaphoneAlgorithm.compute("woolfe")
"wlf"
```

# Algorithms

## Bag Distance

_Return: float_
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
Compares two strings by calculating the minimum number of single-character edits needed to change one string into the other. 

## Metaphone Exact

:metaphone_exact
Compares two strings by converting each to an approximate phonetic representation in ASCII and then comparing those phoenetic representations. Returns a 1 if the phoentic representations are an exact match.

## Metaphone Scores

:metaphone_scores
Compares two strings by converting each to an approximate phonetic representation in ASCII and then comparing those phoenetic representations. Returns a map of algorithm scores for comparing the phoenetic representations. Currently compares using [:bag_distance, :jaro_winkler, :levenshtein, :chunk_set, :sorted_chunks].

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
A generalization of Sørensen–Dice and Jaccard Similarity.

# In Development

#### Compare results to Python's FuzzyWuzzy library using [ErlPort](http://erlport.org/)
#### Author Name Disambiguation (see lib/akin/and.ex for developments)
#### Double Metaphone (converting from [python](https://github.com/oubiwann/metaphone/blob/master/metaphone/metaphone.py))
