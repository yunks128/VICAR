C#######################################################################
C  NAME OF ROUTINE
C      GENTHIS
C
C  PURPOSE
C      THIS IS THE STANDARD MAIN PROGRAM USED FOR TAE/VICAR PROGRAMS.
C      THIS MODULE CALLS SUBROUTINE MAIN44 TO ENTER INTO THE BODY OF THE
C      PROGRAM.
C      GENTHIS generates small exactly-defined test files.
C  PREPARED FOR USE ON MIPL SYSTEM BY
C      STEVE POHORSKY   INFORMATICS GENERAL CORPORATION    APRIL 1986
C  FOR
C      MIPL SOFTWARE DEVELOPMENT
C
C  DERIVED FROM CODE FOR VICAR PROGRAM GEN
C
C     
C  REVISION HISTORY
C      Converted to UNIX/VICAR May 2, 1991  ---  Ron Alley
C  SUBROUTINES CALLED
C      MAIN44
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      INCLUDE 'VICMAIN_FOR'

      SUBROUTINE MAIN44

C           GENTHIS A NL NS PARAMS

C     GENTHIS DOES NOT DISTINGUISH BETWEEN INTEGER AND REAL 
C     NUMBER DN VALUES. ALL VALUES ARE NOW PROCESSED AS REAL NUMBERS. 

      CALL XVMESSAGE(' GENTHIS Version 1.1',' ')
      CALL GENTHISLAB
      CALL GENTHIS1

      RETURN
      END
C*****************************************************************************
      SUBROUTINE GENTHISLAB

      IMPLICIT NONE

      COMMON /C1XX/ NL,NS,PIXSIZ,NCODE,BUF
      INTEGER*4 NL,NS,PIXSIZ,NCODE
      LOGICAL*1 BUF(80000)

      COMMON /FORMATS/ DATA
      COMMON /UNIT/ OUTUNIT
C
      INTEGER DEF,CNT,STATUS,OUTUNIT, I
      REAL PAR(1000)
      INTEGER*4 KAR(1000)
      EQUIVALENCE ( PAR,KAR )
      CHARACTER*5 FORMAT, DATA

C          Label processor
      CALL XVUNIT(OUTUNIT,'OUT',1,STATUS,' ')

C--- Determine data type and pixel size and add to label
      CALL XVP('FORMAT',DATA,CNT)

      IF (DATA .EQ. 'HALF ') THEN
	FORMAT(1:4) = 'HALF'
        NCODE = -6
        PIXSIZ = 2
      ELSE IF (DATA .EQ. 'FULL ') THEN
	FORMAT(1:4) = 'FULL'
        NCODE = 4
        PIXSIZ = 4
      ELSE IF (DATA .EQ. 'REAL4' .OR. DATA.EQ.'REAL') THEN
	FORMAT(1:4) = 'REAL'
        NCODE = 4
        PIXSIZ = 4
      ELSE IF (DATA .EQ. 'REAL8') THEN
	FORMAT(1:4) = 'DOUB'
        NCODE = 9
        PIXSIZ = 8
      ELSE 
	FORMAT(1:4) = 'BYTE'
        NCODE = -5
        PIXSIZ = 1
      END IF

C--- Open output file with specified values
      CALL XVPARM('NL',NL,CNT,DEF,0)
      CALL XVPARM('NS',NS,CNT,DEF,0)
      CALL XVOPEN(OUTUNIT,STATUS,'U_FORMAT',FORMAT,'O_FORMAT',
     +            FORMAT,'OP','WRITE','U_NL',NL,'U_NS',NS,
     +		  'IO_ACT','SA','OPEN_ACT','SA',' ')

C--- Get DN VALUES.
      CALL XVP('DN', PAR, CNT)
      IF (CNT .NE. NL*NS) THEN
         CALL XVMESSAGE(
     +            ' **PARAMETER ERR...DN COUNT DOES NOT MATCH SIZE',' ')
         CALL XVMESSAGE(' **GENTHIS TASK CANCELLED',' ')
	 CALL ABEND
      END IF
      
C--- CONVERT DN VALUES TO SPECIFIED FORMAT

      IF (DATA(:1).EQ.'B' .OR. DATA(:1).EQ.'H' .OR. 
     +                                  DATA(:1).EQ.'F') THEN
        DO I = 1, CNT
           KAR(I) = PAR(I)          ! CONVERT TO INTEGER.
        END DO
      END IF
      CALL MVE (NCODE, CNT, PAR, BUF, 1, 1 )

      RETURN
      END
C************************************************************************
      SUBROUTINE GENTHIS1

      IMPLICIT NONE

      COMMON /C1XX/ NL,NS,PIXSIZ,NCODE,BUF
      INTEGER*4 NL,NS,PIXSIZ,NCODE
      LOGICAL*1 BUF(80000)

      COMMON /FORMATS/ DATA
      CHARACTER*5 DATA
      COMMON /UNIT/ OUTUNIT
      INTEGER OUTUNIT,STATUS

      INTEGER I, N, NBYTES

        NBYTES = NS* PIXSIZ
        N = 1

	DO I = 1, NL
	  CALL XVWRIT(OUTUNIT,BUF(N),STATUS,' ')
          N = N + NBYTES
	END DO

C--- Close output file
      CALL XVCLOSE(OUTUNIT,STATUS,' ')
      CALL XVMESSAGE(' GENTHIS TASK COMPLETED',' ')
      RETURN
      END