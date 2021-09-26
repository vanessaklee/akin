# defmodule Akin.MatchTest do
#   @moduledoc """
#   Tests to cover author name disambiguation.
#   """
#   use ExUnit.Case
#   import SweetXml

#   @doc """
#   This data set is used for studying name disambiguation in digital library. It contains 110 author names and their disambiguation results (ground truth). Each author name corresponds to a raw file in the "data" folder and an answer file (ground truth) in the "answers" folder.

#   - Data files: the raw file is formatted as a XML file. In the XML file, the author name is associated with a number of publications. An example of a publication is as follow:
#   "
#     <publication>
#       <title>Explanation-based Failure Recovery</title>
#       <year>1987</year>
#       <authors>Ajay Gupta</authors>
#       <jconf>AAAI</jconf>
#       <id>13048</id>
#       <label>0</label>
#       <organization>null</organization>
#     </publication>
#   "
#   where <title> denotes the title of the publication;
#   <year> denotes the publication year;
#   <jconf> denotes the publication venue;
#   <id> denotes the publication id;
#   <label> denotes the labeled person, e.g., all publications with "<label>0</label>" can be considered as published by the same person;
#   <organization> denotes the affiliation of the author(s).
#   """
#   test "test against aminer dataset" do
#     authors = Path.wildcard("test/support/and/aminer/data/*.xml") |> Enum.map(&Path.basename/1)
#       |> Enum.take(1)

#     for author <- authors do
#       {:ok, xmldoc} = File.read("test/support/and/aminer/data/#{author}")
#       scholar = String.replace(author, ".xml", "")

#       parsed_xml = xmldoc
#         |> HtmlEntities.decode()
#         |> String.replace("&", " ")
#         |> String.replace("  ", " ")
#         |> SweetXml.parse(dtd: :all)
#       first_name = SweetXml.xpath(parsed_xml, ~x"//person/FirstName/text()") |> to_string()
#       last_name = SweetXml.xpath(parsed_xml, ~x"//person/LastName/text()") |> to_string()

#       {given_name, middle_name, family_name} = if empty?(first_name) || empty?(last_name) do
#           full_name = SweetXml.xpath(parsed_xml, ~x"//person/FullName/text()") |> to_string()
#           case String.split(full_name) do
#             [g, m, l] -> {g, m, l}
#             [g, l] -> {g, "", l}
#             _ -> {nil, nil, nil}
#           end
#         else
#           {first_name, "", last_name}
#         end

#       if not empty?(given_name) && not empty?(family_name) do
#         publications = SweetXml.xpath(parsed_xml, ~x"//person/publication"l)

#         for p <- publications do
#           authors = SweetXml.xpath(p, ~x"//publication/authors/text()")
#             |> to_string()
#             |> String.split(",")

#           if Enum.any?(authors, fn author -> String.bag_distance(scholar, author) >= And.min_bag_distance() end) do
#             assert And.match(given_name, middle_name, family_name, authors)
#           else
#             assert [] == And.match(given_name, middle_name, family_name, authors)
#           end
#         end
#       end
#     end
#   end

#   defp empty?(string), do: string in [nil, "", "null"]
# end
