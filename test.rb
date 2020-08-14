require_relative 'lib/feen'

# Dump an empty 3x8x8 board position
raise unless FEEN.dump([3, 8, 8],
  *Array.new(3 * 8 * 8)
) == '8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8 B /'

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

# Dump Chess's position after the move 1. e4
raise unless FEEN.dump([8, 8],
  '♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜',
  '♟', '♟', '♟', '♟', '♟', '♟', '♟', '♟',
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, '♙', nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  '♙', '♙', '♙', '♙', nil, '♙', '♙', '♙',
  '♖', '♘', '♗', '♕', '♔', '♗', '♘', '♖', is_turn_to_topside: true
) == '♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/4,♙,3/8/♙,♙,♙,♙,1,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ t /'

# Dump Chess's position after the moves 1. e4 c5
raise unless FEEN.dump([8, 8],
  '♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜',
  '♟', '♟', '♟', '♟', nil, '♟', '♟', '♟',
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, '♟', nil, nil, nil,
  nil, nil, nil, nil, '♙', nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  '♙', '♙', '♙', '♙', nil, '♙', '♙', '♙',
  '♖', '♘', '♗', '♕', '♔', '♗', '♘', '♖', is_turn_to_topside: false
) == '♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,1,♟,♟,♟/8/4,♟,3/4,♙,3/8/♙,♙,♙,♙,1,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ B /'

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

# Dump a classic Tsume Shogi problem
raise unless FEEN.dump([9, 9],
  nil, nil, nil, 's', 'k', 's', nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, '+P', nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, '+B', nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  is_turn_to_topside: false,
  bottomside_in_hand_pieces: %w[S],
  topside_in_hand_pieces: %w[r r b g g g g s n n n n p p p p p p p p p p p p p p p p p]
) == '3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 B S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s'

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


# Parse an empty 3x8x8 board position
raise unless FEEN.parse('8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8 B /').eql?(
  is_turn_to_topside: false,
  indexes: [3, 8, 8],
  squares: Array.new(3 * 8 * 8),
  bottomside_in_hand_pieces: [],
  topside_in_hand_pieces: []
)

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

# Parse a classic Tsume Shogi problem
raise unless FEEN.parse('3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 B S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s').eql?(
  is_turn_to_topside: false,
  indexes: [9, 9],
  squares: [
    nil, nil, nil, 's', 'k', 's', nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, '+P', nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, '+B', nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil
  ],
  bottomside_in_hand_pieces: %w[S],
  topside_in_hand_pieces: %w[b g g g g n n n n p p p p p p p p p p p p p p p p p r r s]
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
