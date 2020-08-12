require_relative 'lib/feen'

# Dump Chess's starting position
raise unless FEEN.dump([8, 8],
  '♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜',
  '♟', '♟', '♟', '♟', '♟', '♟', '♟', '♟',
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  '♙', '♙', '♙', '♙', '♙', '♙', '♙', '♙',
  '♖', '♘', '♗', '♕', '♔', '♗', '♘', '♖'
) == '♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/8/8/♙,♙,♙,♙,♙,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ B /'

# Dump Makruk's starting position
raise unless FEEN.dump([8, 8],
  '♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜',
  nil, nil, nil, nil, nil, nil, nil, nil,
  '♟', '♟', '♟', '♟', '♟', '♟', '♟', '♟',
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  '♙', '♙', '♙', '♙', '♙', '♙', '♙', '♙',
  nil, nil, nil, nil, nil, nil, nil, nil,
  '♖', '♘', '♗', '♔', '♕', '♗', '♘', '♖'
) == '♜,♞,♝,♛,♚,♝,♞,♜/8/♟,♟,♟,♟,♟,♟,♟,♟/8/8/♙,♙,♙,♙,♙,♙,♙,♙/8/♖,♘,♗,♔,♕,♗,♘,♖ B /'

# Dump Shogi's starting position
raise unless FEEN.dump([9, 9],
  'l', 'n', 's', 'g', 'k', 'g', 's', 'n', 'l',
  nil, 'r', nil, nil, nil, nil, nil, 'b', nil,
  'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p',
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',
  nil, 'B', nil, nil, nil, nil, nil, 'R', nil,
  'L', 'N', 'S', 'G', 'K', 'G', 'S', 'N', 'L'
) == 'l,n,s,g,k,g,s,n,l/1,r,5,b,1/p,p,p,p,p,p,p,p,p/9/9/9/P,P,P,P,P,P,P,P,P/1,B,5,R,1/L,N,S,G,K,G,S,N,L B /'

# Dump Xiangqi's starting position
raise unless FEEN.dump([10, 9],
  '車', '馬', '象', '士', '將', '士', '象', '馬', '車',
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, '砲', nil, nil, nil, nil, nil, '砲', nil,
  '卒', nil, '卒', nil, '卒', nil, '卒', nil, '卒',
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  '兵', nil, '兵', nil, '兵', nil, '兵', nil, '兵',
  nil, '炮', nil, nil, nil, nil, nil, '炮', nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  '俥', '傌', '相', '仕', '帥', '仕', '相', '傌', '俥'
) == '車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 B /'


# Parse Chess's starting position
raise unless FEEN.parse('♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/8/8/♙,♙,♙,♙,♙,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ B /').eql?(
  is_turn_to_topside: false,
  indexes: [8, 8],
  squares: [
    '♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜',
    '♟', '♟', '♟', '♟', '♟', '♟', '♟', '♟',
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    '♙', '♙', '♙', '♙', '♙', '♙', '♙', '♙',
    '♖', '♘', '♗', '♕', '♔', '♗', '♘', '♖'
  ],
  bottomside_in_hand_pieces: [],
  topside_in_hand_pieces: []
)

# Parse Makruk's starting position
raise unless FEEN.parse('♜,♞,♝,♛,♚,♝,♞,♜/8/♟,♟,♟,♟,♟,♟,♟,♟/8/8/♙,♙,♙,♙,♙,♙,♙,♙/8/♖,♘,♗,♔,♕,♗,♘,♖ B /').eql?(
  is_turn_to_topside: false,
  indexes: [8, 8],
  squares: [
    '♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜',
    nil, nil, nil, nil, nil, nil, nil, nil,
    '♟', '♟', '♟', '♟', '♟', '♟', '♟', '♟',
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    '♙', '♙', '♙', '♙', '♙', '♙', '♙', '♙',
    nil, nil, nil, nil, nil, nil, nil, nil,
    '♖', '♘', '♗', '♔', '♕', '♗', '♘', '♖'
  ],
  bottomside_in_hand_pieces: [],
  topside_in_hand_pieces: []
)

# Parse Shogi's starting position
raise unless FEEN.parse('l,n,s,g,k,g,s,n,l/1,r,5,b,1/p,p,p,p,p,p,p,p,p/9/9/9/P,P,P,P,P,P,P,P,P/1,B,5,R,1/L,N,S,G,K,G,S,N,L B /').eql?(
  is_turn_to_topside: false,
  indexes: [9, 9],
  squares: [
    'l', 'n', 's', 'g', 'k', 'g', 's', 'n', 'l',
    nil, 'r', nil, nil, nil, nil, nil, 'b', nil,
    'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p',
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',
    nil, 'B', nil, nil, nil, nil, nil, 'R', nil,
    'L', 'N', 'S', 'G', 'K', 'G', 'S', 'N', 'L'
  ],
  bottomside_in_hand_pieces: [],
  topside_in_hand_pieces: []
)

# Parse Xiangqi's starting position
raise unless FEEN.parse('車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 B /').eql?(
  is_turn_to_topside: false,
  indexes: [10, 9],
  squares: [
    '車', '馬', '象', '士', '將', '士', '象', '馬', '車',
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, '砲', nil, nil, nil, nil, nil, '砲', nil,
    '卒', nil, '卒', nil, '卒', nil, '卒', nil, '卒',
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    '兵', nil, '兵', nil, '兵', nil, '兵', nil, '兵',
    nil, '炮', nil, nil, nil, nil, nil, '炮', nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    '俥', '傌', '相', '仕', '帥', '仕', '相', '傌', '俥'
  ],
  bottomside_in_hand_pieces: [],
  topside_in_hand_pieces: []
)
