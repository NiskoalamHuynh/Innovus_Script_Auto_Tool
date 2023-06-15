# Innovus_Script_Auto_Tool
[TCL] - PNR - Innovus <p>
PlacePinShape : Đặt pin cho shape cần thiết kế <p>

# Documentation
* [Create Place Pin](#createPin)
* [Layer FloorPlan](#howToPlacePin)

<a name="createPin"></a>
## Create Place Pin
<img src="./img/img_0608_ExPlacePin.png"> <p>
1. group A gồm các pin *O_*
2. group B gồm các pin *x0a*
3. group C gồm các pin *I_*
4. group D các chân còn lại (Chứa các chân clk) 

Yêu cầu đặt pin ở layer M4 hoặc M5 <p>
Size Depth: 0.25 width: 0.05 (Nhân 2 cho with ở group D) <p>

### Tạo script Place Pin
<img src="./img/img_0608_PlacePinForShape.png"> <p>

<a name="howToPlacePin"></a>
## Layer FloorPlan
Layer M1:
>#=============================================
># CREATE M1 and M2 RAIL
>#=============================================
>sroute -connect corePin -crossoverViaBottomLayer M1 -crossoverViaTopLayer M3 -nets {VDD VSS} -corePinLayer M1
>sroute -connect corePin -crossoverViaBottomLayer M2 -crossoverViaTopLayer M3 -nets {VDD VSS} -corePinLayer M2

Layer M2:
Layer M3:
Layer M4:
Layer M5:

