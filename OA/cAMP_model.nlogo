;; Author:  Gabriel Cronin
;; Created July, 2015
;;
;; Adapted from HALOBACTIERUM PURPLE MEMBRANE BIOGENESIS MODEL
;; Author: Patrick Mar, Institute for Systems Biology


;; ***** VARIABLE DECLARATIONS *****


breed [ membranes ] ;; note that this needs to be declared BEFORE nodes in order for the transporters to be above the 
breed [ nodes ]
breed [ edges ]
breed [ edge-heads ]
breed [ edge-bodies ]
breed [ CO2 ]
breed [ G3P ]
breed [ deadTurtles ]

globals [ runCalvinCycle? tickCounter animationRate  
  ocean-top cell-top chloroplast-top plasmid-top cell-left cell-right chloroplast-left chloroplast-right plasmid-left plasmid-right 
  G3Pcount 
  ATPcount ATP-per-CO2Transport
  slope CO2-ppm-min CO2-ppm-max CO2-current 
  i 
  cAMP-ko-status
  ]

CO2-own [ calvinCycle-location ]
G3P-own [ location ]
membranes-own [ name ]
nodes-own [ name amount in-edges out-edges knockedout? nodetype ]
edges-own [ from into edge_type ]
edge-heads-own [ parent-edge ]
edge-bodies-own [ parent-edge ]


;; ***** SETUP PROCEDURES *****

to setup
  clear-all
  ask patches [ set pcolor 109 ]   ;; set background color

  set ATP-per-CO2Transport 1
  set CO2-ppm-min 400
  set CO2-ppm-max 800
  set animationRate 5;
    
   ;; DNA Turtle
  crt 1 [ set heading 0 set size 9 set shape "spiral" set color black setxy (0.65 * max-pxcor) (-0.1 * max-pycor) stamp die]
  
  setup-membranes
  setup-nodes
  setup-edges
  setup-calvincycle
  setup-CO2
  
  do-plots
  
  reset-ticks
end

to setup-CO2
  set ocean-top max-pycor - 0
  set cell-top max-pycor - 6
  set chloroplast-top 6
  set plasmid-top 2.5
  set cell-left min-pxcor
  set cell-right max-pxcor
  set chloroplast-left min-pxcor + 1
  set chloroplast-right 3
  set plasmid-left min-pxcor + 2
  set plasmid-right 2
  create-CO2 CO2-amount / 10 [ set shape "CO2" setxy random-Xcor (cell-top + random (ocean-top - cell-top) + 1) set size 3 set color [0 0 0 100] ]
end
  

to setup-calvincycle
  ;; create Calvin Cycle loop
  create-membranes 1 [
    set shape "circle 2"
    set heading 0
    set color black
    setxy (-0.4 * max-pxcor) (-0.4 * max-pycor)
    set size 10
    set name "calvinCycle"
    set label-color black
    set label name
    ]
end



to setup-membranes
  ;; Create 4 membranes for the cell membrane, the chloroplast membrane, the plasmid membrane, and the nuclear membrane... cell wall left out for simplicity
  create-membranes 4 [ set shape "square 3" set color black ] 
  ask membranes with [ who = 1 ] [ set name "cell" setxy (0 * max-pxcor) (0 * max-pycor)  set size 2.5 * max-pycor set heading 0 ]
  ask membranes with [ who = 2 ] [ set name "chloroplast" setxy (-0.25 * max-pxcor) (-0.3 * max-pycor) set size 1.7 * max-pycor set heading 90]
  ask membranes with [ who = 3 ] [ set name "plastid" set shape "square 4" setxy (-0.25 * max-pxcor) (-0.48 * max-pycor) set size 1.6 * max-pycor set heading 90]
  ask membranes with [ who = 4 ] [ set name "nucleus" setxy (0.6 * max-pxcor) (-0.1 * max-pycor) set size 0.8 * max-pycor set heading 90]
end


to setup-nodes
    
  ;; create the nodes in the genetic pathway
  create-nodes 9
    [ set in-edges []
      set out-edges []
      set knockedout? false 
      set amount 0 ]
  
  ;; customize individual nodes
  
  ;; CO2
  ask nodes with [ who = 5 ] [ set name "CO2" 
                               set nodetype "control"
                               setxy (0.2 * max-pxcor) (0.9 * max-pycor) 
                               set amount CO2-amount
                               ]      
  ;;CYCc
  ask nodes with [ who = 6 ] [ set name "CYCc" 
                               set nodetype "protein"
                               setxy (0.4 * max-pxcor) (0.45 * max-pycor)                               
                               ]   
  ;;cAMP
  ask nodes with [ who = 7 ] [ set name "cAMP" 
                               set nodetype "messenger"
                               setxy (0.8 * max-pxcor) (0.35 * max-pycor)                               
                               ]       
  ;;Transcription Factor
  ask nodes with [ who = 8 ] [ set name "Transcription Factor" 
                               set nodetype "protein"
                               setxy (0.45 * max-pxcor) (0 * max-pycor)                               
                               ]        
  ;;Gamma Carbonic Anhydrase - REMOVED
  ask nodes with [ who = 9 ] [ set name "Gamma Carbonic Anhydrase" 
                               set nodetype "protein"
                               setxy (0 * max-pxcor) (0.28 * max-pycor)   
                               hide-turtle                             
                               ]
  ;;CCM Transporter
  ask nodes with [ who = 10 ] [ set name "CCM Transporter" 
                               set nodetype "activeTransporter"
                               setxy (-0.4 * max-pxcor) (0.16 * max-pycor)                               
                               ]
  ;;  262258 Transporter - REMOVED
  ask nodes with [ who = 11 ] [ set name "262258 Transporter" 
                               set nodetype "activeTransporter"
                               setxy (-0.7 * max-pxcor) (0.17 * max-pycor)
                               set amount 50    
                               hide-turtle                           
                               ]
  
  ;;CCM Transporter
  ask nodes with [ who = 12 ] [ set name "CCM Transporter" 
                               set nodetype "transporter"
                               setxy (-0.4 * max-pxcor) (0.38 * max-pycor)                               
                               ]
                               
  ;;CCM Transporter
  ask nodes with [ who = 13 ] [ set name "CCM Transporter" 
                               set nodetype "transporter"
                               setxy (-0.4 * max-pxcor) (0.62 * max-pycor)                               
                               ]    
      
  
  
   ;; set shapes 
  ask nodes with [ nodetype = "control" ] [ set shape "triangle" ]
  ask nodes with [ nodetype = "protein" ] [ set shape "square" ]
  ask nodes with [ nodetype = "messenger" ] [ set shape "pentagon" ]
  ask nodes with [ nodetype = "transporter" ] [ set shape "transport" set color 109 ]
  ask nodes with [ nodetype = "activeTransporter" ] [ set shape "rectangle" set color orange ]
  
  ;; set general node variables  
  ask nodes [set label name 
             set label-color black]   
  
  ;; update physical amounts of each node
  update-nodes
end

to setup-edges
  ;; define edge parts
  set-default-shape edges "line"
  set-default-shape edge-heads "edge-heads"
  set-default-shape edge-bodies "edge-bodies"
  
   ;; define node connections
  ask nodes with [ name = "CO2" ] [ connect-to (turtle 6) "sensing" ]
  ask nodes with [ name = "CYCc" ] [ connect-to (turtle 7) "signaling" ]
  ask nodes with [ name = "cAMP" ] [ connect-to (turtle 8) "signaling" ]
  ask nodes with [ name = "Transcription Factor" ] [ connect-to (turtle 10) "signaling" ]
    
end


to connect-to [other-node edge-type]  ;; node procedure
  hatch-edges 1
    [ set label ""
      
      ;; set edge color
      if edge-type = "sensing" [ set color red ]
      if edge-type = "signaling" [ set color blue ]
      
      ;; set edge direction
      set from myself
      set into other-node
      
      ;; position the edge
      reposition ]
end


to reposition  ;; edge procedure
  ;; turn off display while positioning edge
  no-display

  ;; edge starting point
  setxy ([xcor] of from) ([ycor] of from)
  
  ;; make sure edge doesn't fall exactly on top of node
  if distance into = 0 [ask into [fd 1]]  
 
  ;; set edge heading
  set heading towards-nowrap into

  ;; set edge size
  set size distance-nowrap into - ([size] of into / 2)

  ;; definte edge parts
  jump (distance-nowrap into) / 2  
  ask edge-heads with [parent-edge = myself] [die]
  ask edge-bodies with [parent-edge = myself] [die]
  hatch-edge-heads 1 [
   set parent-edge myself
   set size 1.5
   jump [size] of parent-edge / 2 - size / 2
  ]
  hatch-edge-bodies 1 [
    set parent-edge myself
    set size 1
  ]
 
  ;; turn display back on
  display
end     





;; ***** RUNTIME PROCEDURES *****

to go
    
    if( G3Pcount = Amount-of-G3P-to-Produce ) [ stop ]
    update-nodes
    run-animation
    run-CO2
    pump-CO2
    do-plots
    tick
end


to run-CO2
  if (ticks - tickCounter > animationRate) [
    ask CO2 [ if ycor > cell-top [ setxy random-Xcor (cell-top + random (ocean-top - cell-top) + 1)  set heading random 360 ]]
    ask CO2 [ if ycor < cell-top AND ycor > chloroplast-top [setxy (chloroplast-left + random (chloroplast-right - chloroplast-left)) (chloroplast-top + random (cell-top - chloroplast-top - 1) + 1)  set heading random 360 ]]
    ask CO2 [ if ycor < chloroplast-top AND ycor > plasmid-top [setxy (plasmid-left + random (plasmid-right - plasmid-left)) (plasmid-top + random (chloroplast-top - plasmid-top - 1) + 1)  set heading random 360 ]]
    ask CO2 [ if ycor < plasmid-top AND calvinCycle-location != 1 AND  calvinCycle-location != 2 AND calvinCycle-location != 3 AND calvinCycle-location != 4 [setxy (plasmid-left + random (plasmid-right - plasmid-left)) (plasmid-top - 3 + random 3 )  set heading random 360 ]]
    set tickCounter ticks 
  ]
end

to pump-CO2
  ask nodes with [ who = 10 ] [ if knockedout? = false  
  [
    diffuse-in (-0.4 * max-pxcor) (0.62 * max-pycor)
    diffuse-out (-0.4 * max-pxcor) (0.62 * max-pycor)
    diffuse-in (-0.4 * max-pxcor) (0.38 * max-pycor)
    diffuse-out (-0.4 * max-pxcor) (0.38 * max-pycor)
    if ( count CO2 with [ ycor < plasmid-top ] < 30 ) [ pump-in (-0.4 * max-pxcor) (0.16 * max-pycor) ]
   ]]
end 

to pump-in [ xlocation ylocation ]
  ask patches with [ pxcor > xlocation - 800 / CO2-amount AND pxcor < xlocation + 800 / CO2-amount  AND pycor > ylocation AND pycor < ylocation + 1.5 ] [ if any? CO2-here [ ask one-of CO2-here [set ycor ycor - 3 set heading one-of [ 90 270 ] fd 4 set ATPcount ATPcount + ATP-per-CO2Transport ]]]
end

to diffuse-in [ xlocation ylocation ]
  ask patches with [ pxcor > xlocation - 800 / CO2-amount AND pxcor < xlocation + 800 / CO2-amount  AND pycor > ylocation AND pycor < ylocation + 1.5 ] [ if any? CO2-here [ ask one-of CO2-here [set ycor ycor - 3 set heading one-of [ 90 270 ] fd 4 ]]]
end

to diffuse-out [ xlocation ylocation ]
  ask patches with [ pxcor > xlocation - 800 / CO2-amount AND pxcor < xlocation + 800 / CO2-amount  AND pycor < ylocation AND pycor > ylocation - 1 ] [ if any? CO2-here [ ask one-of CO2-here [set ycor ycor + 3 set heading one-of [ 90 270 ] fd 4 ]]]
end



to run-animation
    
  if ( runCalvinCycle? = true ) [
    if (ticks - tickCounter > animationRate) [
    
    
      ;; Rotate Calvin Cycle Arrow
      ask membranes with [ name = "calvinCycle" ] [ set heading (heading - 10) ]
  
      ;; Move CO2 molecules around Calvin Cycle
      ifelse ( count CO2 with [ calvinCycle-location = 4 ] > 2 )
      [
        ;; create a G3P molecule from 3 CO2 molecules... have to change breed of CO2s otherwise there are issues with "nobody" errors when "ask one-of CO2" is called in pump-CO2 function
      
        repeat 3 [ ask one-of CO2 with [ calvinCycle-location = 4 ] [ set calvinCycle-location 0 set breed deadTurtles die ] ] create-G3P 1 [ set shape "g3p" set size 4 setxy -0.4 * max-pxcor -0.8 * max-pycor set location 1 ]
      ]
    
      [ ifelse ( any? CO2 with [ calvinCycle-location = 3 ] ) 
        [ 
          ask one-of CO2 with [ calvinCycle-location = 3 ] [ set heading 125 fd 3 set calvinCycle-location 4]
        ]
        
        [ ifelse ( any? CO2 with [ calvinCycle-location = 2 ] ) 
          [
            ask one-of CO2 with [ calvinCycle-location = 2 ] [ set heading 165 fd 3 set calvinCycle-location 3]
          ]
    
          [ ifelse ( any? CO2 with [ calvinCycle-location = 1 ] ) 
            [ 
              ask one-of CO2 with [ calvinCycle-location = 1 ] [ set heading 200 fd 3 set calvinCycle-location 2 ]
            ]
        
            [ if ( any? CO2 with [  ycor < plasmid-top AND ycor > plasmid-top - 2 ] ) 
              [ 
                ask one-of CO2 with [  ycor < plasmid-top AND ycor > plasmid-top - 2 ] [ setxy -0.4 * max-pxcor -2 set heading 250 fd 3 set calvinCycle-location 1 ] 
              ]
            ]
          ]
        ]
      ]
    
      ;; Move G3P over to graph
      ifelse ( any? G3P with [ location = 4 ] )
      [
        ask one-of G3P with [ location = 4 ] [ set G3Pcount G3Pcount + 1 set location 0 set breed deadTurtles die ]
      ]
      [ ifelse ( any? G3P with [ location = 3 ] ) 
        [ 
          ask one-of G3P with [ location = 3 ] [  fd 3 set location 4 ]
        ]
        
        [ ifelse ( any? G3P with [ location = 2 ] ) 
          [
            ask one-of G3P with [ location = 2 ] [ fd 3 set location 3]
          ]
        
          [ if ( any? G3P with [ location = 1 ] ) 
            [ 
              ask one-of G3P with [ location = 1 ] [ set heading 280 fd 3 set location 2 ]
            ]
          ]
        ] 
      ]
    
    
      
    ]
  ]
end


to update-nodes 

  ask nodes with [ name = "CO2" ] [ set amount CO2-amount / 10 ] 

  ask nodes with [ name = "CYCc" ] [set amount CO2-amount / 8 ]
                                  
  
  ask nodes with [ name = "cAMP" ] [ ifelse knockedout? = true [ set amount 0 ]  
                                  [ set amount CO2-amount / 8 ]]                                

  ask nodes with [ name = "Transcription Factor" ] [ ifelse knockedout? = true [ set amount 0 ]  
                                  [ set amount CO2-amount / 8 ]]
                                                                    
  
  ask nodes with [ name = "CCM Transporter" ] [ ifelse knockedout? = true [ set amount 0 ]  
                                  [ set amount (800 - CO2-amount) / 6 ]]
                                  
  ask nodes with [ name = "Gamma Carbonic Anhydrase" ] [ ifelse knockedout? = true [ set amount 0 ]  
                                  [ set amount (800 - CO2-amount) / 10 ]]
                                  
                                  
  ask nodes [ update-display ]
end


to update-display ;; node procedure
  ;; set sizes
  set size ((amount / 25) + 1.5)
  
  ;; set colors
  ifelse knockedout? = true [ set color 109 ] [
    if nodetype = "control"  [ set color scale-color yellow amount 220 -20]
    if nodetype = "protein"  [ set color scale-color green amount 220 -20 ]
    if nodetype = "messenger" [ set color scale-color orange amount 220 -20 ] ]
end





;; ***** KNOCKOUT PROCEDURES *****

to knockout [ nodename ]
  if nodename = "cAMP" [ toggle-cAMP true set cAMP-ko-status true]
end


to reactivate [ nodename ] 
  if nodename = "cAMP" [ toggle-cAMP false set cAMP-ko-status false ]
  if cAMP-ko-status = true [ toggle-cAMP true ]

end

to toggle-cAMP [ change-value ]
 ask nodes with [ name = "cAMP" or name = "Transcription Factor" or name = "Gamma Carbonic Anhydrase" or name = "CCM Transporter"  ] [ set knockedout? change-value ]                              
end


;; *********  GRAPHING PROCEDURES **********************

to do-plots
    
  set-current-plot "CO2 Distribution"
  set-current-plot-pen "OceanCO2"
  plot count CO2 with [ ycor > cell-top ]
  set-current-plot-pen "CytoplasmCO2"
  plot count CO2 with [ ycor < cell-top AND ycor > chloroplast-top ]
  set-current-plot-pen "ChloroplastCO2"
  plot count CO2 with [ ycor < chloroplast-top AND ycor > plasmid-top] 
  set-current-plot-pen "PlasmidCO2"
  plot count CO2 with [ ycor < plasmid-top ]
     
  set-current-plot "ATP Used"
  set-current-plot-pen "ATP"
  plot ATPcount
  
  if ( CO2-amount != CO2-current ) 
  [ 
    set-current-plot "Gene Enrichment"
    clear-plot
    
    set-current-plot-pen "TCA"
    plot50 0 0
    plot100 50 scale CO2-amount ( CO2-ppm-min - 10 ) CO2-ppm-max 0 -2 
    
    set-current-plot-pen "Photosynthesis"
    plot50 150 0
    plot100 200 scale CO2-amount ( CO2-ppm-min - 10 ) CO2-ppm-max 0 -1.5 
    
    set-current-plot-pen "Kinases"
    plot50 300 0
    plot100 350 scale CO2-amount ( CO2-ppm-min - 10 ) CO2-ppm-max 0 -4.5 
    
    set-current-plot-pen "Transcription"
    plot50 450 0
    plot100 500 scale CO2-amount ( CO2-ppm-min - 10 ) CO2-ppm-max 0 -4 
    
    set-current-plot-pen "Ribosome"
    plot50 600 0
    plot100 650 scale CO2-amount ( CO2-ppm-min - 10 ) CO2-ppm-max 0 4 
    
    set-current-plot-pen "Ion Transport"
    plot50 750 0
    plot100 800 scale CO2-amount ( CO2-ppm-min - 10 ) CO2-ppm-max 0 -5 
    
    set CO2-current CO2-amount 
      
   ]
  

  
end

to plot100 [ starting-x number-to-plot ]
  set i 0
  repeat 100 [ 
    plotxy (starting-x + i) number-to-plot 
    set i ( i + 1)
    ]
end

to plot50 [ starting-x number-to-plot ]
  set i 0
  repeat 50 [ 
    plotxy (starting-x + i) number-to-plot 
    set i ( i + 1)
    ]
end

to-report scale [ number CO2-ppm-low CO2-ppm-high CO2-value-low CO2-value-high ]
  set slope ( CO2-value-high -  CO2-value-low ) / ( CO2-ppm-high - CO2-ppm-low )
  report (  CO2-value-low + slope * ( number - CO2-ppm-low ) )
end
@#$#@#$#@
GRAPHICS-WINDOW
368
22
1074
749
16
16
21.1
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

SLIDER
28
59
297
92
CO2-amount
CO2-amount
CO2-ppm-min
CO2-ppm-max
400
100
1
ppm
HORIZONTAL

BUTTON
83
14
150
47
NIL
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
171
15
234
48
NIL
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

BUTTON
73
160
273
193
knockout cAMP with IBMX
knockout \"cAMP\"
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
206
241
239
Reactive cAMP
reactivate \"cAMP\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
24
298
349
530
ATP Used
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
"ATP" 1.0 0 -16777216 true "" ""

SLIDER
39
701
311
734
Amount-of-G3P-to-Produce
Amount-of-G3P-to-Produce
0
5
3
1
1
NIL
HORIZONTAL

PLOT
1100
33
1718
443
Gene Enrichment
NIL
Gene Enrichment
0.0
950.0
-5.0
5.0
false
true
"" ""
PENS
"TCA" 1.0 1 -13791810 true "" ""
"Photosynthesis" 1.0 1 -2674135 true "" ""
"Kinases" 1.0 1 -13840069 true "" ""
"Transcription" 1.0 1 -5825686 true "" ""
"Ribosome" 1.0 1 -6459832 true "" ""
"Ion Transport" 1.0 1 -1184463 true "" ""
"pen-6" 1.0 0 -16777216 false "" ";; we don't want the \"auto-plot\" feature to cause the\n;; plot's x range to grow when we draw the axis.  so\n;; first we turn auto-plot off temporarily\nauto-plot-off\n;; now we draw an axis by drawing a line from the origin...\nplotxy 0 0\n;; ...to a point that's way, way, way off to the right.\nplotxy 1000000000 0\n;; now that we're done drawing the axis, we can turn\n;; auto-plot back on again"

TEXTBOX
393
193
543
218
Cell
20
0.0
1

TEXTBOX
871
511
1021
536
Nucleus
20
0.0
1

TEXTBOX
436
695
586
714
Plasmid
15
0.0
1

TEXTBOX
415
274
565
293
Chloroplast
15
0.0
1

PLOT
1103
450
1719
780
CO2 Distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"OceanCO2" 1.0 0 -16777216 true "" ""
"CytoplasmCO2" 1.0 0 -13840069 true "" ""
"ChloroplastCO2" 1.0 0 -2674135 true "" ""
"PlasmidCO2" 1.0 0 -955883 true "" ""

BUTTON
37
650
170
683
Calvin Cycle On
set runCalvinCycle? true
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
186
650
320
683
Calvin Cycle Off
set runCalvinCycle? false
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 90 60 135 60 135 285 165 285 165 60 210 60

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

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
true
0
Circle -7500403 false true 30 30 240
Polygon -7500403 true true 150 30 180 15 180 45
Polygon -7500403 true true 120 255 150 270 120 285

co2
true
0
Circle -16777216 true false 135 135 30
Circle -2674135 true false 165 135 30
Circle -2674135 true false 105 135 30

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

dot
false
0
Circle -7500403 true true 90 90 120

edge-bodies
true
0
Polygon -7500403 false true 135 105 165 105 165 135 180 135 180 165 165 165 165 195 135 195 135 165 120 165 120 135 135 135

edge-heads
true
0
Polygon -7500403 true true 45 255 150 0 255 255 150 225

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

g3p
true
0
Line -16777216 false 195 180 225 150
Line -16777216 false 150 150 195 180
Line -16777216 false 105 165 150 150
Line -16777216 false 60 135 105 165
Circle -16777216 true false 135 135 30
Circle -16777216 true false 180 165 30
Circle -16777216 true false 210 135 30
Circle -2674135 true false 90 150 30
Circle -955883 true false 45 120 30

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

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

rectangle
false
0
Rectangle -7500403 true true 45 120 255 180
Line -16777216 false 15 90 45 120
Line -16777216 false 45 120 45 180
Line -16777216 false 45 180 15 210
Line -16777216 false 285 90 255 120
Line -16777216 false 255 120 255 180
Line -16777216 false 255 180 285 210
Line -16777216 false 120 135 120 165
Line -16777216 false 120 165 135 150
Line -16777216 false 120 165 105 150
Line -16777216 false 180 135 180 165
Line -16777216 false 180 165 195 150
Line -16777216 false 180 165 165 150

selectablecircle
false
0
Circle -7500403 true true 16 16 270
Circle -13840069 true false 46 46 210

selectableoctagon
false
0
Polygon -7500403 true true 90 15 210 15 285 90 285 210 210 285 90 285 15 210 15 90 90 15 180 120 90 15
Circle -7500403 false true 84 24 42
Circle -13840069 true false 30 30 240

selectablesquare
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -13840069 true false 60 60 240 240

selectabletriangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -13840069 true false 151 99 225 223 75 224

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

spiral
true
0
Line -7500403 true 105 45 120 60
Line -7500403 true 120 60 150 75
Line -7500403 true 150 75 165 75
Line -7500403 true 165 75 180 60
Line -7500403 true 180 60 150 45
Line -7500403 true 150 45 135 45
Line -7500403 true 135 45 105 90
Line -7500403 true 105 90 120 105
Line -7500403 true 120 105 150 120
Line -7500403 true 150 120 165 120
Line -7500403 true 165 120 180 105
Line -7500403 true 180 105 150 90
Line -7500403 true 150 90 135 90
Line -7500403 true 135 90 105 135
Line -7500403 true 105 135 120 150
Line -7500403 true 120 150 150 165
Line -7500403 true 150 165 165 165
Line -7500403 true 165 165 180 150
Line -7500403 true 180 150 150 135
Line -7500403 true 150 135 135 135
Line -7500403 true 135 135 105 180
Line -7500403 true 105 180 120 195
Line -7500403 true 120 195 150 210
Line -7500403 true 150 210 165 210
Line -7500403 true 165 210 180 195
Line -7500403 true 180 195 150 180
Line -7500403 true 150 180 135 180
Line -7500403 true 135 180 105 225
Line -7500403 true 105 225 120 240
Line -7500403 true 120 240 150 255
Line -7500403 true 150 255 165 255
Line -7500403 true 165 255 180 240
Line -7500403 true 180 240 150 225
Line -7500403 true 150 225 135 225
Line -7500403 true 135 225 105 270

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

square 3
true
0
Rectangle -7500403 false true 30 75 270 270

square 4
true
0
Rectangle -7500403 false true 30 75 240 270

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

transport
false
0
Rectangle -7500403 true true 45 105 255 195
Line -16777216 false 45 90 45 210
Line -16777216 false 255 90 255 210
Line -16777216 false 45 90 30 75
Line -16777216 false 45 210 30 225
Line -16777216 false 255 90 270 75
Line -16777216 false 255 210 270 225

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
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
