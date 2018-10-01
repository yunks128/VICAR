C   6-87  KFE   Add tiepoint input from IBIS interface file.
C
C   1-87  SXP   Modified to use DGELG and LLSQ to solve linear and linear least 
C               squares system of equations.
C
C   10-94 CRS (CRI) Ported to UNIX 
C
      INCLUDE 'VICMAIN_FOR'
      SUBROUTINE MAIN44
C
C  IBIS ROUTINE TIECONM - A. ZOBRIST   G. MANACHER
C
C
      IMPLICIT INTEGER(A-Z)
      INTEGER MAXTIE, MAXLSQ, MAXOUT
      INTEGER*2 LPTR,LNBR,LINK,HEAPF,HEAPT,DANGLE
      REAL*4 PTX,PTY,HEAPL,ANGLE
      PARAMETER (MAXTIE=1600,  MAXLSQ=400, MAXOUT=40000)
      COMMON /COM1/ RPAR(4*MAXTIE+25)
      COMMON /COM2/ PTX(MAXTIE),PTY(MAXTIE),LPTR(MAXTIE),
     .      LNBR(6*MAXTIE),LINK(6*MAXTIE),
     .      HEAPF(MAXTIE),HEAPT(MAXTIE),HEAPL(MAXTIE),
     .      ANGLE(MAXTIE),DANGLE(MAXTIE)
      COMMON /COM3/ CON1(2*MAXTIE), CON2(2*MAXTIE), CON3(2*MAXTIE)
      CHARACTER*72 OUTNAM
      REAL TMAXX,TMAXY,TMINX,TMINY,X,Y,XX,YY,TPTS(1),XSQ,YSQ
      REAL*4 CLSQ(3*MAXLSQ), CLSQXY(2*MAXLSQ), ELSQXY(2*MAXLSQ)
      REAL*4 CSOL(6),AUX(6),REJECT
      REAL*8 TAB(6),WORK(36)
      REAL*4 RPAR, COEFF(6,2*MAXTIE),DX,DY,MINX,MINY,MAXX,MAXY
      REAL*4 ROUT(4*MAXOUT)
      INTEGER   IPIV(3)
      INTEGER*2 CON1,CON2,CON3
      INTEGER   COLS(4)
      LOGICAL   GEOMA,LGEOM,ZGEOM,MGEOM,ABENDL,LONLY,INSIDE
      LOGICAL	PLOT,NOPRINT, XVPTST
      CHARACTER*4 TIEP, OINT, BLANK, SAMP,LE,LINE,NAHC,NAVC

      DATA NAH,NAV,NPOINT,NRANK,NERR/30,30,4,6,0/
      DATA GEOMA/.TRUE./,LGEOM/.FALSE./, REJECT/.01/
      DATA SAMP,LE,LINE,NAHC,NAVC/'SAMP','LE  ','LINE','NAH ','NAV '/
      DATA TIEP,OINT/'TIEP','OINT'/,BLANK/' '/
      EQUIVALENCE (TPTS,COEFF)
      EQUIVALENCE (TPTS,PTX)

      CALL IFMESSAGE('TIECONM version 31-OCT-94')
C---- READ PARAMETERS.

      NOPRINT = XVPTST('NOPRINT')

C		If INP file specified then read in tiepoints from
C		  the IBIS interface file.
      CALL XVPCNT ('INP', INPCNT)
      IF (INPCNT .GT. 0) THEN
        CALL XVUNIT( UNIT, 'INP', 1, STATUS,' ' )  
	CALL XVPARM ('COLS', COLS, COLCOUNT, DEF,4 )
	CALL IBIS_FILE_OPEN(UNIT,IBIS,'READ',0,0,' ',' ',STATUS)
        IF (STATUS.NE.1) CALL IBIS_SIGNAL(IBIS,STATUS,1)
	CALL IBIS_FILE_GET(IBIS,'NR',CLEN,1,1)
        PTR = 1
        CALL IBIS_RECORD_OPEN(IBIS,RECORD,'FORMAT:REAL',
     +                     COLS,COLCOUNT,'REAL',STATUS)
          IF (STATUS.NE.1) CALL IBIS_SIGNAL(IBIS,STATUS,1)
	  DO ROW = 1, CLEN
              CALL IBIS_RECORD_READ(RECORD,RPAR(PTR),ROW,STATUS)
              IF (STATUS.NE.1) CALL IBIS_SIGNAL(IBIS,STATUS,1)
	      PTR = PTR + COLCOUNT
	  ENDDO
          CALL IBIS_FILE_CLOSE(IBIS,' ', STATUS)
          IF (STATUS.NE.1) CALL IBIS_SIGNAL(IBIS,STATUS,1)
	  NTIEPP = PTR - 1
      ELSE
	  CALL XVPARM('TIEPOINT', RPAR, NTIEPP, TIEPDF,(4*MAXTIE+25))
      ENDIF

      CALL XVPARM('NAH',NHT,ICNT,IDEF,1)
      CALL XVPARM('NAV',NVT,ICNT,IDEF,1)


      ABENDL = XVPTST('ABEND')
      CALL XVPARM('REJECT',REJECT,ICNT,IDEF,1)
      REJECT = REJECT**2
        GEOMA = XVPTST('GEOMA')
        MGEOM = XVPTST('MGEOM')
        LONLY = XVPTST('LGEOM')
        LGEOM = MGEOM.OR.LONLY
        ZGEOM = XVPTST('GEOMZ')
        PLOT = XVPTST('PLOT')

      IF (ZGEOM) NPOINT = 3
      IF (ZGEOM) NRANK = 3
        N = NTIEPP/NPOINT
      IF (N .LE. 3) THEN
	  CALL PRNT (4,1,N,'NEED 4 TIEPOINTS.')
	  CALL ABEND
      ENDIF
      IF (N .GT. MAXTIE) THEN
	  CALL XVMESSAGE('MAXIMUM INPUT TIEPOINTS EXCEEDED',' ')
          CALL ABEND
      ENDIF
      IF ((NHT+1)*(NVT+1) .GT. MAXOUT) THEN
	  CALL XVMESSAGE('MAXIMUM OUTPUT TIEPOINTS EXCEEDED',' ')
          CALL ABEND
      ENDIF

      IF (.NOT.LGEOM) GO TO 1235
      IU = NTIEPP-3
      DO 1234 I=1,IU,4
         DX = RPAR(I)
         RPAR(I) = RPAR(I+2)
         RPAR(I+2) = DX
         DX = RPAR(I+1)
         RPAR(I+1) = RPAR(I+3)
 1234 RPAR(I+3) = DX
 1235 CONTINUE
      TMAXX = 0.
      TMAXY = 0.
      TMINX = 1.E20
      TMINY = 1.E20
      NKLSQ = MIN0(N,MAXLSQ)
      NKLSQ2 = NKLSQ*2
        PTR = 1
      IF(.NOT.ZGEOM)PTR = PTR+2
      DO 5 I=1,N
      TPTS(I) = RPAR(PTR)
      TPTS(I+MAXTIE) = RPAR(PTR+1)
      IF(RPAR(PTR).GT.TMAXX)TMAXX=RPAR(PTR)
      IF(RPAR(PTR).LT.TMINX)TMINX=RPAR(PTR)
      IF(RPAR(PTR+1).GT.TMAXY)TMAXY = RPAR(PTR+1)
      IF(RPAR(PTR+1).LT.TMINY)TMINY = RPAR(PTR+1)
      IF (I .GT. MAXLSQ) GO TO 7771
      CLSQ(I) = RPAR(PTR)
      CLSQ(I+NKLSQ) = RPAR(PTR+1)
      CLSQ(I+NKLSQ2) = 1.
      IF (.NOT.ZGEOM) CLSQXY(I) = RPAR(PTR-2)
      IF (.NOT.ZGEOM) CLSQXY(I+NKLSQ) = RPAR(PTR-1)
      IF (ZGEOM) CLSQXY(I) = RPAR(PTR+2)
      ELSQXY(I) = CLSQXY(I)
      ELSQXY(I+NKLSQ) = CLSQXY(I+NKLSQ)
 7771 CONTINUE
      PTR = PTR+NPOINT
    5 CONTINUE
      EPS = 1.E-7
      CALL LLSQ(CLSQ,CLSQXY,NKLSQ,3,NPOINT-2,CSOL,IPIV,EPS,IER,AUX)
      IF(.NOT.NOPRINT) THEN
        CALL PRNT(7,NPOINT*3-6,CSOL,'LSQ FIT.')
        CALL PRNT(7,NKLSQ,ELSQXY,'DATA.')
      ENDIF
      IF (.NOT.ZGEOM.AND..NOT.NOPRINT)THEN
        CALL PRNT(7,NKLSQ,ELSQXY(NKLSQ+1),'DATA.')
      ENDIF
        PTR = 1
      IF (.NOT.ZGEOM) PTR = PTR+2
      DO 8771 I=1,NKLSQ
         ELSQXY(I)=ELSQXY(I)-RPAR(PTR)*CSOL(1)-
     *             RPAR(PTR+1)*CSOL(2)-CSOL(3)
         IF (.NOT.ZGEOM) ELSQXY(I+NKLSQ) = ELSQXY(I+NKLSQ)
     *      -RPAR(PTR)*CSOL(4)-RPAR(PTR+1)*CSOL(5)-CSOL(6)
 8771 PTR = PTR+NPOINT
      IF(.NOT.NOPRINT) THEN
        CALL PRNT(7,NKLSQ,ELSQXY,'RESIDUALS.')
      ENDIF
      IF (.NOT.ZGEOM.AND..NOT.NOPRINT)THEN
        CALL PRNT(7,NKLSQ,ELSQXY(NKLSQ+1),'RESIDUALS.')
      ENDIF
C
        CALL XVPARM('MINS',MINY,ICNT,MINSDF,1)
        CALL XVPARM('MAXS',MAXY,ICNT,MAXSDF,1)
        CALL XVPARM('MINL',MINX,ICNT,MINLDF,1)
        CALL XVPARM('MAXL',MAXX,ICNT,MAXLDF,1)
        IF(MINSDF.EQ.1) MINY = TMINY
        IF(MAXSDF.EQ.1) MAXY = TMAXY
        IF(MINLDF.EQ.1) MINX = TMINX
        IF(MAXLDF.EQ.1) MAXX = TMAXX
        IF (LONLY) NAH = 10
        IF (LONLY) NAV = 10
        IF (NHT.NE.0) NAH = NHT
        IF (NVT.NE.0) NAV = NVT
      DX = (TMAXX-TMINX+TMAXY-TMINY)*5.
        PTR = 1+N*NPOINT
      IF (.NOT.ZGEOM) PTR = PTR+2
      RPAR(PTR) = TMINX-DX
      RPAR(PTR+1) = (TMINY+TMAXY)/2.
      RPAR(PTR+NPOINT)   = (TMINX+TMAXX)/2.
      RPAR(PTR+NPOINT+1) = TMAXY+DX
      RPAR(PTR+2*NPOINT)   = (TMINX+TMAXX)/2.
      RPAR(PTR+2*NPOINT+1) = TMINY-DX
      RPAR(PTR+3*NPOINT)   = TMAXX+DX
      RPAR(PTR+3*NPOINT+1) = (TMINY+TMAXY)/2.
      IF(ZGEOM)GOTO 702
      DO 700 I=1,4
      XSQ = RPAR(PTR)
      YSQ = RPAR(PTR+1)
      TPTS(N+I) = XSQ
      TPTS(N+MAXTIE+I) = YSQ
      RPAR(PTR-2) = CSOL(1)*XSQ+CSOL(2)*YSQ+CSOL(3)
      RPAR(PTR-1) = CSOL(4)*XSQ+CSOL(5)*YSQ+CSOL(6)
      IF(.NOT.NOPRINT)THEN
        CALL PRNT(7,4,RPAR(PTR-2),'CORNERPT.')
      ENDIF
      PTR = PTR+4
  700 CONTINUE
      GOTO 701
  702 DO 704 I=1,4
      TPTS(N+I) = RPAR(PTR)
      TPTS(N+MAXTIE+I) = RPAR(PTR+1)
      RPAR(PTR+2) = CSOL(1)*RPAR(PTR)+CSOL(2)*RPAR(PTR+1)+CSOL(3)
      IF(.NOT.NOPRINT)THEN
        CALL PRNT(7,3,RPAR(PTR),'CORNERPT.')
      ENDIF
      PTR = PTR+3
  704 CONTINUE
  701 N = N+4
C
C  MANAKR: DATA STRUCTURE IN /COM2/
C  TRIANG:  DATA STRUCTURE IN /COM2,COM3/
C
      CALL MANAKR(N,NLRET,REJECT,ABENDL,NOPRINT)
      CALL TRIANG(N,NLRET,NTRI)
      IF(.NOT.NOPRINT)THEN
        CALL PRNT(4,1,N,'NODES.')
        CALL PRNT(4,1,NLRET,'EDGES.')
        CALL PRNT(4,1,NTRI,'TRIANGLES.')
      ENDIF
      IF (PLOT) GO TO 2000
C
C  SOLVE TRIANGLES
C
        PTR = 1
      IF(.NOT.ZGEOM)PTR = PTR+2
      DO 70 I=1,NTRI
  501 DO 500 J=1,36
  500 WORK(J) = 0.D+0
      CON1(I) = PTR+(CON1(I)-1)*NPOINT
      CON2(I) = PTR+(CON2(I)-1)*NPOINT
      CON3(I) = PTR+(CON3(I)-1)*NPOINT
      WORK(1) = RPAR(CON1(I))
      WORK(2) = RPAR(CON2(I))
      WORK(3) = RPAR(CON3(I))
      IF(ZGEOM)GOTO 511
      TAB(1) = RPAR(CON1(I)-2)
      TAB(2) = RPAR(CON2(I)-2)
      TAB(3) = RPAR(CON3(I)-2)
      TAB(4) = RPAR(CON1(I)-1)
      TAB(5) = RPAR(CON2(I)-1)
      TAB(6) = RPAR(CON3(I)-1)
      WORK(7) = RPAR(CON1(I)+1)
      WORK(8) = RPAR(CON2(I)+1)
      WORK(9) = RPAR(CON3(I)+1)
      DO 8 J=13,15
    8 WORK(J) = 1.D+0
      DO 17 J=1,3
      DO 17 K=1,3
      I1 = J+(K-1)*6
   17 WORK(I1+21) = WORK(I1)
      GOTO 512
  511 TAB(1) = RPAR(CON1(I)+2)
      TAB(2) = RPAR(CON2(I)+2)
      TAB(3) = RPAR(CON3(I)+2)
      WORK(4) = RPAR(CON1(I)+1)
      WORK(5) = RPAR(CON2(I)+1)
      WORK(6) = RPAR(CON3(I)+1)
      WORK(7) = 1.
      WORK(8) = 1.
      WORK(9) = 1.
  512 CALL DGELG(TAB,WORK,NRANK,1,1.E-14,IER)
      IF(IER.EQ.0)GOTO 80
      COEFF(1,I) = 1.E35
      GOTO 70
   80 DO 18 J=1,3
      COEFF(J,I) = TAB(J)
      IF(.NOT.ZGEOM) COEFF(J+3,I) = TAB(J+3)
   18 CONTINUE
   70 CONTINUE
      NTRI = NTRI-NERR
      NAV1 = NAV+1
      NAH1 = NAH+1
        DX = (MAXX-MINX)/FLOAT(NAV)
        DY = (MAXY-MINY)/FLOAT(NAH)
C
C---- OPEN OUTPUT "PARMS" FILE.
C
      LBOUT = 4*4*(NAH+1)*(NAV+1) + 100
      CALL XVPARM('OUT',OUTNAM,NOUT,OUTDF,1)
      CALL XVPOPEN(STATUS,3,LBOUT,OUTNAM,'SA',UNIT)
      CALL XVPOUT(STATUS,'NAH',NAH,'INT',1)
      CALL XVPOUT(STATUS,'NAV',NAV,'INT',1)
C
C     START THE GEOM OF THE GRID
C
      PTR = 1
      TRI = 1
      TTRJ1 = 1
      DO I=1,NAV1
        X = MINX+FLOAT(I-1)*DX
        IF (LONLY) X = INT(X)
        DO J=1,NAH1
          Y = MINY+FLOAT(J-1)*DY
          IF (LONLY) Y = INT(Y)
          ISIGN = -1
          TTRI = TRI-1+NTRI
          DO 160 K=1,NTRI
            TRI = MOD(TTRI+(K/2)*ISIGN,NTRI)+1
            ISIGN = -1*ISIGN
            IF(COEFF(1,TRI).EQ.1.E35)GOTO 160
            IF (INSIDE(X,Y,TRI)) GO TO 170
  160     CONTINUE
          TRI = TTRI+1-NTRI
          IF (J.EQ.1) TRI = TTRJ1
          IF(.NOT.NOPRINT)THEN
            CALL PRNT(7,2,X,'NOT IN TRI.')
          ENDIF
 170      IF (J.EQ.1) TTRJ1 = TRI
          IF (LGEOM)THEN
           XX = COEFF(1,TRI)*X+COEFF(2,TRI)*Y+COEFF(3,TRI)
           YY = COEFF(4,TRI)*X+COEFF(5,TRI)*Y+COEFF(6,TRI)
           ROUT(PTR) = X
           ROUT(PTR+1) = Y
           ROUT(PTR+2) = XX
           ROUT(PTR+3) = YY
           PTR = PTR+4
          ELSE
           XX = COEFF(1,TRI)*X+COEFF(2,TRI)*Y+COEFF(3,TRI)
           IF(ZGEOM) THEN
            ROUT(PTR) = X
            ROUT(PTR+1) = Y
            ROUT(PTR+2) = XX
            PTR = PTR+3
           ELSE
            YY = COEFF(4,TRI)*X+COEFF(5,TRI)*Y+COEFF(6,TRI)
            ROUT(PTR) = XX
            ROUT(PTR+1) = YY
            ROUT(PTR+2) = X
            ROUT(PTR+3) = Y
            PTR = PTR+4
           ENDIF
          ENDIF
        ENDDO
      ENDDO
      CALL XVPOUT(STATUS,'TIEPOINT',ROUT,'REAL',PTR-1)
      CALL XVPCLOSE(STATUS)
      RETURN
C
C
C---- PLOT OPTION.
C
 2000 CONTINUE
      NL = (32*NTRI+511)/512
      CALL XVUNIT(WUNIT,'OUT',1,STATUS,' ')
      CALL XVOPEN(WUNIT,STATUS,'OP','WRITE', 
     *			'OPEN_ACT','SA','IO_ACT','SA',
     *			'U_FORMAT','BYTE', 'O_FORMAT','BYTE',
     *			'U_NS',512,'U_NL',NL,' ')
      REC1 = 0
      CALL ZIA(ROUT,128)
      PTR = 1
      IF (.NOT.ZGEOM) PTR = PTR+2
      P = 1
      DO 2002 I=1,NTRI
         CON1(I) = PTR+(CON1(I)-1)*NPOINT
         CON2(I) = PTR+(CON2(I)-1)*NPOINT
         CON3(I) = PTR+(CON3(I)-1)*NPOINT
         DO 2001 J=1,4
            DO 2001 K=1,2
                IF (J.LE.3) ROUT(P) = RPAR(CON1(I+2*MAXTIE*(J-1))+K-1)
                IF (J.EQ.4) ROUT(P) = 0.
                P = P+1
                IF (P.LE.128) GO TO 2001
                REC1 = REC1+1
  	        CALL XVWRIT(WUNIT,ROUT,STATUS,'LINE',REC1,' ')
                P = 1
                CALL ZIA(OUTPUT,128)
 2001    CONTINUE
 2002 CONTINUE
      REC1 = REC1+1
        IF (P.LE.1) GO TO 9999
        CALL XVWRIT(WUNIT,OUTPUT,STATUS,'LINE',REC1,' ')
 9999   CALL XVCLOSE(WUNIT,STATUS,' ')
      RETURN
      END
C
C
C********************************************************
      LOGICAL FUNCTION INSIDE(X,Y,NT)
      INTEGER MAXTIE
      PARAMETER (MAXTIE=1600)
      INTEGER*2 CON1,CON2,CON3
      COMMON /COM1/RPAR(4*MAXTIE+25)
      COMMON /COM3/ CON1(2*MAXTIE), CON2(2*MAXTIE), CON3(2*MAXTIE)
      INTEGER EDGE(4)
      INSIDE = .FALSE.
      EDGE(1) = CON1(NT)
      EDGE(2) = CON2(NT)
      EDGE(3) = CON3(NT)
      EDGE(4) = CON1(NT)
      DO 10 I=1,3
      X1 = RPAR(EDGE(I))
      X2 = RPAR(EDGE(I+1))
      Y1 = RPAR(EDGE(I)+1)
      Y2 = RPAR(EDGE(I+1)+1)
      DOT = (X-X1)*(Y2-Y1)-(Y-Y1)*(X2-X1)
      IF (DOT.GT.0) RETURN
   10 CONTINUE
      INSIDE = .TRUE.
      RETURN
      END
C
C

      SUBROUTINE MANAKR(NPTS,NLRET,REJECT,ABENDL,NOPRINT)
      IMPLICIT INTEGER(A-Z)
      INTEGER MAXTIE
      PARAMETER (MAXTIE=1600)
      INTEGER*2 LPTR,LNBR,LINK,HEAPF,HEAPT,DANGLE
      INTEGER*2 CON1,CON2,CON3,NBCNT(MAXTIE)
      REAL*4 PTX,PTY,HEAPL,ANGLE,REJECT
      REAL*4 DMIN,DIST,DX,DY,DFLOOR,DXSET,DYSET
      LOGICAL QTEST,FLTEST,FAST,ABENDL,NOPRINT
      COMMON /COM2/ PTX(MAXTIE),PTY(MAXTIE),LPTR(MAXTIE),
     .      LNBR(6*MAXTIE),LINK(6*MAXTIE),
     .      HEAPF(MAXTIE),HEAPT(MAXTIE),HEAPL(MAXTIE),
     .      ANGLE(MAXTIE),DANGLE(MAXTIE)
      COMMON /COM3/ CON1(2*MAXTIE), CON2(2*MAXTIE), CON3(2*MAXTIE)
      EQUIVALENCE (CON1,NBCNT)

      DIMENSION MCOUNT(5)
      DATA MCOUNT/5*0/,FAST/.TRUE./
C
      IU = NPTS*6
      DO 1 I=1,IU
 1    LINK(I) = I+1
      AVAIL = 1
      DO 2 I=1,NPTS
      NBCNT(I) = 0
 2    LPTR(I) = 0
C
      IU = NPTS-1
      HSIZE = 0
      DO 10 I=1,IU
      DMIN = 1.E35
      JL = I+1
      DO 9 J=JL,NPTS
      DX = PTX(J)-PTX(I)
      DY = PTY(J)-PTY(I)
      DIST = DX*DX+DY*DY
      IF (DIST.GE.DMIN) GO TO 9
      IF (DIST.GE.REJECT) GO TO 8
      IF (.NOT. NOPRINT)  CALL PRNT(4,1,J,'DUPLIC PT.')
      NBCNT(J) = 10000
      IF (ABENDL) CALL EXIT()
      GO TO 9
 8    JMIN = J
      DMIN = DIST
 9    CONTINUE
      IF (DMIN.GE.1.E35) GO TO 10
      HSIZE = HSIZE+1
      CALL HEAP(HSIZE,HSIZE,I,JMIN,DMIN)
 10   CONTINUE
      DO 11 I=1,HSIZE
      IR = HSIZE-I+1
      J = HEAPF(IR)
      K = HEAPT(IR)
      DIST = HEAPL(IR)
      CALL HEAP(IR,HSIZE,J,K,DIST)
 11   CONTINUE
C
 400  ISET = HEAPF(1)
      JSET = HEAPT(1)
      DXSET = PTX(JSET)-PTX(ISET)
      DYSET = PTY(JSET)-PTY(ISET)
      IF (NBCNT(ISET).GE.10000) GO TO 600
      IF (NBCNT(JSET).GE.10000) GO TO 600
      MCOUNT(3) = MCOUNT(3)+1
      IF (QTEST(ISET,JSET,.NOT.FAST)) GO TO 600
      IF (QTEST(JSET,ISET,.NOT.FAST)) GO TO 600
      MCOUNT(4) = MCOUNT(4)+1
 30   IF (FLTEST(ISET,JSET,NPTS)) GO TO 600
C
 500  CALL TADD(ISET,JSET,AVAIL)
      CALL TADD(JSET,ISET,AVAIL)
      MCOUNT(5) = MCOUNT(5)+1
      CALL REDUCE(ISET,JSET)
C
 600  IF (NBCNT(ISET).GE.10000) GO TO 50
      DFLOOR = DXSET*DXSET+DYSET*DYSET
      JL = ISET+1
 40   DMIN = 1.E35
      JMIN = 0
      DO 43 J=JL,NPTS
      IF (NBCNT(J).GE.10000) GO TO 43
      DX = PTX(J)-PTX(ISET)
      DY = PTY(J)-PTY(ISET)
      DIST = DX*DX+DY*DY
      IF (DIST-DFLOOR) 43,42,41
 42   IF (J.LE.JSET) GO TO 43
 41   IF (DIST.GE.DMIN) GO TO 43
      JMIN = J
      DMIN = DIST
 43   CONTINUE
      IF (JMIN.EQ.0) GO TO 50
      DFLOOR = DMIN
      JSET = JMIN
      MCOUNT(1) = MCOUNT(1)+1
      IF (QTEST(ISET,JSET,FAST)) GO TO 40
      IF (QTEST(JSET,ISET,FAST)) GO TO 40
      MCOUNT(2) = MCOUNT(2)+1
      CALL HEAP(1,HSIZE,ISET,JSET,DMIN)
      GO TO 400
 50   IF (HSIZE.EQ.1) GO TO 900
      I = HEAPF(HSIZE)
      J = HEAPT(HSIZE)
      CALL HEAP(1,HSIZE-1,I,J,HEAPL(HSIZE))
      HSIZE = HSIZE-1
      GO TO 400
C
 900  NLRET = MCOUNT(5)
      CALL PRNT(4,5,MCOUNT,'COUNTS.')
      RETURN
      END


      SUBROUTINE TRIANG(NPTS,NLRET,NTRI)
      IMPLICIT INTEGER(A-Z)
      INTEGER MAXTIE
      PARAMETER (MAXTIE=1600)
      INTEGER*2 LPTR,LNBR,LINK,HEAPF,HEAPT,DANGLE
      INTEGER*4 ICENT,IX_DANGLE(MAXTIE),IX_ICENT(2*MAXTIE)
      REAL*4 PTX,PTY,HEAPL,ANGLE,ATAN2
      INTEGER*2 CON1,CON2,CON3
      REAL*4 DX,DY,XCENT(2*MAXTIE)
      COMMON /COM2/ PTX(MAXTIE),PTY(MAXTIE),LPTR(MAXTIE),
     .      LNBR(6*MAXTIE),LINK(6*MAXTIE),
     .      HEAPF(MAXTIE),HEAPT(MAXTIE),HEAPL(MAXTIE),
     .      ANGLE(MAXTIE),DANGLE(MAXTIE)
      COMMON /COM3/ CON1(2*MAXTIE),CON2(2*MAXTIE),CON3(2*MAXTIE)
      DIMENSION ICENT(2*MAXTIE)
      EQUIVALENCE (XCENT,HEAPL),(ICENT,LINK)
C
      TP = 0
      IU = NPTS-1
      DO 100 I=1,IU
      NANGLE = 0
      PTR = LPTR(I)
      IF (PTR.EQ.0) GO TO 100
 20   J = LNBR(PTR)
      DX = PTX(J)-PTX(I)
      DY = PTY(J)-PTY(I)
      NANGLE = NANGLE+1
      ANGLE(NANGLE) = ATAN2(DY,DX)
      DANGLE(NANGLE) = J
      PTR = LINK(PTR)
      IF (PTR.NE.0) GO TO 20
      CALL SSORTP (ANGLE,1,NANGLE,IX_DANGLE)
      DO 50 K=1,NANGLE
      KP = MOD(K,NANGLE)+1
      J1 = DANGLE(IX_DANGLE(K))
      J2 = DANGLE(IX_DANGLE(KP))
      IF (J1.LE.I.OR.J2.LE.I) GO TO 50
      PTR = LPTR(J1)
 40   IF (LNBR(PTR).EQ.J2) GO TO 41
      PTR = LINK(PTR)
      IF (PTR) 40,50,40
 41   TP = TP+1
      CON1(TP) = I
      CON2(TP) = J1
      CON3(TP) = J2
 50   CONTINUE
 100  CONTINUE
C
      DO 60 I=1,TP
      ICENT(I) = I
 60   XCENT(I) = (PTX(CON1(I))+PTX(CON2(I))+PTX(CON3(I)))/3.
      CALL SSORTP (XCENT,1,TP,IX_ICENT)
      IU = MAXTIE*6
      DO 61 I=1,IU
 61   LNBR(I) = CON1(I)
      DO 62 I=1,TP
      J = ICENT(IX_ICENT(I))
      CON1(I) = LNBR(J)
      CON2(I) = LNBR(J+MAXTIE*2)
 62   CON3(I) = LNBR(J+MAXTIE*4)
      NTRI = TP
      RETURN
      END

      SUBROUTINE REDUCE(IQ,JQ)
      IMPLICIT INTEGER(A-Z)
      INTEGER MAXTIE
      PARAMETER (MAXTIE=1600)
      INTEGER*2 LPTR,LNBR,LINK,HEAPF,HEAPT,DANGLE
      INTEGER*2 CON1,CON2,CON3,NBCNT(MAXTIE)
      REAL*4 PTX,PTY,HEAPL,ANGLE
      LOGICAL NOCONN,CCWISE
      COMMON /COM2/ PTX(MAXTIE),PTY(MAXTIE),LPTR(MAXTIE),
     .      LNBR(6*MAXTIE),LINK(6*MAXTIE),
     .      HEAPF(MAXTIE),HEAPT(MAXTIE),HEAPL(MAXTIE),
     .      ANGLE(MAXTIE),DANGLE(MAXTIE)
      COMMON /COM3/ CON1(2*MAXTIE), CON2(2*MAXTIE), CON3(2*MAXTIE)
      EQUIVALENCE (CON1,NBCNT)
C
      PTR = LPTR(IQ)
 100  J = LNBR(PTR)
      IF (NBCNT(J).LE.2) GO TO 500
      IF (NBCNT(J).GE.10000) GO TO 500
      IF (NOCONN(J,JQ)) GO TO 500
      P = LPTR(J)
      KZ = LNBR(P)
      KO = KZ
      P = LINK(P)
 200  K = LNBR(P)
      IF (NOCONN(K,KO)) GO TO 500
      IF (CCWISE(J,KO,K)) GO TO 500
      KO = K
      P = LINK(P)
      IF (P.NE.0) GO TO 200
      IF (NOCONN(K,KZ)) GO TO 500
      IF (CCWISE(J,K,KZ)) GO TO 500
      NBCNT(J) = NBCNT(J)+10000
 500  PTR = LINK(PTR)
      IF (PTR.NE.0) GO TO 100
      RETURN
      END
C
      LOGICAL FUNCTION CCWISE(J,K,L)
      INTEGER MAXTIE
      PARAMETER (MAXTIE=1600)
      INTEGER*2 LPTR,LNBR,LINK,HEAPF,HEAPT,DANGLE
      REAL*4 PTX,PTY,HEAPL,ANGLE
      COMMON /COM2/ PTX(MAXTIE),PTY(MAXTIE),LPTR(MAXTIE),
     .      LNBR(6*MAXTIE),LINK(6*MAXTIE),
     .      HEAPF(MAXTIE),HEAPT(MAXTIE),HEAPL(MAXTIE),
     .      ANGLE(MAXTIE),DANGLE(MAXTIE)
C
      CCWISE = ((PTX(J)-PTX(K))*(PTY(L)-PTY(K))
     . -(PTY(J)-PTY(K))*(PTX(L)-PTX(K))).GT.0.
      RETURN
      END
C
      LOGICAL FUNCTION QTEST(IQ,JQ,FAST)
      IMPLICIT INTEGER(A-Z)
      INTEGER MAXTIE
      PARAMETER (MAXTIE=1600)
      INTEGER*2 LPTR,LNBR,LINK,HEAPF,HEAPT,DANGLE
      INTEGER*2 CON1,CON2,CON3,NBCNT(MAXTIE)
      REAL*4 PTX,PTY,HEAPL,ANGLE,ATAN2,SIN,ABS
      REAL*4 TANGLE,DX,DY,TPI,AMOD
      LOGICAL FAST,NOCONN
      COMMON /COM2/ PTX(MAXTIE),PTY(MAXTIE),LPTR(MAXTIE),
     .      LNBR(6*MAXTIE),LINK(6*MAXTIE),
     .      HEAPF(MAXTIE),HEAPT(MAXTIE),HEAPL(MAXTIE),
     .      ANGLE(MAXTIE),DANGLE(MAXTIE)
      COMMON /COM3/ CON1(2*MAXTIE), CON2(2*MAXTIE), CON3(2*MAXTIE)
      EQUIVALENCE (CON1,NBCNT)
      DATA TPI/6.2831853/
C
      QTEST = .FALSE.
      IF (NBCNT(IQ).LE.1) RETURN
      PTR = LPTR(IQ)
      DX = PTX(JQ)-PTX(IQ)
      DY = PTY(JQ)-PTY(IQ)
      TANGLE = ATAN2(DY,DX)
      NANGLE = 0
      IU = 0
 1    J = LNBR(PTR)
      NANGLE = NANGLE+1
      DANGLE(NANGLE) = J
      IF (IU*LINK(PTR).NE.0) GO TO 2
      DX = PTX(J)-PTX(IQ)
      DY = PTY(J)-PTY(IQ)
      ANGLE(NANGLE) = ATAN2(DY,DX)
      IF (TANGLE.LE.ANGLE(NANGLE).AND.IU.EQ.0) IU = NANGLE
      IF (FAST) GO TO 2
      IF (ABS(SIN((TANGLE-ANGLE(NANGLE))/2.)).GE..0001) GO TO 2
      QTEST = .TRUE.
      RETURN
 2    PTR = LINK(PTR)
      IF (PTR.NE.0) GO TO 1
      IF (IU.EQ.0) IU = 1
      IL = IU-1
      IF (IL.EQ.0) IL = NANGLE
      J1 = DANGLE(IL)
      J2 = DANGLE(IU)
      IF (NOCONN(J1,J2)) RETURN
      QTEST = AMOD(ANGLE(IU)-ANGLE(IL)+TPI,TPI).LE.3.14159
      RETURN
      END
C
      LOGICAL FUNCTION FLTEST(IQ,JQ,NPTS)
      INTEGER MAXTIE
      PARAMETER (MAXTIE=1600)
      INTEGER*2 LPTR,LNBR,LINK,HEAPF,HEAPT,DANGLE
      COMMON /COM2/ PTX(MAXTIE),PTY(MAXTIE),LPTR(MAXTIE),
     .      LNBR(6*MAXTIE),LINK(6*MAXTIE),
     .      HEAPF(MAXTIE),HEAPT(MAXTIE),HEAPL(MAXTIE),
     .      ANGLE(MAXTIE),DANGLE(MAXTIE)
C
      FLTEST = .FALSE.
      DX1 = PTX(JQ)-PTX(IQ)
      DY1 = PTY(JQ)-PTY(IQ)
      THETA1 = ATAN2(DY1,DX1)
      ST = SIN(THETA1)
      CT = COS(THETA1)
      B1 = SQRT(DX1*DX1+DY1*DY1)
      DO 10 I=1,NPTS
      IF (I.EQ.IQ.OR.I.EQ.JQ) GO TO 10
      Z3 = PTX(I)-PTX(IQ)
      W3 = PTY(I)-PTY(IQ)
      X3 = Z3*CT+W3*ST
      Y3 = -Z3*ST+W3*CT
      PTR = LPTR(I)
 1    IF (PTR.EQ.0) GO TO 10
      J = LNBR(PTR)
      IF (J.LE.I) GO TO 2
      IF (J.EQ.IQ.OR.J.EQ.JQ) GO TO 2
      Z4 = PTX(J)-PTX(IQ)
      W4 = PTY(J)-PTY(IQ)
      X4 = Z4*CT+W4*ST
      Y4 = -Z4*ST+W4*CT
      DX2 = X4-X3
      DY2 = Y4-Y3
      B2 = SQRT(DX2*DX2+DY2*DY2)
      EPS = .0001*(B1+B2)
      IF (ABS(DY2).GE.EPS) GO TO 3
      IF (ABS(Y3).GE.EPS.AND.ABS(Y4).GE.EPS) GO TO 2
      IF (X3.GT.B1.AND.X4.GT.B1) GO TO 2
      IF (X3.LT.0..AND.X4.LT.0.) GO TO 2
      FLTEST = .TRUE.
      RETURN
 3    T1 = -Y3/DY2
      IF (T1.LT.0..OR.T1.GT.1.) GO TO 2
      T2 = (DX2*T1+X3)/B1
      IF (T2.LT.0..OR.T2.GT.1.) GO TO 2
      FLTEST = .TRUE.
      RETURN
 2    PTR = LINK(PTR)
      GO TO 1
 10   CONTINUE
      RETURN
      END
C
      LOGICAL FUNCTION NOCONN(IQ,JQ)
      IMPLICIT INTEGER(A-Z)
      INTEGER MAXTIE
      PARAMETER (MAXTIE=1600)
      INTEGER*2 LPTR,LNBR,LINK,HEAPF,HEAPT,DANGLE
      REAL*4 PTX,PTY,HEAPL,ANGLE
      COMMON /COM2/ PTX(MAXTIE),PTY(MAXTIE),LPTR(MAXTIE),
     .      LNBR(6*MAXTIE),LINK(6*MAXTIE),
     .      HEAPF(MAXTIE),HEAPT(MAXTIE),HEAPL(MAXTIE),
     .      ANGLE(MAXTIE),DANGLE(MAXTIE)
C
      NOCONN = .FALSE.
      PTR = LPTR(IQ)
 1    IF (PTR.EQ.0) GO TO 2
      IF (LNBR(PTR).EQ.JQ) RETURN
      PTR = LINK(PTR)
      GO TO 1
 2    NOCONN = .TRUE.
      RETURN
      END


      SUBROUTINE HEAP(P,N,I,J,K)
      IMPLICIT INTEGER(A-Z)
      INTEGER MAXTIE
      PARAMETER (MAXTIE=1600)
      INTEGER*2 LPTR,LNBR,LINK,HEAPF,HEAPT,DANGLE
      REAL*4 PTX,PTY,HEAPL,ANGLE
      REAL*4 K
      COMMON /COM2/ PTX(MAXTIE),PTY(MAXTIE),LPTR(MAXTIE),
     .      LNBR(6*MAXTIE),LINK(6*MAXTIE),
     .      HEAPF(MAXTIE),HEAPT(MAXTIE),HEAPL(MAXTIE),
     .      ANGLE(MAXTIE),DANGLE(MAXTIE)
C
      Q = 2*P
 10   IF (Q-N) 1,2,20
 1    IF (HEAPL(Q).GT.HEAPL(Q+1)) Q = Q+1
 2    M = Q/2
      IF (K.GT.HEAPL(Q)) GO TO 3
      HEAPF(M) = I
      HEAPT(M) = J
      HEAPL(M) = K
      RETURN
 3    HEAPF(M) = HEAPF(Q)
      HEAPT(M) = HEAPT(Q)
      HEAPL(M) = HEAPL(Q)
      Q = 2*Q
      GO TO 10
 20   M = Q/2
      HEAPF(M) = I
      HEAPT(M) = J
      HEAPL(M) = K
      RETURN
      END


      SUBROUTINE TADD(ISET,JSET,AVAIL)
      IMPLICIT INTEGER(A-Z)
      INTEGER MAXTIE
      PARAMETER (MAXTIE=1600)
      INTEGER*2 LPTR,LNBR,LINK,HEAPF,HEAPT,DANGLE
      INTEGER*2 CON1,CON2,CON3,NBCNT(MAXTIE)
      REAL*4 PTX,PTY,HEAPL,ANGLE,ATAN2
      REAL*4 TANGLE,DX,DY
      COMMON /COM2/ PTX(MAXTIE),PTY(MAXTIE),LPTR(MAXTIE),
     .      LNBR(6*MAXTIE),LINK(6*MAXTIE),
     .      HEAPF(MAXTIE),HEAPT(MAXTIE),HEAPL(MAXTIE),
     .      ANGLE(MAXTIE),DANGLE(MAXTIE)
      COMMON /COM3/ CON1(2*MAXTIE), CON2(2*MAXTIE), CON3(2*MAXTIE)
      EQUIVALENCE (CON1,NBCNT)
C
      NBCNT(ISET) = NBCNT(ISET)+1
      DX = PTX(JSET)-PTX(ISET)
      DY = PTY(JSET)-PTY(ISET)
      TANGLE = ATAN2(DY,DX)
      P = AVAIL
      AVAIL = LINK(P)
      LNBR(P) = JSET
      PTR = LPTR(ISET)
      IF (PTR.EQ.0) GO TO 3
 1    J = LNBR(PTR)
      DX = PTX(J)-PTX(ISET)
      DY = PTY(J)-PTY(ISET)
      IF (ATAN2(DY,DX).GE.TANGLE) GO TO 2
      OPTR = PTR
      PTR = LINK(PTR)
      IF (PTR.NE.0) GO TO 1
 2    IF (PTR.EQ.LPTR(ISET)) GO TO 3
      LINK(P) = PTR
      LINK(OPTR) = P
      RETURN
 3    LINK(P) = PTR
      LPTR(ISET) = P
      RETURN
      END
