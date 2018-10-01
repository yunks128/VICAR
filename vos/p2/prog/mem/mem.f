C  PROGRAM MEM
C
C	PERFORMS MAXIMUM ENTROPY DECONVOLUTION.
C
C
C	VERSION :	NEW		JANUARY 1986
C
c                B      ported 7,1998  J. Lorre
C	REVISION A:	ADDED DIRECT CONVOLUTION, FIX BUGS
C			KFE	FEBRUARY 1986
C
C
C	ORIGINAL PROGRAMMER :		K. F. EVANS
C
C
	INCLUDE 'VICMAIN_FOR'
	SUBROUTINE MAIN44

	INCLUDE 'mem.inc'

	INTEGER	LOG2, SCRNUM
	REAL	MAXFORMAT
	CHARACTER*32 FORMAT
	CHARACTER*40 STRING
	LOGICAL	XVPTST
        integer junk1,junk2

	DATA	DATA/1/, PSF/2/, DEFAULT/3/, OUT/4/, XFER/5/, TMPFFT/6/,
     +      DEF/7/, CURRENT/8/, GRDE/9/, CNVSTP/9/, RESID/10/, STEP/11/ 

	
C ******************************** START OF EXECUTABLE CODE


C		GET THE INPUT PARAMETERS
	CALL XVP ('MAXITER', MAXITER, COUNT)
	CALL XVP ('RMSERROR', TARGETRMS, COUNT)
	CALL XVP ('MAXCRIT', MAXCRIT, COUNT)

	RESTART = XVPTST ('RESTART')


C		OPEN THE CONVOLVED (BLURRED) IMAGE
	CALL XVUNIT (UNIT(DATA), 'INP', 1, STATUS,' ')
	CALL XVOPEN (UNIT(DATA), STATUS, 'IO_ACT', 'SA',
     +		'OPEN_ACT', 'SA', 'U_FORMAT', 'REAL',' ')
	CALL XVSIZE (SL,SS,NL,NS,junk1,junk2)
	IF (NL .GT. 4096 .OR. NS .GT. 4096) THEN
	    CALL xvmessage ('Maximum image size exceeded.',' ')
	    CALL ABEND
	ENDIF
	NPIXELS = FLOAT(NL*NS)
	CALL XVGET (UNIT(DATA), STATUS, 'FORMAT', FORMAT,' ')
	IF (FORMAT(1:4) .EQ. 'HALF' .OR. FORMAT(1:4) .EQ. 'WORD') THEN
	    MAXFORMAT = 32767.0
	ELSE IF (FORMAT(1:4) .EQ. 'FULL') THEN
	    MAXFORMAT = 2147483647.0
	ELSE IF (FORMAT(1:4) .EQ. 'BYTE') THEN
	    MAXFORMAT = 255.0
	ENDIF



C		OPEN THE POINT SPREAD FUNCTION (PSF)
	CALL XVUNIT (UNIT(PSF), 'INP', 2, STATUS,' ')
	CALL XVOPEN (UNIT(PSF), STATUS, 'IO_ACT', 'SA', 'OPEN_ACT', 'SA',
     +		'U_FORMAT', 'REAL',' ')
	CALL XVGET (UNIT(PSF), STATUS, 'NL',NLPSF, 'NS',NSPSF,' ')

	IF (NLPSF .LE. 16 .AND. NSPSF .LE. 16)  THEN
	    SMALLPSF = .TRUE.
	ELSE
	    SMALLPSF = .FALSE.
	ENDIF


C		CALCULATE THE SIZE NEEDED FOR THE FFT 
C		    MUST BE BIG ENOUGH SO THAT THE PSF WON'T WRAP AROUND
	NLFFT = 2**( LOG2(NL+NLPSF-1) + 1 )
	NSFFT = 2**( LOG2(NS+NSPSF-1) + 1 )



C		CREATE AND OPEN THE SCRATCH FILES
	SCRNUM = 0
	IF (.NOT. SMALLPSF) THEN
	    CALL OPENSCRATCH (UNIT(XFER), 'MEM1', 
     +						SCRNUM,	NLFFT, NSFFT)
	    CALL OPENSCRATCH (UNIT(TMPFFT), 'MEM2', 
     +						SCRNUM, NLFFT, NSFFT)
	ENDIF
	CALL OPENSCRATCH (UNIT(DEF), 'MEM3',
     +						SCRNUM, NL, NS)
	CALL OPENSCRATCH (UNIT(GRDE), 'MEM4', 
     +						SCRNUM, NL, NS)
	CALL OPENSCRATCH (UNIT(RESID), 'MEM5', 
     +						SCRNUM, NL, NS)
	CALL OPENSCRATCH (UNIT(STEP), 'MEM6', 
     +						SCRNUM, NL, NS)
	CALL OPENSCRATCH (UNIT(CURRENT), 'MEM7', 
     +						SCRNUM, NL, NS)



	IF (SMALLPSF) THEN
	    CALL READPSF
	ELSE
C		MAKE THE TRANSFER FUNCTION FROM THE PSF
	    CALL MAKEXFER
	ENDIF
	CALL XVCLOSE (UNIT(PSF), STATUS,' ')



C		COPY OR MAKE THE DEFAULT IMAGE
	CALL MAKEDEFAULT



	IF (RESTART) THEN
C		COPY THE OLD OUTPUT INTO THE CURRENT IMAGE SCRATCH
	    CALL XVUNIT( UNIT(OUT), 'OUT',1, STATUS,' ')
	    CALL XVOPEN( UNIT(OUT), STATUS, 'OP', 'READ', 
     +			'OPEN_ACT', 'SA', 'IO_ACT', 'SA',
     +			'U_FORMAT', 'REAL',' ')
	    IMAGEMIN = 1.0E20
	    DO LINE = 1, NL
		CALL XVREAD(UNIT(OUT), IMAGE(1,CURRENT), STATUS, 'LINE',LINE,
     +                       ' ')
		DO SAMP = 1, NS
		    IMAGE(SAMP,CURRENT) = MAX( IMAGE(SAMP,CURRENT), 1.0E-8)
		    IMAGEMIN = MIN (IMAGEMIN, IMAGE(SAMP,CURRENT) )
		ENDDO
		CALL XVWRIT (UNIT(CURRENT), IMAGE(1,CURRENT), STATUS, 
     +							'LINE',LINE,' ')
	    ENDDO
	    CALL XVCLOSE (UNIT(OUT), STATUS,' ')

	ELSE
C		COPY THE DEFAULT INTO THE CURRENT IMAGE TO START WITH
	    IMAGEMIN = 1.0E20
	    DO LINE = 1, NL
 		CALL XVREAD(UNIT(DEF), IMAGE(1,CURRENT), STATUS, 'LINE',LINE,
     +                       ' ')
		DO SAMP = 1, NS
		    IMAGEMIN = MIN (IMAGEMIN, IMAGE(SAMP,CURRENT) )
		ENDDO
		CALL XVWRIT (UNIT(CURRENT), IMAGE(1,CURRENT), STATUS, 
     +					'LINE',LINE,' ')
	    ENDDO
	ENDIF



C		MAKE THE STARTING RESIDUALS FROM THE CURRENT IMAGE AND THE DATA
	CALL MAKEFIRSTRESID
	CALL XVCLOSE (UNIT(DATA), STATUS,' ')


	TARGETERROR = NPIXELS* TARGETRMS**2
	TOL = 0.10
	PSFVOLUME = 1.0
	MAXSTEPLEN = 2.0
	ITER = 0



C		CALCULATE THE STARTING ALPHA
	RMSERROR = SQRT(ERROR/NPIXELS)
	CALL xvmessage (' ',' ')
	WRITE (STRING,103) 'Starting RMS Error : ', RMSERROR
103	FORMAT (A,F12.4)
	CALL xvmessage (STRING,' ')

	CALL CONVIMAGE (RESID, GRDE, .TRUE.)
	CALL FIRSTALPHA
	IF (RESTART)  CALL UPDATEALPHA
C	TYPE *,'Starting alpha : ',ALPHA

	CALL xvmessage (' ',' ')


C		* * *	START OF MEM ITERATIONS   * * *

100	CONTINUE

	    ITER = ITER + 1

	    CALL CALCSTEP

	    CALL CONVIMAGE (STEP, CNVSTP, .FALSE.)
	    CALL CALCSTEPLEN

	    CALL TAKESTEP
	    CALL MAKENEWRESID
	    CALL CONVIMAGE (RESID, GRDE, .TRUE.)

	    CALL UPDATEALPHA

	    CALL TERMOUTPUT

	IF ( ITER .LT. MAXITER      .AND.
     +	     ((SOLUCRIT - MAXCRIT)/MAXCRIT .GT. TOL  .OR.
     +	      ABS((RMSERROR-TARGETRMS)/TARGETRMS) .GT. TOL) )  GOTO 100


	IF (  ((SOLUCRIT - MAXCRIT)/MAXCRIT .LE. TOL)  .AND.
     +	      (ABS((RMSERROR-TARGETRMS)/TARGETRMS) .LE. TOL) )  THEN
	    CALL xvmessage (' ',' ')
	    CALL xvmessage ('      * * *  CONVERGENCE ACHIEVED  * * *  '
     +				,' ')
	ENDIF

C		* * *	END OF MEM ITERATIONS   * * *



C		COPY CURRENT IMAGE SCRATCH INTO OUTPUT MEM IMAGE
	CALL XVUNIT( UNIT(OUT), 'OUT',1, STATUS,' ')
	CALL XVOPEN( UNIT(OUT), STATUS, 'OP', 'WRITE', 
     +		'U_NL', NL,  'U_NS', NS,
     +		'OPEN_ACT', 'SA', 'IO_ACT', 'SA',
     +		'U_FORMAT', 'REAL', 'O_FORMAT',FORMAT,' ')

	DO LINE = 1, NL
	    CALL XVREAD(UNIT(CURRENT), IMAGE(1,CURRENT), STATUS,
     +			 'LINE',LINE, ' ')
	    IF (FORMAT(1:4) .NE. 'REAL') THEN
		DO SAMP = 1, NS
		    IMAGE(SAMP,CURRENT) = 
     +			   MIN( IMAGE(SAMP,CURRENT) + 0.5, MAXFORMAT)
		ENDDO
	    ENDIF
	    CALL XVWRIT (UNIT(OUT), IMAGE(1,CURRENT), STATUS,
     +			 'LINE',LINE,' ')
	ENDDO
	CALL XVCLOSE (UNIT(OUT), STATUS,' ')



C		CLOSE AND DELETE SCRATCH FILES
	IF (.NOT. SMALLPSF) THEN
	    CALL XVCLOSE (UNIT(TMPFFT), STATUS,'CLOS_ACT','DELETE',' ')
	    CALL XVCLOSE (UNIT(XFER), STATUS, 'CLOS_ACT','DELETE',' ')
	ENDIF
	CALL XVCLOSE (UNIT(GRDE), STATUS, 'CLOS_ACT','DELETE',' ')
	CALL XVCLOSE (UNIT(CURRENT), STATUS, 'CLOS_ACT','DELETE',' ')
	CALL XVCLOSE (UNIT(DEF), STATUS, 'CLOS_ACT','DELETE',' ')
	CALL XVCLOSE (UNIT(RESID), STATUS, 'CLOS_ACT','DELETE',' ')
	CALL XVCLOSE (UNIT(STEP), STATUS, 'CLOS_ACT','DELETE',' ')


	RETURN
	END




	SUBROUTINE OPENSCRATCH (UNIT, NAME, SCRNUM, NL, NS)
C
C	CREATES AND OPENS A REAL SCRATCH FILE WITH NAME (NAME) 
C	    OF SIZE NL BY NS AND RETURNS THE UNIT NUMBER
C
	IMPLICIT NONE
	INTEGER	UNIT, NL, NS
	CHARACTER*32 NAME
	INTEGER	STATUS, SCRNUM

	SCRNUM = SCRNUM + 1
	CALL XVUNIT (UNIT,'   ',SCRNUM,  STATUS, 'U_NAME',NAME,' ')
	CALL XVOPEN (UNIT, STATUS, 'OP','WRITE',
     +				'U_NL',NL, 'U_NS',NS,
     +				'O_FORMAT','REAL', 
     +				'COND','LABELS', 'OPEN_ACT','SA',' ')
	CALL XVCLOSE (UNIT, STATUS,' ')
	CALL XVUNIT (UNIT,'   ',SCRNUM,  STATUS, 'U_NAME',NAME,' ')
	CALL XVOPEN (UNIT, STATUS, 'OP','UPDATE',
     +			'U_NL',NL, 'U_NS',NS,
     +			'I_FORMAT','REAL', 'U_FORMAT', 'REAL',
     +			'O_FORMAT','REAL',
     +			'IO_ACT', 'SA', 'OPEN_ACT', 'SA',' ')

	RETURN
	END



	SUBROUTINE MAKEDEFAULT
	INCLUDE 'mem.inc'
	REAL	DATAFLUX, AVGLEVEL
	INTEGER	INPCOUNT
	CHARACTER*132	INPFILES(3)

C		OPEN AND COPY THE DEFAULT IMAGE IF THERE IS ONE
	CALL XVP ('INP', INPFILES, INPCOUNT)
	IF (INPCOUNT .EQ. 3) THEN
	    DEFFLAG = .TRUE.
	ELSE
	    DEFFLAG = .FALSE.
	ENDIF

	IF (DEFFLAG) THEN
	    CALL XVUNIT (UNIT(DEFAULT), 'INP', 3, STATUS,' ')
	    CALL XVOPEN (UNIT(DEFAULT), STATUS, 'IO_ACT', 'SA', 
     +		'OPEN_ACT', 'SA', 'U_FORMAT', 'REAL',' ')
	    DO LINE = 1, NL
		CALL XVREAD(UNIT(DEFAULT), IMAGE(1,DEF), STATUS,
     +						 'LINE',LINE,' ')
		DO SAMP = 1, NS
		    IMAGE(SAMP,DEF) = MAX( IMAGE(SAMP,DEF), 1.0E-8 )
		ENDDO
		CALL XVWRIT (UNIT(DEF), IMAGE(1,DEF), STATUS,
     +						 'LINE',LINE,' ')
	    ENDDO
	    CALL XVCLOSE (UNIT(DEFAULT), STATUS,' ')
	ELSE
	    DATAFLUX = 0.0
	    DO LINE = 1, NL
		CALL XVREAD(UNIT(DATA), IMAGE(1,DATA), STATUS, 
     +					'LINE',LINE+SL-1, 'SAMP',SS,' ')
		DO SAMP = 1, NS
		    DATAFLUX = DATAFLUX + IMAGE(SAMP,DATA)
		ENDDO
	    ENDDO
	    AVGLEVEL = DATAFLUX/FLOAT(NL*NS)
	    DO SAMP = 1, NS
		IMAGE(SAMP,DEF) = AVGLEVEL
	    ENDDO
	    DO LINE = 1, NL
		CALL XVWRIT (UNIT(DEF), IMAGE(1,DEF), STATUS,
     +						 'LINE',LINE,' ')
	    ENDDO
	ENDIF

	RETURN
	END





	SUBROUTINE MAKEFIRSTRESID
	INCLUDE 'mem.inc'

C		CONVOLVE THE IMAGE WITH THE PSF AND SUBTRACT THE DATA
C		    IN ORDER TO MAKE THE STARTING RESIDUALS
	CALL CONVIMAGE (CURRENT, RESID, .FALSE.)
	ERROR = 0.0
	DO LINE = 1, NL
	    CALL XVREAD(UNIT(DATA), IMAGE(1,DATA), STATUS, 
     +				'LINE',LINE+SL-1, 'SAMP',SS,' ')
	    CALL XVREAD(UNIT(RESID), IMAGE(1,RESID), STATUS,
     +				 'LINE',LINE,' ')
	    DO SAMP = 1, NS
		IMAGE(SAMP,RESID) = IMAGE(SAMP,RESID) - IMAGE(SAMP,DATA)
		ERROR = ERROR + IMAGE(SAMP,RESID)**2
	    ENDDO
	    CALL XVWRIT (UNIT(RESID), IMAGE(1,RESID), STATUS,
     +						 'LINE',LINE,' ')
	ENDDO

	RETURN
	END



	SUBROUTINE FIRSTALPHA
	INCLUDE 'mem.inc'
	REAL	GRAD(3), GHDGE, GEDGE

	GHDGE = 0.0
	GEDGE = 0.0
	IF (RESTART) THEN
	    DO LINE = 1, NL
	        CALL XVREAD(UNIT(CURRENT), IMAGE(1,CURRENT), STATUS, 
     +				'LINE',LINE,' ')
	        CALL XVREAD(UNIT(DEF), IMAGE(1,DEF), STATUS,
     +				 'LINE',LINE,' ')
	        CALL XVREAD(UNIT(GRDE),IMAGE(1,GRDE),STATUS,
     +				'LINE',LINE,' ')
	        DO SAMP = 1, NS
		    GRAD(H) = -LOG( IMAGE(SAMP,CURRENT)/IMAGE(SAMP,DEF) )
		    GRAD(E) = 2.0*IMAGE(SAMP,GRDE)
		    GHDGE = GHDGE + GRAD(H)*GRAD(E)
		    GEDGE = GEDGE + GRAD(E)**2
	        ENDDO
	    ENDDO
	    ALPHA = GHDGE/GEDGE
	ELSE
	    DO LINE = 1, NL
	        CALL XVREAD(UNIT(GRDE),IMAGE(1,GRDE),STATUS,
     +				'LINE',LINE,' ')
	        DO SAMP = 1, NS
		    GRAD(E) = 2.0*IMAGE(SAMP,GRDE)
		    GEDGE = GEDGE + GRAD(E)**2
	        ENDDO
	    ENDDO
	    ALPHA = 1.0/SQRT(GEDGE/NPIXELS)
	ENDIF

	RETURN
	END






	SUBROUTINE TAKESTEP
	INCLUDE 'mem.inc'

	IMAGEMIN = 1.0E20
	DO LINE = 1, NL
	    CALL XVREAD(UNIT(CURRENT), IMAGE(1,CURRENT), STATUS,
     +			 'LINE',LINE, ' ')
	    CALL XVREAD(UNIT(STEP), IMAGE(1,STEP), STATUS,
     +			 'LINE',LINE,' ')
	    DO SAMP = 1, NS
		IMAGE(SAMP,CURRENT) = IMAGE(SAMP,CURRENT)
     +				+ STEPLEN * IMAGE(SAMP,STEP)
		IMAGEMIN = MIN (IMAGEMIN, IMAGE(SAMP,CURRENT) )
	    ENDDO
	    CALL XVWRIT (UNIT(CURRENT), IMAGE(1,CURRENT), STATUS,
     +			 'LINE',LINE, ' ')
	ENDDO

	RETURN
	END



	SUBROUTINE MAKENEWRESID
	INCLUDE 'mem.inc'

	ERROR = 0.0
	DO LINE = 1, NL
	    CALL XVREAD(UNIT(RESID), IMAGE(1,RESID), STATUS,
     +				 'LINE',LINE,' ')
	    CALL XVREAD(UNIT(CNVSTP),IMAGE(1,CNVSTP),STATUS,
     +				'LINE',LINE,' ')
	    DO SAMP = 1, NS
		IMAGE(SAMP,RESID) = IMAGE(SAMP,RESID)
     +				+ STEPLEN * IMAGE(SAMP,CNVSTP)
		ERROR = ERROR + IMAGE(SAMP,RESID)**2
	    ENDDO
	    CALL XVWRIT (UNIT(RESID), IMAGE(1,RESID), STATUS,
     +				'LINE',LINE,' ')
	ENDDO
	RMSERROR = SQRT(ERROR/NPIXELS)

	RETURN
	END



	SUBROUTINE TERMOUTPUT
	INCLUDE 'mem.inc'
	CHARACTER*60  STRING

	WRITE (STRING,101) ' Iteration ',ITER, ' of ', MAXITER
101	FORMAT (A,I3,A,I3)
	CALL xvmessage (STRING,' ')
	WRITE (STRING,103) '     RMS Error          : ',RMSERROR
103	FORMAT (A,F12.4)
	CALL xvmessage (STRING,' ')
	WRITE (STRING,105) '     Solution Criterion : ',SOLUCRIT
105	FORMAT (A,F8.4)
	CALL xvmessage (STRING,' ')

C	TYPE *,'     Step Length        : ',STEPLEN
C	TYPE *,'     Alpha              : ', ALPHA

	RETURN
	END






	REAL FUNCTION CALCJAY (LENGTH)
	INCLUDE 'mem.inc'
	REAL	LENGTH
	REAL	ENTROPY, OUTPIXEL

	ENTROPY = 0.0
	DO LINE = 1, NL
	    CALL XVREAD(UNIT(CURRENT), IMAGE(1,CURRENT), STATUS,
     +				 'LINE',LINE, ' ')
	    CALL XVREAD(UNIT(STEP), IMAGE(1,STEP), STATUS,
     +				 'LINE',LINE,' ')
	    CALL XVREAD(UNIT(DEF), IMAGE(1,DEF), STATUS,
     +				 'LINE',LINE,' ')
	    DO SAMP = 1, NS
		OUTPIXEL = IMAGE(SAMP,CURRENT)+LENGTH*IMAGE(SAMP,STEP)
		ENTROPY = ENTROPY - OUTPIXEL
     +			  *( LOG(OUTPIXEL/IMAGE(SAMP,DEF)) - 1.0 )
	    ENDDO
	ENDDO

	CALCJAY = ENTROPY - ALPHA*(E0 + 2*E1*LENGTH + E2*LENGTH**2)

	RETURN
	END



	SUBROUTINE CALCSTEPLEN
	INCLUDE 'mem.inc'
	REAL	LENLOW, LENUP, LENA, LENB
	REAL	JAYLOW, JAYUP, JAYA, JAYB, CALCJAY

	E0 = ERROR
	E1 = 0.0
	E2 = 0.0
	DO LINE = 1, NL
	    CALL XVREAD(UNIT(RESID), IMAGE(1,RESID), STATUS,
     +				 'LINE',LINE,' ')
	    CALL XVREAD(UNIT(CNVSTP),IMAGE(1,CNVSTP),STATUS,
     +				'LINE',LINE,' ')
	    DO SAMP = 1, NS
		E1 = E1 + IMAGE(SAMP,RESID) * IMAGE(SAMP,CNVSTP)
		E2 = E2 + IMAGE(SAMP,CNVSTP)**2
	    ENDDO
	ENDDO


	LENLOW = 0.0
	LENUP = MAXSTEPLEN

	LENA = LENUP - 0.618*(LENUP-LENLOW)
	JAYA = CALCJAY(LENA)
	LENB = LENLOW + 0.618*(LENUP-LENLOW)
	JAYB = CALCJAY(LENB)

	DO WHILE (ABS((LENB-LENA)/LENA) .GT. 0.05)
	    IF (JAYA .GT. JAYB) THEN
		LENUP = LENB
		JAYUP = JAYB
		LENB = LENA
		JAYB = JAYA
		LENA = LENUP - 0.618*(LENUP-LENLOW)
		JAYA = CALCJAY (LENA)
	    ELSE
		LENLOW = LENA
		JAYLOW = JAYA
		LENA = LENB
		JAYA = JAYB
		LENB = LENLOW + 0.618*(LENUP-LENLOW)
		JAYB = CALCJAY (LENB)
	    ENDIF
	ENDDO

	IF (JAYA .GT. JAYB)  THEN
	    STEPLEN = LENA
	ELSE
	    STEPLEN = LENB
	ENDIF

	MAXSTEPLEN = 2.0*STEPLEN

	RETURN
	END




	SUBROUTINE CALCSTEP 
	INCLUDE 'mem.inc'
	REAL	TMP, INVGRDGRDJ, DELPIX
	REAL	GRAD(3)

	TMP = 2.0*ALPHA*PSFVOLUME

	DO LINE = 1, NL
	    CALL XVREAD(UNIT(CURRENT), IMAGE(1,CURRENT), STATUS,
     +					'LINE',LINE,' ')
	    CALL XVREAD(UNIT(DEF), IMAGE(1,DEF), STATUS,
     +					 'LINE',LINE,' ')
	    CALL XVREAD(UNIT(GRDE), IMAGE(1,GRDE), STATUS,
     +					 'LINE',LINE,' ')
	    DO SAMP = 1, NS
		GRAD(H) = -LOG( IMAGE(SAMP,CURRENT)/IMAGE(SAMP,DEF) )
		GRAD(E) = 2.0*IMAGE(SAMP,GRDE)
		GRAD(J) = GRAD(H) - ALPHA*GRAD(E)
		INVGRDGRDJ = 1.0/( 1.0/IMAGE(SAMP,CURRENT) + TMP)
		DELPIX = INVGRDGRDJ * GRAD(J)
		DELPIX = MAX( DELPIX, 
     +			  (0.1*IMAGEMIN-IMAGE(SAMP,CURRENT))/MAXSTEPLEN )
		IMAGE(SAMP,STEP) = DELPIX
	    ENDDO
	    CALL XVWRIT (UNIT(STEP), IMAGE(1,STEP), STATUS,
     +					 'LINE',LINE,' ')
	ENDDO

	RETURN
	END




	SUBROUTINE UPDATEALPHA
	INCLUDE 'mem.inc'
	INTEGER	I1, I2
	REAL	TMP, INVGRDGRDJ
	REAL	GRAD(3)
	REAL	A, B, C, DELTAALPHA, ALPHAUPBND, ALPHALOWBND

	DO I1 = 1, 3
	    DO I2 = 1, 3
		GRADDOTGRAD(I1,I2) = 0.0
	    ENDDO
	ENDDO

	TMP = 2.0*ALPHA*PSFVOLUME

	DO LINE = 1, NL
	    CALL XVREAD(UNIT(CURRENT), IMAGE(1,CURRENT), STATUS,
     +					 'LINE',LINE, ' ')
	    CALL XVREAD(UNIT(DEF), IMAGE(1,DEF), STATUS,
     +					 'LINE',LINE,' ')
	    CALL XVREAD(UNIT(GRDE), IMAGE(1,GRDE), STATUS,
     +					'LINE',LINE,' ')
	    DO SAMP = 1, NS
		GRAD(H) = -LOG( IMAGE(SAMP,CURRENT)/IMAGE(SAMP,DEF) )
		GRAD(E) = 2.0*IMAGE(SAMP,GRDE)
		GRAD(J) = GRAD(H) - ALPHA*GRAD(E)
		INVGRDGRDJ = 1.0/( 1.0/IMAGE(SAMP,CURRENT) + TMP)
		DO I1 = 1, 3
		    DO I2 = I1, 3
			GRADDOTGRAD(I1,I2) = GRADDOTGRAD(I1,I2) +
     +				GRAD(I1) * INVGRDGRDJ * GRAD(I2)
		    ENDDO
		ENDDO
	    ENDDO
	ENDDO

	DO I1 = 1, 3
	    DO I2 = I1, 3
		GRADDOTGRAD(I2,I1) = GRADDOTGRAD(I1,I2)
	    ENDDO
	ENDDO


	COMPOFGRADJ = GRADDOTGRAD(H,H) + ALPHA**2 *GRADDOTGRAD(E,E)
	IF (COMPOFGRADJ .GT. 0.0) THEN
	    SOLUCRIT = GRADDOTGRAD(J,J) / COMPOFGRADJ
	ELSE
	    SOLUCRIT = 0.0
	ENDIF



	IF (SOLUCRIT .LT. MAXCRIT) THEN

	    DELTAALPHA = (ERROR - TARGETERROR)/ GRADDOTGRAD(E,E)

C	    A = (1-MAXCRIT)* GRADDOTGRAD(E,E)
C	    B = -GRADDOTGRAD(J,E) - MAXCRIT*ALPHA*GRADDOTGRAD(E,E)
C	    C = GRADDOTGRAD(J,J) - MAXCRIT *COMPOFGRADJ

	    A = GRADDOTGRAD(E,E)		! Tim Cornwell's method
	    B = -GRADDOTGRAD(J,E)
	    C = GRADDOTGRAD(J,J) - MAXCRIT *COMPOFGRADJ
	
	    ALPHAUPBND = ( -B + SQRT(B**2 - A*C) )/ A
	    ALPHALOWBND = ( -B - SQRT(B**2 - A*C) )/ A

	    DELTAALPHA = MIN (MAX( DELTAALPHA, ALPHALOWBND), ALPHAUPBND)
	    ALPHA = ALPHA + DELTAALPHA
	    ALPHA = MAX( ALPHA, 0.0)

	ENDIF


	RETURN
	END


	



	SUBROUTINE READPSF
	INCLUDE 'mem.inc'

	REAL	VOLUME

	VOLUME = 0.0
	DO LINE = 1, NLPSF
	    CALL XVREAD(UNIT(PSF), IMAGE(1,PSF), STATUS,
     +						 'LINE',LINE,' ')
	    DO SAMP = 1, NSPSF
		PSFIMAGE(SAMP,LINE) = IMAGE(SAMP,PSF)
		VOLUME = VOLUME + PSFIMAGE(SAMP,LINE)
	    ENDDO
	ENDDO

	if (volume.eq.0.0) call mabend(' ** empty PSF file **')

	DO LINE = 1, NLPSF
	    DO SAMP = 1, NSPSF
		PSFIMAGE(SAMP,LINE)= PSFIMAGE(SAMP,LINE)/VOLUME
	    ENDDO
	ENDDO

	RETURN
	END







	SUBROUTINE MAKEXFER
	INCLUDE 'mem.inc'

	REAL	VOLUME
	COMPLEX CBUFFER(2048), TWOPII


	TWOPII = 2*3.1415926*(0,1)

	VOLUME = 0.0
	DO LINE = 1, NLPSF
	    CALL XVREAD(UNIT(PSF), IMAGE(1,PSF), STATUS,
     +					 'LINE',LINE,' ')
	    DO SAMP = 1, NSPSF
		VOLUME = VOLUME + IMAGE(SAMP,PSF)
	    ENDDO
	ENDDO
	VOLUME = VOLUME*NLFFT*NSFFT

	DO LINE = 1, NLPSF
	    CALL XVREAD(UNIT(PSF), IMAGE(1,PSF), STATUS,
     +					 'LINE',LINE,' ')
	    DO SAMP = 1, NSPSF
		IMAGE(SAMP,XFER)= IMAGE(SAMP,PSF)/VOLUME
	    ENDDO
	    DO SAMP = NSPSF+1, NSFFT
		IMAGE(SAMP,XFER) = 0.0
	    ENDDO
	    CALL XVWRIT (UNIT(XFER), IMAGE(1,XFER), STATUS,
     +					 'LINE',LINE,' ')
	ENDDO
	DO SAMP = 1, NSFFT
	    IMAGE(SAMP,XFER) = 0.0
	ENDDO
	DO LINE = NLPSF+1, NLFFT
	    CALL XVWRIT (UNIT(XFER), IMAGE(1,XFER), STATUS,
     +					 'LINE',LINE,' ')
	ENDDO


	CALL FFTVICARR (UNIT(XFER), NLFFT,NSFFT, +1, XFERCOLBUF)


	DO LINE = 1, NLFFT
	    CALL XVREAD(UNIT(XFER), CBUFFER, STATUS,
     +					 'LINE',LINE,' ')
	    DO SAMP = 1, NSFFT/2
		CBUFFER(SAMP) = CBUFFER(SAMP)
     +		 * CEXP(-TWOPII*( FLOAT(LINE-1)*INT(NLPSF/2.)/NLFFT 
     +			       +  FLOAT(SAMP-1)*INT(NSPSF/2.)/NSFFT ) )
	    ENDDO
	    CALL XVWRIT (UNIT(XFER), CBUFFER, STATUS, 'LINE',LINE)
	    XFERCOLBUF(LINE) = XFERCOLBUF(LINE)
     +			 * CEXP(-TWOPII*( FLOAT(LINE-1)*INT(NLPSF/2.)/NLFFT 
     +				       + FLOAT(NSFFT/2)*INT(NSPSF/2.)/NSFFT ) )

	ENDDO

	RETURN
	END






	SUBROUTINE CONVIMAGE (INIM, OUTIM, CONJGFLAG)
	INCLUDE 'mem.inc'

	INTEGER	INIM, OUTIM
	LOGICAL CONJGFLAG

	IF (SMALLPSF) THEN
	    CALL CONVDIRECT (INIM, OUTIM, CONJGFLAG)
	ELSE
	    CALL CONVFFT (INIM, OUTIM, CONJGFLAG)
	ENDIF

	RETURN
	END




	SUBROUTINE CONVDIRECT (INIM, OUTIM, CONJGFLAG)
C		CONVOLVES THE INPUT WITH THE PSF AND STORES THE
C		    RESULT IN OUTPUT.  PERFORMS CONVOLUTION DIRECTLY
C		    USING A CIRCULAR LINE BUFFER FOR THE IMAGE.
C		  CONJGFLAG IS TRUE IF THE PSF SHOULD BE FLIPPED 
C
	INCLUDE 'mem.inc'

	INTEGER	INIM, OUTIM
	LOGICAL CONJGFLAG
	INTEGER	LSTART, LEND, BUFLINE, SSTART, L, S, CONVLINE, SOFF, LOFF
	REAL	SUM

	SSTART = NSPSF/2 + 1
	IF (.NOT. CONJGFLAG .AND. (MOD( NSPSF, 2) .EQ. 0)) SSTART =
     +						 SSTART - 1
	LSTART = 1 - NLPSF/2
	IF (CONJGFLAG .AND. (MOD( NLPSF, 2) .EQ. 0)) LSTART =
     +						 LSTART + 1
	LEND = NL + LSTART - 1

	DO LINE = 2 - NLPSF , NL
	    BUFLINE = MOD( LINE + NLPSF - 2, NLPSF) + 1
	    IF (LINE .GE. LSTART .AND. LINE .LE. LEND) THEN
		CALL XVREAD(UNIT(INIM), CONVBUF(SSTART,BUFLINE),
     +			  STATUS, 'LINE',LINE-LSTART+1,' ')
	    ELSE
	        DO SAMP = 1, NS+NSPSF+2
		    CONVBUF(SAMP,BUFLINE) = 0.0
	        ENDDO
	    ENDIF

	    IF (LINE .GE. 1) THEN
		DO SAMP = 1, NS
		    SUM = 0.0
		    IF (CONJGFLAG) THEN
			SOFF = SAMP - 1
			LOFF = LINE - 2
			DO L = 1, NLPSF
			    CONVLINE = MOD(LOFF+L, NLPSF) + 1
			    DO S = 1, NSPSF
				SUM = SUM + PSFIMAGE(S,L)
     +				       *CONVBUF(SOFF+S,CONVLINE)
			    ENDDO
			ENDDO
		    ELSE
			SOFF = NSPSF + SAMP
			LOFF = NLPSF + LINE - 1
			DO L = 1, NLPSF
			    CONVLINE = MOD( LOFF-L, NLPSF) + 1
			    DO S = 1, NSPSF
				SUM = SUM + PSFIMAGE(S,L)
     +				       *CONVBUF(SOFF-S,CONVLINE)
			    ENDDO
			ENDDO
		    ENDIF
		    IMAGE(SAMP,OUTIM) = SUM
		ENDDO
		CALL XVWRIT (UNIT(OUTIM), IMAGE(1,OUTIM), STATUS, 
     +					'LINE',LINE,' ')
	    ENDIF
	ENDDO

	RETURN
	END




	SUBROUTINE CONVFFT (INIM, OUTIM, CONJGFLAG)
C		CONVOLVES THE INPUT WITH THE PSF AND STORES THE
C		    RESULT IN OUTPUT.  PERFORMS CONVOLUTION USING FFT'S.
C		  CONJGFLAG IS TRUE IF THE PSF SHOULD BE FLIPPED 
C
	INCLUDE 'mem.inc'

	INTEGER	INIM, OUTIM
	LOGICAL CONJGFLAG
	COMPLEX	FCOLBUF(4096), FBUFFER(2048), XFERBUFFER(2048)


C		COPY THE INPUT IMAGE INTO THE FFT SCRATCH FILE 
C		    AND PAD WITH ZEROS
	DO LINE = 1, NL
	    CALL XVREAD(UNIT(INIM), IMAGE(1,INIM), STATUS,
     +						 'LINE',LINE,' ')
	    DO SAMP = 1, NS
		IMAGE(SAMP,TMPFFT) = IMAGE(SAMP,INIM)
	    ENDDO
	    DO SAMP = NS+1, NSFFT
		IMAGE(SAMP,TMPFFT) = 0.0
	    ENDDO
	    CALL XVWRIT(UNIT(TMPFFT),IMAGE(1,TMPFFT),STATUS,
     +						'LINE',LINE,' ')
	ENDDO
	DO LINE = NL+1, NLFFT
	    DO SAMP = 1, NSFFT
		IMAGE(SAMP,TMPFFT) = 0.0
	    ENDDO
	    CALL XVWRIT(UNIT(TMPFFT),IMAGE(1,TMPFFT),STATUS,
     +						'LINE',LINE,' ')
	ENDDO

C		FFT THE INPUT IMAGE
	CALL FFTVICARR (UNIT(TMPFFT), NLFFT,NSFFT, +1, FCOLBUF)

C		COMPLEX MULTIPLY THE TRANSFORM OF THE INPUT IMAGE 
C		    BY THE TRANSFER IMAGE
	DO LINE = 1, NLFFT
	    CALL XVREAD(UNIT(TMPFFT), FBUFFER, STATUS,
     +						 'LINE',LINE,' ')
	    CALL XVREAD(UNIT(XFER), XFERBUFFER, STATUS,
     +						 'LINE',LINE,' ')
	    DO SAMP = 1, NSFFT/2
		IF (CONJGFLAG)  XFERBUFFER(SAMP) =
     +					 CONJG(XFERBUFFER(SAMP))
		FBUFFER(SAMP) = FBUFFER(SAMP) * XFERBUFFER(SAMP)
	    ENDDO
	    CALL XVWRIT(UNIT(TMPFFT), FBUFFER, STATUS,
     +						 'LINE',LINE,' ')
	    IF (CONJGFLAG)  XFERCOLBUF(LINE) =
     +					 CONJG(XFERCOLBUF(LINE))
	    FCOLBUF(LINE) = FCOLBUF(LINE)* XFERCOLBUF(LINE)
	ENDDO

C		FFT BACK TO GET THE CONVOLVED IMAGE
	CALL FFTVICARR (UNIT(TMPFFT), NLFFT,NSFFT, -1, FCOLBUF)


C		COPY INTO THE OUTPUT FILE
	DO LINE = 1, NL
	    CALL XVREAD(UNIT(TMPFFT),IMAGE(1,TMPFFT),STATUS,
     +						'LINE',LINE,' ')
	    CALL XVWRIT(UNIT(OUTIM), IMAGE(1,TMPFFT), STATUS,
     +						 'LINE',LINE,' ')
	ENDDO


	RETURN
	END





	SUBROUTINE FFTVICARR (UNIT, NLFFT, NSFFT, FFTSIGN, COLBUF)
C
C
C	FFTVICARR IS A TWO DIMENSIONAL FAST FOURIER TRANSFORM ROUTINE.
C	    IT DOES AN IN PLACE REAL TO COMPLEX CONJUGATE OR COMPLEX
C	    CONJUGATE TO REAL TRANSFORM ON AN EXISTING VICAR IMAGE.  
C	    THE IMAGE MUST BE ALREADY OPENED FOR UPDATE WITH XVOPEN,
C	    WITH REAL FORMATS, AND HAVE REAL SIZE NLFFT BY NSFFT
C	    WHICH MUST BE POWERS OF TWO.  
C	    THE SIGN (+1 OR -1) OF THE TRANSFORM IS PASSED IN FFTSIGN.
C	    IF FFTSIGN = +1 THEN THE TRANSFORM IS REAL TO COMPLEX CONJUGATE
C	    AND IF FFTSIGN = -1 THEN THEN TRANSFORM IS THE OTHER WAY.
C	    COLBUF IS A COMPLEX ARRAY OF LENGTH EQUAL TO THE NUMBER OF ROWS.
C	      IT CONTAINS THE 'EXTRA' COLUMN FOR THE COMPLEX CONJUGATE FORMAT.
C	    THE MAXIMUM SIZE IN EITHER DIRECTION IS 32768.
C	THE TRANSFORM DOES NOT TRANSPOSE THE IMAGE AND THE ZERO-FREQUENCY
C	    PIXEL IS AT THE FIRST LINE AND SAMPLE.
C
C
	IMPLICIT NONE
	INTEGER	UNIT, NLFFT, NSFFT, FFTSIGN
	INTEGER	MAXN, LINE, STATUS, BUFPTR
	COMPLEX COLBUF(1)
	INTEGER*2 BITREV(8192)
	COMPLEX BUFFER(512*256), PHASE(8192)

	COMMON	/BITREV/ BITREV
	COMMON  /PHASE/  PHASE


	MAXN = MAX(NLFFT,NSFFT)
	CALL MAKEBITREV (BITREV, MAXN)
	CALL MAKEPHASE (PHASE, FFTSIGN, MAXN)


	IF (NLFFT*NSFFT .GT. 512*512) THEN 

	IF (FFTSIGN .EQ. +1) THEN
	    DO LINE = 1, NLFFT
		CALL XVREAD(UNIT, BUFFER, STATUS, 'LINE',LINE,' ')
		CALL FFTC1D (BUFFER, NSFFT/2)
		CALL FIXREAL (BUFFER, COLBUF(LINE), NSFFT/2, +1)
		CALL XVWRIT(UNIT, BUFFER, STATUS, 'LINE',LINE,' ')
	    ENDDO
	    CALL FFTC1D (COLBUF, NLFFT)
	    CALL FFTC1VD (UNIT, NSFFT/2, NLFFT)
	ELSE
	    CALL FFTC1VD (UNIT, NSFFT/2, NLFFT)
	    CALL FFTC1D (COLBUF, NLFFT)
	    DO LINE = 1, NLFFT
		CALL XVREAD(UNIT, BUFFER, STATUS, 'LINE',LINE,' ')
		CALL FIXREAL (BUFFER, COLBUF(LINE), NSFFT/2, -1)
		CALL FFTC1D (BUFFER, NSFFT/2)
		CALL XVWRIT(UNIT, BUFFER, STATUS, 'LINE',LINE,' ')
	    ENDDO
	ENDIF

	ELSE

	IF (FFTSIGN .EQ. +1) THEN
	    DO LINE = 1, NLFFT
		BUFPTR = (NSFFT/2)*(LINE-1)+1
		CALL XVREAD(UNIT, BUFFER(BUFPTR), STATUS,
     +						 'LINE',LINE,' ')
		CALL FFTC1D (BUFFER(BUFPTR), NSFFT/2)
		CALL FIXREAL (BUFFER(BUFPTR), COLBUF(LINE), NSFFT/2,+1)
	    ENDDO
	    CALL FFTCV (BUFFER, NSFFT/2, NLFFT)
	    CALL FFTC1D (COLBUF, NLFFT)
	    DO LINE = 1, NLFFT
		BUFPTR = (NSFFT/2)*(LINE-1)+1
		CALL XVWRIT(UNIT, BUFFER(BUFPTR), STATUS,
     +						 'LINE',LINE,' ')
	    ENDDO
	ELSE
	    DO LINE = 1, NLFFT
		BUFPTR = (NSFFT/2)*(LINE-1)+1
		CALL XVREAD(UNIT, BUFFER(BUFPTR), STATUS,
     +						 'LINE',LINE,' ')
	    ENDDO
	    CALL FFTC1D (COLBUF, NLFFT)
	    CALL FFTCV (BUFFER, NSFFT/2, NLFFT)
	    DO LINE = 1, NLFFT
		BUFPTR = (NSFFT/2)*(LINE-1)+1
		CALL FIXREAL (BUFFER(BUFPTR), COLBUF(LINE), NSFFT/2, -1)
		CALL FFTC1D (BUFFER(BUFPTR), NSFFT/2)
		CALL XVWRIT(UNIT, BUFFER(BUFPTR), STATUS,
     +						 'LINE',LINE,' ')
	    ENDDO
	ENDIF

	ENDIF

	RETURN
	END





	SUBROUTINE MAKEBITREV(BITREV,NMAX)
	IMPLICIT NONE
	INTEGER	I,IREV,J,K,L,M,LMAX,NMAX
	INTEGER*2 BITREV(1)
	INTEGER LOG2

	LMAX=LOG2(NMAX)
	I=0
	DO L=0,LMAX
	    IREV=0
	    DO J=0,2**L-1
		I=I+1
		BITREV(I)=IREV
		DO K=1,L
		    M=2**(L-K)
		    IF (IREV.LT.M) GO TO 70
		    IREV=IREV-M
		END DO
70		IREV=IREV+M
	    END DO
	END DO

	RETURN
	END



	SUBROUTINE MAKEPHASE (PHASE, SIGN, NMAX)
	IMPLICIT NONE
	INTEGER	I,J,L,LMAX,NMAX,SIGN, LOG2
	COMPLEX	PHASE(1)

	LMAX=LOG2(NMAX)
	J=0
	DO L=0,LMAX
	    DO I=0,2**L-1
		J=J+1
		PHASE(J) = CEXP(SIGN*2*3.1415926535*(0,1)*FLOAT(I)/2**L)
	    END DO
	END DO

	RETURN
	END




	SUBROUTINE FFTC1D (DATA, N)
	IMPLICIT NONE
	INTEGER	I,J,K,N,LN,M0,M1,JMAX,OFF,IDXPH,POWER, LOG2
	INTEGER*2 BITREV(1)
	COMPLEX	DATA(1),TMP,PHASE(1)
	COMMON	/BITREV/ BITREV
	COMMON  /PHASE/  PHASE

	LN = LOG2(N)
	DO I = 0,N-1
	    J = BITREV(I+N)
	    IF (J .GT. I) THEN
		TMP = DATA(I+1)
		DATA(I+1) = DATA(J+1)
		DATA(J+1) = TMP
	    END IF
	END DO

	M0 = 1
	M1 = 2
	JMAX = N/2
	DO J = 1,JMAX
	    TMP = DATA(M1)
	    DATA(M1) = DATA(M0) - TMP
	    DATA(M0) = DATA(M0) + TMP
	    M0 = M0 + 2
	    M1 = M1 + 2
	END DO

	DO I = 1,LN-1
	    POWER = 2**I
	    OFF = 2*POWER
	    M0 = 0
	    M1 = POWER
	    JMAX = 2**(LN-I-1)
	    DO J = 1,JMAX
		IDXPH = OFF
		DO K = 0,POWER-1
		    M0 = M0 + 1
		    M1 = M1 + 1
		    TMP = PHASE(IDXPH)*DATA(M1)
		    IDXPH = IDXPH + 1
		    DATA(M1) = DATA(M0) - TMP
		    DATA(M0) = DATA(M0) + TMP
		END DO
		M0 = M0 + POWER
		M1 = M1 + POWER
	    END DO
	END DO

	RETURN
	END





	SUBROUTINE FIXREAL(DATA,COLBUF,N,DIR)
	IMPLICIT NONE
	INTEGER N,DIR,I,ICONJ,IDXPH
	REAL PHR(2),TMPR
	COMPLEX DATA(1),COLBUF, PHASE(1), TMP0,TMP1, PH
	EQUIVALENCE (PHR(1),PH)
	COMMON  /PHASE/  PHASE

	IDXPH = 2*N+1
	ICONJ = N

	IF (DIR .EQ. +1) THEN
	    COLBUF = REAL(DATA(1))-AIMAG(DATA(1))
	    DATA(1) = REAL(DATA(1))+AIMAG(DATA(1))
	    DO I = 2,N/2+1
		PH = PHASE(IDXPH)
		IDXPH = IDXPH + 1
		TMPR = PHR(1)		! MULT BY i
		PHR(1) = -PHR(2)
		PHR(2) = TMPR
		TMP0 = DATA(I)+CONJG(DATA(ICONJ))
		TMP1 = PH*( DATA(I)-CONJG(DATA(ICONJ)) )
		DATA(I) = (TMP0-TMP1)/2
		DATA(ICONJ) = CONJG(TMP0+TMP1)/2
		ICONJ = ICONJ-1
	    ENDDO
	ELSE
	    DATA(1) = ( REAL(DATA(1)) + REAL(COLBUF) )
     +			+ (0,1)*( REAL(DATA(1)) - REAL(COLBUF) )
	    DO I = 2,N/2+1
		PH = PHASE(IDXPH)
		IDXPH = IDXPH + 1
		TMPR = PHR(1)		! MULT BY -i
		PHR(1) = PHR(2)
		PHR(2) = -TMPR
		TMP0 = DATA(I)+CONJG(DATA(ICONJ))
		TMP1 = PH*( DATA(I)-CONJG(DATA(ICONJ)) )
		DATA(I) = TMP0-TMP1
		DATA(ICONJ) = CONJG(TMP0+TMP1)
		ICONJ = ICONJ-1
	    ENDDO
	ENDIF

	RETURN
	END




	SUBROUTINE FFTC1VD (UNIT, NS, NL)
	IMPLICIT NONE
	INTEGER	I,J,K,C,NS,NL,LNL,ROW0,ROW1,JMAX,OFF
	INTEGER*2 BITREV(1)
	COMPLEX	PHASE(1)
	INTEGER	POWER,STAT, LOG2, UNIT
	COMPLEX	DATA0(4096),DATA1(4096),TMP0,TMP1,PH
	COMMON	/BITREV/ BITREV
	COMMON  /PHASE/  PHASE

	LNL=LOG2(NL)
	DO I=0,NL-1
	    J=BITREV(I+NL)
	    IF (J.GT.I) THEN
		CALL XVREAD(UNIT, DATA0, STAT, 'LINE',I+1,' ')
		CALL XVREAD(UNIT, DATA1, STAT, 'LINE',J+1,' ')
		CALL XVWRIT(UNIT, DATA0, STAT, 'LINE',J+1,' ')
		CALL XVWRIT(UNIT, DATA1, STAT, 'LINE',I+1,' ')
	    END IF
	END DO


	DO I=0,LNL-1
	    JMAX=2**(LNL-I-1)
	    POWER=2**I
	    OFF=2*POWER
	    DO J=0,JMAX-1
		ROW0=OFF*J
		ROW1=ROW0+POWER
		DO K=0,POWER-1
		    ROW0=ROW0+1
		    ROW1=ROW1+1
		    PH=PHASE(K+OFF)
		    CALL XVREAD(UNIT, DATA0, STAT, 'LINE',ROW0,' ')
		    CALL XVREAD(UNIT, DATA1, STAT, 'LINE',ROW1,' ')
		    DO C=1,NS
			TMP0=DATA0(C)
			TMP1=PH*DATA1(C)
			DATA0(C)=TMP0+TMP1
			DATA1(C)=TMP0-TMP1
		    END DO
		    CALL XVWRIT(UNIT, DATA0, STAT, 'LINE',ROW0,' ')
		    CALL XVWRIT(UNIT, DATA1, STAT, 'LINE',ROW1,' ')
		END DO
	    END DO
	END DO

	RETURN
	END




	SUBROUTINE FFTCV(DATA,NS,NL)
	IMPLICIT NONE
	INTEGER	I,J,K,C,NS,NL,LNL,M0,M1,JMAX,OFF, LOG2
	INTEGER POWER,IDXPH
	INTEGER*2 BITREV(1)
	COMPLEX	DATA(1),TMP,PHASE(1),PH
	COMMON	/BITREV/ BITREV
	COMMON  /PHASE/  PHASE

	LNL = LOG2(NL)
	DO I = 0,NL-1
	    J = BITREV(I+NL)
	    IF (J .GT. I) THEN
		M0 = NS*I
		M 1= NS*J
		DO C = 1,NS
		    M0 = M0 + 1
		    M1 = M1 + 1
		    TMP = DATA(M0)
		    DATA(M0) = DATA(M1)
		    DATA(M1) = TMP
		END DO
	    END IF
	END DO


	DO I = 0,LNL-1
	    JMAX = 2**(LNL-I-1)
	    POWER = 2**I
	    OFF = 2*POWER
	    M0 = 0
	    M1 = POWER*NS
	    DO J = 0,JMAX-1
		IDXPH = OFF
		DO K = 0,POWER-1
		    PH = PHASE(IDXPH)
		    IDXPH = IDXPH + 1
		    DO C = 1,NS
			M0 = M0 + 1
			M1 = M1 + 1
			TMP = PH*DATA(M1)
			DATA(M1) = DATA(M0) - TMP
			DATA(M0) = DATA(M0) + TMP
		    END DO
		END DO
		M0 = M0 + POWER*NS
		M1 = M1 + POWER*NS
	    END DO
	END DO

	RETURN
	END



	INTEGER FUNCTION LOG2(N)
	IMPLICIT NONE
	INTEGER	N
	LOG2 = 2
	DO WHILE (ISHFT(N,-LOG2) .GT. 0)
	    LOG2 = LOG2 + 1
	ENDDO
	LOG2 = LOG2 - 1
	RETURN
	END
