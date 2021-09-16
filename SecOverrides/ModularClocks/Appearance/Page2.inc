; ---------------------------------------------------------------------------- ;
;                                   Functions                                  ;
; ---------------------------------------------------------------------------- ;

[ContentContainer]
MouseScrollUpAction=
MouseScrollDownAction=

[Shape:S]
X=(220*[Set.S])r
Y=r
Shape=Rectangle 0,0,200,200,#Set.R# | strokeWidth 0 | Scale [Set.S],[Set.S] | Extend This
This=Fill Color #Set.Ter_Color#
MouseOverAction=[!SetOption #CURRENTSECTION# This "Fill Color #Set.Subtext_Color#"][!UpdateMeter #CURRENTSECTION#][!Redraw]
MouseLeaveAction=[!SetOption #CURRENTSECTION# This "Fill Color #Set.Ter_Color#"][!UpdateMeter #CURRENTSECTION#][!Redraw]
Dynamicvariables=1
Container=ContentContainer
[Image:S]
MEasureName=Image[#CURRENTSECTION]
; ImageName=#ROOTCONFIGPATH#\.DeveloperResources\WebResources\Clocks\Page1\Image1.png
X=0r
Y=0r
W=(200*[Set.S])
H=(200*[Set.S])
Container=ContentContainer
Dynamicvariables=1
Group=ParsedDisplay

; ---------------------------------------------------------------------------- ;
;                                    Content                                   ;
; ---------------------------------------------------------------------------- ;

[Shape1]
Meter=Shape
X=(30*[Set.S])
y=(30*[Set.S])R
MeterStyle=Shape:S
[0001]
Meter=Image
MeterStyle=Image:S

[Shape2]
Meter=Shape
MeterStyle=Shape:S

[Shape3]
Meter=Shape
MeterStyle=Shape:S

[Shape4]
Meter=Shape
X=(30*[Set.S])
y=(220*[Set.S])r
MeterStyle=Shape:S

[Shape5]
Meter=Shape
MeterStyle=Shape:S

[Shape6]
Meter=Shape
MeterStyle=Shape:S

[Shape7]
Meter=Shape
X=(30*[Set.S])
y=(220*[Set.S])r
MeterStyle=Shape:S

[Shape8]
Meter=Shape
MeterStyle=Shape:S

[Shape9]
Meter=Shape
MeterStyle=Shape:S

[Shape10]
Meter=Shape
X=(30*[Set.S])
y=(220*[Set.S])r
MeterStyle=Shape:S

[Shape11]
Meter=Shape
MeterStyle=Shape:S

[Shape12]
Meter=Shape
MeterStyle=Shape:S


; ---------------------------------------------------------------------------- ;
;                                    Parser                                    ;
; ---------------------------------------------------------------------------- ;
; @includeWeb=WebParse\Measures.inc