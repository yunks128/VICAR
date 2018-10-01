C  PROGRAM FFT22
C  1 JUL 94 ... CRI ... MSTP S/W CONVERSION (VICAR PORTING)

      INCLUDE 'VICMAIN_FOR'
      SUBROUTINE MAIN44
C  CALLS 'WORK' WITH USER-SPECIFIABLE MEMORY SIZE
      INTEGER BUFSIZ, POW
      EXTERNAL WORK

      CALL IFMESSAGE('FFT22 version 1-JUL-94')
      CALL XVEACTION('SA',' ')
      CALL XVPARM( 'BUFPOW', POW, I, J, 1)
      BUFSIZ = 2**POW
      CALL STACKA(3, WORK, 1, BUFSIZ)
      RETURN
      END

      SUBROUTINE WORK( BUF, BUFSIZ)
      INTEGER TOTCOR, BUFSIZ
      REAL*4 BUF(BUFSIZ/4)
C
      INTEGER SLO,SSO,UNIT1,UNIT2,UNIT3,STAT
      INTEGER SGN1, SGN2, INFM, IOS
      CHARACTER*4 FMT
      CHARACTER*4 OUTFMT(5)
      CHARACTER*8 OTFMT, MODE,UNAME
      CHARACTER*132 SCR
      LOGICAL INVFLG
      DATA SGN1/-2/, SGN2/-2/, INFM/1/
      DATA OUTFMT/'BYTE','HALF','FULL','REAL','COMP'/
      DATA INVFLG/.FALSE./

C        DEFINE IEXP FUNCTION
      IEXP(N) = 2**N

      TOTCOR = BUFSIZ/8
      ISRINC = 0

C  OPEN INPUT DATA SET
      CALL XVUNIT(UNIT1,'INP',1,STAT,' ')
      CALL XVOPEN(UNIT1, STAT,' ')

C  'SIZE'
      CALL XVSIZE(SLO,SSO,NLO,NSO,NLI,NSI)
      IF ((SLO + NLO - 1).GT.NLI) NLO = NLI - SLO + 1
      IF ((SSO + NSO - 1).GT.NSI) NSO = NSI - SSO + 1
      IF (NSO.LE.0 .OR. NLO.LE.0) THEN
	CALL XVMESSAGE('** INVALID INPUT AREA REQUESTED **',' ')
	CALL ABEND
      ENDIF

C  GET FORMAT OF INPUT FILE
      CALL XVGET(UNIT1,STAT,'FORMAT',FMT,' ')
      IF (FMT.EQ.'BYTE') INFM=1
      IF (FMT.EQ.'HALF') INFM=2
      IF (FMT.EQ.'FULL') INFM=3
      IF (FMT.EQ.'REAL') INFM=4
      IF (FMT.EQ.'COMP'.OR.FMT.EQ.'COMPLEX') INFM=5

C  'MODE'
      CALL XVPARM( 'MODE', MODE, ICNT, IDEF, 1)
      IF ((ICNT.EQ.0.AND.INFM.EQ.5) .OR. MODE.EQ.'INVERSE')
     & INVFLG = .TRUE.

      IF (INVFLG) THEN
	SGN1 = 2
	SGN2 = 2
	IF (INFM.NE.5) CALL MABEND(
     &	 '** INPUT TO INVERSE TRANSFORM MUST BE COMPLEX **')
	CALL XVMESSAGE('INVERSE TRANSFORM',' ')
      ELSE
	CALL XVMESSAGE('FORWARD TRANSFORM',' ')
      ENDIF

C  'FORMAT' = FORMAT OF IMAGE
      IF (INVFLG) THEN		! ONLY VALID FOR INVERSE TRANSFORM
	CALL XVPARM('FORMAT',FMT,ICOUNT,IDEF,1)
	IF (IDEF.EQ.0) THEN
	  IF(FMT.EQ.'BYTE') IFMT=1
	  IF(FMT.EQ.'HALF') IFMT=2
	  IF(FMT.EQ.'FULL') IFMT=3
	  IF(FMT.EQ.'REAL') IFMT=4
	  IF(FMT.EQ.'COMP'.OR.FMT.EQ.'COMPLEX') IFMT=5
	ELSE
	  IFMT = 1		! BYTE DEFAULT OUTPUT FOR INVERSE
	ENDIF
      ELSE			! FORWARD: USE LABEL FORMAT
	IFMT = INFM
      ENDIF

      IF (.NOT.INVFLG .AND. IFMT.NE.5) THEN
	CALL XVCLOSE( UNIT1, STAT,' ')
	CALL XVOPEN( UNIT1, STAT, 'U_FORMAT', 'COMP',' ')
      ENDIF

C  SET DATA LIMITS FOR INTEGER OUTPUT:
      IF (INVFLG) THEN
	IF (IFMT.EQ.1) THEN
	  VLO = 0.0
	  VHI = 255.0
	ELSEIF (IFMT.EQ.2) THEN
	  VLO = -32768.0
	  VHI = 32767.0
	ELSEIF (IFMT.EQ.3) THEN
	  VLO = -2.14748E9
	  VHI = 2.14748E9
	ENDIF
      ENDIF

      DO I = 1,2*TOTCOR		! ZERO THE BUFFER
	BUF(I) = 0.0
      ENDDO

C  FIND THE POWER OF 2 THAT CONTAINS MAX(NLO,NSO):
      NA = 1
      IDIMEN = 2
      DO WHILE (IDIMEN.LT.NLO .OR. IDIMEN.LT.NSO)
	NA = NA+1
	IDIMEN = 2*IDIMEN
      ENDDO

      NSPG = TOTCOR/IDIMEN
      JA = MIN0(LOG2(NSPG),NA)
      IF (JA.LE.0) THEN
	CALL XVMESSAGE('** BUFFER MUST HOLD AT LEAST 2 LINES **',' ')
	CALL ABEND
      ENDIF

      NSPG = IEXP(JA)
      KK = (NA - 1)/JA		! NUMBER OF PASSES REQUIRED
      MSROW = 1
      ITEMP2 = IEXP(JA * (KK + 1) - NA)
      MAXC = NSPG * IDIMEN
      LINE = SLO

      NSAMP = NSO  ! (THESE DEFINITIONS LEFT OVER FROM OLD ALGORITHM)
      NLINE = NLO
      NL = NLO
      NS = NSO
      RESCAL = NLINE*NSAMP

C  ASSIGN UNIT NO. TO OUTPUT
      CALL XVUNIT( UNIT2,'OUT',1,STAT,' ')

C  DETERMINE IF SCRATCH FILE NEEDED
      UNIT3 = UNIT2			! BY DEFAULT, USE OUTPUT FILE
      IF (KK.GT.0 .AND. ((IFMT.NE.5 .AND. INVFLG) .OR.
     & NLINE.LT.IDIMEN .OR. NSAMP.LT.IDIMEN)) THEN
	CALL XVPARM( 'SCRATCH', SCR, I, IDEF,1)
        IF (IDEF.EQ.1) THEN
              CALL TESTOS(IOS)
              IF (IOS.EQ.0) SCR='V2$SCRATCH:FFT2SCRX'
              IF (IOS.EQ.1) THEN
                 CALL GTPRCS(UNAME)
                 SCR='/tmp/fft2scrx.'
                 SCR(15:17)=UNAME
              END IF
        ENDIF
	CALL XVUNIT( UNIT3, 'DUMMY', 1, STAT, 'U_NAME', SCR,' ')
	CALL XVMESSAGE('USING SCRATCH FILE: '//SCR,' ')
      ENDIF
C
C  OPEN OUTPUT DATA SET
      IF (.NOT.INVFLG) THEN
	OTFMT = 'COMP'
      ELSE
	OTFMT = OUTFMT(IFMT)
	IF (IFMT.EQ.5) OTFMT = 'COMP'
      ENDIF
      CALL XVOPEN( UNIT2, STAT, 'OP', 'WRITE', 'U_NL', NSAMP,
     & 'U_NS', NLINE, 'U_FORMAT', 'COMP', 'O_FORMAT', OTFMT,' ')

C  AND SCRATCH, IF NEEDED
      IF (UNIT3.NE.UNIT2)
     & CALL XVOPEN( UNIT3, STAT, 'OP', 'WRITE', 'U_NL', IDIMEN,
     &  'U_NS', IDIMEN, 'U_FORMAT', 'COMP', 'O_FORMAT', 'COMP',' ')

C  BEGIN PASS 1:  PROCESS A BLOCK OF 'NSPG' LINES, WHICH WILL
C  FILL THE BUFFER.

      LM = 1
100   DO 150 I = 1, MAXC, IDIMEN	! 'NSPG' TIMES

      IF (LM.GT.NL) THEN

	DO J = 1,2*NSAMP  ! FILL NON-SQUARE PART (IN LINE DIR.) WITH 0'S
          BUF(2*I+J-2) = 0.0
	ENDDO

      ELSE

	IF (LINE.EQ.SLO) THEN
	  CALL XVREAD(UNIT1,BUF(2*I-1),STAT,'LINE',LINE,
     &     'SAMP',SSO,'NSAMPS',NS,' ')
	  LINE = 0
	ELSEIF (SSO.NE.1 .OR. NS.NE.NSI) THEN
	  CALL XVREAD(UNIT1,BUF(2*I-1),STAT,'SAMP',SSO,'NSAMPS',NS,' ')
	ELSE
	  CALL XVREAD(UNIT1,BUF(2*I-1),STAT,' ')
	ENDIF

	CALL DFFT( BUF(2*I-1), BUF(2*I), NSAMP, NSAMP, NSAMP,
     .   -SGN1, *998, *999)

      ENDIF
      LM = LM + 1
150   CONTINUE

C  NOW TRANSPOSE THE MATRIX IN BLOCKS OF NSPG*NSPG ELEMENTS

      INDEX1 = 2
      INDEX2 = IDIMEN + 1
      DO 155 IP = 2,NSPG
      IPQ = INDEX1
      IQP = INDEX2
      IPM1 = IP - 1
      DO 154 IQ = 1,IPM1
      IPQI = IPQ
      IQPI = IQP
      DO 152 I = 1,IDIMEN,NSPG
      CTEMP1 = BUF(2*IPQI-1)
      CTEMP2 = BUF(2*IPQI)
      BUF(2*IPQI-1) = BUF(2*IQPI-1)
      BUF(2*IPQI) = BUF(2*IQPI)
      BUF(2*IQPI-1) = CTEMP1
      BUF(2*IQPI) = CTEMP2
      IPQI = IPQI + NSPG
      IQPI = IQPI + NSPG
152   CONTINUE
      IPQ = IPQ + IDIMEN
      IQP = IQP + 1
154   CONTINUE
      INDEX2 = INDEX2 + IDIMEN
      INDEX1 = INDEX1 + 1
155   CONTINUE

      IF (KK.EQ.0) GO TO 350
C  (IF TRANSFORMATION CAN BE DONE ENTIRELY IN CORE, BYPASS ALL
C   INTERMEDIATE PROCESSING AND GO TO FINAL STEP)

C  WRITE THE 'NSPG' LINES TO SCRATCH FILE

      DO 160 I = 1, MAXC, IDIMEN
      CALL XVWRIT( UNIT3, BUF(2*I-1), STAT,' ')
  160 CONTINUE
      IF(LM.LT.IDIMEN) GO TO 100	! GO BACK & DO NEXT BLOCK
C
C  END OF PASS 1

C  RE-OPEN OUTPUT/SCRATCH DATA SET FOR UPDATE TO ALLOW RANDOM ACCESS
C  (EVEN IF OUTPUT HAS NOT YET BEEN WRITTEN TO)

      CALL XVCLOSE( UNIT2, STAT,' ')
      CALL XVOPEN(UNIT2, STAT, 'OP', 'UPDATE',
     &            'U_FORMAT', 'COMP', 'O_FORMAT', OTFMT,' ')
      IF (UNIT2.NE.UNIT3) THEN
	CALL XVCLOSE( UNIT3, STAT,' ')
	CALL XVOPEN(UNIT3, STAT, 'OP', 'UPDATE',
     &	            'U_FORMAT', 'COMP', 'O_FORMAT', 'COMP',' ')
      ENDIF

      IF (KK .LT. 2) GO TO 300
C  (IF ONLY 1 PASS NEEDED, GO DIRECTLY TO LAST PASS)

C  INTERMEDIATE PASSES:

      KKM1 = KK - 1
      DO K = 1, KKM1
	IRINC = IEXP(JA * K)
	MSROW1 = 1
	MSROW2 = IRINC
	ISROW2 = IDIMEN
	ISRINC = IRINC * NSPG
	DO MSROW = MSROW1, MSROW2
	  DO ISROW = MSROW, ISROW2, ISRINC
	    I = 1
	    ITEMP = ISROW + ISRINC - 1
	    DO IROW = ISROW, ITEMP, IRINC
	      CALL XVREAD( UNIT3, BUF(2*I-1), STAT, 'LINE', IROW,' ')
              I = I+IDIMEN
	    ENDDO
            INDEX1 = IDIMEN+1
            INDEX2 = IRINC + 1
            DO IP = 2, NSPG
              IPQ = INDEX1
              IQP = INDEX2
              IPM1 = IP - 1
              DO IQ = 1, IPM1
                IPQI = IPQ
                IQPI = IQP
                DO I = 1, IDIMEN, ISRINC
                  DO IT = 1, IRINC
		    CTEMP1 = BUF(2*(IPQI-1+IT)-1)
		    CTEMP2 = BUF(2*(IPQI-1+IT))
		    BUF(2*(IPQI-1+IT)-1) = BUF(2*(IQPI-1+IT)-1)
		    BUF(2*(IPQI-1+IT)) = BUF(2*(IQPI-1+IT))
		    BUF(2*(IQPI-1+IT)-1) = CTEMP1
		    BUF(2*(IQPI-1+IT)) = CTEMP2
		  ENDDO
                  IPQI = IPQI + ISRINC
                  IQPI = IQPI + ISRINC
		ENDDO
                IPQ = IPQ + IRINC
                IQP = IQP + IDIMEN
	      ENDDO
              INDEX1 = INDEX1 + IDIMEN
              INDEX2 = INDEX2 + IRINC
	    ENDDO
            I = 1
            DO IROW = ISROW, ITEMP, IRINC
              CALL XVWRIT( UNIT3, BUF(2*I-1), STAT, 'LINE', IROW,' ')
	      I = I + IDIMEN
	    ENDDO

	  ENDDO		!  END ISROW LOOP

	ENDDO		!  END MSROW LOOP

      ENDDO		!  END K LOOP
C
C  BEGIN LAST PASS

300   ISRINC = IEXP(JA * KK)
      INDINC = IEXP(NA - JA*KK)
      MSROW = 1

C  LOOP OVER MSROW:  READ IN 'NSPG' LINES AT A TIME, 'ITEMP2' LINES 
C  FROM EACH 2**(KK-1)-TH BLOCK:

301   I = 1
      ISROW = MSROW
305   ITEMP = ISROW + ITEMP2 - 1

      DO IROW = ISROW,ITEMP		! READ 'ITEMP2' LINES
	CALL XVREAD( UNIT3, BUF(2*I-1), STAT, 'LINE', IROW,' ')
	I = I+IDIMEN
      ENDDO

      ISROW = ISROW + ISRINC
      IF (I.LT.MAXC) GO TO 305	! LOOP UNTIL 'NSPG' LINES READ
C
C  TRANSPOSE ELEMENTS BETWEEN THE NSPG*NSPG-ELEMENT BLOCKS
C
      INDEX1 = 2
      INDEX2 = NSPG + 1
      DO 340 IR  =  1, ITEMP2
      IPR = INDEX1
      IRP  =  INDEX2
      DO 330 IP  =  2, INDINC
      IPRQ  =  IPR
      IQRP  =  IRP
      IPM1  =  IP  -  1
      DO 320 IQ  =  1, IPM1
      DO 315 IT = 1, ISRINC
      CTEMP1 = BUF(2*((IPRQ-1)*ISRINC+IT)-1)
      CTEMP2 = BUF(2*((IPRQ-1)*ISRINC+IT))
      BUF(2*((IPRQ-1)*ISRINC+IT)-1) = BUF(2*((IQRP-1)*ISRINC+IT)-1)
      BUF(2*((IPRQ-1)*ISRINC+IT)) = BUF(2*((IQRP-1)*ISRINC+IT))
      BUF(2*((IQRP-1)*ISRINC+IT)-1) = CTEMP1
      BUF(2*((IQRP-1)*ISRINC+IT)) = CTEMP2
315   CONTINUE
      IPRQ = IPRQ + NSPG
      IQRP = IQRP + 1
320   CONTINUE
      IPR = IPR + 1
      IRP = IRP + NSPG
330   CONTINUE
      INDEX1 = INDEX1 + INDINC
      INDEX2 = INDEX2 + INDINC
340   CONTINUE
350   CONTINUE

C  PERFORM THE SECOND FFT & WRITE TO THE OUTPUT FILE

      I = 0
      ISROW = MSROW
400   ITEMP = ISROW + ITEMP2 - 1
      DO IROW = ISROW,ITEMP

	IF (IROW.LE. NSAMP) THEN ! EXCLUDE DUMMY LINES FOR NON-POWER OF 2

	  CALL DFFT( BUF(2*I+1), BUF(2*I+2), NLINE, NLINE, NLINE,
     .     -SGN2, *998, *999)

	  IF (.NOT.INVFLG .OR. IFMT.EQ.5) THEN	! IF COMPLEX OUTPUT

	    CALL XVWRIT( UNIT2, BUF(2*I+1), STAT, 'LINE', IROW,' ')

	  ELSE			! NON-COMPLEX OUTPUT

	    IF (IFMT.LE.3) THEN	! INTEGER OUTPUT
	      DO K = 1,NLINE
	        V = BUF(2*(I+K)-1)/RESCAL
	        IF (V.LT.VLO) V = VLO
	        IF (V.GT.VHI) V = VHI
	        BUF(2*K-1) = V + 0.5
	      ENDDO
	    ELSEIF (IFMT.EQ.4) THEN	! FLOATING POINT OUTPUT
	      DO K = 1,NLINE	
	        BUF(2*K-1) = BUF(2*(I+K)-1)/RESCAL
	      ENDDO
	    ENDIF

	    CALL XVWRIT( UNIT2, BUF, STAT, 'LINE', IROW,' ')

	  ENDIF

	ENDIF
	I = I + IDIMEN

      ENDDO
C
C     Sequential write to output file
      IF (ISRINC .EQ. 0) THEN
          ISROW = ISROW + 1
      ELSE
C     Random write to output file
          ISROW = ISROW + ISRINC
      END IF
      IF (I.LT.MAXC) GO TO 400
      MSROW = MSROW + ITEMP2
      IF (MSROW.LE.ISRINC) GO TO 301
C  END LOOP OVER MSROW

C  FIX OUTPUT LABEL IF NL < IDIMEN
      IF (NSAMP.LT.NLINE) THEN
	CALL XLDEL( UNIT2, 'SYSTEM', 'NL', STAT, 'ERR_ACT', 'SA',' ')
	CALL XLADD( UNIT2, 'SYSTEM', 'NL', NSAMP, STAT, 'FORMAT',
     &	 'INT', 'ERR_ACT', 'SA',' ')
      ENDIF
C
C  CLOSE DATA SETS
      CALL XVCLOSE( UNIT1, STAT,' ')
      CALL XVCLOSE( UNIT2, STAT,' ')
      IF (UNIT2.NE.UNIT3) CALL XVCLOSE( UNIT3, STAT, 'CLOS_ACT',
     & 'DELETE',' ')

      CALL XVMESSAGE('TRANSFORM COMPLETED',' ')
C
      RETURN
C
998   CALL XVMESSAGE('*** A PRIME FACTOR OF N EXCEEDS 23 ***',' ')
      CALL ABEND
999   CALL XVMESSAGE
     &  ('*** TOO MANY SQUARE-FREE OR PRIME FACTORS IN N ***',' ')
      CALL ABEND
      END
C
      FUNCTION LOG2(N)
      I = N
      LOG2 = 0
10    I = I/2
      IF (I.EQ.0) RETURN
      LOG2 = LOG2 + 1
      GO TO 10
      END
