# Football

This is a simpler version of football included in David [Ahl's BASIC Computer Games](https://www.atariarchives.org/basicgames/). One player plays against the computer and has seven offensive plays in his/her playbook. I got the source from [Vintage BASIC's site](http://www.vintage-basic.net/bcg/ftball.bas) complete with a program error in line 1700. I can confirm the original listing included in the printed book has the correct syntax.

## Variables and SUBroutines

+ `S(0), S(1)` are scores for Player and CPU
+ `P` is offense, can be either 0 (Human) or 1 (CPU)
+ `D` is current down `(1-4)`
+ `X1` is ball position _at start_ of play
+ `X` is ball position _after_ play
+ `Z` is current play (1..7)
+ `FNF()` determines direction of play
+ `FNG()` is gain/loss of current play
+ `SUB 800` prints current position
+ `SUB 2800` prints current score
+ `F` is a flag for turn over or loss of possession (0,-1)

```
10 PRINT TAB(33);"FTBALL"
20 PRINT TAB(15);"CREATIVE COMPUTING  MORRISTOWN, NEW JERSEY"
30 PRINT:PRINT
220 PRINT "THIS IS DARTMOUTH CHAMPIONSHIP FOOTBALL.":PRINT
230 PRINT "YOU WILL QUARTERBACK DARTMOUTH. CALL PLAYS AS FOLLOWS:"
240 PRINT "1= SIMPLE RUN; 2= TRICKY RUN; 3= SHORT PASS;"
250 PRINT "4= LONG PASS; 5= PUNT; 6= QUICK KICK; 7= PLACE KICK."
260 PRINT
270 PRINT "CHOOSE YOUR OPPONENT";
280 INPUT O$(1)
290 O$(0)="DARTMOUTH"
300 PRINT
```
Initialise score and in-game messages

```
310 LET S(0)=0: LET S(1)=0
320 REM
330 DIM L$(20)
340 FOR I=1 TO 20: READ L$(I): NEXT I
350 DATA "KICK","RECEIVE"," YARD ","RUN BACK FOR ","BALL ON "
360 DATA "YARD LINE"," SIMPLE RUN"," TRICKY RUN"," SHORT PASS"
370 DATA " LONG PASS","PUNT"," QUICK KICK "," PLACE KICK"," LOSS "
380 DATA " NO GAIN","GAIN "," TOUCHDOWN "," TOUCHBACK ","SAFETY***"
385 DATA "JUNK"
390 LET P=INT(RND(1)*2)
400 PRINT O$(P);" WON THE TOSS"
```
User-defined `FNF()` looks resolves to direction of play, so if 
+ `P=0` &rarr; `FNF(P) = 1`
+ `P=1` &rarr; `FNF(P) = -1`

User-defined `FNG()` always takes 1 as argument, whenever it is called

```
410 DEF FNF(X)=1-2*P
420 DEF FNG(Z)=P*(X1-X)+(1-P)*(X-X1)
430 IF P=0 THEN 470
440 PRINT O$(1);" ELECTS TO RECEIVE."
450 PRINT
460 GOTO 580
470 PRINT "DO YOU ELECT TO KICK OR RECEIVE";
480 INPUT A$
490 PRINT
500 FOR E=1 TO 2
510 IF A$=L$(E) THEN 550
520 NEXT E
530 PRINT "INCORRECT ANSWER.  PLEASE TYPE 'KICK' OR 'RECIEVE'";
540 GOTO 480
550 IF E=2 THEN 580
560 LET P=1
```
X is starting position before kick-off
+ `P=0` &rarr; `X=40 + (1)*20` &rarr; `X=60`
+ `P=1` &rarr; `X=40 + (0)*20` &rarr; `X=40`

On subsequent kick-offs after scoring, the program continues from here
```
580 LET X=40+(1-P)*20
```
Kick-off distance. Y can be anything between 30 and 80 yards

```
590 LET Y=INT(200*(RND(1)-.5)^3+55)
600 PRINT Y;L$(3);" KICKOFF"
610 LET X=X-FNF(1)*Y
620 IF ABS(X-50)>=50 THEN 700
630 LET Y=INT(50*RND(1)^2)+(1-P)*INT(50*RND(1)^4)
640 LET X=X+FNF(1)*Y
650 IF ABS(X-50)>=50 THEN 655
651 PRINT Y;L$(3);" RUNBACK"
652 GOTO 720
655 PRINT L$(4);
660 GOTO 2600
700 PRINT "TOUCHBACK FOR ";O$(P);"."
710 LET X=20+P*60
720 REM FIRST DOWN
730 GOSUB 800
```
Sets X1 to the start of down

```
740 LET X1=X
750 LET D=1
760 PRINT:PRINT "FIRST DOWN ";O$(P);"***"
770 PRINT
780 PRINT
790 GOTO 860
```
## Print position
Depending on where ball is, it will either print
+ `X < 50` Ball is on Player's side &rarr; `"BALL ON "` + (Player) + (Pos) + `"YARD LINE"`
+ `X >= 50` Ball is on CPU's side &rarr; `"BALL ON "` + (CPU) + (Pos) + `"YARD LINE"`

So something like `"BALL ON DARTMOUTH 24 YARD LINE"` or `"BALL ON PENN STATE 36 YARD LINE"` etc.

```
800 REM PRINT POSITION
810 IF X>50 THEN 840
820 PRINT L$(5);O$(0);X;L$(6)
830 GOTO 850
840 PRINT L$(5);O$(1);100-X;L$(6)
850 RETURN
```
## New Play
`T` is the number of "turns". After 50 turns, on every play there's a 20% chance that the game will end. Average no. of offensive plays per game is 56-70 according to the [Team Rankings site](https://www.teamrankings.com/nfl/stat/plays-per-game)

```
860 REM NEW PLAY
870 LET T=T+1
880 IF T=30 THEN 1060
890 IF T<50 THEN 940
900 IF RND(1)>.2 THEN 940
910 PRINT "END OF GAME  ***"
920 PRINT "FINAL SCORE:  ";O$(0);": ";S(0);"  ";O$(1);": ";S(1)
930 STOP
```
If CPU offense, determine next play with routine at lines `1870-`, otherwise ask human player for next play no.

```
940 IF P=1 THEN 1870
950 PRINT "NEXT PLAY";
960 INPUT Z
970 IF Z<>INT(Z) THEN 990
980 IF ABS(Z-4)<=3 THEN 1010
990 PRINT "ILLEGAL PLAY NUMBER, RETYPE";
1000 GOTO 960
1010 LET F=0
1020 PRINT L$(Z+6);".  ";
```
+ `R1` is used to calculate gain `[0..1]` &times; `(.98 ` &plusmn;`0.02)` on _passes_
+ `R` is used to calculate gain on _runs_. In passes, it is used as chance for a "special event" occurring i.e. 
  * For a short pass play, 5% chance for interception (line 1330), 15% chance passer tackled (sacked maybe?), 55% pass incomplete
  * For a long pass play, 10% chance interception, 30% passer tackled (sacked?), 75% pass incomplete

```
1030 LET R=RND(1)*(.98+FNF(1)*.02)
1040 LET R1=RND(1)
```

`Z` contains a number `(1-7)` corresponding to the play, i.e. simple run, tricky run, short pass etc.

Note that program flow `GOTOs` and not `GOSUBs`
```
1050 ON Z GOTO 1110,1150,1260,1480,1570,1570,1680
```
_Aww_. I can see this in my mind's eye. The author is typing away madly and his girlfriend says "how about a delay of game?". 

More likely, `"JEAN"`, 100% in glorious [Rainbow&trade; sandals](https://www.google.com/search?q=vintage+rainbow+flip+flops&tbm=isch&), [Ditto&trade; saddleback jeans](https://www.google.com/search?q=ditto+saddleback+jeans&tbm=isch) and [Farrah Fawcett side-wing feathered blowback hair](https://www.google.com/search?q=farrah+fawcett+hair&tbm=isch) had always been _waay_ out of his league and this was _the one time_ she had ever spoken to him, but hey, a guy can dream.

```
1060 REM  JEAN'S SPECIAL
1070 IF RND(1)> 1/3 THEN 940
1080 PRINT "GAME DELAYED.  DOG ON FIELD."
1090 PRINT
1100 GOTO 940
```
## Simple Run
```
1110 REM  SIMPLE RUN
1120 LET Y=INT(24*(R-.5)^3+3)
1130 IF RND(1)<.05 THEN 1180
1140 GOTO 2190
```
## Tricky Run
```
1150 REM  TRICKY RUN
1160 LET Y=INT(20*R-5)
1170 IF RND(1)>.1 THEN 2190
1180 LET F=-1
1190 LET X3=X
1200 LET X=X+FNF(1)*Y
1210 IF ABS(X-50)>=50 THEN 1240
1220 PRINT "***  FUMBLE AFTER ";
1230 GOTO 2230
1240 PRINT "***  FUMBLE."
1250 GOTO 2450
```
## Short Pass
R and R1 are calculated in lines `1030-1050`
```
1260 REM  SHORT PASS
1270 LET Y=INT(60*(R1-.5)^3+10)
1280 IF R<.05 THEN 1330
1290 IF R<.15 THEN 1390
1300 IF R<.55 THEN 1420
1310 PRINT "COMPLETE.  ";
1320 GOTO 2190
```
Lines `1330-1470` is where pass outcomes other than completion are calculated, i.e. interception, QB sack, pass incomplete (with a 30% chance it was batted down)

Lines `2190-` then calculate gain/loss

```
1330 IF D=4 THEN 1420
1340 PRINT "INTERCEPTED."
1350 LET F=-1
1360 LET X=X+FNF(1)*Y
1370 IF ABS(X-50)>=50 THEN 2450
1380 GOTO 2300
1390 PRINT "PASSER TACKLED.  ";
1400 LET Y=-INT(10*R1)
1410 GOTO 2190
1420 LET Y=0
1430 IF RND(1)<.3 THEN 1460
1440 PRINT "INCOMPLETE.  ";
1450 GOTO 2190
1460 PRINT "BATTED DOWN.  ";
1470 GOTO 2190
```
## Long Pass

```
1480 REM  LONG PASS
1490 LET Y=INT(160*(R1-.5)^3+30)
1500 IF R<.1 THEN 1330
1510 IF R<.3 THEN 1540
1520 IF R<.75 THEN 1420
1530 GOTO 1310
1540 PRINT "PASSER TACKLED.  ";
```
Compute loss of yardage due to sack.
```
1550 LET Y=-INT(15*R1+3)
1560 GOTO 2190
```
## Punt or Kick

```
1570 REM  PUNT OR KICK
1580 LET Y=INT(100*(R-.5)^3+35)
1590 IF D=4 THEN 1610
1600 LET Y=INT(Y*1.3)
1610 PRINT Y;L$(3);" PUNT"
1620 IF ABS(X+Y*FNF(1)-50)>=50 THEN 1670
1630 IF D<4 THEN 1670
1640 LET Y1=INT(R1^2*20)
1650 PRINT Y1;L$(3);" RUN BACK"
1660 LET Y=Y-Y1
1670 GOTO 1350
```
## Place Kick
I think they mean Field Goal

**NOTE**: the  program listing I downloaded from [Vintage BASIC's site](http://www.vintage-basic.net/bcg/ftball.bas) has line 1700 saying `IF R1>.15 THEN 1740`

This is in incorrect, because in this case a field goal will never be awarded. 

The human player is instead awarded a first down and the ball stays where it is. The line should read `IF R1>.15 THEN 1750`

I can confirm the original program listing included in the paper book indeed says `THEN 1750`

```
1680 REM  PLACE KICK
1690 LET Y=INT(100*(R-.5)^3+35)
1700 IF R1>.15 THEN 1750
1710 PRINT "KICK IS BLOCKED  ***"
1720 LET X=X-5*FNF(1)
1730 LET P=1-P
1740 GOTO 720
1750 LET X=X+FNF(1)*Y
1760 IF ABS(X-50)>=60 THEN 1810
1770 PRINT "KICK IS SHORT."
1780 IF ABS(X-50)>=50 THEN 2710
1790 P=1-P
1800 GOTO 630
1810 IF R1>.5 THEN 1840
1820 PRINT "KICK IS OFF TO THE SIDE."
1830 GOTO 2710
1840 PRINT "FIELD GOAL ***"
1850 LET S(P)=S(P)+3
1860 GOTO 2640
```
## Opponent's Play (Computer)
Looks like you don't get to pick a defense
```
1870 REM  OPPONENT'S PLAY
1880 IF D>1 THEN 1940
```
This only happens on 1st down. Z contains the play number. So, 2/3 of the time the computer will pick a `SIMPLE RUN` &rarr; `LET Z=1`, and 1/3 of the time the computer will pick a `SHORT PASS` &rarr; `LET Z=3`

```
1890 IF RND(1)>1/3 THEN 1920
1900 LET Z=3
1910 GOTO 1010
1920 LET Z=1
1930 GOTO 1010
```
Decide what to do on 4th down. X1 is the current ball position, X is where the down began

```
1940 IF D=4 THEN 2090
```
+ Looks like the CPU will not attempt a pass if it's within  5 yards of 1st down or of goal
+ If the CPU is within 10 yards of goal it will either try a tricky run or a short pass (lines 2160 etc.)
+ `X>X1` means negative gain, ball is currently _behind_ where it started on 1st down.
  + on 1st and 2nd down, it will try either a tricky run or a short pass
  + if ball is within 45 yards of goal it will try either a tricky run or a short pass, irrespective of down
  + line `2040` is only executed if none of the above cases are met, i.e. we are on 3rd down and more than 45 yards away from goal line. 25% of the time the CPU will execute a `"QUICK KICK"` (i.e. `LET Z=6`), and the remainder 75% of the time the CPU will execute a `"LONG PASS"` (i.e. `LET Z=4`)

Execution then resumes at line `1010` i.e. new play

```
1950 IF 10+X-X1<5 THEN 1890
1960 IF X<5 THEN 1890
1970 IF X<=10 THEN 2160
1980 IF X>X1 THEN 2020
1990 LET A=INT(2*RND(1))
2000 LET Z=2+A*2
2010 GOTO 1010
2020 IF D<3 THEN 1990
2030 IF X<45 THEN 1990
2040 IF RND(1)>1/4 THEN 2070
2050 LET Z=6
2060 GOTO 1010
2070 LET Z=4
2080 GOTO 1010
```
On 4th down the computer will pick a 
* `PUNT` &rarr; `LET Z=5` if distance to the goal is over 30 yards &rarr; `IF X>30 THEN 2140`, 
* it will try to convert 4th down on less than 3 yards to go, 
* or it will attempt a field goal otherwise.

```
2090 IF X>30 THEN 2140
2100 IF 10+X-X1<3 THEN 1890
2110 IF X<3 THEN 1890
2120 LET Z=7
2130 GOTO 1010
2140 LET Z=5
2150 GOTO 1010
2160 LET A=INT(2*RND(1))
2170 LET Z=2+A
2180 GOTO 1010
```
## Gain or loss

+ Prev ball position is stored in `X3`
+ New ball position is gain `Y`  &times; direction of play `FNF(1)`

```
2190 REM GAIN OR LOSS
2200 LET X3=X
2210 LET X=X+FNF(1)*Y
2220 IF ABS(X-50)>=50 THEN 2450
```
+ `L$(15)` is `"NO GAIN"`, and `L$(3)` is `"YARD"`, so this will ether print `NO GAIN` if `Y=0` or it will print gain in yards + `" YARD "` and then either `"GAIN "` or `" LOSS "` depending on the sign of Y (positive or negative gain)

Finally there's a 10% chance of penalty (line 2290). Penalty is calculated in lines `2860-`

```
2230 IF Y=0 THEN 2250
2240 PRINT ABS(Y);L$(3);
2250 PRINT L$(15+SGN(Y))
2280 IF ABS(X3-50)>40 THEN 2300
2290 IF RND(1)<.1 THEN 2860
2300 GOSUB 800
```
`F` signals a loss of possession &rarr; `F=0` no turn over, `F=-1` loss of possession/turn over

Line 740 is first down

```
2310 IF F=0 THEN 2340
2320 LET P=1-P
2330 GOTO 740
```
+ `FNG(1)` returns gain/loss of current drive after last play
+ `IF (X1-50)*FNF(1)<40 THEN 2410` are we within 10 yards of the goal line?

This seems like a funny way to print down progress. 

Usual form would be something like `3RD AND 4` or `3RD AND GOAL` but in this case the program would print `DOWN: 3     YARDS TO GO:4` or `DOWN: 3     GOAL TO GO:4`

`FNG(1)>=10` &rarr; `TRUE` means 1st down (the overall gain is 10 or higher)

```
2340 IF FNG(1)>=10 THEN 740
2350 IF D=4 THEN 2320
2360 LET D=D+1
2370 PRINT "DOWN: ";D;"     ";
2380 IF (X1-50)*FNF(1)<40 THEN 2410
2390 PRINT "GOAL TO GO"
2400 GOTO 2420
2410 PRINT "YARDS TO GO: ";10-FNG(1)
2420 PRINT
2430 PRINT
2440 GOTO 860
2450 REM BALL IN END-ZONE
2460 IF X>=100 THEN 2490
2470 LET E=0
2480 GOTO 2500
2490 LET E=1
```
## Scoring (I think)
+ `E` can only be 0 or 1 (whether ball is in opponent's end zone or not)
+ `F` can only be 0 or -1, F seems to signal loss of possession/turn-around
+ `P` is offense and can only be 0 or 1

These are the outcomes based on the values of the E, F, P variables

| E | F | P | Result | GOTO | Result |
|:-:|:-:|:-:|:-:|:-:|:--|
| 0 | 0 | 0 | `1+0-0*2+0*4 =1` | `2510` | SAFETY |
| 1 | 0 | 0 | `1+1-0*2+0*4 = 2` | `2590` | OFFENSIVE TD |
| 0 |-1 | 0 | `1+0-(-1)*2+0*4 = 3`|`2760`| DEFENSIVE TD |
| 1 |-1 | 0 | `1+1-(-1)*2+0*4 = 4`|`2710`| TOUCHBACK |
| 0 | 0 | 1 | `1+0-(0)*2+1*4 = 5`|`2590`| OFFENSIVE TD |
| 1 | 0 | 1 | `1+1-(0)*2+1*4 = 6`|`2510`| SAFETY |
| 0 |-1 | 1 | `1+1-(-1)*2+1*4 = 7`|`2590`| TOUCHBACK |
| 1 |-1 | 1 | `1+1-(-1)*2+1*4 = 8`|`2590`| DEFENSIVE TD |

`SUB` at line 2800 prints current score
```
2500 ON 1+E-F*2+P*4 GOTO 2510,2590,2760,2710,2590,2510,2710,2760
```
## Safety

```
2510 REM SAFETY
2520 LET S(1-P)=S(1-P)+2
2530 PRINT L$(19)
2540 GOSUB 2800
2550 PRINT O$(P);" KICKS OFF FROM ITS 20 YARD LINE."
2560 LET X=20+P*60
2570 LET P=1-P
2580 GOTO 590
```
## Offensive TD

```
2590 REM OFFENSIVE TD
2600 PRINT L$(17);"***"
2610 IF RND(1)>.8 THEN 2680
2620 LET S(P)=S(P)+7
2630 PRINT "KICK IS GOOD."
2640 GOSUB 2800
2650 PRINT O$(P);" KICKS OFF"
2660 LET P=1-P
2670 GOTO 580
2680 PRINT "KICK IS OFF TO THE SIDE"
2690 LET S(P)=S(P)+6
2700 GOTO 2640
```
## Touchback

```
2710 REM TOUCHBACK
2720 PRINT L$(18)
2730 LET P=1-P
2740 LET X=20+P*60
2750 GOTO 720
```
## Defensive TD

```
2760 REM DEFENSIVE TD
2770 PRINT L$(17);"FOR ";O$(1-P);"***"
2780 LET P=1-P
2790 GOTO 2600
```
## Print Score

```
2800 REM SCORE
2810 PRINT
2820 PRINT "SCORE:  ";S(0);" TO ";S(1)
2830 PRINT
2840 PRINT
2850 RETURN
```
## Penalty

`P3` holds the team that is assigned the penalty (0=Human, 1=CPU)

```
2860 REM PENALTY
2870 LET P3=INT(2*RND(1))
2880 PRINT O$(P3);" OFFSIDES -- PENALTY OF 5 YARDS."
2890 PRINT
2900 PRINT
2910 IF P3=0 THEN 2980
2920 PRINT "DO YOU ACCEPT THE PENALTY";
2930 INPUT A$
2940 IF A$="NO" THEN 2300
2950 IF A$="YES" THEN 3110
2960 PRINT "TYPE 'YES' OR 'NO'";
2970 GOTO 2930
```
## Opponent's Strategy on Penalty

```
2980 REM OPPONENT'S STRATEGY ON PENALTY
2990 IF P=1 THEN 3040
3000 IF Y<=0 THEN 3080
3010 IF F<0 THEN 3080
3020 IF FNG(1)<3*D-2 THEN 3080
3030 GOTO 3100
3040 IF Y<=5 THEN 3100
3050 IF F<0 THEN 3100
3060 IF D<4 THEN 3080
3070 IF FNG(1)<10 THEN 3100
3080 PRINT "PENALTY REFUSED."
3090 GOTO 2300
```
## Penalty yards

+ Down is reset back by one
+ `P<>P3` &rarr; `TRUE` means penalty is _DEFENSE_
+ `P<>P3` &rarr; `FALSE` means penalty is _OFFENSE_
+ `X3` holds the ball position _before_ the last play


```
3100 PRINT "PENALTY ACCEPTED."
3110 LET F=0
3120 LET D=D-1
3130 IF P<>P3 THEN 3160
3140 LET X=X3-FNF(1)*5
3150 GOTO 2300
3160 LET X=X3+FNF(1)*5
3170 GOTO 2300
3180 END
```
