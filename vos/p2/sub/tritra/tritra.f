      SUBROUTINE TRITRA(IND,CONV,NPH,NPV,LINE,SAMP,MODE)
C	THIS IS THE UCL VERSION OF TRITRA
C  TRANSFORM COORDINATES USING GEOMA PARAMETERS
C  CONV=GEOMA PARAMETERS STARTING AFTER 'TIEP' KEYWORD
C  NPH,NPV NUMBER POINTS HORIZONTAL,VERTICAL
C  LINE,SAMP  R*4 REPLACED BY OUTPUT VALUES
C  MODE=0 NL,NS TO OL,OS  MODE=1 OL,OS TO NL,NS
      REAL LINE,CONV(4,NPH,NPV),CORNER(2,4),POINT(2),A(16),B(4)
      CHARACTER*80 MSG1
      LOGICAL   INSIDE
C==================================================================
      II=2
      LL=1
      IITO=4
      LLTO=3
      IF(MODE.EQ.0) GO TO 5
      II=4
      LL=3
      IITO=2
      LLTO=1
5     CONTINUE
      POINT(1)=SAMP
      POINT(2)=LINE
      IND=0
      NAH=NPH-1
      NAV=NPV-1
C
C  FIND CLOSEST TIEPOINT TO LINE,SAMP
C  LOOP EACH ROW POINTS
      RMAX=1.0E+20
      SAMOLD=RMAX
      DO 90 L=1,NPV
C  LOOP EACH POINT IN ROW L
      DO 91 I=1,NPH
      SAMNEW=CONV(II,I,L)
      IF(SAMNEW.EQ.SAMOLD) GO TO 91
      R=(LINE-CONV(LL,I,L))**2+(SAMP-SAMNEW)**2
      IF(R.GT.RMAX) GO TO 92
      RMAX=R
      ISAV=I
      LSAV=L
92    SAMOLD=SAMNEW
91    CONTINUE
90    CONTINUE
C
C  SEARCH TWENTY QUADRILATERALS AROUND CLOSEST POINT
      ILEFT=ISAV-2
      IF(ILEFT.LT.1) ILEFT=1
      IRIGHT=ISAV+2
      IF(IRIGHT.GT.NAH) IRIGHT=NAH
      LTOP=LSAV-2
      IF(LTOP.LT.1) LTOP=1
      LBOT=LSAV+1
      IF(LBOT.GT.NAV) LBOT=NAV
C  AREA ROW LOOP
      DO 10 L=LTOP,LBOT
C  AREA COLUMN LOOP
      DO 20 I=ILEFT,IRIGHT
      N=1
C  LOAD UPPER LEFT CORNER
      CORNER(1,N)=CONV(II,I,L)
      CORNER(2,N)=CONV(LL,I,L)
C  CHECK IF POINTS ARE SAME
      IF(CORNER(1,N).EQ.CONV(II,I+1,L)) GO TO 40
      N=N+1
      CORNER(1,N)=CONV(II,I+1,L)
      CORNER(2,N)=CONV(LL,I+1,L)
40    CONTINUE
C  LOAD LOWER RIGHT POINT
      N=N+1
      CORNER(1,N)=CONV(II,I+1,L+1)
      CORNER(2,N)=CONV(LL,I+1,L+1)
C  CHECK IF POINTS ARE SAME
      IF(CONV(II,I,L+1).EQ.CORNER(1,N)) GO TO 41
      N=N+1
      CORNER(1,N)=CONV(II,I,L+1)
      CORNER(2,N)=CONV(LL,I,L+1)
41    CONTINUE
C  CHECK FOR DEGENERACY
      IF(N.GT.2) GO TO 43
      IND=1
      write (MSG1, 9000) I, L
9000  FORMAT('DEGENERATE QUADRILATERAL AT AH=',I3,'    AV=',I3)
      CALL XVMESSAGE(MSG1,' ')
      RETURN
43    CONTINUE
C  CHECK IF INSIDE CURRENT QUADRILATERAL
      IF(INSIDE(POINT,CORNER,N)) GO TO 50
20    CONTINUE
10    CONTINUE
C
C  POINT OUTSIDE QUADRILATERAL ARRAY - SET TO ONE OF 4 QUADS.
      I=ISAV
      L=LSAV
      IF(LINE.GT.CONV(LL,I,L)) GO TO 85
      IF(SAMP.GT.CONV(II,I,L)) GO TO 83
      I=I-1
      L=L-1
      IF(L.LT.1) L=1
      IF(I.LT.1) I=1
      GO TO 89
C  SAMP IS TO RIGHT OF ISAV
83    L=L-1
      IF(L.LT.1) L=1
      IF(I.EQ.NPH) GO TO 89
      IF(CONV(II,I,L).EQ.CONV(II,I+1,L)) I=I+1
      GO TO 89
C  LINE IS BELOW LSAV
85    IF(SAMP.GT.CONV(II,I,L)) GO TO 87
      I=I-1
      IF(I.LT.1) I=1
      GO TO 89
87    IF(I.EQ.NPH) GO TO 89
      IF(CONV(II,I,L).EQ.CONV(II,I+1,L)) I=I+1
89    IF(I.GT.NAH) I=NAH
      IF(L.GT.NAV) L=NAV
C  CHECK IF IS QUADRILATERAL OR REALLY A TRIANGLE (WHAT A PAIN)
      N=3
      IF(CONV(II,I,L).EQ.CONV(II,I+1,L)) GO TO 82
      IF(CONV(II,I,L+1).EQ.CONV(II,I+1,L+1)) GO TO 82
      N=4
82    CONTINUE
C
C  SOLVE SIMULTANEOUS EQUATIONS X,Y=A+BX+CY+DXY
50    IF(N.LT.4) GO TO 60
C  QUADRILATERALS ONLY
      DO 62 M=LLTO,IITO
      DO 61 J=1,4
61    A(J)=1.0
      A(5)=CONV(II,I,L)
      A(6)=CONV(II,I+1,L)
      A(7)=CONV(II,I,L+1)
      A(8)=CONV(II,I+1,L+1)
      A(9)=CONV(LL,I,L)
      A(10)=CONV(LL,I+1,L)
      A(11)=CONV(LL,I,L+1)
      A(12)=CONV(LL,I+1,L+1)
      A(13)=A(5)*A(9)
      A(14)=A(6)*A(10)
      A(15)=A(7)*A(11)
      A(16)=A(8)*A(12)
      B(1)=CONV(M,I,L)
      B(2)=CONV(M,I+1,L)
      B(3)=CONV(M,I,L+1)
      B(4)=CONV(M,I+1,L+1)
      CALL SIMQ(A,B,N,IND)
      IF(IND.NE.0) CALL XVMESSAGE('SIMQ MATRIX IS SINGULAR',' ')
      IF(IND.NE.0) RETURN
      IF(M.EQ.IITO) GO TO 63
      XLINE=B(1)+B(2)*SAMP+B(3)*LINE+B(4)*LINE*SAMP
      GO TO 62
63    SAMP=B(1)+B(2)*SAMP+B(3)*LINE+B(4)*LINE*SAMP
      LINE=XLINE
62    CONTINUE
      RETURN
C
C  TRIANGLES ONLY
60    DO 65 M=LLTO,IITO
      DO 66 J=1,3
66    A(J)=1.0
      A(4)=CONV(II,I,L)
      A(7)=CONV(LL,I,L)
      B(1)=CONV(M,I,L)
      IF(CONV(II,I+1,L).EQ.A(4)) GO TO 67
      A(5)=CONV(II,I+1,L)
      A(8)=CONV(LL,I+1,L)
      B(2)=CONV(M,I+1,L)
67    A(6)=CONV(II,I,L+1)
      A(9)=CONV(LL,I,L+1)
      B(3)=CONV(M,I,L+1)
      IF(CONV(II,I+1,L+1).EQ.A(6)) GO TO 68
      A(5)=CONV(II,I+1,L+1)
      A(8)=CONV(LL,I+1,L+1)
      B(2)=CONV(M,I+1,L+1)
68    CALL SIMQ(A,B,N,IND)
      IF(IND.NE.0) CALL XVMESSAGE('SIMQ MATRIX IS SINGULAR',' ')
      IF(IND.NE.0) RETURN
      IF(M.EQ.IITO) GO TO 69
      XLINE=B(1)+B(2)*SAMP+B(3)*LINE
      GO TO 65
69    SAMP=B(1)+B(2)*SAMP+B(3)*LINE
      LINE=XLINE
65    CONTINUE
      RETURN
      END