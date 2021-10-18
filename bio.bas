DECLARE FUNCTION D2D! (Y!, M!, D!)
REM Biorhythm chart
CLS
PI = 3.141592
T$ = DATE$: REM Get today's date from system
REM Convert day, month, year from system date
MT = VAL(LEFT$(T$, 2)): DT = VAL(MID$(T$, 4, 2)): YT = VAL(RIGHT$(T$, 4))
'PRINT USING "Today's date (according to system) ####_-##_-##"; YT; MT; DT
REM Get Date of Birth
INPUT "Enter your date of birth (YYYY,MM,DD) "; Y, M, D
'PRINT USING "Your Date of birth ####_-##_-##"; Y; M; D
PRINT USING "Today is ####_-##_-##"; YT; MT; DT
PRINT "============================="
G1 = D2D(Y, M, D)
G2 = D2D(YT, MT, DT)
G = G2 - G1
'PRINT USING "Your Gregorian Days ######"; G1
'PRINT USING "Today's Gregorian Days ######"; G2
'PRINT USING "The difference is ##### days"; G
P = SIN(2 * PI * G / 23): P1 = SIN(2 * PI * (G - 1) / 23)
E = SIN(2 * PI * G / 28): E1 = SIN(2 * PI * (G - 1) / 28)
I = SIN(2 * PI * G / 33): I1 = SIN(2 * PI * (G - 1) / 33)
REM Calculate trends
IF P1 >= P THEN P$ = "falling" + CHR$(25) ELSE P$ = "rising" + CHR$(24)
IF E1 >= E THEN E$ = "falling" + CHR$(25) ELSE E$ = "rising" + CHR$(24)
IF I1 >= I THEN I$ = "falling" + CHR$(25) ELSE I$ = "rising" + CHR$(24)
PRINT USING "Your PHYSICAL biorhythm is +#.## &"; P; P$
PRINT USING "Your EMOTIONAL biorhythm is +#.## &"; E; E$
PRINT USING "Your INTELLECTUAL biorhythm is +#.## &"; I; I$

FUNCTION D2D (Y, M, D)
  REM Convert a date to the no. of Gregorian days
  REM Make "year" start in March
  M = (M + 9) - INT((M + 9) / 12) * 12
  Y = Y - INT(M / 10)
  D2D = 365 * Y + INT(Y / 4) - INT(Y / 100) + INT(Y / 400) + INT((M * 306 + 5) / 10) + (D - 1)
END FUNCTION

