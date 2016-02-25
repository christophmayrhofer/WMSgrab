pi := 3.14159265358979
const := 20037508.34

Gosub, GUICreate
return

GUICreate:
Gui, Add, Edit, vullon x10 y40 w80 h20, Left Longitude
Gui, Add, Edit, vlrlon x100 y40 w80 h20, Right Longitude
Gui, Add, Edit, vullat x50 y10 w80 h20, Upper Latitude
Gui, Add, Edit, vlrlat x50 y70 w80 h20, Lower Latitude

Gui, Add, Radio, vsat x10 y110 w80 h20 Checked, SAT
Gui, Add, Radio, vmap x10 y135 w80 h20 , MAP
Gui, Add, Radio, vhyb x10 y160 w80 h20 , HYBRID
Gui, Add, Radio, vair x10 y185 w80 h20 , AIR

Gui, Add, Edit, vres x100 y110 w40 h20 , 1
Gui, Add, Text, x140 y115 w50 h20 , Res. (m)
Gui, Add, DropDownList, vformat x100 y135 w45 Choose1, JPG|PNG|BMP|GIF|ECW|IMG|ENVI|GeoTiff
Gui, Add, Text, x145 y140 w35 h20 , Format
Gui, Add, Button, x100 y165 w80 h20 , OK
Gui, Add, Button, x100 y185 w80 h20 , Cancel
Gui, Show, h210 w190, WMSgrab
Exit

GUIReload:
GuiControl,,ullon, %ullon%
GuiControl,,lrlon, %lrlon%
GuiControl,,ullat, %ullat%
GuiControl,,lrlat, %lrlat%
GuiControl,,res, %res%
GuiControl,Choose,format,%format%
if sat
	GuiControl,,sat,1
else if map
	GuiControl,,map,1
else if hyb
	GuiControl,,hyb,1
else if air
	GuiControl,,air,1

Gui, Show,h210 w190, WMSgrab
Exit

GuiClose:
ButtonCancel:
ExitApp
return

ButtonOK:
Gui, Submit
if ullon not between -180 and 180
{
	MsgBox, Check Coordinates (Left Longitude)
	Gosub, GUIReload
}
if lrlon not between -180 and 180
{
	MsgBox, Check Coordinates (Right Longitude)
	Gosub, GUIReload
}
if ullat not between -90 and 90
{
	MsgBox, Check Coordinates (Upper Latitude)
	Gosub, GUIReload
}
if lrlat not between -90 and 90
{
	MsgBox, Check Coordinates (Lower Latitude)
	Gosub, GUIReload
}
IfGreaterOrEqual, ullon, %lrlon%
{
	MsgBox, Check Coordinates (Longitudes)
	Gosub, GUIReload
}
IfLessOrEqual, ullat, %lrlat%
{
	MsgBox, Check Coordinates (Latitudes)
	Gosub, GUIReload
} 

if map 
xml = map.xml
else if sat 
xml = sat.xml
else if hyb 
xml = hyb.xml
else if air
xml = air.xml

if format = 1
{
	format = jpg
	outf = -of JPEG -co worldfile=YES
}
else if format = 2
{
	format = png
	outf = -of PNG -co worldfile=YES
}
else if format = 3
{
	format = bmp
	outf = -of BMP -co worldfile=YES
}
else if format = 4
{
	format = gif
	outf = -of GIF -co worldfile=YES
}
else if format = 5
{
	format = ecw
	outf = -of ECW -co LARGE_OK=YES
}
else if format = 6
{
	format = img
	outf = -of IMG
}
else if format = 7
{
	format = envi
	outf = -of ENVI
}
else if format = 8
{
	format = tif
	outf = -of GTiff
}


FileSelectFile, file, S16,, Save As, *.%format%
if file =
{
	MsgBox, Please select a file destination.
	Gosub, GUIReload
}

Gosub, transform
Gosub, download
ExitApp

transform:
ullatphi := Ln(Tan((90+ullat)*pi/360))/(pi/180)
lrlatphi := Ln(Tan((90+lrlat)*pi/360))/(pi/180)

ulx := ullon * const / 180
uly := ullatphi * const / 180
lrx := lrlon * const / 180
lry := lrlatphi * const / 180

diffx := Floor(Abs(ulx - lrx))
diffy := Floor(Abs(uly - lry))
x := diffx/res
y := diffy/res
return

download:
FileDelete, run.bat
FileAppend,
(
@echo off
SET GDAL_DATA=GDAL\gdal-data
SET GDAL_DRIVER_PATH=GDAL\gdalplugins
SET PROJ_LIB=GDAL\projlib
SET PYTHONPATH=GDAL\python

GDAL\gdal_translate %xml% %file%.%format% %outf% -outsize %x% %y% -projwin %ulx% %uly% %lrx% %lry%

pause
), run.bat
RunWait, run.bat
FileDelete, run.bat
FileRemoveDir, gdalwmscache,1
return