;; Author:  Gabriel Cronin
;; Created July, 2015

;--------------------------------------------------------------------------------------------------------------------------
; BREEDS AND GLOBAL VARIABLES
;--------------------------------------------------------------------------------------------------------------------------

breed [ TFs TF ] ;Transcription Factors
breed [ cellFunctions cellFunction ]
breed [ banners ]
breed [ diatoms diatom ]
breed [ genes gene ]
breed [CO2s CO2]     ;; packets of carbon dioxide
TFs-own [ statusLight statusNutrient ] ;1=on or 0=off
cellFunctions-own [ statusLight statusNutrient] ;1=on or 0=off
genes-own [ statusLight statusNutrient ] ;1=on or 0=off
diatoms-own [ N P Si health uptakeProbability ]

globals [ nitrogenMax siliconMax phosphorousMax nitrogenCurrent siliconCurrent phosphorousCurrent numDiatoms pH nutrientsPresent initialHealth growthRate ]



;--------------------------------------------------------------------------------------------------------------------------
; SETUP
;--------------------------------------------------------------------------------------------------------------------------

to setup
  clear-all
  
  set growthRate 1
  set initialHealth 800
  set numDiatoms 2   ;actually each represents 5
  set nitrogenMax 20
  set siliconMax 20
  set phosphorousMax 20
  
  setupPatches
  addNitrogen
  addSilicon
  addPhosphorous
      
  ;Create transcription factors, genes, cellular functions in appropriate locations at top
  let xlocation  -3 * max-pxcor / 4
  setupTFs xlocation
  set xlocation 3 * max-pxcor / 4
  setupCellFunctions xlocation
  set xlocation  0
  setupGenes xlocation
  setupLinks
  
  setupDiatoms
  if CarbonDioxide = 400 [ addCO2 13  ]
  if CarbonDioxide = 800 [ addCO2 25 ]
  
  reset-ticks
  
end


;--------------------------------------------------------------------------------------------------------------------------
; MAIN LOOP
;--------------------------------------------------------------------------------------------------------------------------

to go

  if count diatoms = 0 [ stop ]
      
  ;ifelse ( CO2 = 400 ) [ set growthRate 1 ] [ set growthRate 1 ]
  ifelse ( siliconCurrent > 0.1 * siliconMax and phosphorousCurrent > 0.1 * phosphorousMax  and nitrogenCurrent > 0.1 * nitrogenMax  ) [ set nutrientsPresent  true ] [ set nutrientsPresent  false ] ;10% threshold for low nutrients
  
  if ( mixing = true ) [ mix ]
    
  ; dusk ( end of 12hr light )
  ifelse ( Light = true ) [ 
    ask cellfunction 8 [ LightturnONdual ]
    ask cellfunction 9 [ LightturnONsingle ]
    ask cellfunction 10 [ LightturnONdual ]
    ask cellfunction 11 [ LightturnONdual ]
    ask cellfunction 12 [ LightturnOFFdual ]
    ask cellfunction 13 [ LightturnONdual ]
    
    ask TF 0 [ LightturnONsingle ]
    ask TF 1 [ lightturnOFFdual ]
    ask TF 2 [ LightturnOFFdual ]
    ask TF 3 [ LightturnONsingle ] 
    
    ask gene 20 [ lightturnONdual ]
    ask gene 23 [ lightturnOFFdual ]
    
    ask patches [ if (pycor < 0 ) and (pycor > -3) [ set pcolor yellow ] ]
  ]
  
  ; dawn (no light)
  [ 
    ask cellfunction 8 [ LightturnOFFdual ]
    ask cellfunction 9 [ LightturnOFFsingle ]
    ask cellfunction 10 [ LightturnOFFdual ]
    ask cellfunction 11 [ LightturnOFFdual ]
    ask cellfunction 12 [ LightturnONdual ]
    ask cellfunction 13 [ LightturnOFFdual ]
        
    ask TF 0 [ LightturnOFFsingle ]
    ask TF 1 [ lightturnONdual ]
    ask TF 2 [ LightturnONdual ]
    ask TF 3 [ LightturnOFFsingle ] 
    
    ask gene 20 [ lightturnOFFdual ]
    ask gene 23 [ lightturnONdual ]
    
    ask patches [ if (pycor < 0 ) and (pycor > -3) [ set pcolor black ] ]
  ]
    
  ; exponential 
  ifelse ( nutrientsPresent ) [
    ask cellfunction 8 [ NutrientturnONdual ]
    ask cellfunction 10 [ NutrientturnONdual ]
    ask cellfunction 11 [ NutrientturnOFFdual ]
    ask cellfunction 12 [ NutrientturnOFFdual ]
    ask cellfunction 13 [ NutrientturnOFFdual ]
    
    ask TF 1 [ NutrientturnOFFdual ]
    ask TF 2 [ NutrientturnONdual ] 
  
    ask gene 20 [ NutrientturnOFFdual ]
    ask gene 21 [ NutrientturnOFFsingle ]
    ask gene 22 [ NutrientturnOFFsingle ]
    ask gene 23 [ NutrientturnOFFdual ]
  ]
  
  ; stationary
  [ 
    ask cellfunction 8 [ NutrientturnOFFdual ]
    ask cellfunction 10 [ NutrientturnOFFdual ]
    ask cellfunction 11 [ NutrientturnONdual ]
    ask cellfunction 12 [ NutrientturnONdual ]
    ask cellfunction 13 [ NutrientturnONdual ]
    
    ask TF 1 [ NutrientturnONdual ]
    ask TF 2 [ NutrientturnOFFdual ] 
    
    ask gene 20 [ NutrientturnONdual ]
    ask gene 21 [ NutrientturnONsingle ]
    ask gene 22 [ NutrientturnONsingle ]
    ask gene 23 [ NutrientturnONdual ]
  ]
  
  ;; These commands check to see if adjacent turtles in the top are the same color.  If so, the links between them are colored.  Otherwise, the links are hidden.
  ask TFs [ if ( color = green ) [ ask my-out-links [ ifelse [color] of other-end = green [ set color green ] [ set color 39 ] ] ] ]
  ask TFs [ if ( color = red ) [ ask my-out-links [ ifelse [color] of other-end = red [ set color red ] [ set color 39 ] ] ] ]
  ask TFs [ if ( color = orange ) [ ask my-out-links [ ifelse [color] of other-end = orange [ set color orange ] [ set color 39 ] ] ] ]
  
  ask genes [ if ( color = green ) [ ask my-out-links [ ifelse [color] of other-end = green [ set color green ] [ set color 39 ] ] ] ]
  ask genes [ if ( color = red ) [ ask my-out-links [ ifelse [color] of other-end = red [ set color red ] [ set color 39 ] ] ] ]
  ask genes [ if ( color = orange ) [ ask my-out-links [ ifelse [color] of other-end = orange [ set color orange ] [ set color 39 ] ] ] ]
  
  
  ;; diatom behavior
  ask diatoms [
    feed
    move
    reproduce
    if ( health < 0 ) [ die ]
  ]
  
  ;; Plotting method... rest of plotting is done directly from the interface
  set-current-plot "pH"
  set-current-plot-pen "pH"
  plot ((count CO2s * -.005035) + 8.630)
  
 tick
  
end



;--------------------------------------------------------------------------------------------------------------------------
; ....................................OBSERVER METHODS....................................................................
;--------------------------------------------------------------------------------------------------------------------------

to setupPatches  ;Setup Patches:  Grey at top, black line in middle, sunlight or not, blue water at bottom
  ask patches [ if pycor > 0 [ set pcolor 39 ]]
  ask patches [ if pycor = 0 [set pcolor black ]]
  ask patches [ if (light = true) and (pycor < 0 ) and (pycor > -3) [ set pcolor yellow ] ] 
  ask patches [ if (pycor <= -3 ) and (pycor >= min-pycor) [ set pcolor blue ]]
end

to mix
 ;; this doesn't currently do anything
end


;--------------------------------------------------------------------------------------------------------------------------
; ADD NUTRIENTS
;--------------------------------------------------------------------------------------------------------------------------
to addNitrogen
  let i Nitrogen
  while [ i > 0 ] [
    let randomY ((-1) * (random (max-pycor - 2) + 3))
    let randomX random-xcor
    ask patch randomX randomY [ ifelse pcolor = 15 [ ] [ set pcolor 15  set i ( i - 1 ) set plabel-color black  set plabel "N"] ]
    ]
  set nitrogenCurrent ( nitrogenCurrent + Nitrogen ) 
end

to addSilicon
  let i Silicon
  while [ i > 0 ] [
    let randomY ((-1) * (random (max-pycor - 2) + 3))
    let randomX random-xcor
    ask patch randomX randomY [ ifelse ( pcolor = 15 OR pcolor = 116 ) [ ] [ set pcolor 116  set i ( i - 1 ) set plabel-color black  set plabel "Si"] ]
    ]
  set siliconCurrent ( siliconCurrent + Silicon ) 
end

to addPhosphorous
  let i Phosphorous
  while [ i > 0 ] [
    let randomY ((-1) * (random (max-pycor - 2) + 3))
    let randomX random-xcor
    ask patch randomX randomY [ ifelse ( pcolor = 15 OR pcolor = 116 OR pcolor = 27 ) [ ] [ set pcolor 27  set i ( i - 1 ) set plabel-color black  set plabel "P"] ]
    ]
  set phosphorousCurrent ( phosphorousCurrent + Phosphorous ) 
end



;--------------------------------------------------------------------------------------------------------------------------
; CREATE LINKS IN UPPER PANEL
;--------------------------------------------------------------------------------------------------------------------------

to setupLinks
  set-default-shape links "default"
  let i 0
  repeat 4 [
    ask turtle i [ create-links-to genes ]
    set i i + 1
  ]
  
  set i 20
  repeat 4 [
    ask turtle i [ create-links-to cellFunctions ]
    set i i + 1
  ]
  
  ask links [ set color 39 ]
end


;--------------------------------------------------------------------------------------------------------------------------
; CREATE/REMOVE CARBON DIOXIDE
;--------------------------------------------------------------------------------------------------------------------------
 to addCO2 [ numCO2 ]
  set-default-shape CO2s "dot"
  create-CO2s numCO2 [
    set color yellow
    ;; pick a random position in the sky area
    setxy random-xcor
          (-1)* ( random (max-pycor - 2) + 3 )
  ]
end
 
to remove-CO2 ;; randomly remove 1 CO2 molecule
   if any? CO2s [ 
          
      ask one-of CO2s [ die ]
    ]
end


;--------------------------------------------------------------------------------------------------------------------------
; CREATE DIATOMS
;--------------------------------------------------------------------------------------------------------------------------

to setupDiatoms
  set-default-shape diatoms "diatoms"
  create-diatoms numDiatoms [ setxy random-xcor (-1)* ( random (max-pycor - 2) + 3 ) set health initialHealth ]
end

;--------------------------------------------------------------------------------------------------------------------------
; CREATE GENES
;--------------------------------------------------------------------------------------------------------------------------
; Create the 4 genes, attach labels, and position appropriately
to setupGenes [ xlocation ]
  let numberGenes 4
  let scalingFactor max-pycor / 2 / ( numberGenes - 1.8  )  ;last number is a fudge factor which spreads the cellFunctions evenly vertically
  create-genes numberGenes
  ask genes [ 
    set shape "pentagon"
    set color yellow
    set size 3   
    set label-color black ]
  ask gene 20 [ 
    attach-banner "PTP1" 3  ;Turtle 24
    set xcor xlocation
    set ycor 1 * scalingFactor ]
  ask gene 21 [ 
    attach-banner "SIT1" 3  ;Turtle 25
    set xcor xlocation
    set ycor 2 * scalingFactor ]
  ask gene 22 [ 
    attach-banner "NRT1" 3  ;Turtle 26
    set xcor xlocation
    set ycor 3 * scalingFactor ]
  ask gene 23 [ 
    attach-banner "NRT3" 3  ;Turtle 27
    set xcor xlocation
    set ycor 4 * scalingFactor ]
end

;--------------------------------------------------------------------------------------------------------------------------
; CREATE CELL FUNCTIONS
;--------------------------------------------------------------------------------------------------------------------------
; Create the 5 cellular functions, attach labels, and position appropriately
to setupCellFunctions [ xlocation ]
  let numFunctions 6
  let scalingFactor max-pycor / 2 / ( numFunctions - 2.8 )   ;last number is a fudge factor which spreads the cellFunctions evenly vertically
  create-cellFunctions numFunctions
  ask cellFunctions [ 
    set shape "circle"
    set color orange
    set size 2.5 
    set label-color black ]
  ask cellFunction 8 [ 
    attach-banner "Make Glucose" 1.5 ;Turtle 14
    set xcor xlocation
    set ycor scalingFactor ] 
  ask cellFunction 9 [ 
    attach-banner "Maintain DNA" 1.5 ;Turtle 15
    set xcor xlocation
    set ycor 2 * scalingFactor ] 
   ask cellFunction 10 [ 
    attach-banner "Divide!" 0.8  ;Turtle 16
    set xcor xlocation
    set ycor 3 * scalingFactor ] 
  ask cellFunction 11 [ 
    attach-banner "Transport P" 1.2  ;Turtle 17
    set xcor xlocation
    set ycor 4 * scalingFactor] 
  ask cellFunction 12 [ 
    attach-banner "Transport N" 1.2  ;Turtle 18
    set xcor xlocation
    set ycor 5 * scalingFactor ] 
  ask cellFunction 13 [ 
    attach-banner "Transport Si" 1.2   ;Turtle 19
    set xcor xlocation
    set ycor 6 * scalingFactor] 
end


;--------------------------------------------------------------------------------------------------------------------------
; CREATE TRANSCRIPTION FACTORS
;--------------------------------------------------------------------------------------------------------------------------

; Create the 4 transcription factors, attach labels, and position appropriately 
to setupTFs [ xlocation ]
  let numTFs 4
  let scalingFactor max-pycor / 2 / ( numTFs - 1.8 )  ;last number is a fudge factor which spreads the cellFunctions evenly vertically
  create-TFs numTFs  
  ask TFs [ 
    set size 3
    set label-color black
    set shape "square"
    set color white ]
  ask TF 0 [ 
    attach-banner "Myb" 0.5  ;Turtle 4
    set xcor xlocation
    set ycor 1 * scalingFactor ]
  ask TF 1 [ 
    attach-banner "HSF" 0.5  ;Turtle 5
    set xcor xlocation
    set ycor 2 * scalingFactor ]
  ask TF 2 [ 
    attach-banner "bZip" 0.5 ;Turtle 6
    set xcor xlocation
    set ycor 3 * scalingFactor] 
  ask TF 3 [ 
    attach-banner "E2F" 0.5  ;Turtle 7
    set xcor xlocation
    set ycor 4 * scalingFactor ] 
end


;--------------------------------------------------------------------------------------------------------------------------
; LABELS (BANNERS)
;--------------------------------------------------------------------------------------------------------------------------
; creates a banner turtle with a label, moves that turtle relative to the object it's attached to.
to attach-banner [labelname offset]  
  hatch-banners 1 [
    set size 0
    set label labelname
    create-link-from myself [   ;this works because the agent calling it is the turtle to which it will be attached (myself)
      tie
      hide-link
    ]
    set heading 90
    fd offset
  ]
end


;--------------------------------------------------------------------------------------------------------------------------
; REGULATION
;--------------------------------------------------------------------------------------------------------------------------
; Change appearance of Transcription Factors/Genes/Cell Functions to make them appear on or off  
to NutrientturnONdual
  set statusNutrient 1
  setSizeShapeDualRegulated
end

to NutrientturnOFFdual
  set statusNutrient 0
  setSizeShapeDualRegulated
end

to LightturnONdual
  set statusLight 1
  setSizeShapeDualRegulated
end

to LightturnOFFdual
  set statusLight 0
  setSizeShapeDualRegulated
end

to NutrientturnONsingle
  set statusNutrient 1
  setSizeShapeSingleRegulated
end

to NutrientturnOFFsingle
  set statusNutrient 0
  setSizeShapeSingleRegulated
end

to LightturnONsingle
  set statusLight 1
  setSizeShapeSingleRegulated
end

to LightturnOFFsingle
  set statusLight 0
  setSizeShapeSingleRegulated
end

;; Two versions are used to set the size and the color.  The first is used if the turtle is affected by both light and nutrients.  
;; The second is used if the turtle is affected by only one or the other.
to setSizeShapeDualRegulated
  set size ( statusNutrient + statusLight + 2 )
  if ( statusNutrient + statusLight = 2 ) [ set color green ]
  if ( statusNutrient + statusLight = 1 )[ set color orange ]
  if ( statusNutrient + statusLight = 0 ) [ set color red ]
end

to setSizeShapeSingleRegulated
  set size ( statusNutrient + statusLight + 2 )
  if ( statusNutrient + statusLight = 1 ) [ set color green ]
  if ( statusNutrient + statusLight = 0 ) [ set color red ]
end



;--------------------------------------------------------------------------------------------------------------------------
; ....................................TURTLE METHODS....................................................................
;--------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------
; EAT NUTRIENTS
;--------------------------------------------------------------------------------------------------------------------------
to feed
   set uptakeProbability random 20
    
    if ( nutrientsPresent ) [ set uptakeProbability uptakeProbability - 10 ] 
    
    if ( uptakeProbability > 5 ) [
    
      if pcolor = 15 [ 
        set N ( N + 1 )
        set nitrogenCurrent ( nitrogenCurrent - 1)
        ask patch-here [ set pcolor blue set plabel "" ]
        set health health + 20 
      ]
      if pcolor = 116 [ 
        set Si ( Si + 1 )
        set siliconCurrent ( siliconCurrent  - 1 )
        ask patch-here [ set pcolor blue set plabel "" ]
        set health health + 20 
      ]
      if pcolor = 27 [ 
        set P ( P + 1 )
        set phosphorousCurrent ( phosphorousCurrent  - 1 )
        ask patch-here [ set pcolor blue set plabel "" ]
        set health health + 20 
      ]
    ]
end


;--------------------------------------------------------------------------------------------------------------------------
; MOVE
;--------------------------------------------------------------------------------------------------------------------------
to move
    fd 1
    if ycor > -3 [ set ycor (-1) * (random (max-pycor - 2) + 3 )] 
    if ycor < (min-pycor ) [ set ycor (-1) * (random (max-pycor - 2) + 3 ) ] 
    set health health - 1
end
    
  
;--------------------------------------------------------------------------------------------------------------------------
; REPRODUCE IF THERE IS LIGHT AND NUTRIENTS AVAILABLE
;--------------------------------------------------------------------------------------------------------------------------
to reproduce  
  if ( light = true AND Si > 0 AND N > 0 ) [
      hatch growthRate [ set N 0  set P 0 set Si 0 set heading ( random 360 ) fd 5 set health initialHealth ]
      set N ( N - 0.2 )
      set P ( P - 0 )
      set Si ( Si - 2 ) 
      remove-CO2
    ]  

end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
796
787
13
17
21.333333333333332
1
10
1
1
1
0
1
1
1
-13
13
-17
17
1
1
1
ticks
30.0

SWITCH
41
102
144
135
Light
Light
0
1
-1000

SWITCH
39
149
142
182
Mixing
Mixing
1
1
-1000

BUTTON
11
18
81
51
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
95
19
158
52
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1066
352
1595
669
Nutrients
time
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Nitrogen" 1.0 0 -2674135 true "" "plot nitrogenCurrent"
"Phosphorous" 1.0 0 -8630108 true "" "plot phosphorousCurrent"
"Silicon" 1.0 0 -612749 true "" "plot siliconCurrent"

PLOT
1068
33
1590
341
Diatom Population
time
Diatoms
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Diatoms" 1.0 0 -16777216 true "" "plot (count Diatoms * 5 )"

PLOT
822
194
1022
344
Carbon Dioxide
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count CO2s"

PLOT
824
29
1024
179
pH
NIL
NIL
0.0
10.0
7.5
9.0
true
false
"" ""
PENS
"pH" 1.0 0 -7500403 true "" ""

SLIDER
15
322
187
355
Nitrogen
Nitrogen
1
nitrogenMax
20
1
1
NIL
HORIZONTAL

SLIDER
14
374
186
407
Silicon
Silicon
0
siliconMax
20
1
1
NIL
HORIZONTAL

SLIDER
14
423
186
456
Phosphorous
Phosphorous
1
phosphorousMax
20
1
1
NIL
HORIZONTAL

SLIDER
9
200
190
233
CarbonDioxide
CarbonDioxide
400
800
800
400
1
ppm
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model is based on the work of Ashworth et. al. “Genome-wide diel growth state transitions in the diatom Thalassiosira pseudonana”, PNAS, vol. 110 no. 1,  7518–7523.   The purpose of the model is to show some of the effects of changing environmental conditions on diatoms both from a genetic point of view and also from an agent-based point of view.

## HOW IT WORKS

The world is split into two different areas.  The top shows genetic expression of transcription factors, genes, and cellular functions, with green color indicating upregulation, red indicating downregulation, and orange indicated a combination of up- and down-regulation.  The size of these turtles is based on how much they are being regulated.  A preset series of rules are used to set the size and color based on the presence or absence of light, and the presence of absence of nutrients.  These rules were taken from the paper referenced above.
 
The bottom part of the world is a model of diatoms in seawater.  The diatoms are green.  The seawater contains carbon dioxide (yellow dots), and nitrogen, phosphorous, and silicon nutrients (colored patches with labels).  Diatoms move randomly in the bottom space, can pick up nutrients if diatoms moves over a nutrient patch and a random check is made, and can reproduce if certain conditions are met.  Diatoms have a certain amount of health, and gain health when they pick up nutrients, but lose health as they move.   Diatoms can track how much of each nutrient they possess using the diatom-owned variables N, Si, and P.  With a finite level of nutrients present in the world, they all eventually die when their health is below zero, but the maximum population reached varies as a function of the environmental conditions.  

In terms of reproduction, diatoms hatch another diatom if and only if they own at least one unit of Si, one unit of N, and if there is light on.  Reproducing costs them 0.2 units of N and 2 units of Si.


## HOW TO USE IT

Adjust the environmental conditions to those that you want.  You may turn light On or Off, turn mixing On or Off, set carbonDioxide slider to be 400ppm or 800ppm, and chose the relatively levels of nitrogen, silicon, and phosphorous using the slider.   Then click on the setup button.  Light and Mixing can be toggled on after the “Go” button is hit, but the nutrient levels (N, Si, P, and CO2) do not change after the “Go” button is hit.

## THINGS TO NOTICE

Watch the graphs to see how the population of diatoms changes, how the nutrients are used up, how CO2 is depleted in the area as diatoms use it up, and how the pH of the seawater varies based on the CO2 level.

Also, notice that changes in gene expression occur.  Try changing the light conditions during a run to see what transcription factors, genes, and cellular functions are present with light on or off.   Notice that as nutrients are used up, the gene expression changes drastically.


## EXTENDING THE MODEL

The mixing button currently does nothing.  It could be used to cause the nutrients to randomly shift patches.

There is no effect of changing CO2  levels on growth of diatoms in the model.  The second line of the "Go" function is a line which is commented out, but which would change the global variable growthRate.  This variable determines how many diatoms are hatched in the function "reproduce".

A binary system is in effect for whether the diatoms can pick up nutrients.  See "feed".  A random number between 0 and 19 is generated.  If nutrients levels are high, 10 is subtracted from this number.  If nutrients levels are low, the number is not changed.  Then the numbers if compared to 5, and if it is greater, the diatom "picks up" the nutrient.   This system seems artificial to me.

The motion of the diatoms is not very appealing to the eye.  They could be made to "diffuse" in more of a random walk within the bottom of the world. 


## NETLOGO FEATURES

This model has a couple interesting features.  In the top of the world, there are lines which show connections between the transcription factors (TFs), genes, and cellular functions.  To show that transcription factors can control the expression of genes which can control the cellular functions, there are lines running from same colored TFs to genes, and from same colored genes to cellular functions.  Links were setup between every This lines were created using a series of commands such as:

ask TFs [ if ( color = green ) [ ask my-out-links [ ifelse [color] of other-end = green [ set color green ] [ set color 39 ] ] ] ]

The green colored TFs look at their out links and if the color of the gene to which they are attached is also green, then the link is set to be green, and otherwise it is set to be the color of the background patches, so that the link disappears.

Another interesting feature is that there are turtles which function as labels but are much more customizable than normal labels.  The turtles are breed "banners", and are hatched in the "attach-banner" function.  This function is called from the turtle to be labeled, and then the banner is linked to the calling turtle, tied to the calling turtle, and moved a distance to offset it from the calling turtle.  This distance is a parameter in the function call. 

## RELATED MODELS


## CREDITS AND REFERENCES

This model was developed with the help of Monica Orellana, Justin Ashworth, Mari Herbert, and Claudia Ludwig at the Institute for Systems Biology under the financial support of NSF MCB 1316206 .   The paper on which this model is based can be found here:  http://www.pnas.org/content/110/18/7518.abstract .
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

activecellfunction
false
0
Circle -13840069 true false 0 0 300

activetranscriptionfactor
false
0
Rectangle -13840069 true false 30 30 270 270

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

cellularfunctions
false
0
Circle -955883 true false 0 0 300

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

diatoms
false
0
Circle -13840069 true false 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

inactivecellfunction
false
0
Circle -2674135 true false 0 0 300

inactivetranscriptionfactor
false
0
Rectangle -2674135 true false 30 30 270 270

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

transcriptionfactor
false
0
Rectangle -1 true false 30 30 270 270

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0

line
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
4
Line -7500403 false 150 150 120 180
Line -7500403 false 150 150 180 180

@#$#@#$#@
0
@#$#@#$#@
