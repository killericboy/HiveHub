pToken := Gdip_Startup()

; buff characters for stack detection
buff_characters := Map()
buff_characters[0] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAgAAAAKCAAAAACsrEBcAAAAAnRSTlMAAHaTzTgAAAArSURBVHgBY2Rg+MzAwMALxCAaQoDBZyYYmwlMYmXAAFApWPVnBkYIi5cBAJNvCLCTFAy9AAAAAElFTkSuQmCC")
buff_characters[1] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAIAAAAMCAAAAABt1zOIAAAAAnRSTlMAAHaTzTgAAAACYktHRAD/h4/MvwAAABZJREFUeAFjYPjM+JmBgeEzEwMDLgQAWo0C7U3u8hAAAAAASUVORK5CYII=")
buff_characters[2] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAALCAAAAAB9zHN3AAAAAnRSTlMAAHaTzTgAAABCSURBVHgBATcAyP8BAPMAAADzAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPMAAADzAAAA8wAAAPMAAAAB8wAAAAIAAAAAtc8GqohTl5oAAAAASUVORK5CYII=")
buff_characters[3] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAKCAAAAAC2kKDSAAAAAnRSTlMAAHaTzTgAAAA9SURBVHgBATIAzf8BAPMAAAAAAAAAAAAAAAAAAAAAAAAAAADzAAAAAAAAAAAAAAAAAAAAAPMAAAABAPMAAFILA8/B68+8AAAAAElFTkSuQmCC")
buff_characters[4] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAGCAAAAADBUmCpAAAAAnRSTlMAAHaTzTgAAAApSURBVHgBAR4A4f8AAAAA8wAAAAAAAAAA8wAAAPMAAALzAAAAAfMAAABBtgTDARckPAAAAABJRU5ErkJggg==")
buff_characters[5] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAALCAAAAAB9zHN3AAAAAnRSTlMAAHaTzTgAAABCSURBVHgBATcAyP8B8wAAAAIAAAAAAPMAAAACAAAAAAHzAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHzAAAAgmID1KbRt+YAAAAASUVORK5CYII=")
buff_characters[6] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAJCAAAAAAwBNJ8AAAAAnRSTlMAAHaTzTgAAAA4SURBVHgBAS0A0v8AAAAA8wAAAPMAAADzAAACAAAAAAEA8wAAAPPzAAAA8wAAAAAA8wAAAQAA8wC5oAiQ09KYngAAAABJRU5ErkJggg==")
buff_characters[7] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAMCAAAAABgyUPPAAAAAnRSTlMAAHaTzTgAAABHSURBVHgBATwAw/8B8wAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA8wIAAAAAAgAAAABDdgHu70cIeQAAAABJRU5ErkJggg==")
buff_characters[8] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAKCAAAAAC2kKDSAAAAAnRSTlMAAHaTzTgAAAA9SURBVHgBATIAzf8BAADzAAAA8wAAAgAAAAABAPMAAAEAAPMAAADzAAAAAAAAAADzAAAAAADzAAABAADzALv5B59oKTe0AAAAAElFTkSuQmCC")
buff_characters[9] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAKCAAAAAC2kKDSAAAAAnRSTlMAAHaTzTgAAAA9SURBVHgBATIAzf8BAADzAAAA8wAAAPMAAAAAAPMAAAEAAPMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA87TcBbXcfy3eAAAAAElFTkSuQmCC")

; bitmaps for buff identification
(bitmaps := Map()).CaseSense := 0
bitmaps["pBMHaste"] := Gdip_CreateBitmap(10,1)
pGraphics := Gdip_GraphicsFromImage(bitmaps["pBMHaste"]), Gdip_GraphicsClear(pGraphics, 0xfff0f0f0), Gdip_DeleteGraphics(pGraphics)
bitmaps["pBMMelody"] := Gdip_CreateBitmap(3,2)
pGraphics := Gdip_GraphicsFromImage(bitmaps["pBMMelody"]), Gdip_GraphicsClear(pGraphics, 0xff242424), Gdip_DeleteGraphics(pGraphics)
bitmaps["pBMHastePlus"] := Gdip_CreateBitmap(20,1)
pGraphics := Gdip_GraphicsFromImage(bitmaps["pBMHastePlus"]), Gdip_GraphicsClear(pGraphics, 0xffeddb4c), Gdip_DeleteGraphics(pGraphics)
bitmaps["pBMOil"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABQAAAABBAMAAAAsvJMWAAAALVBMVEVKRDlNRjlXTTpgVDtwXjhzXzV5ZDaDaziefjutiT3Gm0LWp0XsuEv8xE/+xlCsCySdAAAAFklEQVR4AQELAPT/AO7bl1MQACRorO4cdQTqnFFEXAAAAABJRU5ErkJggg==")
bitmaps["pBMSmoothie"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABgAAAABBAMAAAA2gHOYAAAAMFBMVEVKRDlKRTlYTjpjVjtvXjh1YDV2YTV5YzeNcjmkgzywiz3PokTotUr0vk36w0/+xlDRVtQJAAAAGElEQVR4AQENAPL/AP7JcxAAAAACRWir3x4xBISoIvpcAAAAAElFTkSuQmCC")
bitmaps["pBMBearBrown"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAwAAAABBAMAAAAYxVIKAAAAD1BMVEUwLi1STEihfVWzpZbQvKTt7OCuAAAAEklEQVR4AQEHAPj/ACJDEAE0IgLvAM1oKEJeAAAAAElFTkSuQmCC")
bitmaps["pBMBearBlack"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAA4AAAABBAMAAAAcMII3AAAAFVBMVEUwLi1TTD9lbHNmbXN5enW5oXHQuYJDhTsuAAAAE0lEQVR4AQEIAPf/ACNGUQAVZDIFbwFmjB55HwAAAABJRU5ErkJggg==")
bitmaps["pBMBearPanda"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABAAAAABBAMAAAAlVzNsAAAAGFBMVEUwLi1VU1G9u7m/vLXAvbbPzcXg3dfq6OXkYMPeAAAAFElEQVR4AQEJAPb/AENWchABJ2U0CO4B3TmcTKkAAAAASUVORK5CYII=")
bitmaps["pBMBearPolar"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAA4AAAABBAMAAAAcMII3AAAAElBMVEUwLi1JSUqOlZy0vMbY2dnc3NtuftTJAAAAE0lEQVR4AQEIAPf/AFVDIQASNFUFhQFVdZ1AegAAAABJRU5ErkJggg==")
bitmaps["pBMBearGummy"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAA4AAAABBAMAAAAcMII3AAAAFVBMVEWYprGDrKWisd+hst+ctNtFyJ4xz5uqDngAAAAAE0lEQVR4AQEIAPf/ACNAFWZRBDIFqwFmOuySwwAAAABJRU5ErkJggg==")
bitmaps["pBMBearScience"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAA4AAAABBAMAAAAcMII3AAAAFVBMVEUwLi1TTD+zjUy0jky8l1W5oXHevny+g95vAAAAE0lEQVR4AQEIAPf/ACNGUQAVZDIFbwFmjB55HwAAAABJRU5ErkJggg==")
bitmaps["pBMBearMother"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABAAAAABBAMAAAAlVzNsAAAAJFBMVEVBNRlDNxtTRid8b0avoG69r22+sG7Qw4PRw4Te0Jbk153m2Z5VNHxxAAAAFElEQVR4AQEJAPb/AFVouTECSnZVDPsCv+2QpmwAAAAASUVORK5CYII=")

offsetY := 0

; ── Live speed state globals (read by HiveHub UpdateStats) ─────
global lastDetectedSpeed := 0
global lastHaste         := 0
global lastOil           := false
global lastSmoothie      := false
global lastBear          := false
global lastHastePlus     := false
global lastCoconut       := false

Walk(n, hasteCap:=0)
{
	static freq := 0, init := DllCall("QueryPerformanceFrequency", "Int64*", &freq)
	d := freq // 8, l := n * freq * 4
	d += (v := DetectMovespeed(&s, &f, hasteCap)) * (f - s)
	while (d < l) {
		global paused, running
		if !running
			return
		while paused {
			if !running
				return
			Sleep 50
		}
		d += ((v + 0) + (v := DetectMovespeed(&s, &f, hasteCap)))/2 * (f - s)
	}
}

DetectMovespeed(&s, &f, hasteCap:=0)
{
	DllCall("QueryPerformanceCounter", "Int64*", &s := 0)

	global hasty_guard, gifted_hasty, base_movespeed, buff_characters, bitmaps, offsetY
	global lastDetectedSpeed, lastHaste, lastOil, lastSmoothie
	global lastBear, lastHastePlus, lastCoconut

	; check roblox window exists
	GetRobloxClientPos()
	if (windowWidth = 0)
		return (DllCall("QueryPerformanceCounter", "Int64*", &f := 0), 10000000)

	; get screen bitmap of buff area
	chdc := CreateCompatibleDC(), hbm := CreateDIBSection(windowWidth, 30, chdc), obm := SelectObject(chdc, hbm), hhdc := GetDC()
	BitBlt(chdc, 0, 0, windowWidth, 30, hhdc, windowX, windowY+offsetY+48)
	ReleaseDC(hhdc)
	pBMArea := Gdip_CreateBitmapFromHBITMAP(hbm)
	SelectObject(chdc, obm), DeleteObject(hbm), DeleteDC(hhdc), DeleteDC(chdc)

	; find haste buffs
	x := 0
	haste := 0
	Loop 3
	{
		if (Gdip_ImageSearch(pBMArea, bitmaps["pBMHaste"], &list, x, 14, , , , , 6) != 1)
			break
		x := SubStr(list, 1, InStr(list, ",")-1), y := SubStr(list, InStr(list, ",")+1)
		if (Gdip_ImageSearch(pBMArea, bitmaps["pBMMelody"], , x+2, , x+Max(16, 2*y-24), y, 12) = 0)
		{
			haste++
			if (haste = 1)
				x1 := x, y1 := y
		}
		x += 2*y-14
	}

	coconut_haste := (haste = 2) ? 1 : 0
	if haste
	{
		Loop 9
		{
			if (Gdip_ImageSearch(pBMArea, buff_characters[10-A_Index], , x1+2*y1-44, Max(0, y1-18), x1+2*y1-14, y1-1) = 1)
			{
				haste := (A_Index = 9) ? 10 : 10 - A_Index
				break
			}
			if (A_Index = 9)
				haste := 1
		}
	}

	haste_plus := (Gdip_ImageSearch(pBMArea, bitmaps["pBMHastePlus"], , , 25, , 27, , , 2) = 1)
	oil        := (Gdip_ImageSearch(pBMArea, bitmaps["pBMOil"],        , , 25, , 27, 4, , 2) = 1)
	smoothie   := (Gdip_ImageSearch(pBMArea, bitmaps["pBMSmoothie"],   , , 25, , 27, 4, , 2) = 1)
	bear := 0
	for v in ["Brown","Black","Panda","Polar","Gummy","Science","Mother"]
	{
		if (Gdip_ImageSearch(pBMArea, bitmaps["pBMBear" v], , , 25, , 27, 8, , 2) = 1)
		{
			bear := 1
			break
		}
	}
	Gdip_DisposeImage(pBMArea)

	; calculate live speed
	v := ((base_movespeed + (coconut_haste ? 10 : 0) + (bear ? 6 : 0)) * (hasty_guard ? 1.1 : 1) * (gifted_hasty ? 1.2 : 1) * (1 + max(0, haste-hasteCap)*0.1) * (haste_plus ? 2 : 1) * (oil ? 1.2 : 1) * (smoothie ? 1.25 : 1))

	; ── write live state so UI UpdateStats can read them ───────
	lastDetectedSpeed := v
	lastHaste         := haste
	lastOil           := oil
	lastSmoothie      := smoothie
	lastBear          := bear
	lastHastePlus     := haste_plus
	lastCoconut       := coconut_haste

	return (DllCall("QueryPerformanceCounter", "Int64*", &f := 0), v)
}
