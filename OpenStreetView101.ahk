fVersion = 1.1
#MaxMem, 256
LoadMapPosX := 0
LoadMapPosY := 0
MapZoom := 0
Loading := 0
MouseOver := 0

INIRead, ScreenshootDir, settings.ini, Screenshoot, Path
INIRead, ScreenshootFormat, settings.ini, Screenshoot, Format, BMP
INIRead, Screenshoot_compass, settings.ini, Screenshoot, Compass, 1
INIRead, Screenshoot_show, settings.ini, Screenshoot, Show, 1

INIRead, TextureMem, settings.ini, System, TexMem, 128
INIRead, TextureFilter, settings.ini, System, TexFilter, 1

INIRead, Print_compass, settings.ini, Print, Compass

INIRead, INI_StartPosType, settings.ini, Startup, StartPosType, 1
INIRead, INI_LastPosX, settings.ini, Startup, LastPosX, 0
INIRead, INI_LastPosY, settings.ini, Startup, LastPosY, 0
INIRead, INI_LastZoom, settings.ini, Startup, LastZoom, 0
if (INI_StartPosType = 2)
{
  LoadMapPosX := INI_LastPosX
  LoadMapPosY := INI_LastPosY
  MapZoom := INI_LastZoom
}
INIRead, INI_UsePosX, settings.ini, Startup, UsePosX, 0
INIRead, INI_UsePosY, settings.ini, Startup, UsePosY, f0
INIRead, INI_UseZoom, settings.ini, Startup, UseZoom, 0
if (INI_StartPosType = 3)
{
  LoadMapPosX := INI_UsePosX
  LoadMapPosY := INI_UsePosY
  MapZoom := INI_UseZoom
}

MapPosX := LonMapToOpenGL(LoadMapPosX)
MapPosY := LatMapToOpenGL(LoadMapPosY)
hOpenGL32 := DllCall("LoadLibrary", "Str", "opengl32")
Gui, +LastFound +Resize
Gui, +OwnDialogs
hGui := WinExist()
hDC := DllCall("GetDC", "uInt", WinExist())
Hotkey, IfWinActive, % "ahk_id " WinExist()
Hotkey, WheelUp, WheelUp
Hotkey, IfWinActive, % "ahk_id " WinExist()
Hotkey, WheelDown, WheelDown

VarSetCapacity(pfd, 40, 0)
NumPut(40, pfd, 0, "uShort")
NumPut(1, pfd, 2, "uShort")
NumPut(37, pfd, 4, "uInt")
NumPut(24, pfd, 9, "uChar")
NumPut(16, pfd, 23, "uChar")
DllCall("SetPixelFormat", "uInt", hDC, "uInt", DllCall("ChoosePixelFormat", "uInt", hDC, "uInt", &pfd), "uInt", &pfd)

hRC := DllCall("opengl32\wglCreateContext", "uInt", hDC)
DllCall("opengl32\wglMakeCurrent", "uInt", hDC, "uInt", hRC)
DllCall("opengl32\glEnable", "uint", 0x0DE1)
DllCall("opengl32\glShadeModel", "uInt", 0x1D01) ;GL_SMOOTH



Gui, 2:+Owner1 -MaximizeBox -MinimizeBox
Gui, 2:add, Groupbox, x10 y10 w330 h80, Koordinaten
Gui, 2:add, text, xp+10 yp+30 w150, Breitengrad (Lon):
Gui, 2:add, text, x+10 yp wp, Längengrad (Lat):
Gui, 2:add, edit, xp-160 y+5 wp v2Lon
Gui, 2:add, edit, x+10 yp wp v2Lat
Gui, 2:add, Groupbox, x10 y100 w330 h90, Zoom
Gui, 2:add, text, xp+10 yp+30 w150, Zoomfaktor:
Gui, 2:add, slider, xp y+5 w200 range0-18 g2Slider v2Slider, 0
Gui, 2:add, edit, x+10 yp w100 +ReadOnly v2SliderEdit, x1
Gui, 2:add, button, x240 y200 w100 g2Ok +Default, Los!

Gui, 4:+Owner1 -MaximizeBox -MinimizeBox
Gui, 4:add, pic, x10 y10 w64 h64 +Altsubmit, tex\icon.png
Gui, 4:add, text, x84 y10 w226, OpenStreetMap Viewer`nVersion %Version%
Gui, 4:add, text, x10 y90 w150 +right, Programmcode
Gui, 4:add, text, xp y+5 wp +right, Kartenmaterial
Gui, 4:add, text, xp y+5 wp +right, Icons
Gui, 4:add, text, xp y+5 wp
Gui, 4:add, text, xp y+10 wp +right, Creative Common 2.5
Gui, 4:font, underline cBlue
Gui, 4:add, text, x170 y90 w150 gLinkAHK, Bentschi (AutoHotkey Forum)
Gui, 4:add, text, x170 y+5 w150 gLinkOSM, www.openstreetmap.org
Gui, 4:add, text, x170 y+5 w150 gLinkFAM, www.famfamfam.com
Gui, 4:add, text, x170 y+5 w150 gLinkCP, www.everaldo.com/crystal
Gui, 4:add, text, x170 y+10 w150 gLinkCC, www.creativecommons.org
Gui, 4:font
Gui, 4:font, underline
Gui, 4:add, text, x10 y+20 w310, Besonderer Dank geht an:
Gui, 4:font
Gui, 4:add, text, xp y+5 wp,
(Join%A_Space%
micld
und
Z_Gecko
)
Gui, 4:add, text, x10 y+30 wp, 
(Join%A_Space%
Dieser Programmcode ist linzensiert unter "Creative Common 2.5"
(www.creativecommons.org), alle weiteren Linzenzen und Informationen
können unter dem jeweiligen Link nachgeschlagen werden.
)

Gui, Show, w640 h480, OpenStreetMap Viewer (v %Version%)

earth := LoadTexture(DownloadTile(0, 0, 0))
hud_font := LoadTexture("tex\hud_font.png")
hud_compass := LoadTexture("tex\compass.png")
hud_img := LoadTexture("hud_img.png")
hud_zoom_in := LoadTexture("icon\zoom_in.png")
hud_zoom_out := LoadTexture("icon\zoom_out.png")
hud_world_go := LoadTexture("icon\world_go.png")
hud_page_copy := LoadTexture("icon\page_copy.png")
hud_camera := LoadTexture("icon\camera.png")
hud_printer := LoadTexture("icon\printer.png")
hud_wrench := LoadTexture("icon\wrench.png")
hud_information := LoadTexture("icon\information.png")
hud_help := LoadTexture("icon\help.png")

OnExit, ExitSub
SetTimer, Paint, 50
SetTimer, Loader, 1
OnMessage(0x200, "WM_MOUSEMOVE")
OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x202, "WM_LBUTTONUP")
return


SettingsWindow:
Gui, 3:+Owner1 -MaximizeBox -MinimizeBox
Gui, 3:add, button, x240 y270 w90 g3ok, Ok
Gui, 3:add, button, x+0 yp wp g3cancel, Abbrechen
Gui, 3:add, button, x+0 yp wp g3apply, Übernehmen

Gui, 3:add, tab, x10 y10 w500 h250, Start|Screenshoots|Drucken|Speicher && Leistung
Gui, 3:add, Groupbox, x20 y50 w480 h140, Kartenpostion beim Starten
Gui, 3:add, Radio, x40 y70 w200 g3RadioStartMap v3RadioStartMap1, Ganze Karte zeigen
Gui, 3:add, Radio, xp y+5 wp g3RadioStartMap v3RadioStartMap2, Letzte Position wiederherstellen
Gui, 3:add, Radio, xp y+5 wp g3RadioStartMap v3RadioStartMap3, Koordinaten verwenden
Gui, 3:add, edit, xp+20 y+5 w80 +right v3StartMapX, 0.000000
Gui, 3:add, text, x+5 yp hp +0x200 v3StartMapXtext, °E (lon)
Gui, 3:add, edit, x+20 yp w80 +right v3StartMapY, 0.000000
Gui, 3:add, text, x+5 yp hp +0x200 v3StartMapYtext, °N (lat)
Gui, 3:add, edit, x+20 yp w50 +right v3StartMapZedit
Gui, 3:add, updown, range0-18 v3StartMapZ, 0
Gui, 3:add, text, x+5 yp hp +0x200 v3StartMapZtext, Zoomlevel
Gui, 3:add, button, x60 y+5 v3StartMapUse g3SartMapUse, Aktuelle Koordinaten
Gui, 3:add, button, x+5 yp v3StartMapReset g3SartMapReset, Zurücksetzen
GuiControl, 3:, 3StartMapX, % INI_UsePosX
GuiControl, 3:, 3StartMapY, % INI_UsePosY
GuiControl, 3:, 3StartMapZ, % INI_UseZoom
GuiControl, 3:, 3RadioStartMap%INI_StartPosType%, 1
Gosub, 3RadioStartMap

Gui, 3:tab, 2
Gui, 3:add, Groupbox, x20 y50 w480 h90, Screenshoots speichern unter
Gui, 3:add, edit, x40 y70 w380 v3ScreenshootPath, % ScreenshootDir
Gui, 3:add, button, x+0 yp w60 hp g3SearchScreenshootPath, Suchen
Gui, 3:add, text, x40 y+5 hp +0x200, Format:
Gui, 3:add, ddl, x+10 yp w200 v3ScreenshootFormat +AltSubmit,
(Join|
BMP - Windows Bitmap
GIF - Compuserve GIF
JPG - JPG/JPEG format
PNG - Portable Network Graphics
)
Gui, 3:add, Groupbox, x20 y150 w480 h70, Screenshoot Extras
Gui, 3:add, checkbox, % "x40 yp+20 v3ScreenshootCompass" ((Screenshoot_compass) ? " +checked" : ""), Kompass auf Screenshoot zeichnen
Gui, 3:add, checkbox, % "xp y+5 v3ScreenshootShow" ((Screenshoot_show) ? " +checked" : ""), Nach speichern Pfad öffnen
ScreenshootFormatBMP := 1
ScreenshootFormatGIF := 2
ScreenshootFormatJPG := 3
ScreenshootFormatPNG := 4
GuiControl, 3:choose, 3ScreenshootFormat, % ScreenshootFormat%ScreenshootFormat%

Gui, 3:tab, 3
Gui, 3:add, Groupbox, x20 y50 w480 h50, Druck-Extras
Gui, 3:add, checkbox, % "x40 yp+20 v3PrintCompass" ((Print_compass) ? " +checked" : ""), Kompass auf Ausdruck zeichnen

Gui, 3:tab, 4
Gui, 3:add, Groupbox, x20 y50 w480 h80, Grafikeinstellungen
Gui, 3:add, text, x40 yp+23 w200 +right, Maximal verwendeter Texturenspeicher
Gui, 3:add, ddl, x+10 yp-3 w200 v3GraphicMemory +AltSubmit, 32 MB|64 MB|128 MB|256 MB|512 MB
GuiControl, 3:choose, 3GraphicMemory, % TextureMem " MB"
Gui, 3:add, text, x40 y+8 w200 +right, Texturfilter
Gui, 3:add, ddl, x+10 yp-3 w200 v3TextureFilter +AltSubmit, Nearest (schneller)|Linear (schöner)
GuiControl, 3:choose, 3TextureFilter, % TextureFilter+1

Gui, 3:show,, Einstellungen
return


3SearchScreenshootPath:
GuiControlGet, 3ScreenshootPath
FileSelectFolder, 3SearchScreenshootPath, % "*" 3ScreenshootPath, 3, Wähle einen Pfad
GuiControl,, 3ScreenshootPath, % 3SearchScreenshootPath
return

3ok:
Gui, 3:hide
3apply:
Gui, 3:Submit, % ((A_ThisLabel="3apply") ? "NoHide" : "")
if (A_ThisLabel="3ok")
  Gui, 3:Destroy
if (3RadioStartMap3)
{
  StringReplace, 3StartMapX, 3StartMapX, `,, ., 1
  StringReplace, 3StartMapY, 3StartMapY, `,, ., 1
  INIWrite, % 3StartMapX, settings.ini, Startup, UsePosX
  INIWrite, % 3StartMapY, settings.ini, Startup, UsePosY
  INIWrite, % 3StartMapZ, settings.ini, Startup, UseZoom
  INIWrite, 3, settings.ini, Startup, StartPosType
}
else if (3RadioStartMap2)
  INIWrite, 2, settings.ini, Startup, StartPosType
else if (3RadioStartMap1)
  INIWrite, 1, settings.ini, Startup, StartPosType
ScreenshootPath := 3ScreenshootPath
INIWrite, % 3ScreenshootPath, settings.ini, Screenshoot, Path
ScreenshootFormat1 := "BMP"
ScreenshootFormat2 := "GIF"
ScreenshootFormat3 := "JPG"
ScreenshootFormat4 := "PNG"
INIWrite, % ScreenshootFormat%3ScreenshootFormat%, settings.ini, Screenshoot, Format
INIWrite, % 3ScreenshootCompass, settings.ini, Screenshoot, Compass
INIWrite, % 3ScreenshootShow, settings.ini, Screenshoot, Show
INIWrite, % 3PrintCompass, settings.ini, Print, Compass
INIWrite, % (2**3GraphicMemory)*16, settings.ini, System, TexMem
INIWrite, % 3TextureFilter-1, settings.ini, System, TexFilter
ScreenshootDir := 3ScreenshootPath
ScreenshootFormat := ScreenshootFormat%3ScreenshootFormat%
Screenshoot_compass := 3ScreenshootCompass
Screenshoot_show := 3ScreenshootShow
Print_compass := 3PrintCompass
TextureMem := (2**3GraphicMemory)*16
if (TextureFilter != 3TextureFilter-1)
{
  MsgBox, 52, Achtung!, Das ändern des Texturfilters erfordert`neinen Neustart des Programmes`nNeu starten?
  IfMsgBox, Yes
    Reload
}
TextureFilter := 3TextureFilter-1
return

LinkAHK:
Run, http://de.autohotkey.com/forum/viewtopic.php?t=7569
return

LinkOSM:
Run, http://www.openstreetmap.org/
return

LinkFAM:
Run, http://www.famfamfam.com/lab/icons/silk/
return

LinkCP:
Run, http://www.everaldo.com/crystal/
return

LinkCC:
Run, http://creativecommons.org/licenses/by/2.5/
return

3cancel:
3GuiClose:
Gui, 3:Destroy
return

3SartMapReset:
GuiControl,, 3StartMapX, 0.000000
GuiControl,, 3StartMapY, 0.000000
GuiControl,, 3StartMapZ, 0
return

3SartMapUse:
GuiControl,, 3StartMapX, % Lon
GuiControl,, 3StartMapY, % Lat
GuiControl,, 3StartMapZ, % MapZoom
return

3RadioStartMap:
GuiControlGet, 3RadioStartMap3, 3:
if (3RadioStartMap3)
  gosub, 3RadioStartMapEnable
else
  gosub, 3RadioStartMapDisable
return

3RadioStartMapEnable:
GuiControl, 3:Enable, 3StartMapX
GuiControl, 3:Enable, 3StartMapY
GuiControl, 3:Enable, 3StartMapZ
GuiControl, 3:Enable, 3StartMapZedit
GuiControl, 3:Enable, 3StartMapuse
GuiControl, 3:Enable, 3StartMapreset
Gui, 3:font
GuiControl, 3:font, 3StartMapXtext
GuiControl, 3:font, 3StartMapYtext
GuiControl, 3:font, 3StartMapZtext
return

3RadioStartMapDisable:
GuiControl, 3:Disable, 3StartMapX
GuiControl, 3:Disable, 3StartMapY
GuiControl, 3:Disable, 3StartMapZ
GuiControl, 3:Disable, 3StartMapZedit
GuiControl, 3:Disable, 3StartMapuse
GuiControl, 3:Disable, 3StartMapreset
Gui, 3:font, cgray
GuiControl, 3:font, 3StartMapXtext
GuiControl, 3:font, 3StartMapYtext
GuiControl, 3:font, 3StartMapZtext
Gui, 3:font
return

2Slider:
GuiControlGet, 2Slider
GuiControl,, 2SliderEdit, % "x" 2**2Slider " (" 2Slider ")"
return

2GuiClose:
Gui, 2:hide
Gui, 1:-Disable
return

2Ok:
GuiControlGet, 2Lat
GuiControlGet, 2Lon
GuiControlGet, MapZoom,, 2Slider
StringReplace, 2Lat, 2Lat, `,, ., 1
StringReplace, 2Lon, 2Lon, `,, ., 1
MapPosX := LonMapToOpenGL(2Lon)
MapPosY := LatMapToOpenGL(2Lat)
CalcMapTile()
Gui, 2:hide
Gui, 1:-Disable
return

WheelUp:
MapZoom+=1
if (MapZoom>18)
  MapZoom := 18
CalcMapTile()
return

WheelDown:
MapZoom-=1
if (MapZoom<0)
  MapZoom := 0
CalcMapTile()
return

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd)
{
  global
  if (hwnd!=hGui)
  {
    SendMessage, msg, wParam, lParam,, ahk_id %hWnd%
    return 0
  }
  if ((WhileCopyCoord) && (CursorLon) && (CursorLat))
  {
    WhileCopyCoord := 0
    write_to_clipboard := CursorLon "°E`n" CursorLat "°N"
    clipboard := write_to_clipboard
    MsgBox, 64, Kopieren erfolgreich!, % "Die Koordinaten:`n" clipboard "`nwurden erfolgreich in die`nZwischenablage kopiert."
    return 1
  }
  MouseX := -(ScreenW/2)+(lParam & 0xFFFF)
  MouseY := -(ScreenH/2)+(lParam >> 16)
  if ((MouseY > (ScreenH/2)-22) && (MouseX > -105) && (MouseX < 105))
  {
    if ((MouseX > -105) && (MouseX < -85))
      Gosub, WheelUp
    else if ((MouseX > -85) && (MouseX < -65))
      Gosub, WheelDown
    else if ((MouseX > -55) && (MouseX < -35))
    {
      GuiControl, 2:, 2Lon, % Lon
      GuiControl, 2:, 2Lat, % Lat
      GuiControl, 2:, 2Slider, % MapZoom
      GuiControl, 2:, 2SliderEdit, % "x" 2**MapZoom " (" MapZoom ")"
      Gui, 2:Show,, Gehe zu...
      Gui, 1:+Disable
    }
    else if ((MouseX > -35) && (MouseX < -15))
      WhileCopyCoord := 1
    else if ((MouseX > -5) && (MouseX < 15))
      WhileMakeScreenshoot := 1
    else if ((MouseX > 15) && (MouseX < 35))
      WhileMakeScreenshoot := 2
    else if ((MouseX > 45) && (MouseX < 65))
      Gosub, SettingsWindow
    else if ((MouseX > 65) && (MouseX < 85))
      Gui, 4:Show,, OpenStreetMap Viewer (v %Version%)
    ;else if ((MouseX > 85) && (MouseX < 105))
    return 1
  }
  BeginDragX := MapPosX - ((lParam & 0xFFFF)/(2**MapZoom))
  BeginDragY := MapPosY - ((lParam >> 16)/(2**MapZoom))
  WhileDrag := 1
  VarSetCapacity(rect, 16, 0)
  DllCall("ClientToScreen", "uint", hGui, "uint", &rect)
  NumPut(NumGet(rect, 0)+ScreenW, rect, 8)
  NumPut(NumGet(rect, 4)+ScreenH, rect, 12)
  DllCall("ClipCursor", "uint", &rect)
  return 1
}

WM_MOUSEMOVE(wParam, lParam, msg, hwnd)
{
  global
  if (hwnd != hGui)
  {
    SendMessage, msg, wParam, lParam,, ahk_id %hWnd%
    CoordX =
    CoordY =
    return 0 
  }
  MouseX := -(ScreenW/2)+(lParam & 0xFFFF)
  MouseY := -(ScreenH/2)+(lParam >> 16)
  if (WhileDrag)
  {
    MapPosX := BeginDragX-((-(lParam & 0xFFFF))/(2**MapZoom))
    MapPosY := BeginDragY-((-(lParam >> 16))/(2**MapZoom))
    if (MapPosX > 128)
      MapPosX := 128
    if (MapPosX < -128)
      MapPosX := -128
    if (MapPosY > 128)
      MapPosY := 128
    if (MapPosY < -128)
      MapPosY := -128
    CalcMapTile()
  }
  else if ((MouseY > (ScreenH/2)-22) && (MouseX > -105) && (MouseX < 105))
  {
    if ((MouseX > -105) && (MouseX < -85))
    {
      MouseOver := -105
      HelpText := "Zoom In"
    }
    else if ((MouseX > -85) && (MouseX < -65))
    {
      MouseOver := -85
      HelpText := "Zoom Out"
    }
    else if ((MouseX > -55) && (MouseX < -35))
    {
      MouseOver := -55
      HelpText := "Go to ..."
    }
    else if ((MouseX > -35) && (MouseX < -15))
    {
      MouseOver := -35
      HelpText := "Copy coordinates"
    }
    else if ((MouseX > -5) && (MouseX < 15))
    {
      MouseOver := -5
      HelpText := "Make a screenshoot"
    }
    else if ((MouseX > 15) && (MouseX < 35))
    {
      MouseOver := 15
      HelpText := "Print"
    }
    else if ((MouseX > 45) && (MouseX < 65))
    {
      MouseOver := 45
      HelpText := "Settings"
    }
    else if ((MouseX > 65) && (MouseX < 85))
    {
      MouseOver := 65
      HelpText := "About"
    }
    else if ((MouseX > 85) && (MouseX < 105))
    {
      MouseOver := 85
      HelpText := "Help (Comming soon...)"
    }
    else
      MouseOver := 0
  }
  else
  {
    MouseOver := 0
  }
  CursorLon := LonOpenGLToMap(MapPosX-((((lParam&0xFFFF)/(ScreenW/2))-1)*(ScreenW/2)/(2**MapZoom)))
  CursorLat := LatOpenGLToMap(MapPosY-((((lParam>>16)/(ScreenH/2))-1)*(ScreenH/2)/(2**MapZoom)))
  Lon := LonOpenGLToMap(MapPosX)
  Lat := LatOpenGLToMap(MapPosY)
  return 1
}

WM_LBUTTONUP(wParam, lParam, msg, hwnd)
{
  global
  if (hwnd!=hGui)
  {
    SendMessage, msg, wParam, lParam,, ahk_id %hWnd%
    return 0
  }
  WhileDrag := 0
  DllCall("ClipCursor", "uint", 0)
  return 1
}

CalcMapTile()
{
  global
  MapChanged := 1
  MapTileX := Floor((((Screenw/2)-((MapPosX-128)*(2**MapZoom)))-ScreenW)/256)
  MapTileY := Floor((((ScreenH/2)-((MapPosY-128)*(2**MapZoom)))-ScreenH)/256)
}

Paint:
DllCall("opengl32\glClear", "uInt", 0x4100) ;GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
DllCall("opengl32\glLoadIdentity")
DllCall("opengl32\glScalef", "float", 2**(MapZoom), "float", 2**(MapZoom), "float", 1)
DllCall("opengl32\glTranslatef", "float", MapPosX, "float", MapPosY, "float", 0)
DrawTile(-128, -128, earth)
RoundMapZoom := Round(MapZoom)
if (RoundMapZoom>0)
{
  DllCall("opengl32\glScalef", "float", 1/(2**MapZoom), "float", 1/(2**MapZoom), "float", 1)
  map_begin_x := -(((2**MapZoom)/2)*256)+(MapTileX*256)
  map_begin_y := -(((2**MapZoom)/2)*256)+(MapTileY*256)
  Loop, % VisibleTilesX
  {
    if (A_Index-1+MapTileX<0)
      Continue
    if (A_Index+MapTileX>2**MapZoom)
      Continue
    loop_x := A_Index
    Loop, % VisibleTilesY
    {
      if (A_Index-1+MapTileY<0)
        Continue
      if (A_Index+MapTileY>2**MapZoom)
        Continue
      thisTileX := loop_x-1+MapTileX
      thisTileY := A_Index-1+MapTileY
      if (Tile_%thisTileX%_%thisTileY%_%RoundMapZoom%)
        DrawTile(map_begin_x+((loop_x-1)*256), map_begin_y+((A_Index-1)*256), Tile_%thisTileX%_%thisTileY%_%RoundMapZoom%)
    }
  }
}
DllCall("opengl32\glLoadIdentity")
DllCall("opengl32\glEnable", "uint", 0x0BE2)


If ((WhileMakeScreenshoot>0) && (WhileMakeScreenshoot<16))
{
  if (((Screenshoot_compass) && (WhileMakeScreenshoot=1)) || ((Print_compass) && (WhileMakeScreenshoot=2)))
  {
    DllCall("opengl32\glBindTexture", "uint", 0x0DE1, "uint", hud_compass)
    DllCall("opengl32\glBegin", "uint", 0x0007)
    DllCall("opengl32\glTexCoord2f", "float", 0, "float", 1)
    DllCall("opengl32\glVertex2f", "float", -(ScreenW/2-16), "float", -(ScreenH/2-16))
    DllCall("opengl32\glTexCoord2f", "float", 1, "float", 1)
    DllCall("opengl32\glVertex2f", "float", -((ScreenW/2-16)-128), "float", -(ScreenH/2-16))
    DllCall("opengl32\glTexCoord2f", "float", 1, "float", 0)
    DllCall("opengl32\glVertex2f", "float", -((ScreenW/2-16)-128), "float", -((ScreenH/2-16)-128))
    DllCall("opengl32\glTexCoord2f", "float", 0, "float", 0)
    DllCall("opengl32\glVertex2f", "float", -(ScreenW/2-16), "float", -((ScreenH/2-16)-128))
    DllCall("opengl32\glEnd")
  }
  DllCall("opengl32\glFlush")
  
  hDC_tmp := DllCall("CreateCompatibleDC", "uint", hDC)
  VarSetCapacity(bmi, 40, 0)
  NumPut(40, bmi, 0, "uInt")      ;biSize
  NumPut(ScreenW, bmi, 4, "Int")  ;biWidth
  NumPut(ScreenH, bmi, 8, "Int")  ;biHeight
  NumPut(1, bmi, 12, "uShort")    ;biPlanes
  NumPut(24, bmi, 14, "uShort")   ;biBitCount
  hBM := DllCall("CreateDIBSection", "uInt", hDC_tmp, "uInt", &bmi, "uInt", 0, "uIntP", diBits, "uInt", 0, "uInt", 0)
  DllCall("opengl32\glReadPixels", "int", 0, "int", 0, "int", ScreenW, "int", ScreenH, "uint", 0x80E0, "uint", 0x1401, "uint", diBits)

  SetTimer, SaveScreenshoot, -1
  return
}
DllCall("opengl32\glEnable", "uint", 0x0BE2)
DllCall("opengl32\glBlendFunc", "uint", 0x0302, "uint", 0x0303)
DllCall("opengl32\glBindTexture", "uint", 0x0DE1, "uint", hud_font)
if (Loading)
{
  DllCall("opengl32\glTranslatef", "float", -ScreenW/2, "float", ScreenH/2-16, "float", 0)
  DrawText("Loading...")
  DllCall("opengl32\glLoadIdentity")
}
if (CursorLat!="")
{
  TextLen := (StrLen(CursorLat "°N")-1)*9+16
  TextPosX := MouseX - (TextLen/2)
  if (TextPosX<(-ScreenW/2))
    TextPosX := (-ScreenW/2)
  if (TextPosX>(ScreenW/2)-(16+TextLen))
    TextPosX := (ScreenW/2)-(16+TextLen)
  DllCall("opengl32\glTranslatef", "float", Round(TextPosX), "float", -ScreenH/2, "float", 0)
  DrawText(CursorLat "°N")
  DllCall("opengl32\glLoadIdentity")
}
if (CursorLon!="")
{
  TextLen := (StrLen(CursorLon "°E")-1)*9+16
  TextPosY := MouseY + (TextLen/2)
  if (TextPosY<(-ScreenH/2)+(16+TextLen))
    TextPosY := (-ScreenH/2)+(16+TextLen)
  if (TextPosY>(ScreenH/2))
    TextPosY := (ScreenH/2)
  DllCall("opengl32\glTranslatef", "float", ScreenW/2-16, "float", Round(TextPosY), "float", 0)
  DllCall("opengl32\glRotatef", "float", -90, "float", 0, "float", 0, "float", 1)
  DrawText(CursorLon "°E")
  DllCall("opengl32\glLoadIdentity")
}
if (WhileCopyCoord)
{
  DllCall("opengl32\glTranslatef", "float", -ScreenW/2+48, "float", -ScreenH/2+48, "float", 0)
  DrawText("Klicke auf einen Teil der Map,")
  DllCall("opengl32\glLoadIdentity")
  DllCall("opengl32\glTranslatef", "float", -ScreenW/2+48, "float", -ScreenH/2+64, "float", 0)
  DrawText("um die Koordinaten an diesem Punkt")
  DllCall("opengl32\glLoadIdentity")
  DllCall("opengl32\glTranslatef", "float", -ScreenW/2+48, "float", -ScreenH/2+80, "float", 0)
  DrawText("zu Kopieren.")
  DllCall("opengl32\glLoadIdentity")
}
else
{
  DllCall("opengl32\glDisable", "uint", 0x0DE1)
  DllCall("opengl32\glColor4f", "float", 0.9, "float", 0.9, "float", 0.9, "float", 0.7)

  DllCall("opengl32\glBegin", "uint", 0x0007)
  DllCall("opengl32\glVertex2f", "float", -110, "float", ScreenH/2-20)
  DllCall("opengl32\glVertex2f", "float", 110, "float", ScreenH/2-20)
  DllCall("opengl32\glVertex2f", "float", 110, "float", ScreenH/2)
  DllCall("opengl32\glVertex2f", "float", -110, "float", ScreenH/2)
  DllCall("opengl32\glVertex2f", "float", -110, "float", ScreenH/2-20)
  DllCall("opengl32\glVertex2f", "float", -106, "float", ScreenH/2-24)
  DllCall("opengl32\glVertex2f", "float", 106, "float", ScreenH/2-24)
  DllCall("opengl32\glVertex2f", "float", 110, "float", ScreenH/2-20)
  DllCall("opengl32\glEnd")

  DllCall("opengl32\glColor3f", "float", 0.5, "float", 0.5, "float", 0.5)

  DllCall("opengl32\glBegin", "uint", 0x0003)
  DllCall("opengl32\glVertex2f", "float", -110, "float", ScreenH/2)
  DllCall("opengl32\glVertex2f", "float", -110, "float", ScreenH/2-20)
  DllCall("opengl32\glVertex2f", "float", -106, "float", ScreenH/2-24)
  DllCall("opengl32\glVertex2f", "float", 106, "float", ScreenH/2-24)
  DllCall("opengl32\glVertex2f", "float", 110, "float", ScreenH/2-20)
  DllCall("opengl32\glVertex2f", "float", 110, "float", ScreenH/2)
  DllCall("opengl32\glEnd")

  if (MouseOver != 0)
  {
    DllCall("opengl32\glDisable", "uint", 0x0DE1)

    DllCall("opengl32\glColor3f", "float", 0.7, "float", 0.7, "float", 1)
    DllCall("opengl32\glBegin", "uint", 0x0007)
    DllCall("opengl32\glVertex2f", "float", MouseOver, "float", ScreenH/2-22)
    DllCall("opengl32\glVertex2f", "float", MouseOver+20, "float", ScreenH/2-22)
    DllCall("opengl32\glVertex2f", "float", MouseOver+20, "float", ScreenH/2-2)
    DllCall("opengl32\glVertex2f", "float", MouseOver, "float", ScreenH/2-2)
    DllCall("opengl32\glEnd")

    DllCall("opengl32\glColor3f", "float", 0.2, "float", 0.2, "float", 0.8)
    DllCall("opengl32\glBegin", "uint", 0x0002)
    DllCall("opengl32\glVertex2f", "float", MouseOver, "float", ScreenH/2-22)
    DllCall("opengl32\glVertex2f", "float", MouseOver+20, "float", ScreenH/2-22)
    DllCall("opengl32\glVertex2f", "float", MouseOver+20, "float", ScreenH/2-2)
    DllCall("opengl32\glVertex2f", "float", MouseOver, "float", ScreenH/2-2)
    DllCall("opengl32\glEnd")

    DllCall("opengl32\glEnable", "uint", 0x0DE1)
    DllCall("opengl32\glColor3f", "float", 1, "float", 1, "float", 1)

    DllCall("opengl32\glTranslatef", "float", Round(MouseOver+8-((Strlen(HelpText)-1)*9+16)/2), "float", ScreenH/2-40, "float", 0)
    DllCall("opengl32\glBindTexture", "uint", 0x0DE1, "uint", hud_font)
    DrawText(HelpText)
    DllCall("opengl32\glLoadIdentity")
  }

  DllCall("opengl32\glColor3f", "float", 1, "float", 1, "float", 1)
  DllCall("opengl32\glEnable", "uint", 0x0DE1)

  DrawIcon(-103, ScreenH/2-20, hud_zoom_in)
  DrawIcon(-83, ScreenH/2-20, hud_zoom_out)
  DrawIcon(-53, ScreenH/2-20, hud_world_go)
  DrawIcon(-33, ScreenH/2-20, hud_page_copy)
  DrawIcon(-3, ScreenH/2-20, hud_camera)
  DrawIcon(17, ScreenH/2-20, hud_printer)
  DrawIcon(47, ScreenH/2-20, hud_wrench)
  DrawIcon(67, ScreenH/2-20, hud_information)
  DrawIcon(87, ScreenH/2-20, hud_help)
}
DllCall("opengl32\glBindTexture", "uint", 0x0DE1, "uint", 0)
DllCall("opengl32\glLoadIdentity")
DllCall("opengl32\glDisable", "uint", 0x0BE2)
DllCall("SwapBuffers", "uint", hDC)
return

Loader:
SetTimer, Loader, Off
Loop
{
  MapChanged := 0
  Loading := 1
  Loop, % VisibleTilesY
  {
    if (A_Index-1+MapTileY<0)
      Continue
    if (A_Index+MapTileY>2**MapZoom)
      Continue
    loader_loop_y := A_Index
    Loop, % VisibleTilesX
    {
      if (A_Index-1+MapTileX<0)
        Continue
      if (A_Index+MapTileX>2**MapZoom)
        Continue
      loaderTileY := loader_loop_y-1+MapTileY
      loaderTileX := A_Index-1+MapTileX
      LoadTile(loaderTileX, loaderTileY, MapZoom)
      if (MapChanged)
        break
    }
    if (MapChanged)
      break
  }
  While (MapChanged=0)
  {
    Loading := 0
    sleep, 100
  }
}
return

SaveScreenshoot:
WhileMakeScreenshoot += 16
DllCall("LoadLibrary", "str", "gdiplus")
VarSetCapacity(pGdiplusToken, 4, 0)
VarSetCapacity(pGdiplusInput, 16, 0)
NumPut(1, pGdiplusInput)
DllCall("gdiplus\GdiplusStartup", "uInt", &pGdiplusToken, "uInt", &pGdiplusInput, "uInt", 0)
DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "uint", hBM, "uint", 0, "uint*", pBitmap)
DllCall("DeleteObject", "uint", hBM)
DllCall("DeleteDC", "uint", hDC_tmp)
if (WhileMakeScreenshoot = 17)
{
  ScreenshootDir .= ((Substr(ScreenshootDir, StrLen(ScreenshootDir))="\") ? "" : "\")
  FileCreateDir, % ScreenshootDir
  SaveBitmap(pBitmap, ScreenshootDir "Lon" Lon "_Lat" Lat "_x" MapZoom, ScreenshootFormat)
  If (Screenshoot_show)
    Run, explore "%ScreenshootDir%",,, ScreenshootPid
}
else if (WhileMakeScreenshoot = 18)
{
  SaveBitmap(pBitmap, A_Temp "\Print_map", "BMP")
  Run, print "%A_Temp%\Print_map.bmp"
}
DllCall("gdiplus\GdiplusShutdown", "uInt", NumGet(pGdiplusToken))
DllCall("FreeLibrary", "uInt", DllCall("GetModuleHandle", "Str", "gdiplus"))
WhileMakeScreenshoot := 0
return

GuiSize:
ScreenW := A_GuiWidth
ScreenH := A_GuiHeight
CalcMapTile()
VisibleTilesX := Ceil(ScreenW/256)+1
VisibleTilesY := Ceil(ScreenH/256)+1
DllCall("opengl32\glViewport", "Int", 0, "Int", 0, "Int", A_GuiWidth, "Int", A_GuiHeight)
DllCall("opengl32\glMatrixMode", "uInt", 0x1701) ;GL_PROJECTION
DllCall("opengl32\glLoadIdentity")
DllCall("opengl32\glOrtho", "Double", -A_GuiWidth/2, "Double", A_GuiWidth/2, "Double", A_GuiHeight/2, "Double", -A_GuiHeight/2, "Double", -1, "Double", 1)
DllCall("opengl32\glMatrixMode", "uInt", 0x1700) ;GL_MODELVIEW
return


GuiClose:
ExitApp


ExitSub:
UnloadAllTiles()
INIWrite, % LonOpenGLToMap(MapPosX), settings.ini, Startup, LastPosX
INIWrite, % LatOpenGLToMap(MapPosY), settings.ini, Startup, LastPosY
INIWrite, % MapZoom, settings.ini, Startup, LastZoom
DllCall("opengl32\wglMakeCurrent", "uInt", 0, "uInt", 0)
DllCall("opengl32\wglDeleteContext", "uInt", hRC)
DllCall("ReleaseDC", "uInt", hDC)
DllCall("FreeLibrary", "uInt", hOpenGL32)
ExitApp


DrawTile(x, y, texture)
{
  DllCall("opengl32\glBindTexture", "uint", 0x0DE1, "uint", texture)
  DllCall("opengl32\glBegin", "uint", 0x0007)
  DllCall("opengl32\glTexCoord2f", "float", 0.001, "float", 0.999)
  DllCall("opengl32\glVertex2f", "float", x, "float", y)
  DllCall("opengl32\glTexCoord2f", "float", 0.999, "float", 0.999)
  DllCall("opengl32\glVertex2f", "float", x+256, "float", y)
  DllCall("opengl32\glTexCoord2f", "float", 0.999, "float", 0.001)
  DllCall("opengl32\glVertex2f", "float", x+256, "float", y+256)
  DllCall("opengl32\glTexCoord2f", "float", 0.001, "float", 0.001)
  DllCall("opengl32\glVertex2f", "float", x, "float", y+256)
  DllCall("opengl32\glEnd")
}

DrawIcon(x, y, texture)
{
  DllCall("opengl32\glBindTexture", "uint", 0x0DE1, "uint", texture)
  DllCall("opengl32\glBegin", "uint", 0x0007)
  DllCall("opengl32\glTexCoord2f", "float", 0, "float", 1)
  DllCall("opengl32\glVertex2f", "float", x, "float", y)
  DllCall("opengl32\glTexCoord2f", "float", 1, "float", 1)
  DllCall("opengl32\glVertex2f", "float", x+16, "float", y)
  DllCall("opengl32\glTexCoord2f", "float", 1, "float", 0)
  DllCall("opengl32\glVertex2f", "float", x+16, "float", y+16)
  DllCall("opengl32\glTexCoord2f", "float", 0, "float", 0)
  DllCall("opengl32\glVertex2f", "float", x, "float", y+16)
  DllCall("opengl32\glEnd")
}

LoadTile(x, y, zoom)
{
  Global
  zoom := Round(zoom)
  if (!Tile_%x%_%y%_%zoom%)
  {
    Tile_%x%_%y%_%zoom% := LoadTexture(DownloadTile(x, y, zoom))
    if (!Tile_%x%_%y%_%zoom%)
      return 0
    LoadedTiles := ((LoadedTiles="") ? 1 : LoadedTiles+1)
    Tiles := ((Tiles="") ? x "_" y "_" zoom : Tiles "|" x "_" y "_" zoom)
    UnloadTiles()
  }
  return Tile_%x%_%y%_%zoom%
}

UnloadTiles()
{
  global
  local this_tile
  MaxTiles := (TextureMem*16)-50
  while (LoadedTiles => MaxTiles)
  {
    this_tile := Substr(Tiles, 1, (Instr(Tiles, "|")-1))
    Tiles := Substr(Tiles, instr(Tiles, "|")+1)
    VarSetCapacity(textures_to_delete, 4, 0)
    NumPut(Tile_%this_tile%, textures_to_delete)
    DllCall("opengl32\glDeleteTextures", "int", 1, "uint", &textures_to_delete)
    Tile_%this_tile% := 0
    LoadedTiles --
  }
  return 1
}

UnloadAllTiles()
{
  global
  old_MaxTiles := MaxTiles
  MaxTiles := 0
  UnloadTiles()
  MaxTiles := old_MaxTiles
  return 1
}

DownloadTile(x, y, zoom, update=0)
{
  x:=Round(x)
  y:=Round(y)
  zoom := Round(zoom)
  if (fileexist("maps\" x "_" y "_" zoom ".png"))
  {
    if (update=0) ;Die Tiles werden nicht geupdatet
      return "maps\" x "_" y "_" zoom ".png"
    else if (update>1) ;Die Tiles werden je nach alter geupdatet (tage)
    {
      FileGetTime, time, % "maps\" x "_" y "_" zoom ".png"
      EnvSub, time, A_Now, days
      if (time<=update)
        return "maps\" x "_" y "_" zoom ".png"
    }
  }
  RunWait, Download %x% %y% %zoom%
  return "maps\" x "_" y "_" zoom ".png"
}



LoadTexture(Filename)
{
  global TextureFilter
  DllCall("LoadLibrary", "str", "gdiplus")
  VarSetCapacity(pGdiplusToken, 4, 0)
  VarSetCapacity(pGdiplusInput, 16, 0)
  NumPut(1, pGdiplusInput)
  DllCall("gdiplus\GdiplusStartup", "uInt", &pGdiplusToken, "uInt", &pGdiplusInput, "uInt", 0)

  SizeOfFilename := DllCall("MultiByteToWideChar", "uInt", 0, "uInt", 0, "uInt", &Filename, "Int", -1, "uInt", 0, "Int", 0) * 2
  VarSetCapacity(WideFilename, SizeOfFilename, 0)
  DllCall("MultiByteToWideChar", "uInt", 0, "uInt", 0, "uInt", &Filename, "Int", -1, "uInt", &WideFilename, "uInt", SizeOfFilename)
  DllCall("gdiplus\GdipCreateBitmapFromFile", "uInt", &WideFilename, "uIntP", GdiplusBitmap)
  DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "uInt", GdiplusBitmap, "uIntP", hBitmap, "uInt", 0xFF000000)
  DllCall("gdiplus\GdipDisposeImage", "uInt", GdiplusBitmap)
  DllCall("gdiplus\GdiplusShutdown", "uInt", NumGet(pGdiplusToken))
  DllCall("FreeLibrary", "uInt", DllCall("GetModuleHandle", "Str", "gdiplus"))

  if (hBitmap=0)
    return 0
  VarSetCapacity(ImgInfo, 24, 0)
  DllCall("GetObject", "uInt", hBitmap, "uInt", 24, "uInt", &ImgInfo)
  bmBits := NumGet(ImgInfo, 20)
  w := NumGet(ImgInfo, 4)
  h := NumGet(ImgInfo, 8)

  DllCall("opengl32\glGenTextures", "int", 1, "uintp", texture)
  DllCall("opengl32\glBindTexture", "uint", 0x0DE1, "uint", texture)
  DllCall("opengl32\glTexParameteri", "uint", 0x0DE1, "uint", 0x2800, "uint", 0x2600+TextureFilter)
  DllCall("opengl32\glTexParameteri", "uint", 0x0DE1, "uint", 0x2801, "uint", 0x2600+TextureFilter)
  DllCall("opengl32\glTexImage2D", "uint", 0x0DE1, "int", 0, "int", 4, "int", w, "int", h, "int", 0, "uint", 0x80E1, "uint", 0x1401, "uint", bmBits)
  DllCall("DeleteObject", "uint", hBitmap)
  return texture
}

DrawText(text)
{
  Loop, parse, text
  {
    y := (Floor(Asc(A_Loopfield)/16))
    x := (Asc(A_Loopfield)-(y*16))
    
    DllCall("opengl32\glBegin", "uint", 0x0007)
    DllCall("opengl32\glTexCoord2f", "float", x/16, "float", 1-(y/16))
    DllCall("opengl32\glVertex2f", "float", 0, "float", 0)
    DllCall("opengl32\glTexCoord2f", "float", (x+1)/16, "float", 1-(y/16))
    DllCall("opengl32\glVertex2f", "float", 16, "float", 0)
    DllCall("opengl32\glTexCoord2f", "float", (x+1)/16, "float", 1-((y+1)/16))
    DllCall("opengl32\glVertex2f", "float", 16, "float", 16)
    DllCall("opengl32\glTexCoord2f", "float", x/16, "float", 1-((y+1)/16))
    DllCall("opengl32\glVertex2f", "float", 0, "float", 16)
    DllCall("opengl32\glEnd")
    DllCall("opengl32\glTranslatef", "float", 9, "float", 0, "float", 0)
  }
}

SaveBitmap(pBitmap, Filename, Type="bmp")
{
  StringLower, Type, Type
  if (Instr(Filename, "." Type) != StrLen(Filename)-3)
    Filename .= "." Type

  DllCall("gdiplus\GdipGetImageEncodersSize", "uintp", Count, "uintp", Size)
  VarSetCapacity(enc, Size)
  DllCall("gdiplus\GdipGetImageEncoders", "uint", Count, "uint", Size, "uint", &enc)
  Loop, % Count
  {
    loc := NumGet(enc, ((A_Index-1)*76)+44)
    SizeofString := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", loc, "int", -1, "uint", 0, "int",  0, "uint", 0, "uint", 0)
    VarSetCapacity(wideString, SizeofString, 0)
    DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", loc, "int", -1, "str", WideString, "int", SizeofString, "uint", 0, "uint", 0)
    if !InStr(WideString, "*." Type)
      continue
    Codec := ((A_Index-1)*76)+&enc
      break
  }
  if (!Codec)
    return 0

  SizeofString := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &Filename, "int", -1, "uint", 0, "int", 0)
  VarSetCapacity(WideString, SizeofString*2, 0)
  DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &Filename, "int", -1, "uint", &WideString, "int", SizeofString)
  return ((DllCall("gdiplus\GdipSaveImageToFile", "uint", pBitmap, "uint", &WideString, "uint", Codec, "uint", 0)=0) ? 1 : 0)
}

LonOpenGLToMap(OpenGLCoord)
{
  if (OpenGLCoord>128 || OpenGLCoord<-128)
    return
  return -OpenGLCoord/128*180
}

LatOpenGLToMap(OpenGLCoord)
{
  if (OpenGLCoord>128 || OpenGLCoord<-128)
    return
  return ATan(SinH(3.1415926535*(OpenGLCoord/128)))*57.29578
}

LonMapToOpenGL(MapCoord)
{
  OpenGLCoord := -MapCoord/180*128
  if (OpenGLCoord>128 || OpenGLCoord<-128)
    return
  return OpenGLCoord
}

LatMapToOpenGL(MapCoord)
{
  if ((MapCoord>85.051129) || (MapCoord<-85.051129))
    return
  OpenGLCoord := ASinH(Tan(MapCoord*0.01745329252))/3.1415926535*128
  if (OpenGLCoord>128 || OpenGLCoord<-128)
    return
  return OpenGLCoord
}

SinH(x)
{
  return (Exp(x)-Exp(x*-1))/2
}

ASinH(x)
{
  return ln(x+sqrt(x*x+1))
}