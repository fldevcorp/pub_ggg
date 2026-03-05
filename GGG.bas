  ; =====================================================
  ; GreedyGreedyGrabbers3 — Phase 8: Game Flow
  ; Atari 2600 / batari Basic
  ; =====================================================

  set tv_type ntsc
  set kernel_options no_blank_lines

  ; =====================================================
  ; Variable Map (a-z) — all 26 planned upfront
  ; =====================================================
  dim _ballDX        = a
  dim _ballDY        = b
  dim _paddleToggle  = c
  dim _p0pos         = d
  dim _p0idx         = e
  dim _p1pos         = f
  dim _p1idx         = g
  dim _p2pos         = h
  dim _p2idx         = i
  dim _p3pos         = j
  dim _p3idx         = k
  dim _scoreP0       = l
  dim _scoreP1       = m
  dim _scoreP2       = n
  dim _scoreP3       = o
  dim _grabTimer0    = p
  dim _grabTimer1    = q
  dim _grabTimer2    = r
  dim _grabTimer3    = s
  dim _winner        = t
  dim _temp1         = u
  dim _tempA         = v
  dim _tempB         = w
  dim _tempD         = x
  dim _gameState     = y
  dim _rand16        = z


  ; =====================================================
  ; Sprite Data — open hand (8x8)
  ; =====================================================
  player0:
  %00011000
  %00100100
  %01011010
  %11111111
  %11111111
  %01011010
  %00100100
  %00011000
end

  player1:
  %00011000
  %00100100
  %01000010
  %11111111
  %11111111
  %01000010
  %00100100
  %00011000
end

  ; =====================================================
  ; Initialization
  ; =====================================================
__fullInit
  _p0pos = 0 : _p0idx = 0
  _scoreP0 = 0 : _scoreP1 = 0 : _scoreP2 = 0 : _scoreP3 = 0 : _winner = 0
  score = 0
  
  COLUBK = $00
  COLUPF = $0E
  COLUP0 = $2E
  COLUP1 = $8E
  scorecolor = $00

  player0x = 47
  player0y = 18
  player1x = 113
  player1y = 18

  ; --- Ball initialization (center of playfield) ---
  ballx = 80 : bally = 48
  ;_ballDX = 1    ; 1 = right, 0 = left
  ;_ballDY = 1    ; 1 = down,  0 = up

  ; --- Seed _rand16 from current sprite positions and toggle start direction ---
  _ballDX = 0 : _ballDY = 0
  _rand16 = player0x + player1x + player0y + player1y + _paddleToggle
;  _rand16 = _rand16 * 3 + 1
;  if _rand16 > 127 then _ballDX = 1 
;  _rand16 = _rand16 * 3 + 7
;  if _rand16 > 127 then _ballDY = 1 

  ; --- Playfield: all 4 corner borders ---
  pfhline 0 0 31 on
  pfvline 0 0 5 on
  pfvline 31 0 5 on
  pfvline 0 6 10 on
  pfhline 0 10 31 on
  pfvline 31 6 10 on

  ; --- Start in title state ---
  _gameState = 0

  ; =====================================================
  ; Title Screen
  ; =====================================================
  ; Draw "GREEDY" on playfield for title screen
  ; 3-col wide letters, 5 rows tall (rows 3-7), 1 col gap
  ; G:5-7  R:9-11  E:13-15  E:17-19  D:21-23  Y:25-27
  ; Row 3 (top)
  pfhline 5 3 7 on : pfhline 9 3 11 on : pfhline 13 3 15 on
  pfhline 17 3 19 on : pfhline 21 3 23 on : pfpixel 25 3 on : pfpixel 27 3 on
  ; Row 4
  pfpixel 5 4 on : pfpixel 9 4 on : pfpixel 11 4 on : pfpixel 13 4 on
  pfpixel 17 4 on : pfpixel 21 4 on : pfpixel 23 4 on : pfpixel 26 4 on
  ; Row 5 (middle)
  pfpixel 5 5 on : pfpixel 7 5 on : pfhline 9 5 11 on : pfhline 13 5 14 on
  pfhline 17 5 18 on : pfpixel 21 5 on : pfpixel 23 5 on : pfpixel 26 5 on
  ; Row 6
  pfpixel 5 6 on : pfpixel 7 6 on : pfpixel 9 6 on : pfpixel 11 6 on
  pfpixel 13 6 on : pfpixel 17 6 on : pfpixel 21 6 on : pfpixel 23 6 on : pfpixel 26 6 on
  ; Row 7 (bottom)
  pfhline 5 7 7 on : pfpixel 9 7 on : pfpixel 11 7 on : pfhline 13 7 15 on
  pfhline 17 7 19 on : pfhline 21 7 23 on : pfpixel 26 7 on

__titleLoop
  COLUBK = $00
  COLUPF = $4E
  COLUP0 = $2E
  COLUP1 = $8E
  scorecolor = $00

  ; Hide players and ball during title
  player0x = 0 : player0y = 0 : player1x = 0 : player1y = 0 : ballx = 0 : bally = 0

  drawscreen

  ; Wait for joy0 fire button (mouse click in Stella paddle mode)
  if joy0right then goto __startGame
  goto __titleLoop

__startGame
  ; Reset scores and ball for a new game
  _scoreP0 = 0 : _scoreP1 = 0 : _scoreP2 = 0 : _scoreP3 = 0 : _winner = 0: _gameState = 1
  score = 0
  ; Clear title text and tally pixels
  pfhline 5 3 27 off : pfhline 5 4 27 off : pfhline 5 5 27 off
  pfhline 5 6 27 off : pfhline 5 7 27 off
  pfhline 1 1 5 off : pfhline 1 2 5 off
  pfhline 1 8 5 off : pfhline 1 9 5 off
  pfhline 26 1 30 off : pfhline 26 2 30 off
  pfhline 26 8 30 off : pfhline 26 9 30 off
  ballx = 80 : bally = 48
  _ballDX = 0 : _ballDY = 0 
  _rand16 = _rand16 * 5 + 3
  if _rand16 > 127 then _ballDX = 1 
  _rand16 = _rand16 * 3 + 7
  if _rand16 > 127 then _ballDY = 1 

  COLUPF = $0E
  scorecolor = $00

  goto __mainLoop

  ; =====================================================
  ; Game Over Screen
  ; =====================================================
__gameOver
  _gameState = 2

  ; Victory sound
;  AUDC0 = $04
;  AUDF0 = $0F
;  AUDV0 = $0F

__gameOverLoop
  ; Flash winner's color on background
  COLUBK = $2E
  if _winner = 2 then COLUBK = $4E
  if _winner = 3 then COLUBK = $8E
  if _winner = 4 then COLUBK = $CE

  COLUP0 = $0E
  COLUP1 = $0E
  COLUPF = $0E
  scorecolor = $00

  ; Hide ball
  ballx = 0 : bally = 0

  ; Decay victory sound
;  if AUDV0 > 0 then AUDV0 = AUDV0 - 1

  drawscreen

  ; Wait for fire button to restart
  if joy0fire then goto __fullInit
  goto __gameOverLoop

  ; =====================================================
  ; Main Loop
  ; =====================================================
__mainLoop

  ; --- Toggle frame pair ---
  _paddleToggle = _paddleToggle ^ 1
  if _paddleToggle then goto __frameB

  ; === Frame A: show P0 (top-left) + P2 (top-right) ===
__frameA
  COLUP0 = $2E
  COLUP1 = $8E
  gosub __arcP0
  gosub __arcP2
  goto __doDraw

  ; === Frame B: show P1 (bottom-left) + P3 (bottom-right) ===
__frameB
  COLUP0 = $4E
  COLUP1 = $CE
  gosub __arcP1
  gosub __arcP3

__doDraw
  ; --- Refresh playfield each frame ---
  pfhline 0 0 31 on
  pfvline 0 0 5 on
  pfvline 31 0 5 on
  pfvline 0 6 10 on
  pfhline 0 10 31 on
  pfvline 31 6 10 on

  ; --- Per-frame ball movement (execute BEFORE drawscreen) ---
  ; Move X by 1 pixel and bounce within [20,140]
  if _ballDX = 1 then ballx = ballx + 1 : goto __Next001
  ballx = ballx - 1
__Next001  
  if ballx < 20  then ballx = 20  : _ballDX = 1
  if ballx > 140 then ballx = 140 : _ballDX = 0

  ; Move Y by 1 pixel and bounce within [8,79]
  if _ballDY = 1 then bally = bally + 1 : goto __Next002
  bally = bally - 1
__Next002
  if bally < 8   then bally = 8   : _ballDY = 1
  if bally > 79  then bally = 79  : _ballDY = 0

  ; --- Collision detection (check displayed pair) ---
  ; Check player0: Manhattan distance |ballx-px| + |bally-py|
  _tempA = ballx - player0x
  if ballx < player0x then _tempA = player0x - ballx
  _tempB = bally - player0y
  if bally < player0y then _tempB = player0y - bally
  _tempD = _tempA + _tempB
  if _tempD < 12 then goto __grabP0

  ; Check player1
  _tempA = ballx - player1x
  if ballx < player1x then _tempA = player1x - ballx
  _tempB = bally - player1y
  if bally < player1y then _tempB = player1y - bally
  _tempD = _tempA + _tempB
  if _tempD < 12 then goto __grabP1

  goto __noGrab

__grabP0
  ; player0 grabbed: toggle=0 means P0, toggle=1 means P1
  if _paddleToggle = 0 then _scoreP0 = _scoreP0 + 1 : _grabTimer0 = 6 : goto __Next003
  _scoreP1 = _scoreP1 + 1 : _grabTimer1 = 6
__Next003  
  ; Inline tally: P0 top-left (rows 1-2, cols 1-5)
  if _paddleToggle = 0 then _temp1 = _scoreP0 : _tempA = 1 : goto __Next004 
  _temp1 = _scoreP1 : _tempA = 8
__Next004
  if _temp1 > 5 then _temp1 = _temp1 - 5 : _tempA = _tempA + 1
  pfpixel _temp1 _tempA on
  ; Trigger brief grab SFX (channel 0)
;  AUDC0 = $1E
;  AUDF0 = $24
;  AUDV0 = $0F
  goto __doReset

__grabP1
  ; player1 grabbed: toggle=0 means P2, toggle=1 means P3
  if _paddleToggle = 0 then _scoreP2 = _scoreP2 + 1 : _grabTimer2 = 6 : goto __Next005
  _scoreP3 = _scoreP3 + 1 : _grabTimer3 = 6
__Next005
  ; Inline tally: P2 top-right (rows 1-2, cols 26-30), P3 bottom-right (rows 8-9, cols 26-30)
  if _paddleToggle = 0 then _temp1 = _scoreP2 + 25 : _tempA = 1 : goto __Next006
  _temp1 = _scoreP3 + 25 : _tempA = 8 
__Next006

  if _paddleToggle = 0 && _scoreP2 > 5 then _temp1 = _scoreP2 + 20 : _tempA = 2
  if _paddleToggle && _scoreP3 > 5 then _temp1 = _scoreP3 + 20 : _tempA = 9
  pfpixel _temp1 _tempA on
  ; Trigger brief grab SFX (channel 0)
;  AUDC0 = $1E
;  AUDF0 = $24
;  AUDV0 = $0F

__doReset
  ballx = 80 : bally = 48
  _rand16 = _rand16 * 5 + 3
  _ballDX = 0 : _ballDY = 0
  if _rand16 > 127 then _ballDX = 1
  _rand16 = _rand16 * 3 + 7
  if _rand16 > 127 then _ballDY = 1

  ; --- Win check: first to 10 grabs ---
  if _scoreP0 >= 10 then _winner = 1 : goto __gameOver
  if _scoreP1 >= 10 then _winner = 2 : goto __gameOver
  if _scoreP2 >= 10 then _winner = 3 : goto __gameOver
  if _scoreP3 >= 10 then _winner = 4 : goto __gameOver

__noGrab

  ; --- Audio volume decay (auto-decrement each frame) ---
  ; if AUDV0 > 0 then AUDV0 = AUDV0 - 1

  ; --- Grab color flash: if any grab timer active, force HW colors to white briefly and decrement timers ---
  if _grabTimer0 > 0 then COLUP0 = $0E : COLUP1 = $0E : _grabTimer0 = _grabTimer0 - 1
  if _grabTimer1 > 0 then COLUP0 = $0E : COLUP1 = $0E : _grabTimer1 = _grabTimer1 - 1
  if _grabTimer2 > 0 then COLUP0 = $0E : COLUP1 = $0E : _grabTimer2 = _grabTimer2 - 1
  if _grabTimer3 > 0 then COLUP0 = $0E : COLUP1 = $0E : _grabTimer3 = _grabTimer3 - 1

  drawscreen

  ; --- Paddle reading (overscan) ---
  VBLANK = $80
  _temp1 = _temp1
  VBLANK = $00

  if _paddleToggle then goto __readP13

  ; Read paddles 0 & 2
__readP02
  _p0pos = 0 : _p2pos = 0
__loopP02
  if INPT0 < 128 then _p0pos = _p0pos + 1
  if INPT2 < 128 then _p2pos = _p2pos + 1
  _temp1 = 0
  if _p0pos < 128 && INPT0 < 128 then _temp1 = 1
  if _p2pos < 128 && INPT2 < 128 then _temp1 = 1
  if _temp1 then goto __loopP02
  _p0idx = _p0pos / 8
  if _p0idx > 15 then _p0idx = 15
  _p2idx = _p2pos / 8
  if _p2idx > 15 then _p2idx = 15
  goto __mainLoop

  ; Read paddles 1 & 3
__readP13
  _p1pos = 0 : _p3pos = 0
__loopP13
  if INPT1 < 128 then _p1pos = _p1pos + 1
  if INPT3 < 128 then _p3pos = _p3pos + 1
  _temp1 = 0
  if _p1pos < 128 && INPT1 < 128 then _temp1 = 1
  if _p3pos < 128 && INPT3 < 128 then _temp1 = 1
  if _temp1 then goto __loopP13
  _p1idx = _p1pos / 8
  if _p1idx > 15 then _p1idx = 15
  _p3idx = _p3pos / 8
  if _p3idx > 15 then _p3idx = 15

  goto __mainLoop

  ; Arc subroutine — P0 (top-left quadrant)
  ; Center (22,18), radius 25, theta 0-90 in 16 steps
__arcP0
  if _p0idx = 0  then player0x = 47 : player0y = 18 : return 
  if _p0idx = 1  then player0x = 47 : player0y = 21 : return
  if _p0idx = 2  then player0x = 46 : player0y = 23 : return
  if _p0idx = 3  then player0x = 46 : player0y = 26 : return
  if _p0idx = 4  then player0x = 45 : player0y = 28 : return
  if _p0idx = 5  then player0x = 44 : player0y = 31 : return
  if _p0idx = 6  then player0x = 42 : player0y = 33 : return
  if _p0idx = 7  then player0x = 41 : player0y = 35 : return
  if _p0idx = 8  then player0x = 39 : player0y = 37 : return
  if _p0idx = 9  then player0x = 37 : player0y = 38 : return
  if _p0idx = 10 then player0x = 35 : player0y = 40 : return
  if _p0idx = 11 then player0x = 32 : player0y = 41 : return
  if _p0idx = 12 then player0x = 30 : player0y = 42 : return
  if _p0idx = 13 then player0x = 27 : player0y = 42 : return
  if _p0idx = 14 then player0x = 25 : player0y = 43 : return
  if _p0idx = 15 then player0x = 22 : player0y = 43 : return
  return
 
 ; Arc subroutine — P1 (bottom-left quadrant)
 ; Mirror of P0: same X range, Y mirrored to bottom
__arcP1
   if _p1idx = 0  then player0x = 47 : player0y = 78 : return
   if _p1idx = 1  then player0x = 47 : player0y = 75 : return
   if _p1idx = 2  then player0x = 46 : player0y = 73 : return
   if _p1idx = 3  then player0x = 46 : player0y = 70 : return
   if _p1idx = 4  then player0x = 45 : player0y = 68 : return
   if _p1idx = 5  then player0x = 44 : player0y = 65 : return
   if _p1idx = 6  then player0x = 42 : player0y = 63 : return
   if _p1idx = 7  then player0x = 41 : player0y = 61 : return
   if _p1idx = 8  then player0x = 39 : player0y = 59 : return
   if _p1idx = 9  then player0x = 37 : player0y = 58 : return
   if _p1idx = 10 then player0x = 35 : player0y = 56 : return
   if _p1idx = 11 then player0x = 32 : player0y = 55 : return
   if _p1idx = 12 then player0x = 30 : player0y = 54 : return
   if _p1idx = 13 then player0x = 27 : player0y = 54 : return
   if _p1idx = 14 then player0x = 25 : player0y = 53 : return
   if _p1idx = 15 then player0x = 22 : player0y = 53 : return
   return
 
 ; Arc subroutine — P2 (top-right quadrant)
 ; Mirror X to right half: uses player1x/player1y
__arcP2
   if _p2idx = 0  then player1x = 113 : player1y = 18 : return
   if _p2idx = 1  then player1x = 113 : player1y = 21 : return
   if _p2idx = 2  then player1x = 114 : player1y = 23 : return
   if _p2idx = 3  then player1x = 114 : player1y = 26 : return
   if _p2idx = 4  then player1x = 115 : player1y = 28 : return
   if _p2idx = 5  then player1x = 116 : player1y = 31 : return
   if _p2idx = 6  then player1x = 118 : player1y = 33 : return
   if _p2idx = 7  then player1x = 119 : player1y = 35 : return
   if _p2idx = 8  then player1x = 121 : player1y = 37 : return
   if _p2idx = 9  then player1x = 123 : player1y = 38 : return
   if _p2idx = 10 then player1x = 125 : player1y = 40 : return
   if _p2idx = 11 then player1x = 127 : player1y = 41 : return
   if _p2idx = 12 then player1x = 128 : player1y = 42 : return
   if _p2idx = 13 then player1x = 130 : player1y = 42 : return
   if _p2idx = 14 then player1x = 131 : player1y = 43 : return
   if _p2idx = 15 then player1x = 132 : player1y = 43 : return
   return
 
 ; Arc subroutine — P3 (bottom-right quadrant)
 ; Mirror X to right, Y to bottom: player1x/player1y
__arcP3
   if _p3idx = 0  then player1x = 113 : player1y = 78 : return
   if _p3idx = 1  then player1x = 113 : player1y = 75 : return
   if _p3idx = 2  then player1x = 114 : player1y = 73 : return
   if _p3idx = 3  then player1x = 114 : player1y = 70 : return
   if _p3idx = 4  then player1x = 115 : player1y = 68 : return
   if _p3idx = 5  then player1x = 116 : player1y = 65 : return
   if _p3idx = 6  then player1x = 118 : player1y = 63 : return
   if _p3idx = 7  then player1x = 119 : player1y = 61 : return
   if _p3idx = 8  then player1x = 121 : player1y = 59 : return
   if _p3idx = 9  then player1x = 123 : player1y = 58 : return
   if _p3idx = 10 then player1x = 125 : player1y = 56 : return
   if _p3idx = 11 then player1x = 127 : player1y = 55 : return
   if _p3idx = 12 then player1x = 128 : player1y = 54 : return
   if _p3idx = 13 then player1x = 130 : player1y = 54 : return
   if _p3idx = 14 then player1x = 131 : player1y = 53 : return
   if _p3idx = 15 then player1x = 132 : player1y = 53 : return
   return

