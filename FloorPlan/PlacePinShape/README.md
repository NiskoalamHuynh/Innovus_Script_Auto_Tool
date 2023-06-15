# Innovus_Script_Auto_Tool
[TCL] - PNR - Innovus <p>
PlacePinShape : Đặt pin cho shape cần thiết kế <p>

# Documentation
* [Create Place Pin](#createPin)
* [Vấn đề khi thiết kế power mesh và phân bố pin](#howToPlacePin)

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

## Vấn đề khi thiết kế power mesh và phân bố pin
### Config cho Power Mesh
1. Quy tắc tạo layer power mesh trên shape với layer M1 và M2 tạo rail với dạng chạy ngang, từ M3 trở lên dựa vào quy tắc số lẻ chạy dọc số chẳn chạy ngang. Dựa vào việc config đường power trong PowerMesh. <p>
2. Khi đặt pin ở một số layer, pin bị trùng trên đường power. Điều này cần tránh vì đường routing cho pin sẻ đi vòng làm cho routing resource tắt nghẽn nên cần phân bố đồng đều tránh đường power tạo không gian cho route pin di chuyển thỏa mái hơn <p>
3. Một số yêu cầu đặt pin tại layer top tức M5 nơi cấp nguồn cho mem, khi đường power có opt (-extend_to design_boundary) tức cho đường chạy từ core ra die, khi ta đặt pin ở những vị trí này tool tự động cắt xén đường power làm mất đặt tính config.<p>

Setup đường power M5
>=============================================<p>
> CREATE M5 POWER MESH 20%<p>
>=============================================<p>
>set   width    [expr 4.5]<p>
>set   spacing  [expr 0.5]<p>
>addStripe \<p>
>-nets                            {VDD VSS} \<p>
>-layer                           M5 \<p>
>-direction                       Vertical \<p>
>-width                           $width \<p>
>-spacing                         $spacing \<p>
>-stacked_via_top_layer           M6 \<p>
>-stacked_via_bottom_layer        M4 \<p>
>-create_pins                     1 \<p>
>-start_offset                    0 \<p>
>-set_to_set_distance             30 \<p>
>-extend_to                       design_boundary<p>

Hình ảnh cho layer M5:<p>
<img src="./img/img_0615_LayerM5.png"> <p>

### Phương pháp giải quyết 

Trong innovusTCR có function createPinBlk tạo các block không cho pin đặt vào, dựa vào tính năng này ta kết hợp dbShape để vẻ vỏ bọc cho power mesh M5 và ta chọn lại vị trí rãi pin, khi tool rãi nó tự né khu vực powermesh này <p>
<img src="./img/img_0615_LayerM5_BlkPin.png"> <p>

>proc is_createPinBlkPower {} {<p>
>    foreach a [dbShape [dbget [dbget top.pgNets.sWires.layer.name -regexp M5 -p2].box] SIZEX 0.5] {<p>
>        echo "createPinBlkg -area {$a} -cell [dbget top.name] -layer {M5}" >> ./gen_script_fp/testBlkPin.tcl <p> 
>    }<p>
>}<p>

Giải thích lệnh: <p>




