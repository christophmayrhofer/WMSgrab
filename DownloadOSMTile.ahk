#NoTrayIcon
n = %0%
x = %1%
y = %2%
z = %3%
if (n=3)
  DownloadTile(x, y, z)
ExitApp


DownloadTile(x, y, zoom, update=0)
{
  static server=0
  FileCreateDir, maps
  URLDownloadToFile, % "http://" chr(asc("a")+server) ".tile.openstreetmap.org/" zoom "/" x "/" y ".png", % "maps\" x "_" y "_" zoom ".png"
  server := ((server<2) ? server+1 : 0)
  return "maps\" x "_" y "_" zoom ".png"
}