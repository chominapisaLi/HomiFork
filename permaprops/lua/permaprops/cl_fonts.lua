--[[
____                                    ____                                 
/\  _`\                                 /\  _`\                               
\ \ \L\ \ __   _ __    ___ ___      __  \ \ \L\ \_ __   ___   _____     ____  
 \ \ ,__/'__`\/\`'__\/' __` __`\  /'__`\ \ \ ,__/\`'__\/ __`\/\ '__`\  /',__\ 
  \ \ \/\  __/\ \ \/ /\ \/\ \/\ \/\ \L\.\_\ \ \/\ \ \//\ \L\ \ \ \L\ \/\__, `\
   \ \_\ \____\\ \_\ \ \_\ \_\ \_\ \__/.\_\\ \_\ \ \_\\ \____/\ \ ,__/\/\____/
    \/_/\/____/ \/_/  \/_/\/_/\/_/\/__/\/_/ \/_/  \/_/ \/___/  \ \ \/  \/___/ 
                                                                \ \_\         
                                                                 \/_/         
    File: cl_fonts.lua
    Author: Summe

    For internal purposes.
    For the fonts.
]]--

surface.CreateFont("PermaProps.Title", {
	font = "Roboto",
	extended = false,
	size = ScrH()/27,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})


surface.CreateFont("PermaProps.Title2", {
	font = "Roboto",
	size = ScrH()/40,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("PermaProps.Title2Symbol", {
	font = "Roboto",
	extended = true,
	size = ScrH()/40,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	symbol = true,
})

surface.CreateFont("PermaProps.Button", {
	font = "Roboto",
	extended = false,
	size = ScrH()/40,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("PermaProps.Button2", {
	font = "Roboto",
	extended = false,
	size = ScrH()/60,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("PermaProps.Text", {
	font = "Roboto",
	extended = false,
	size = ScrH()/50,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("PermaProps.DetailText", {
	font = "Roboto",
	extended = false,
	size = ScrH()/65,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("PermaProps.TextEntry", {
	font = "Roboto",
	extended = false,
	size = ScrH()/55,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})
