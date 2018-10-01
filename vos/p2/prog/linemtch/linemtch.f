      INCLUDE 'VICMAIN_FOR'
      SUBROUTINE MAIN44
C
C---- VICAR "LINEMTCH".
C
C
C   REVISION HISTORY
C
C     5-96   SP  Corrected DCODE for calls to MVE and MINMAX.  Changed to
C                call the current version of FFTT instead of (a previous
C                one?) with 4 arguments.  Added print of final FFT offset
C                as a consistency check. (The value should be small in
C                absolute value.  Increased buffer size to 60000.
C                Changed to use IBIS-2 calls for output file.  Dropped
C                the "purging of buffers" which wrote numerous rows of
C                zeroes after regular data.

      COMMON/BUFFER/LBUFA(60000),LBUFB(60000)
      BYTE LBUFA,LBUFB
      LOGICAL XVPTST,PRINT
      REAL*4 GRA(1024),GRB(1024),ABSGRB(1024),RLCORR(1024)
      REAL*4 ITIEAR(2),OTIEAR(2)
      INTEGER*4 LINEAR(200)
      INTEGER*4 ITIEDF,OTIEDF,LINEDF,MINSDF,MAXSDF,SPACDF,AREADF,
     *          POWEDF
      INTEGER WUNIT, IBIS, IRECORD, NUMPTS, STATUS

      DIMENSION CORMMX(9),IMMX(9),OFFS(9)
      INTEGER*4 LINEA(100),LINEB(100)
      COMPLEX GRACOM(1024),GRBCOM(1024),GRAC(1024),GRBC(1024)
      COMPLEX CONGRB(1024),CORR(1024)
      DIMENSION ROWBUF(5),ICOLS(5)
      DATA JAREA/128/,JSTEP/12/,IPOWER/5/
      DATA PRINT/.TRUE./
      DATA ROWBUF/5*0./,NCOL/5/,ICOLS/1,2,3,4,5/
C-------------------------------------------------------
C---- READ PARAMETERS.
C
      CALL XVPARM('ITIE',ITIEAR,NITIE,ITIEDF,0)
      CALL XVPARM('OTIE',OTIEAR,NOTIE,OTIEDF,0)
      X1ITIE = ITIEAR(1)
      X2ITIE = ITIEAR(2)
      IF (X1ITIE .EQ. X2ITIE) 
     .   CALL MABEND('ERROR:ITIE values may not be the same')
      X1OTIE = OTIEAR(1)
      X2OTIE = OTIEAR(2)
      IF (X1OTIE .EQ. X2OTIE) 
     .   CALL MABEND('ERROR:OTIE values may not be the same') 
      
      CALL XVPARM('LINES',LINEAR,NLINE,LINEDF,0)
      NPAIR = NLINE/2
      IF (MOD(NLINE,2) .NE. 0) 
     . CALL MABEND('ERROR: Number of values for parameter LINES is odd')
      DO 100 I=1,NPAIR
         LINEA(I) = LINEAR(2*I-1)
         LINEB(I) = LINEAR(2*I)
  100 CONTINUE
      CALL XVPARM('MINS',MINS,NMINS,MINSDF,0)
      CALL XVPARM('MAXS',MAXS,NMAXS,MAXSDF,0)
      CALL XVPARM('SPACING',ISPAC,NSPAC,SPACDF,0)
      CALL XVPARM('AREA',JAREA,NAREA,AREADF,0)
      CALL XVPARM('POWER',IPOWER,NPOWER,POWEDF,0)
      PRINT = .NOT.XVPTST('NOPRINT')
      IF(IPOWER.GT.10) GO TO 2000
      IDIM = 2**IPOWER
      IF(AREADF.EQ.0) JSTEP =(JAREA/2-IDIM/2)/4
      IF(JSTEP.LT.0) JSTEP=0
      CALL PRNT(4,1,IDIM,'SAMPLING SIZE .')
      CALL PRNT(4,1,JAREA,'SEARCH AREA .')
C
C---- OPEN FILES.
C
      CALL XVUNIT(RUNIT1,'INP',1,STATUS,' ')
      CALL XVOPEN(RUNIT1,STATUS, 'OPEN_ACT','SA', 'IO_ACT','SA' ,' ')
      CALL XVGET(RUNIT1,STATUS,'NL',NLA,'NS',NSA,' ')
      CALL XVPCNT('INP',NINP)
      RUNIT2 = RUNIT1
      NLB = NLA
      NSB = NSA
      IF(NINP.EQ.1) GO TO 200
      CALL XVUNIT(RUNIT2,'INP',2,STATUS,' ')
      CALL XVOPEN(RUNIT2,STATUS, 'OPEN_ACT','SA', 'IO_ACT','SA' ,' ')
      CALL XVGET(RUNIT2,STATUS,'NL',NLB,'NS',NSB,' ')
  200 CONTINUE

      LCOL = (MAXS-MINS)/ISPAC+1       ! LOCATIONS PER LINE
      NUMPTS = LCOL * NPAIR            ! NUMBER 0F ROWS = NUMBER OF POINTS
      CALL XVUNIT(WUNIT,'OUT',1,STATUS,' ')
      CALL IBIS_FILE_OPEN(WUNIT,IBIS,'WRITE',NCOL, NUMPTS,
     +                          ' ','ROW',STATUS)
       IF (STATUS .NE. 1)   CALL IBIS_SIGNAL(IBIS,STATUS,1)

      CALL IBIS_RECORD_OPEN(IBIS,IRECORD,' ',    ! 1 record (row) is cols. 1-5.
     +                        ICOLS,NCOL,'NONE',STATUS)
      IF (STATUS.NE.1) CALL IBIS_SIGNAL(IBIS,STATUS,1)

C
C---- BEGIN LINE MATCHING.
C
      IRW = 0    ! moved bam - work courtesy of Thomas Huang

      TRAN1 = (X1ITIE-X2ITIE)/(X1OTIE-X2OTIE)
      TRAN2 = (X1OTIE*X2ITIE-X2OTIE*X1ITIE)/(X1OTIE-X2OTIE)
      DO 1000 N=1,NPAIR
       CALL XVREAD(RUNIT1,LBUFA,STATUS,'LINE',LINEA(N),' ')
       CALL XVREAD(RUNIT2,LBUFB,STATUS,'LINE',LINEB(N),' ')
C
C---- MATCH PORTIONS OF B-IMAGE STARTING AT "MINS" WITH SPACING
C     "SPAC".
C
      DO 900 IS=MINS,MAXS,ISPAC
C
C---- OBTAIN RESAMPLING, FFT, CONJUGATE FFT, ABS FROM THE "B".
C
         CALL GETGR(IDIM,IS,1.,0.,IDIM,LBUFB,GRB,GRBCOM)
         CALL MVE(7,2*IDIM,GRBCOM,GRBC,1,1)
         CALL FFTT(IPOWER,-1,GRBC)
         DO 910 I=1,IDIM
            CONGRB(I) = CONJG(GRBC(I))
            ABSGRB(I) = CABS(GRBC(I))
  910    CONTINUE
C
C---- CONDUCT SEARCH IN JAREA-SAMPLE SEARCH AREA OF THE "A".
C
      JS = IS-5*JSTEP
      DO 800 J=1,9
         JS = JS+JSTEP
C
C---- OBTAIN RESAMPLING, FFT, ABS FROM THE "A".
C
         CALL GETGR(IDIM,JS,TRAN1,TRAN2,IDIM,LBUFA,GRA,GRACOM)
         CALL MVE(7,2*IDIM,GRACOM,GRAC,1,1)
         CALL FFTT(IPOWER,-1,GRAC)
C
C---- COMPUTE CORRELATION FUNCTION (INVERSE FFT).
C
         CORR(1) = CMPLX(0.,0.)
         DO 810 I=2,IDIM
            RNORM = AMAX1(1.E-6,(CABS(GRAC(I))*ABSGRB(I)))
            CORR(I) = GRAC(I)*CONGRB(I)/RNORM
  810    CONTINUE
         CALL FFTT(IPOWER,1,CORR)
         DO 820 I=1,IDIM
            RLCORR(I) = REAL(CORR(I))
  820    CONTINUE
C
C---- FIND LOCAL MAXIMA FOR CORRELATIONS IN A JAREA-SAMP SEARCH AREA
C
         CALL MINMAX(7,IDIM,RLCORR,CORMIN,CORMAX,IMIN,IMAX)
         CORMMX(J) = CORMAX
         IMMX(J) = IMAX-1
         OFFS(J) = IMMX(J)
         IF(IMMX(J).GT.IDIM/2) OFFS(J)=IMMX(J)-IDIM
         OFFS(J) = OFFS(J)+JS-IS
  800 CONTINUE
C
C---- FIND FINAL OFFSET.
C
      CALL MINMAX(7,9,CORMMX,CMIN,CMAX,JMIN,JMAX)
      INDMAX = IMMX(JMAX)
      OFFSET = OFFS(JMAX)
      IF(PRINT)CALL XVMESSAGE('------------------------',' ')
      IF(PRINT)CALL PRNT(4,1,IS,'SAMPLE IN B=.')
C
C---- PERFORM FFT AT FOUND OFFSET.
C
      JS = IS+OFFSET
      CALL GETGR(IDIM,JS,TRAN1,TRAN2,IDIM,LBUFA,GRA,GRACOM)
      CALL MVE(7,2*IDIM,GRACOM,GRAC,1,1)
      CALL FFTT(IPOWER,-1,GRAC)
      CORR(1) = CMPLX(0.,0.)
      DO 920 I=2,IDIM
         RNORM = AMAX1(1.E-6,(CABS(GRAC(I))*ABSGRB(I)))
         CORR(I) = GRAC(I)*CONGRB(I)/RNORM
  920 CONTINUE
      CALL FFTT(IPOWER,1,CORR)
      DO 930 I=1,IDIM
         RLCORR(I) = REAL(CORR(I))
  930 CONTINUE
      CALL MINMAX(7,IDIM,RLCORR,CORMIN,CORMAX,IMIN,IMAX)
      IF(PRINT)CALL PRNT(7,1,CORMAX,'CORRELATION VALUE=.')

      OFFSET = IMAX-1
      IF (OFFSET .GT. IDIM/2)    OFFSET = OFFSET-IDIM
      IF(PRINT)CALL PRNT(7,1,OFFSET,'FFT OFFSET=.')
      
C
C---- PERFORM SUBPIXEL FIT.
C
      I2 = IMAX
      I3 = MOD(IMAX,IDIM)+1
      I1 = IMAX-1
      IF(I1.EQ.0) I1=IDIM
      F1 = RLCORR(I1)
      F2 = RLCORR(I2)
      F3 = RLCORR(I3)
      X2 = IMAX-1
      IF(IMAX.GT.(IDIM/2+1)) X2 = X2-IDIM
      CALL SUBFIT(X2-1,X2,X2+1,F1,F2,F3,X)
      OFFSET = JS-IS+X
      SAMPA = IS+OFFSET
      IRW = IRW+1
      ROWBUF(1) = N
      ROWBUF(2) = SAMPA
      ROWBUF(3) = IS
      ROWBUF(4) = OFFSET
      ROWBUF(5) = CORMAX

      CALL IBIS_RECORD_WRITE(IRECORD, ROWBUF,IRW,STATUS)
          IF (STATUS .NE. 1)   CALL IBIS_SIGNAL(IBIS,STATUS,1)

      IF(PRINT)CALL PRNT(7,1,OFFSET,'OFFSET=.')
      IF(PRINT)CALL PRNT(7,1,SAMPA,'SAMPLE IN A=.')
  900 CONTINUE
 1000 CONTINUE

      CALL IBIS_FILE_CLOSE(IBIS,' ',STATUS)
       IF (STATUS.NE.1) CALL IBIS_SIGNAL(IBIS,STATUS,1)

      RETURN            ! NORMAL COMPLETION

 2000 CONTINUE
      CALL XVMESSAGE('PARAMETER ERROR',' ')
      CALL ABEND
      RETURN
      END
C***********************************************
C             RESAMPLE PIXEL DATA ACCORDING TO GEOMETRIC MODEL.

      SUBROUTINE GETGR(IDIM,ICENTR,TRAN1,TRAN2,NPT,LBUF,GR,GRCOM)
      INCLUDE 'fortport'    !DEFINES BYTE2INT CONVERSION.

      BYTE LBUF(*)
      COMPLEX GRCOM(*)
      REAL*4 GR(*)
C===================================================================
      GAP = TRAN1*1.
      TCENTR = AINT(TRAN1*ICENTR+TRAN2)+.5
      XRES = TCENTR-(IDIM/2+.5)*GAP
      DO 100 I=1,IDIM
         XRES = XRES+GAP
         IRES = XRES
         IGR1 = BYTE2INT(LBUF(IRES))
         IGR2 = BYTE2INT(LBUF(IRES+1))
         GR0 = (XRES-IRES)*(IGR2-IGR1)+IGR1
         GR(I) = GR0
         GRCOM(I) = CMPLX(GR(I),0.0)
  100 CONTINUE
      RETURN
      END
C***********************************************
      SUBROUTINE SUBFIT(X1,X2,X3,F1,F2,F3,X)
      DELA = (F1-F3)*X2 + (F2-F1)*X3 + (F3-F2)*X1
      DELB = (F2-F3)*X1*X1 + (F1-F2)*X3*X3 + (F3-F1)*X2*X2
      X = -.5*DELB/AMAX1(1.E-6,DELA)
      RETURN
      END