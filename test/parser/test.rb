# frozen_string_literal: true

require "simplecov"

::SimpleCov.command_name "Brutal test suite"
::SimpleCov.start

begin
  require_relative "../../lib/feen"
rescue LoadError
  # :nocov:
  require "./../../lib/feen"
  # :nocov:
end

# ------------------------------------------------------------------------------

actual = begin
  FEEN.parse("8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8 0 /")
end

raise if actual.to_h != {:active_side_id=>0, :board=>{}, :indexes=>[3, 8, 8], :pieces_in_hand_grouped_by_sides=>[[], []]}

# ------------------------------------------------------------------------------

actual = begin
  FEEN.parse("3,yR,yN,yB,yK,yQ,yB,yN,yR,3/3,yP,yP,yP,yP,yP,yP,yP,yP,3/14/bR,bP,10,gP,gR/bN,bP,10,gP,gN/bB,bP,10,gP,gB/bK,bP,10,gP,gQ/bQ,bP,10,gP,gK/bB,bP,10,gP,gB/bN,bP,10,gP,gN/bR,bP,10,gP,gR/14/3,rP,rP,rP,rP,rP,rP,rP,rP,3/3,rR,rN,rB,rQ,rK,rB,rN,rR,3 0 ///")
end

raise if actual.to_h != {:active_side_id=>0, :board=>{:"3"=>"yR", :"4"=>"yN", :"5"=>"yB", :"6"=>"yK", :"7"=>"yQ", :"8"=>"yB", :"9"=>"yN", :"10"=>"yR", :"17"=>"yP", :"18"=>"yP", :"19"=>"yP", :"20"=>"yP", :"21"=>"yP", :"22"=>"yP", :"23"=>"yP", :"24"=>"yP", :"42"=>"bR", :"43"=>"bP", :"54"=>"gP", :"55"=>"gR", :"56"=>"bN", :"57"=>"bP", :"68"=>"gP", :"69"=>"gN", :"70"=>"bB", :"71"=>"bP", :"82"=>"gP", :"83"=>"gB", :"84"=>"bK", :"85"=>"bP", :"96"=>"gP", :"97"=>"gQ", :"98"=>"bQ", :"99"=>"bP", :"110"=>"gP", :"111"=>"gK", :"112"=>"bB", :"113"=>"bP", :"124"=>"gP", :"125"=>"gB", :"126"=>"bN", :"127"=>"bP", :"138"=>"gP", :"139"=>"gN", :"140"=>"bR", :"141"=>"bP", :"152"=>"gP", :"153"=>"gR", :"171"=>"rP", :"172"=>"rP", :"173"=>"rP", :"174"=>"rP", :"175"=>"rP", :"176"=>"rP", :"177"=>"rP", :"178"=>"rP", :"185"=>"rR", :"186"=>"rN", :"187"=>"rB", :"188"=>"rQ", :"189"=>"rK", :"190"=>"rB", :"191"=>"rN", :"192"=>"rR"}, :indexes=>[14, 14], :pieces_in_hand_grouped_by_sides=>[[], [], [], []]}

# ------------------------------------------------------------------------------

actual = begin
  FEEN.parse("♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/8/8/♙,♙,♙,♙,♙,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 0 /")
end

raise if actual.to_h != {:active_side_id=>0, :board=>{:"0"=>"♜", :"1"=>"♞", :"2"=>"♝", :"3"=>"♛", :"4"=>"♚", :"5"=>"♝", :"6"=>"♞", :"7"=>"♜", :"8"=>"♟", :"9"=>"♟", :"10"=>"♟", :"11"=>"♟", :"12"=>"♟", :"13"=>"♟", :"14"=>"♟", :"15"=>"♟", :"48"=>"♙", :"49"=>"♙", :"50"=>"♙", :"51"=>"♙", :"52"=>"♙", :"53"=>"♙", :"54"=>"♙", :"55"=>"♙", :"56"=>"♖", :"57"=>"♘", :"58"=>"♗", :"59"=>"♕", :"60"=>"♔", :"61"=>"♗", :"62"=>"♘", :"63"=>"♖"}, :indexes=>[8, 8], :pieces_in_hand_grouped_by_sides=>[[], []]}

# ------------------------------------------------------------------------------

actual = begin
  FEEN.parse("♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/4,♙,3/8/♙,♙,♙,♙,1,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 1 /")
end

raise if actual.to_h != {:active_side_id=>1, :board=>{:"0"=>"♜", :"1"=>"♞", :"2"=>"♝", :"3"=>"♛", :"4"=>"♚", :"5"=>"♝", :"6"=>"♞", :"7"=>"♜", :"8"=>"♟", :"9"=>"♟", :"10"=>"♟", :"11"=>"♟", :"12"=>"♟", :"13"=>"♟", :"14"=>"♟", :"15"=>"♟", :"36"=>"♙", :"48"=>"♙", :"49"=>"♙", :"50"=>"♙", :"51"=>"♙", :"53"=>"♙", :"54"=>"♙", :"55"=>"♙", :"56"=>"♖", :"57"=>"♘", :"58"=>"♗", :"59"=>"♕", :"60"=>"♔", :"61"=>"♗", :"62"=>"♘", :"63"=>"♖"}, :indexes=>[8, 8], :pieces_in_hand_grouped_by_sides=>[[], []]}

# ------------------------------------------------------------------------------

actual = begin
  FEEN.parse("♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,1,♟,♟,♟/8/4,♟,3/4,♙,3/8/♙,♙,♙,♙,1,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 0 /")
end

raise if actual.to_h != {:active_side_id=>0, :board=>{:"0"=>"♜", :"1"=>"♞", :"2"=>"♝", :"3"=>"♛", :"4"=>"♚", :"5"=>"♝", :"6"=>"♞", :"7"=>"♜", :"8"=>"♟", :"9"=>"♟", :"10"=>"♟", :"11"=>"♟", :"13"=>"♟", :"14"=>"♟", :"15"=>"♟", :"28"=>"♟", :"36"=>"♙", :"48"=>"♙", :"49"=>"♙", :"50"=>"♙", :"51"=>"♙", :"53"=>"♙", :"54"=>"♙", :"55"=>"♙", :"56"=>"♖", :"57"=>"♘", :"58"=>"♗", :"59"=>"♕", :"60"=>"♔", :"61"=>"♗", :"62"=>"♘", :"63"=>"♖"}, :indexes=>[8, 8], :pieces_in_hand_grouped_by_sides=>[[], []]}

# ------------------------------------------------------------------------------

actual = begin
  FEEN.parse("♜,♞,♝,♛,♚,♝,♞,♜/8/♟,♟,♟,♟,♟,♟,♟,♟/8/8/♙,♙,♙,♙,♙,♙,♙,♙/8/♖,♘,♗,♔,♕,♗,♘,♖ 0 /")
end

raise if actual.to_h != {:active_side_id=>0, :board=>{:"0"=>"♜", :"1"=>"♞", :"2"=>"♝", :"3"=>"♛", :"4"=>"♚", :"5"=>"♝", :"6"=>"♞", :"7"=>"♜", :"16"=>"♟", :"17"=>"♟", :"18"=>"♟", :"19"=>"♟", :"20"=>"♟", :"21"=>"♟", :"22"=>"♟", :"23"=>"♟", :"40"=>"♙", :"41"=>"♙", :"42"=>"♙", :"43"=>"♙", :"44"=>"♙", :"45"=>"♙", :"46"=>"♙", :"47"=>"♙", :"56"=>"♖", :"57"=>"♘", :"58"=>"♗", :"59"=>"♔", :"60"=>"♕", :"61"=>"♗", :"62"=>"♘", :"63"=>"♖"}, :indexes=>[8, 8], :pieces_in_hand_grouped_by_sides=>[[], []]}

# ------------------------------------------------------------------------------

actual = begin
  FEEN.parse("l,n,s,g,k,g,s,n,l/1,r,5,b,1/p,p,p,p,p,p,p,p,p/9/9/9/P,P,P,P,P,P,P,P,P/1,B,5,R,1/L,N,S,G,K,G,S,N,L 0 /")
end

raise if actual.to_h != {:active_side_id=>0, :board=>{:"0"=>"l", :"1"=>"n", :"2"=>"s", :"3"=>"g", :"4"=>"k", :"5"=>"g", :"6"=>"s", :"7"=>"n", :"8"=>"l", :"10"=>"r", :"16"=>"b", :"18"=>"p", :"19"=>"p", :"20"=>"p", :"21"=>"p", :"22"=>"p", :"23"=>"p", :"24"=>"p", :"25"=>"p", :"26"=>"p", :"54"=>"P", :"55"=>"P", :"56"=>"P", :"57"=>"P", :"58"=>"P", :"59"=>"P", :"60"=>"P", :"61"=>"P", :"62"=>"P", :"64"=>"B", :"70"=>"R", :"72"=>"L", :"73"=>"N", :"74"=>"S", :"75"=>"G", :"76"=>"K", :"77"=>"G", :"78"=>"S", :"79"=>"N", :"80"=>"L"}, :indexes=>[9, 9], :pieces_in_hand_grouped_by_sides=>[[], []]}

# ------------------------------------------------------------------------------

actual = begin
  FEEN.parse("3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 0 S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s")
end

raise if actual.to_h != {:active_side_id=>0, :board=>{:"3"=>"s", :"4"=>"k", :"5"=>"s", :"22"=>"+P", :"43"=>"+B"}, :indexes=>[9, 9], :pieces_in_hand_grouped_by_sides=>[["S"], ["b", "g", "g", "g", "g", "n", "n", "n", "n", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "r", "r", "s"]]}

# ------------------------------------------------------------------------------

actual = begin
  FEEN.parse("車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 0 /")
end

raise if actual.to_h != {:active_side_id=>0, :board=>{:"0"=>"車", :"1"=>"馬", :"2"=>"象", :"3"=>"士", :"4"=>"將", :"5"=>"士", :"6"=>"象", :"7"=>"馬", :"8"=>"車", :"19"=>"砲", :"25"=>"砲", :"27"=>"卒", :"29"=>"卒", :"31"=>"卒", :"33"=>"卒", :"35"=>"卒", :"54"=>"兵", :"56"=>"兵", :"58"=>"兵", :"60"=>"兵", :"62"=>"兵", :"64"=>"炮", :"70"=>"炮", :"81"=>"俥", :"82"=>"傌", :"83"=>"相", :"84"=>"仕", :"85"=>"帥", :"86"=>"仕", :"87"=>"相", :"88"=>"傌", :"89"=>"俥"}, :indexes=>[10, 9], :pieces_in_hand_grouped_by_sides=>[[], []]}
