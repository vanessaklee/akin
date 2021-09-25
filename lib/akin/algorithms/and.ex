defmodule Akin.And do
  @moduledoc """
  Module exploring author name disambigution.

  ### UNDER DEVELOPMENT ###
  """
  alias Akin.Levenshtein
  alias Akin.Util

  @min_bag_distance 0.5
  @jaro_min 0.9
  @jaro_mid 0.85
  @lev_min 0.65
  @parts_min 0.9
  @parts_mid 0.80
  @string_min 0.9
  @string_mid 0.85
  @string_compare_bottom_threshold 0.75
  @jaro_threshold 0.4
  @lev_threshold 0.2
  @min_compare_average 0.875

  def min_bag_distance, do: @min_bag_distance

  @doc """
  The logic for determining whether a comparison score passes our definition of a match. That definition is as follows.

  - TRUE if an exact string match
  - TRUE if jaro > @jaro_min && lev > @lev_min && parts compare > @parts_min && string > @string_min
  - TRUE if (jaro + lev + parts compare + string compare)/4 > @min_compare_average
  - TRUE if string compare >= @string_mid && jaro >= @jaro_mid && parts >= @parts_mid
  - TRUE if parts compare == 1.0 && (string compare >= @string_mid)
  - FALSE for any other condition
  """
  def pass?(%{bag_distance: distance}) when distance < @min_bag_distance, do: false
  def pass?(%{bag_distance: _, exact: true, jaro: _, levenshtein: _, parts_compare: _, string_compare: _}), do: true
  def pass?(%{bag_distance: _, exact: _, jaro: jaro, levenshtein: lev, parts_compare: parts, string_compare: string}) do
    if jaro > @jaro_min && lev > @lev_min && parts > @parts_min && string > @string_min do
      true
    else
      if (jaro + lev + parts + string)/4 > @min_compare_average do
        true
      else
        if string >= @string_mid && jaro >= @jaro_mid && parts >= @parts_mid do
          true
        else
          # this condition will catch matches for a scholar against an author with an initial for a given name, i.e. "author brown" will match "a brown"
          # and "chris" will match "christopher"
          if parts == 1.0 && (string >= @string_mid) do
            true
          else
            false
          end
        end
      end
    end
  end

  @doc """
  Determine if any names in the list are similar to the author's name. Accepts an author given name, middle name, and family name along with a list of to match against that author.
  Example: "Virginia Woolf" and ["W. Shakespear", "L. M Montgomery", "V. Woolf"].

  Comparison is determined by enumerating over the list of names.

  1. If exact match, it is a match
  3. Determine bag distance between each name and the scholar
     a. Less than @min_bag_distance (0.5): not a match, done
     b. Equal to or greater than @min_bag_distance (0.5): possible match, continue
  4. Enumerate over the names which pass the bag distance criteria
  5. Split the scholar name into name parts (i.e. given, middle, family)
     a. If scholar's given name is only an initial (i.e. `J` not `John`)
        1. Split the author name into name parts (i.e. given, middle, family)
        2. Use the first initial of the author's given name to compare to the scholar, for example
           a. Scholar = "J Doe"
           b. Author = "John Doe" converted to "J Doe"
           c. Compare scholar "J Doe" to author "J Doe" using compare/3
     b. If scholar's given name is not an initial (i.e. `John` not `J`)
        1. Compare scholar to author using compare/3
  6. Send the scores returned by compare/3 to pass?/1
  7. If score pass?/1, it is a match

  Return a list of the authors matched.
  """
  def match(given, middle, family, list_of_names) when is_list(list_of_names) do
    scholar = Enum.join([given, middle, family] |> Util.flatten(), " ")
    scholar_permutations = Util.name_parts(given, middle, family)
    Enum.reduce(list_of_names, [], fn author, accumulator ->
      match(accumulator, scholar, scholar_permutations, author)
    end)
  end
  def match(accumulator, scholar, scholar_permutations, author) do
    if String.bag_distance(scholar, author) < @min_bag_distance do
      accumulator
    else
      compare(author, scholar, scholar_permutations)
      |> pass?()
      |> if do
        [accumulator | [author]] |> List.flatten()
      else
        accumulator
      end
    end
  end

  @doc """
  Compare two names. Accepts two strings and a map. The first string representing the author's name and another
  representing the scholar's name. The map is the permutations of the scholar's name.

  Comparison begins with bag distance to weed out obvious mismatches.
  Then moves on to exact match, string compare, jaro, levenshtein, parts compare.

  Preprocessing: both the author and scholar names are normalized. Normalization replaces '.' with whitespace, trims whitespace
  from beginning and end, downcases, and removes symbols.

  1. Determine bag distance between each name and the scholar
     a. Less than @min_bag_distance (0.5): not a match, done
        1. Return %{
            bag_distance: <bag distance score>,
            exact: nil,
            string_compare: nil,
            parts_compare: nil,
            jaro: nil,
            levenshtein: nil
          }
     b. Equal to or greater than @min_bag_distance (0.5): possible match, continue
  3. Determine if author name and scholar are an exact match
     a. True: match, done
        1. Return %{
            bag_distance: <bag distance score>,
            exact: 1,
            string_compare: 1,
            parts_compare: 1,
            jaro: 1,
            levenshtein: 1
          }
     b. False: passible match, continue
  4. Determine string comparison score using Akin.compare(scholar, author)
     a. Less than @string_compare_bottom_threshold (0.75): not a match, done
        1. Return %{
            bag_distance: <bag distance score>,
            exact: 0,
            string_compare: <string compare score>,
            parts_compare: <string compare score>,
            jaro: <string compare score>,
            levenshtein: <string compare score>
          }
     b. Equal to or greater than @string_compare_bottom_threshold (0.75): possible match, continue
  5. Determine jaro using String.jaro_distance(scholar, author) and levenshtein using
     (String.length(scholar) - Levenshtein.distance(scholar, author)) / String.length(scholar)
     a. Less than @jaro_threshold (0.4) and less than @lev_threshold  (0.2): not a match, done
        1. Return %{
            bag_distance: <bag distance score>,
            exact: 0,
            string_compare: <string compare score>,
            parts_compare: 0,
            jaro: <jaro score>,
            levenshtein: <lev score>
          }
     b. Equal to or greater than @jaro_threshold (0.4) and
        equal to or greater than @lev_threshold (0.2): possible match, continue
  6. Determine parts comparison score using parts_match_score(scholar_perms, author) which compares the
     permuations of the scholar's name to the permuations of the author's name; this is very accurate but also
     expensive
  7. Return %{
            bag_distance: <bag distance score>,
            exact: 0,
            string_compare: <string compare score>,
            parts_compare: <parts compare score>,
            jaro: <jaro score>,
            levenshtein: <lev score>
          }

  Return :map
  """
  def compare( %Akin.Primed{string: author},  %Akin.Primed{string: scholar}, scholar_perms)
  when is_binary(author) and is_binary(scholar) do
    compare(Util.prime(author), Util.prime(scholar), scholar_perms)
  end
  def compare(author, scholar, scholar_perms) do
    compare(author, scholar, scholar_perms, String.bag_distance(author, scholar))
  end
  def compare(author, scholar, scholar_perms, bag_distance) when bag_distance >= @min_bag_distance do
    exact = if author == scholar, do: 1, else: 0
    compare(author, scholar, scholar_perms, bag_distance, exact)
  end
  def compare(_author, _scholar, _scholar_perms, bag_distance) do
    %{
      bag_distance: bag_distance,
      exact: nil,
      string_compare: nil,
      parts_compare: nil,
      jaro: nil,
      levenshtein: nil
    }
  end
  def compare(_author, _scholar, _scholar_perms, _bag_distance, nil), do: %{}
  def compare(_author, _scholar, _scholar_perms, bag_distance, 1) do
    %{bag_distance: bag_distance, exact: 1, string_compare: 1, parts_compare: 1, jaro: 1, levenshtein: 1}
  end
  def compare(author, scholar, scholar_perms, bag_distance, exact) do
    string = Akin.compare(scholar, author)
    compare(author, scholar, scholar_perms, bag_distance, exact, string)
  end
  def compare(_author, _scholar, _scholar_perms, bag_distance, exact, string) when
    string < @string_compare_bottom_threshold do
    %{
      bag_distance: bag_distance, exact: exact, string_compare: string,
      parts_compare: string, jaro: string, levenshtein: string
    }
  end
  def compare(author, scholar, scholar_perms, bag_distance, exact, string) do
    jaro = String.jaro_distance(scholar, author)
    lev = (String.length(scholar) - Levenshtein.compare(scholar, author)) / String.length(scholar)
    compare(author, scholar, scholar_perms, bag_distance, exact, string, jaro, lev)
  end
  def compare(_author, _scholar, _scholar_perms, bag_distance, exact, string, jaro, lev) when
    jaro < @jaro_threshold and
    lev < @lev_threshold do
    %{
      bag_distance: bag_distance,
      exact: exact,
      string_compare: string,
      parts_compare: 0,
      jaro: jaro,
      levenshtein: lev
    }
  end
  def compare(author, _scholar, scholar_perms, bag_distance, exact, string, jaro, lev) do
    %{
      bag_distance: bag_distance,
      exact: exact,
      string_compare: string,
      parts_compare: parts_match_score(scholar_perms, author),
      jaro: jaro,
      levenshtein: lev
    }
  end

  @doc """
  Determines if the first parameter exists in the second parameter when the second parameter is a list.
  Return: 1 if true, 0 if false or fails guard
  """
  def score(this, that) when is_list(that) do
    ithis = Util.get_initial(this)
    case that do
      [nthat, ithat] ->
        if nthat == this or ithat == this do
          1
        else
          if Akin.compare(Enum.join(that, " "), this) > @string_min, do: 1, else: 0
        end
      [ithat] ->
        if ithat == ithis, do: 1, else: 0
      _ ->
        if Akin.compare(Enum.join(that, " "), this) > @string_min, do: 1, else: 0
    end
  end
  def score(_, _), do: 0
  def score(this, that, :in) when is_list(that) do
    ithis = Util.get_initial(this)
    case that do
      [nthat, ithat] ->
        if (nthat == this or String.contains?(nthat, this)) or ithat == this, do: 1, else: 0
      [ithat] ->
        if ithat == ithis, do: 1, else: 0
      _ ->
        if Akin.compare(Enum.join(that, " "), this) > @string_min, do: 1, else: 0
    end
  end
  def score(_, _, _), do: 0

  @doc """
  Compare permutations of one name to another name.

  Return 1 if the names are a match; 0 if the names are not a match
  """
  def parts_match_score(%{
    f: f,
    fi: fi,
    l: l,
    li: li,
    mi: mi
  }, comparator) when mi in ["", nil] do
    must_have_firsts = [f, fi] |> Util.flatten()
    must_have_lasts = [l, li] |> Util.flatten()
    parts_match_scoring(String.split(comparator), must_have_firsts, must_have_lasts)
  end
  def parts_match_score(name_parts, comparator) do
    must_have_firsts = [name_parts.f, name_parts.fi] |> Util.flatten()
    must_have_middles = [name_parts.m, name_parts.mi] |> Util.flatten()
    must_have_lasts = [name_parts.l, name_parts.li] |> Util.flatten()
    if must_have_middles == [] do
      parts_match_scoring(String.split(comparator), must_have_firsts, must_have_lasts)
    else
      parts_match_scoring(String.split(comparator), must_have_firsts, must_have_middles, must_have_lasts)
    end
  end

  @doc """
  Compare a name to another name that one has a given and family name (i.e. "John Doe") by
  pattern matching on the shape of a name split into parts [given, middle | family]. Compare them to
  the elements that must exist, which are provided in to lists: must have given names and must have last names.
  """
  def parts_match_scoring([f, m, l], must_have_firsts, [last_name, _] = must_have_lasts) do
    if score(f, must_have_firsts, :in) + score(l, must_have_lasts) == 2 do
      1
    else
      (score(f, must_have_firsts, :in) + score(m, [last_name]))/2
    end
  end
  def parts_match_scoring([f, l], must_have_firsts, must_have_lasts) do
    (score(f, must_have_firsts, :in) + score(l, must_have_lasts))/2
  end
  def parts_match_scoring([f, m | l], must_have_firsts, must_have_lasts) do
    last_checks =
      Enum.any?(l, fn x -> x in must_have_lasts end) ||
        (Enum.intersperse(l, " ") |> List.to_string()) in must_have_lasts
    if last_checks do
      if score(f, must_have_firsts, :in) == 1 do
        1
      else
        (score(f, must_have_firsts, :in) + score(m, must_have_lasts))/2
      end
    else
      0
    end
  end
  def parts_match_scoring(_, _must_have_firsts, _must_have_lasts), do: 0
  # The scholar's middle name is only an initial
  def parts_match_scoring([f, m, l], must_have_firsts, [must_have_middle], must_have_lasts) when is_binary(must_have_middle) do
    # The name to compare to has only an inital for the middle name; it MUST match exactly
    mi = Util.get_initial(m)
    if must_have_middle == m || must_have_middle == mi do
      (score(f, must_have_firsts, :in) + score(l, must_have_lasts))/2
    else
      0
    end
  end
  def parts_match_scoring([f, m, l], must_have_firsts, [middle_name, middle_initial] = must_have_middles, must_have_lasts) do
    mi = Util.get_initial(m)
    if middle_name == m || middle_initial == mi do
      (score(f, must_have_firsts, :in) + score(l, must_have_lasts))/2
    else
      if score(f, must_have_firsts, :in) + score(l, must_have_lasts) == 2 do
        score(m, must_have_middles)
      else
        (score(f, must_have_firsts, :in) + score(m, must_have_middles) +  score(l, must_have_lasts))/3
      end
    end
  end
  # The scholar's middle name is only an initial
  def parts_match_scoring([f, m, l], must_have_firsts, [must_have_middle], must_have_lasts) when is_binary(must_have_middle) do
    (score(f, must_have_firsts, :in) + score(m, [must_have_middle]) +  score(l, must_have_lasts))/3
  end
  # TODO Consider this is wrong; if the scholar has a middle name, should that match on first and last only?
  def parts_match_scoring([f, l], must_have_firsts, _must_have_middles, must_have_lasts) do
    (score(f, must_have_firsts, :in) + score(l, must_have_lasts))/2
  end
  def parts_match_scoring([f, m | l] , must_have_firsts, must_have_middles, must_have_lasts) do
    last_checks =
      Enum.any?(l, fn x -> x in must_have_lasts end) ||
        (Enum.intersperse(l, " ") |> List.to_string()) in must_have_lasts
    last = if last_checks, do: 1, else: 0
    if must_have_middles == [""] do
      (score(f, must_have_firsts, :in) + score(m, must_have_lasts) + last)/3
    else
      (score(f, must_have_firsts, :in) + score(m, must_have_middles) + last)/3
    end
  end
  def parts_match_scoring(_, _must_have_firsts, _must_have_middles, _must_have_lasts), do: 0

  @doc """
  Determine if a name contains any initials (single character names).

  Return :boolean
  """
  def contains_initials?(name) do
    parts = String.split(name)
    Enum.any?(parts, fn p -> String.length(p) == 1 end)
  end
end
