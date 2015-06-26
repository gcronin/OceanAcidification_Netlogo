
globals [consensusDegree]

turtles-own [
  flockmates         ;; agentset of nearby turtles
  agenttype          ;; 1= normal, 0=fixed heading, 2= flexible shill
  tempHead           ;; temp store when updating the headings
]

to setup
  clear-all
  
  set-default-shape links "line"
  
  ask patches
  [set pcolor white]
  
  crt population
    [ ;;set color yellow - 2 + random 7  ;; random shades look nice
      set color green
      set size 4  ;; easier to see
      set agenttype 1
      setxy random-xcor random-ycor
      set tempHead heading ]
  let totalx sum [dx] of turtles 
  let totaly sum [dy] of turtles
  set consensusDegree sqrt ( totalx ^ 2 + totaly ^ 2 ) / ( count turtles )
    
      update-links
      
  reset-ticks
end

to go
  ask turtles with [agenttype = 1 ]    [flock ]
 
  ask turtles with [agenttype < 2] 
  [ 
    set heading tempHead
    fd 1 ]

  ask turtles with [agenttype >= 2 ] 
  [ set heading atan (mouse-xcor - xcor)  (mouse-ycor - ycor)
    let speed int  (sqrt (( mouse-xcor - xcor) ^ 2 + ( mouse-ycor - ycor) ^ 2) / 4 )
    output-print speed
    fd speed
    
    if agenttype = 10 [set size vision] 
    ;;fd 0
    ] 
  
  let totalx sum [dx] of turtles 
  let totaly sum [dy] of turtles

  set consensusDegree sqrt ( totalx ^ 2 + totaly ^ 2 ) / ( count turtles )
    
 update-links   
  tick
end

to flock  ;; turtle procedure
  find-flockmates
  if any? flockmates
    [  align 
      

      
    ]
end

to find-flockmates  ;; turtle procedure
  set flockmates other turtles in-radius vision
end

to link_them
  ;;create-link-with turtle 1 
  
end

;;; ALIGN

to align  ;; turtle procedure
  ;;turn-towards average-flockmate-heading 360
 ;; set heading average-flockmate-heading 
 set tempHead average-flockmate-heading 
end

to-report average-flockmate-heading  ;; I modify the code to include its own heading.
  ;; We can't just average the heading variables here.
  ;; For example, the average of 1 and 359 should be 0,
  ;; not 180.  So we have to use trigonometry.
  
  
  let x-component sum [dx] of flockmates
  let y-component sum [dy] of flockmates
  
  let new_angle 0
  
  set x-component x-component + dx
  set y-component y-component + dy
  
  
  ifelse x-component = 0 
  [ifelse y-component > 0 
    [set new_angle 0]
    [set new_angle 180]
    ]
  [set new_angle (atan x-component y-component) ]
  
  report new_angle +  (random-float noise) - noise / 2 

end


to add-fixed-heading-shills
  crt fixedHeadingShill
    [ set color 104 ;;blue  ;; random shades look nice
      set size 4  ;; easier to see
      set agenttype 0
      set heading angle
      setxy random-xcor random-ycor ]
    
end

to add-mouse-control-shill
  let xx random-xcor
  let yy random-ycor
  
  crt 1
    [ set color red  ;; random shades look nice
      set size 4  ;; easier to see
      set agenttype 2
      set heading 90
      setxy xx yy]
  crt 1 
    [ set shape "mycircle"
      set size vision
      set agenttype 10
      setxy xx yy  ]
  
end


to update-links
  
  ifelse (showLink)
  [   
    ask links [die]
   
    ask turtles [
    find-flockmates
    if any? flockmates
    [ create-links-to flockmates]
    ]
  ]
  [    ask links [die]]

end
@#$#@#$#@
GRAPHICS-WINDOW
271
24
934
513
100
70
3.2525
1
10
1
1
1
0
1
1
1
-100
100
-70
70
1
1
1
ticks
30.0

BUTTON
8
86
103
119
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
105
86
202
119
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

SLIDER
9
51
202
84
population
population
1.0
1000.0
85
1.0
1
NIL
HORIZONTAL

SLIDER
8
121
201
154
vision
vision
0.0
30
12
0.5
1
patches
HORIZONTAL

BUTTON
143
250
198
318
add
add-fixed-heading-shills
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
8
250
143
283
fixedHeadingShill
fixedHeadingShill
0
100
20
1
1
NIL
HORIZONTAL

BUTTON
8
334
198
367
add mouse-control-shill
add-mouse-control-shill
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
8
285
143
318
angle
angle
0
360
360
1
1
NIL
HORIZONTAL

SLIDER
8
155
201
188
noise
noise
0
60
0
0.001
1
NIL
HORIZONTAL

MONITOR
9
395
126
444
NIL
consensusDegree
17
1
12

SWITCH
7
190
106
223
showLink
showLink
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

This is a model to show how soft control work for the flocking model. Based on a Vicsek's model, a special agent--shill is added into the group to intervene the group behavior. You can control the shill by the mouse, so you can get the feeling of how to guide a group. 




## HOW IT WORKS

The agent follow one rule: "alignment".

"Alignment" means that an agent tends to turn so that it is moving in the same direction that nearby birds are moving.

This rule only  affect the agent's heading.  Each agent always moves forward at the same constant speed.



## HOW TO USE IT

First, determine the number of agents you want in the simulation and set the POPULATION slider to that value.  Press SETUP to create the agents, and press GO to have them start flying around.

The default settings for the sliders will produce reasonably good flocking behavior.  However, you can play with them to get variations:

VISION is the distance that each bird can see 360 degrees around it.

NOISE is the noise range [-NOISE/2, NOISE/2], a random value from the range will be added to the angle for heading update each time step. 

showLink will show the realtime neighborhood relationship amoung the agents. 

Now, if you want to intervene the group, press 'add mouse-control-shill'. Then a shill is added and you can use the mouse to control its heading and the speed (you move the mouse faster will increase the speed of the shll). 

You can also add some fixed heading shills by press the 'add'. Number of fixed heading shills are set by the slider of 'fixedHeadingShill'. Their headings are set by the slider of 'angle'. 

## Idea of Soft-Control
The Program is to show the softcontrol idea we proposed in 2005. Related publications are

*Jing Han, Lin Wang. Nondestructive Intervention to Multi-agent Systems Through an Intelligent Agent. PLoS ONE 8(5): e61542. doi:10.1371/ journal.pone.0061542. May, 2013

Soft Control on Collective Behavior of a Group of Autonomous Agents by a Shill Agent.*Jing HAN, Ming LI, Lei GUO. Journal of Systems Science and Complexity, 19(1), pp54-62, 2006


Soft Control on Collective Behavior of a Group of Autonomous Agents by a Shill Agent.*Jing HAN, Ming LI, Lei GUO. Journal of Systems Science and Complexity, 19(1), pp54-62, 2006


Guiding a Group of Locally Interacting Autonomous Mobile Agents. *Han Jing, Guo Lei, Li Ming. Proceedings of the 24th Chinese Control Conference. South China University of Technology Press, Guangzhou, 184-187, July, 2005.

## HOW TO CITE

If you mention this model in a publication, we ask that you include these citations for the model itself and for the NetLogo software:


*Jing Han, Lin Wang. Nondestructive Intervention to Multi-agent Systems Through an Intelligent Agent. PLoS ONE 8(5): e61542. doi:10.1371/ journal.pone.0061542. May, 2013

This program is written by Han Jing, Academy of Mathematics and Systems Science, Chinese Academy Science, China. http://complex.amss.ac.cn/hanjing/. Email: hanjing@amss.ac.cn. 
 


## RELATED MODELS

* Flocking

The code of this model is built based on the flocking model in the netlogo library.
 
Wilensky, U. (1998). NetLogo Flocking model. http://ccl.northwestern.edu/netlogo/models/Flocking. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Part of the code is modified and the softcontrol is added to the flocking model. 
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

mycircle
true
0
Circle -7500403 false true 0 0 300

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

vicsek
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250
Circle -7500403 false true -63 -63 426

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.5
@#$#@#$#@
set population 200
setup
repeat 200 [ go ]
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

line
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0

@#$#@#$#@
0
@#$#@#$#@
