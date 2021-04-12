class TournamentsController < ApplicationController
  def index
  	@results = { "CJ" => { "elo" => 1169, "rank" => "29/30"},
  				"Matt" => { "elo" => 1193, "rank" => "21/30"},
  				"Sriram" => { "elo" => 1220, "rank" => "4/30"},
  				"Ziyou" => { "elo" => 1202, "rank" => "9/30"},
  				"Alex" => { "elo" => 1226, "rank" => "3/30"},
  				"Adam" => { "elo" => 1162, "rank" => "30/30"},
  				"Jonathan" => { "elo" => 1204, "rank" => "7/30"},
  				"Irtiza" => { "elo" => 1230, "rank" => "2/30"},
  				"Dan" => { "elo" => 1192, "rank" => "22/30"}}
    @results2 = { "CJ" => { "elo" => 1167, "rank" => "39/41"},
          "Tyler" => { "elo" => 1264, "rank" => "2/41"},
          "Kyle" => { "elo" => 1168, "rank" => "38/41"},
          "Alex" => { "elo" => 1152, "rank" => "40/41"},
          "Irtiza" => { "elo" => 1311, "rank" => "1/41"},
          "Dan" => { "elo" => 1227, "rank" => "6/41"},
          "DanielMoyer" => { "elo" => 1222, "rank" => "7/41"},
          "Deekpak" => { "elo" => 1297, "rank" => "13/41"},
          "Ziyou" => { "elo" => 1251, "rank" => "3/41"},
          "Noah" => { "elo" => "---", "rank" => "---/41"},
          "JonathanKramer" => { "elo" => 1144, "rank" => "41/41"},
          "Adam" => { "elo" => 1193, "rank" => "29/41"},
          "Vikas" => { "elo" => 1169, "rank" => "36/41"}}
    @results3 = { "Tyler" => { "elo" => 1267, "rank" => "2/42"},
          "Irtiza" => { "elo" => 1212, "rank" => "10/42"},
          "Jonathan" => { "elo" => 1232, "rank" => "5/42"},
          "Vikas" => { "elo" => 1179, "rank" => "39/42"},
          "Zamua" => { "elo" => 1220, "rank" => "8/42"},
          "Adam" => { "elo" => 1195, "rank" => "20/42"},
          "Sabya" => { "elo" => 1237, "rank" => "4/30"}}
  end
end