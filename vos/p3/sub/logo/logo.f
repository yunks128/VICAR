      SUBROUTINE LOGO(IDN,LINE,ILOGO,BGR,BUF)
C     24 MAY 83   ...JHR...  INITIAL RELEASE
C      2 MAR 94   ...REA...  ASTER LOGO ADDED
C
C   THIS ROUTINE GENERATES LOGOS FOR USE WITH MASK PROGRAMS.
C   ONE LINE IS GENERATED EACH TIME THE ROUTINE IS CALLED.
C   THE IMAGE SIZE OCCUPIED BY EACH LOGO IS 64 LINES BY 64 SAMPLES.
C   THE LOGOS ARE STORED HERE SUCH THAT EACH BYTE IS REPRESENTED BY
C   A SINGLE BIT.
C
C   ARGUMENTS IN THE CALLING SEQUENCE ARE:
C     IDN     THE DN VALUE FOR THE LOGO
C     LINE    THE RELATIVE LINE NUMBER (I.E., 1 - 64)
C     ILOGO   SPECIFIES THE LOGO TO BE USED
C             1 = JPL
C             2 = MICKEY MOUSE
C             3 = GODDARD
C             4 = NASA
C             5 = ASTER
C     BGR     RESERVED FOR POSSIBLE FUTURE COLOR LOGOS
C             0 = BLACK AND WHITE
C             1 = BLUE
C             2 = GREEN
C             3 = RED
C     BUF     BUFFER IN WHICH LOGO IS RETURNED (BYTE)
C
      INTEGER*4 BGR,IP(8)/1,2,4,8,16,32,64,128/
      BYTE BUF(8,8),DN
C
C               *** DATA FOR JPL LOGO ***
C
      BYTE PTS1(8,64)/72*0,    3*0,7,-64,3*0,
     & 3*0,4,64,3*0, 3*0,4,64,3*0,  3*0,4,64,3*0,
     & 0,15,-128,4,64,3*0,          0,8,-128,4,64,3*0,
     & 0,8,-128,4,64,3*0,           0,8,-128,4,64,3*0,
     & 0,8,-128,4,64,3*0,           0,15,-128,4,64,3*0, 3*0,4,
     & 64,3*0, 0,15,-65,-60,64,3*0, 0,8,-96,36,64,3*0,
     & 0,8,-96,20,64,3*0,           0,8,-96,20,64,3*0,
     & 0,8,-93,-108,64,3*0,         0,8,-94,-108,64,3*0,
     & 0,8,-94,-108,64,0,63,0,      0,8,-94,-108,64,2*0,-32,
     & 0,8,-94,-108,64,2*0,112,     0,8,-94,-108,64,0,1,-2,
     & 127,-8,-29,-100,127,3*-1,    0,8,-94,-108,64,0,1,-2,
     & 0,8,-94,-108,64,0,1,-8,      0,8,-94,-108,64,0,7,-32,
     & 0,8,-94,-108,64,0,15,0,      0,8,-94,-108,64,0,56,0,
     & 0,8,-93,-108,64,7,-64,0,     0,8,-96,20,64,3*0,
     & 0,24,-96,20,64,3*0,          0,112,-93,100,64,3*0,
     & 0,64,-94,-57,-64,3*0,        0,64,-94,5*0,
     & 0,65,34,5*0,  0,79,34,5*0,   0,120,34,5*0,
     & 2*0,34,5*0,   2*0,34,5*0,    2*0,34,5*0,
     & 2*0,34,5*0,   2*0,34,5*0,    2*0,34,5*0,
     & 2*0,34,5*0,   2*0,34,5*0,    2*0,62,5*0,  80*0/
C
C               *** DATA FOR MICKEY MOUSE LOGO ***
C
      BYTE PTS2(8,64),PTS2A(8,32),PTS2B(8,32)
      EQUIVALENCE (PTS2(1,1),PTS2A(1,1)),(PTS2(1,33),PTS2B(1,1))
      DATA PTS2A/72*0,             5*0,30,2*0,
     & 2*0,-8,2*0,127,-64,0,       0,3,-2,2*0,-1,-16,0,
     & 0,15,-1,0,1,-1,-8,0,        0,31,-1,-128,3,-1,-4,0,
     & 0,63,-1,-128,7,-1,-4,0,     0,127,-1,-64,7,-1,-2,0,
     & 0,127,-1,-64,7,-1,-2,0,     0,127,-1,-64,7,-1,-2,0,
     & 0,-1,-1,-64,7,-1,-2,0,      0,-1,-1,-64,7,-1,-2,0,
     & 0,-1,-1,-49,-25,-1,-2,0,    0,-1,-1,-2,127,-1,-2,0,
     & 0,-1,-1,-8,63,-1,-2,0,      0,-1,-1,0,0,-1,-4,0,
     & 0,-1,-2,124,124,127,-4,0,   0,127,-4,68,68,63,-8,0,
     & 0,63,-4,-40,54,63,-32,0,    0,31,-4,-84,-54,31,-64,0,
     & 0,15,-8,66,-124,30,2*0,     2*0,120,66,-124,30,2*0,
     & 2*0,120,66,-124,15,2*0,     2*0,-8,66,-124,15,2*0/
      DATA PTS2B/2*0,-8,76,100,31,2*0,
     & 2*0,-8,95,-12,31,-128,0,    0,1,-8,94,-12,31,-128,0,
     & 0,1,-4,60,120,63,-128,0,    0,1,-4,27,-80,63,-128,0,
     & 0,1,-28,55,-40,39,-128,0,   0,3,-128,111,-20,0,-64,0,
     & 0,3,0,95,-12,96,-64,0,      0,2,15,31,-16,112,64,0,
     & 0,2,31,31,-16,120,64,0,     0,2,27,7,-64,-56,-128,0,
     & 0,2,19,-128,1,-128,-128,0,  0,2,1,64,2,-127,-128,0,
     & 0,1,0,-80,13,1,0,0,         0,0,-128,-97,-13,2,0,0,
     & 0,0,64,64,2,4,0,0,          0,0,32,95,-12,24,0,0,
     & 0,0,24,-65,-6,32,0,0,
     & 0,0,6,-33,-10,-64,0,0,      0,0,1,-49,-17,3*0,
     & 3*0,99,-104,3*0,            3*0,2*48,3*0, 3*0,15,-64,3*0,
     & 72*0/
C
C               *** DATA FOR GODDARD LOGO ***
C
      BYTE PTS3(8,64),PTS3A(8,32),PTS3B(8,32)
      EQUIVALENCE (PTS3(1,1),PTS3A(1,1)),(PTS3(1,33),PTS3B(1,1))
      DATA PTS3A/8*0,        4*0,-128,3*0,     4*0,-128,3*0,
     & 4*0,-128,3*0,         4*0,-128,3*0,     3*0,1,-64,3*0,
     & 3*0,1,-64,3*0,        3*0,3,-32,3*0,    3*0,5,-48,3*0,
     & 3*0,9,-56,3*0,        3*0,16,-124,3*0,  3*0,17,-60,3*0,
     & 3*0,16,4,3*0,         3*0,16,4,3*0,     3*0,16,4,3*0,
     & 3*0,16,4,3*0,         3*0,16,4,3*0,     3*0,16,4,3*0,
     & 3*0,16,4,3*0,         3*0,16,4,3*0,     3*0,16,4,3*0,
     & 3*0,127,-1,3*0,       3*0,127,-1,3*0,   3*0,80,5,3*0,
     & 3*0,-48,5,-128,2*0,   3*0,-48,5,-128,2*0,
     & 3*0,-112,4,-128,2*0,  3*0,-112,4,-128,2*0,
     & 2*0,1,-112,4,-64,2*0, 2*0,1,-112,4,-64,2*0,
     & 2*0,1,-112,4,-64,2*0, 2*0,1,16,4,64,2*0/
      DATA PTS3B/2*0,3,16,4,96,2*0,
     & 2*0,3,16,4,96,2*0,      2*0,3,16,-124,96,2*0,
     & 2*0,2,17,-60,32,2*0,    2*0,6,19,-28,48,2*0,
     & 2*0,6,23,-12,48,2*0,    2*0,6,19,-28,48,2*0,
     & 2*0,4,31,-4,16,2*0,     2*0,12,3,-32,24,2*0,
     & 2*0,12,3,-32,24,2*0,    2*0,12,3,-32,24,2*0,
     & 2*0,8,3,-32,8,2*0,      2*0,24,1,-64,12,2*0,
     & 2*0,24,1,-64,12,2*0,    2*0,24,1,-64,12,2*0,
     & 2*0,16,1,-64,4,2*0,     2*0,48,1,-64,6,2*0,
     & 2*0,48,1,-64,6,2*0,     2*0,48,0,0,6,2*0,
     & 2*0,32,0,0,2,2*0,       2*0,96,0,0,3,2*0,
     & 2*0,99,-50,124,-29,2*0, 2*0,100,17,65,19,2*0,
     & 2*0,100,8,65,3,2*0,     2*0,100,-60,113,3,2*0,
     & 2*0,100,66,65,3,2*0,    2*0,100,81,65,19,2*0,
     & 2*0,99,-50,64,-29,2*0,  2*0,96,0,0,3,2*0,
     & 2*0,127,-1,-1,-1,2*0,   2*0,127,-1,-1,-1,2*0,
     & 8*0/
C
C               *** DATA FOR NASA LOGO ***
C
      BYTE PTS4(8,64)/176*0,     28,15,1,-64,15,-4,3,-128,
     & 62,15,3,-32,63,-4,7,-64,       127,15,7,-16,127,-4,15,-32,
     & -1,-113,7,-16,-1,-4,15,-32,    -9,-113,15,120,-8,0,30,-16,
     & -9,-113,15,120,-16,0,30,-16,   -9,-113,15,120,-16,0,30,-16,
     & -13,-49,15,120,-8,0,30,-16,    -13,-49,30,60,-1,-32,60,120,
     & -13,-49,30,60,127,-8,60,120,   -13,-49,30,60,63,-4,60,120,
     & -13,-49,30,60,15,-2,60,120,    -13,-49,60,30,0,62,120,60,
     & -15,-17,60,30,0,30,120,60,     -15,-17,60,30,0,30,120,60,
     & -15,-17,60,30,0,62,120,60,     -15,-1,120,15,-1,-2,-16,30,
     & -16,-2,120,15,-1,-4,-16,30,    -16,124,120,15,-1,-8,-16,30,
     & -16,56,120,15,-1,-32,-16,30,   176*0/
C
C               *** DATA FOR ASTER LOGO ***
C
	BYTE ASTER1(64,6) /
     a 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     b 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     c 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     d 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     e 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     f 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     g 0, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     h-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     i-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0,
     j 0, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     k-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     l-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0,
     m 0, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     n-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     o-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0,
     p 0, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     q-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     r-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0/
	BYTE ASTER2(64,6) /
     a 0, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     b-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     c-1, 0, 0, 0, 0, 0, 0, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0,
     d 0, 0,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0,
     e 0,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0,-1,-1,-1, 0, 0, 0, 0, 0, 0,
     f-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0,-1,-1,-1,-1,-1,-1, 0, 0,
     g 0, 0,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1,-1, 0,-1,-1,
     h-1, 0,-1,-1,-1, 0,-1,-1, 0, 0,-1,-1, 0,-1,-1,-1, 0, 0,-1,-1,-1, 0,
     i-1,-1,-1, 0, 0, 0,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1, 0, 0,
     j 0, 0,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1,-1, 0,-1,-1,
     k-1, 0,-1,-1,-1, 0,-1,-1, 0, 0,-1,-1,-1,-1,-1,-1,-1, 0,-1,-1,-1, 0,
     l-1,-1,-1, 0, 0, 0,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1, 0, 0,
     m 0, 0,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1,-1, 0,-1,-1,
     n-1,-1,-1,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1,-1,-1,-1, 0,-1,-1,-1,-1,
     o-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1, 0, 0,
     p 0, 0,-1,-1,-1,-1,-1,-1,-1, 0,-1, 0, 0,-1,-1,-1,-1,-1,-1, 0, 0,-1,
     q-1,-1,-1,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1,-1,-1,-1, 0,-1,-1,-1,-1,
     r-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1, 0, 0/
	BYTE ASTER3(64,6) /
     a 0, 0,-1,-1,-1,-1,-1,-1,-1, 0,-1, 0, 0, 0,-1,-1,-1,-1,-1, 0, 0,-1,
     b-1,-1,-1,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1,-1,-1,-1, 0,-1,-1, 0,-1,
     c-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1, 0, 0,
     d 0, 0,-1,-1,-1,-1,-1,-1,-1, 0,-1, 0, 0, 0,-1,-1,-1,-1,-1, 0, 0, 0,
     e-1,-1,-1,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1,-1,-1,-1, 0,-1,-1, 0,-1,
     f-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1, 0, 0,
     g 0, 0,-1,-1,-1,-1,-1,-1,-1, 0,-1,-1, 0, 0,-1,-1,-1,-1,-1,-1, 0, 0,
     h 0, 0,-1,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0,-1,
     i-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1, 0, 0,
     j 0, 0,-1,-1,-1,-1,-1,-1, 0,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1,-1, 0,
     k 0, 0,-1,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1,-1,-1,-1, 0,-1,-1, 0,-1,
     l-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1,-1, 0, 0,
     m 0, 0,-1,-1,-1,-1,-1,-1, 0,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,
     n 0, 0, 0,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1,-1,-1,-1, 0,-1,-1, 0,-1,
     o-1,-1,-1, 0, 0, 0,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1, 0, 0,
     p 0, 0,-1,-1,-1,-1,-1,-1, 0,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,
     q-1, 0, 0,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1,-1,-1,-1, 0,-1,-1,-1,-1,
     r-1,-1,-1, 0, 0, 0,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1,-1, 0, 0/
	BYTE ASTER4(64,6) /
     a 0, 0,-1,-1,-1,-1,-1,-1, 0,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1,-1,-1,-1,
     b-1, 0, 0,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1,-1,-1,-1, 0,-1,-1,-1,-1,
     c-1,-1,-1, 0, 0, 0, 0, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0,
     d 0, 0,-1,-1,-1,-1,-1, 0,-1,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1, 0,-1,-1,
     e-1, 0, 0,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1,-1,-1,-1, 0,-1,-1,-1,-1,
     f 0,-1,-1, 0, 0, 0,-1, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0,
     g 0, 0,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0,-1,-1,-1, 0,-1,-1,
     h-1, 0, 0,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1,-1,-1,-1, 0,-1,-1,-1,-1,
     i 0,-1,-1, 0, 0, 0,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1, 0, 0,
     j 0, 0,-1,-1,-1,-1,-1, 0,-1,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1, 0, 0,-1,
     k-1, 0,-1,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1,
     l 0,-1,-1, 0, 0, 0,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1, 0, 0,
     m 0, 0,-1,-1,-1,-1, 0,-1,-1,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1, 0, 0,
     n 0,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0,
     o 0,-1,-1, 0, 0, 0,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1,-1, 0, 0,
     p 0, 0,-1,-1,-1,-1, 0,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1,
     q-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     r-1,-1,-1, 0, 0, 0,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1,-1, 0, 0/
	BYTE ASTER5(64,6) /
     a 0, 0,-1,-1,-1,-1, 0,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0,-1,-1, 0, 0, 0,
     b 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     c 0,-1,-1, 0, 0, 0,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1, 0, 0,
     d 0, 0,-1,-1,-1,-1, 0,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1,
     e-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     f-1,-1,-1, 0, 0, 0,-1,-1,-1,-1, 0, 0, 0, 0,-1,-1,-1,-1, 0, 0,
     g 0, 0,-1,-1,-1, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0,-1,-1,-1,-1,-1,
     h-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     i-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1, 0, 0,
     j 0, 0,-1,-1,-1, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,
     k-1,-1,-8,-1,-1,-1,-1,-1,-26,-98,-77,-70,-73,-96,-119,-121,-114,-8,
     l-1,-1,-1,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1, 0, 0, 0, 0,-1,-1,-1,
     m 0, 0, 0, 0,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0,-1,
     n-1,-1,-6,-98,-80,-93,-112,-45,-1,-1,-1,-1,-1,-19,-31,-36,-15,-1,
     o-1,-1,-75,-98,-1,-1,-1,-1,-1, 0, 0, 0,-1,-1,-1,-1,-1,-1, 0, 0, 0,
     p-1,-1,-1, 0, 0, 0, 0,-1, 0, 0, 0, 0, 0,-1,-1,-1,-1,-1, 0, 0, 0, 0,
     q 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,-1,-36,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     r-70,125,-119,-56,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0,-1,-1,-1,-1, 0, 0, 
     s 0, 0, 0,-1, 0, 0/
	BYTE ASTER6(64,6) / 0, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     a-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-59,-66,-26,-17,-19,
     b-38,-84,127,125,-61, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     c-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     d-1,-1,-1,-1,-1,-1,-1,-70,-112,127,127,127,-116,-68,-1,-1,-1,-1,-1,
     e-33,-63,-82,-86,-73, -36,-1,-1,-8,-75,-98,-110,-86,-1,-1,-1,-1,-1,
     f-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0,-1,-1,-1,-1,-1,-1,
     g-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-89,-126,-110,-45,-1,-1,-1,-1,-1,
     h-19,-29,-1,-1,-1,-1,-1, -1,-1,-1,-1,-26,127,127,-89,-43,-13,-1,-8,
     i-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0,-1,-1,
     j-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-36,-123,-105,-22,-1,-1,-1,-1,
     k-1,-1,-1,-1,-1,-1,-56, -13,-1,-1,-1,-1, -38,-103,125,-93,-1,-1,-1,
     l-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0,
     m 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-22,-1,-1,-1,-26,-70,
     n-96,-107,-100,-77,-24,-1,-1,-1,-1, -19,-75, -107,127,127,-116,-84,
     o-19,-1,-1,-15,-47,-61, -38,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     p-1,-1,-1,-1,0, 0, 0, 0, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     q-1,-1,-45,-121,127,-96,-38,-8,-1,-1,-22,-70,-22,-1,-1,-1,-1,-1,-1,
     r-1,-1,-1,-1,-86,127,127,-91,-59,-48,-56,-82,-66,-1,-1,-1,-1,-1,-1,
     s-1,-1,-1,-1,-1,-1,-1,-1,0,0/
	BYTE ASTER7(64,6) / 0, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-6,
     a-31,-75,-121,-123,-63,-1,-1,-1,-1,-1,-1,-1,-1,-1,-22,-19,-1,-1,-1,
     b-1,-1,-1,-54,-119,-119, -29,-1,-1,-1,-1,-1,-1,-1,-22,-52,-1,-1,-1,
     c-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     d-1,-82,-105,-107,-110,-89,-50,-1,-1,-1,-26, -54,-68,-56,-19,-1,-1,
     e-1,-1,-1,-91,127,-121,-116,122,119,-123,-68,-1,-1,-1,-1,-6, -1,-1,
     f-1,-1,-1,-1,-43,-48,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0, 0, 0,-1,-1,
     g-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-6,-93,127,-119,-86,-66,
     h-52,-59,-86,-80,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-36,-105,127,127,
     i-107,-103,-117,-98, -13,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     j 0, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,  -50,-8,-1,-1,-1,-1,-1,-22, -91,
     k-121,-103,-17,-1,-1,-1,-1,-1,-1,-1,-6,-19,-1,-1,-1,-1,-1,-1,-1,-1,
     l-93,-123,-82,-1,-1,-1, -1,-1,-1,-1,-54,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     m-1,-1,-1,-1,0,0,   0,0,-1,-1,-1,-1, -1,-1,-1,-1,-52,-119,122, 117,
     n119,117,125,-98,-29,-1,-1,-1, -1,-1,-1,-1,-1,-1,-1,-1,-54,-98,-77,
     o-61,-63,-86,127,119, -119,-31,-1,-1,-1,-1,-1,-1,-1,-1, -1, -8,-99,
     p-93,-84,-87,-1,-1,-1,-1,-1,-1,-1,-1,0,0,  0,0,-1,-1,-1,-1,-22,-15,
     q-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, -49,-112,125,127,-116,-112,-114,
     r-36,-1,-1,-1,-1,-1,-40,-63,-63,-40,-1,-1,-1,-68,-99,-119,122, -89,
     s-99,-40,-1,-1,-1,-1,-1,-13,-46,-46,-13,-1,-1,-1,-1,-1,-1,-1, 0, 0/
	BYTE ASTER8(64,6) /0,0,-1,-1,-1,-1,-1,-19,-56, 0,-1, 0,-1,-1,-1,
     a-1,-1,-48,-110,-126, -75,-8,-1,-1,-1,-1,-1,-1, -38,-1,-1,-1,-1,-1,
     b-1,-1,-1,-1,-52,-123,-116,-66,-8,-1,-1,-1,-24,-70,-31,-1,-1,-1,-1,
     c-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0, 0, 0,-1,-1,-1,-1,-1,-1,0, 0, 0, 0,
     d 0,-80,-82,-107,125,122,-96,-1,-1,-1, -1,-1,-1,-1,-1,-1,-1,-1,-77,
     e-33,-1,-1,-1,-26,-63,-123,122,-93,-1,-1,-1,-1, -1,-1,-1,-1,-1,-63,
     f-66,-26,-9,-8,-31,-77,-99,-1,-1,-1,-1,-1,0,0,0,0,-1,-116,-121,-89,
     g-36, 0,0,0,0,0,0,0,-43,-36,-17,-1,-1,-1,-56,-110,117,114,122,-105,
     h-49,-1,-1,-1,-1,-8,-73,-99, -114, -119, -110,-70,-1,-1,-1,-52,-77,
     i-82, -61,-29,-1,-1,-1,-1,-1,-29,-75,-107,-99,-98,-77,-31,-1,-1,-1,
     j-1, 0,0, 0, 0,-1,-1,-1,-1, 0, 0, 0, 0, 0,0,0,0,0,-1,-1,-1,-80,119,
     k127,-70, -29, -1,-1,-1,-23, -56,-31,-1,-1,-1,-1,-1,-1,-1,-1,-1,-8,
     l-105,-121,-110,-70,-45,-24,-52,-77,-70,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     m-1,-6,-93,-15,-1, 0, 0, 0, 0,-1,-1,-1, 0, 0, 0, 0, 0, 0,0,0,0,0,0,
     n-105,117,119,-70,-1,-1,-1,-1,-1,-1,-1,-1,-1, -40, -38,-1,-1,-1,-1,
     o-1,-1,80,-123,-121,-15,-1,-1,-1,-1,-1,-1,-1, -15, -45,-1,-1,-1,-1,
     p-1,-1,-24,-93,119,-106,-24,-1,0,0, 0, 0,-73,-75, 0, 0, 0, 0, 0, 0,
     q 0, 0, 0, 0, 0, 0,0,-38,-1,-1,-1,-45,-86,-96,-96,0,-1,-1,-1,-1,-1,
     r-77,127,125,125,122,117,-123,-63,-1,-1,-1,-13,-13, -1,-1,-1,-1,-1,
     s-1,-36,-103,127,122,119,117,117,0,-36,-1,-1, 0, 0, 0/
	BYTE ASTER9(64,6) /
     a 0, 0,-59,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,-26,0,0,125,
     b-98,-73,0,0,0,-91,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,-1,-61,125,119,127,
     c-117, -98,-114,-107,-26,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,-45,0,0,0,0,
     d 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     e-1, 0, 0, 0, 0, 0,-1, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     f-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     g 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     h 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     i 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     j 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     k 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     l 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     m 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     n 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     o 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     p 0, 0, 0, 0, 0, 0, 0, 0, 0,-1, 0, 0, 0,-1, 0, 0, 0,-1,-1,-1,-1, 0,
     q 0, 0, 0,-1, 0, 0, 0,-1, 0, 0, 0,-1, 0, 0, 0, 0, 0, 0, 0,-1, 0, 0,
     r 0,-1, 0, 0,-1,-1,-1, 0, 0, 0, 0,-1, 0, 0, 0, 0, 0, 0, 0, 0/
	BYTE ASTER10(64,6) /
     a 0, 0, 0, 0, 0, 0, 0, 0, 0,-1, 0, 0,-1, 0,-1, 0, 0,-1, 0, 0, 0,-1,
     b 0, 0,-1, 0,-1, 0, 0,-1,-1, 0, 0,-1, 0, 0, 0, 0, 0,-1, 0,-1, 0, 0,
     c 0,-1, 0,-1, 0, 0, 0,-1, 0, 0,-1, 0,-1, 0, 0, 0, 0, 0, 0, 0,
     d 0, 0, 0, 0, 0, 0, 0, 0, 0,-1, 0,-1, 0, 0, 0,-1, 0,-1, 0, 0, 0,-1,
     e 0,-1, 0, 0, 0,-1, 0,-1, 0,-1, 0,-1, 0, 0, 0, 0,-1, 0, 0,-1, 0, 0,
     f 0,-1, 0, 0,-1, 0, 0, 0, 0,-1, 0, 0, 0,-1, 0, 0, 0, 0, 0, 0,
     g 0, 0, 0, 0, 0, 0, 0, 0, 0,-1, 0,-1, 0, 0, 0,-1, 0,-1,-1,-1,-1, 0,
     h 0,-1, 0, 0, 0,-1, 0,-1, 0, 0,-1,-1, 0, 0, 0,-1, 0, 0, 0,-1, 0, 0,
     i 0,-1, 0, 0, 0,-1, 0, 0, 0,-1, 0, 0, 0,-1, 0, 0, 0, 0, 0, 0,
     j 0, 0, 0, 0, 0, 0, 0, 0, 0,-1, 0,-1,-1,-1,-1,-1, 0,-1, 0, 0, 0, 0,
     k 0,-1,-1,-1,-1,-1, 0,-1, 0, 0, 0,-1, 0, 0,-1, 0, 0, 0, 0,-1, 0, 0,
     l 0,-1, 0, 0, 0, 0,-1, 0, 0,-1,-1,-1,-1,-1, 0, 0, 0, 0, 0, 0,
     m 0, 0, 0, 0, 0,-1, 0, 0, 0,-1, 0,-1, 0, 0, 0,-1, 0,-1, 0, 0, 0, 0,
     n 0,-1, 0, 0, 0,-1, 0,-1, 0, 0, 0,-1, 0,-1, 0, 0, 0, 0, 0,-1, 0, 0,
     o 0,-1, 0,-1, 0, 0, 0,-1, 0,-1, 0, 0, 0,-1, 0, 0, 0, 0, 0, 0,
     p 0, 0, 0, 0, 0, 0,-1,-1,-1, 0, 0,-1, 0, 0, 0,-1, 0,-1, 0, 0, 0, 0,
     q 0,-1, 0, 0, 0,-1, 0,-1, 0, 0, 0,-1, 0, 0, 0, 0, 0, 0, 0, 0,-1,-1,
     r-1, 0, 0, 0,-1,-1,-1, 0, 0,-1, 0, 0, 0,-1, 0, 0, 0, 0, 0, 0/
	BYTE ASTER11(64,4) /
     a 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     b 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     c 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     d 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     e 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     f 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     g 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     h 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     i 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     j 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     k 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     l 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0/
	BYTE ASTER(64,64)
	EQUIVALENCE (ASTER(1,1),ASTER1),(ASTER(1,7),ASTER2)
	EQUIVALENCE (ASTER(1,13),ASTER3),(ASTER(1,19),ASTER4)
	EQUIVALENCE (ASTER(1,25),ASTER5),(ASTER(1,31),ASTER6)
	EQUIVALENCE (ASTER(1,37),ASTER7),(ASTER(1,43),ASTER8)
	EQUIVALENCE (ASTER(1,49),ASTER9),(ASTER(1,55),ASTER10)
	EQUIVALENCE (ASTER(1,61),ASTER11)
C
      BYTE DATABASE(8,64,4)
      EQUIVALENCE (PTS1(1,1),DATABASE(1,1,1))
      EQUIVALENCE (PTS2(1,1),DATABASE(1,1,2))
      EQUIVALENCE (PTS3(1,1),DATABASE(1,1,3))
      EQUIVALENCE (PTS4(1,1),DATABASE(1,1,4))
C
      IF(LINE.LT.1.OR.LINE.GT.64) RETURN
C
      CALL ZIA(BUF,16)
      IF (ILOGO.EQ.0) RETURN
      IF (ILOGO.EQ.5) THEN
	  CALL MVE(1,64,ASTER(1,LINE),BUF,1,1)
      ELSE
	  CALL ITL(IDN,DN)
	  DO I=1,8
	      MASK = IV(DATABASE(I,LINE,ILOGO))
	      DO J=8,1,-1
	          K = MOD(MASK,2)
	          IF (K .EQ. 1) BUF(J,I) = DN
	          MASK = MASK/2
	      END DO
	  END DO
      END IF
C
      RETURN
      END
