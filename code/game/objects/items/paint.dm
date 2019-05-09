//NEVER USE THIS IT SUX	-PETETHEGOAT
//IT SUCKS A BIT LESS -GIACOM

/obj/item/paint
	gender= PLURAL
	name = "paint"
	desc = "Used to recolor floors and walls. Can be removed by the janitor."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "paint_neutral"
	item_color = "FFFFFF"
	item_state = "paintcan"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FLAMMABLE
	max_integrity = 100
	var/paintleft = 10

/obj/item/paint/red
	name = "red paint"
	item_color = "C73232" //"FF0000"
	icon_state = "paint_red"

/obj/item/paint/green
	name = "green paint"
	item_color = "2A9C3B" //"00FF00"
	icon_state = "paint_green"

/obj/item/paint/blue
	name = "blue paint"
	item_color = "5998FF" //"0000FF"
	icon_state = "paint_blue"

/obj/item/paint/yellow
	name = "yellow paint"
	item_color = "CFB52B" //"FFFF00"
	icon_state = "paint_yellow"

/obj/item/paint/violet
	name = "violet paint"
	item_color = "AE4CCD" //"FF00FF"
	icon_state = "paint_violet"

/obj/item/paint/black
	name = "black paint"
	item_color = "333333"
	icon_state = "paint_black"

/obj/item/paint/white
	name = "white paint"
	item_color = "FFFFFF"
	icon_state = "paint_white"


/obj/item/paint/anycolor
	gender = PLURAL
	name = "adaptive paint"
	icon_state = "paint_neutral"

/obj/item/paint/anycolor/attack_self(mob/user)
	var/t1 = input(user, "Please select a color:", "[src]", null) in list( "red", "blue", "green", "yellow", "violet", "black", "white")
	if ((user.get_active_held_item() != src || user.stat || user.restrained()))
		return
	switch(t1)
		if("red")
			item_color = "C73232"
		if("blue")
			item_color = "5998FF"
		if("green")
			item_color = "2A9C3B"
		if("yellow")
			item_color = "CFB52B"
		if("violet")
			item_color = "AE4CCD"
		if("white")
			item_color = "FFFFFF"
		if("black")
			item_color = "333333"
	icon_state = "paint_[t1]"
	add_fingerprint(user)


/obj/item/paint/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(paintleft <= 0)
		icon_state = "paint_empty"
		return
	if(!isturf(target) || isspaceturf(target))
		return
	var/newcolor = "#" + item_color
	target.add_atom_colour(newcolor, WASHABLE_COLOUR_PRIORITY)

/obj/item/paint/paint_remover
	gender =  PLURAL
	name = "paint remover"
	desc = "Used to remove color from anything."
	icon_state = "paint_neutral"

/obj/item/paint/paint_remover/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!isturf(target) || !isobj(target))
		return
	if(target.color != initial(target.color))
		target.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)

//tbh I didn't even know paint buckets existed in this game. Also you can only
//paint a tile entirely one colour with paint buckets so they suck again.

//TODO remove this
//Top Left = 1
//Top Right = 4
//Bottom Left = 8
//Bottom Right = 2

/obj/item/tile_painter
	name = "tile painter"
	desc = "A device used to paint tiles"
	icon = 'icons/obj/objects.dmi'
	icon_state = "paint sprayer"
	item_state = "paint sprayer"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=50, MAT_GLASS=50)
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	usesound = 'sound/effects/spray2.ogg'

	var/obj/item/reagent_containers/beaker = null
	var/list/pallete = list("color"="", "alpha"="")
	var/list/colorNW = list("color"="#DE3A3A", "alpha"="")
	var/list/colorNE = list("color"="", "alpha"="")
	var/list/colorSW = list("color"="", "alpha"="")
	var/list/colorSE = list("color"="", "alpha"="")

	//TODO remove debug variables
	var/tempdir = 1
	var/tempcolor = ""
	var/list/stuff = null

/obj/item/tile_painter/Initialize()
	. = ..()
	beaker = new /obj/item/reagent_containers/glass(src)

/obj/item/tile_painter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/B = I

		if(beaker)
			to_chat(user, "<span class='warning'>A container is already attached to [src]!</span>")
			return
		if(!user.transferItemToLoc(B, src))
			return
		beaker = B
		to_chat(user, "<span class='notice'>You add [B] to [src].</span>")
		update_icon()

/obj/item/tile_painter/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/tile_decal_colours)
		assets.send(user)
		ui = new(user, src, ui_key, "tile_painter", name, 565, 550, master_ui, state)
		ui.open()

/obj/item/tile_painter/ui_data(mob/user)
	//TODO Pass corner color data in
	var/data = list()
	var/beakerCurrentVolume = 0
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerCurrentVolume += R.volume
	data["currentInk"] = beakerCurrentVolume
	data["maxInk"] = beaker.volume

	data["NWcolor"] = colorNW["color"]
	data["NEcolor"] = colorNE["color"]
	data["SEcolor"] = colorSE["color"]
	data["SWcolor"] = colorSW["color"]

	return data

/obj/item/tile_painter/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("setNW")
			tempcolor = "#EFB341"
			colorNW["color"] = "#EFB341"
			. = TRUE
		else if("setNE")
			tempcolor = "#EFB341"
			colorNE["color"] = "#EFB341"
			. = TRUE
		else if("setSW")
			tempcolor = "#EFB341"
			colorSW["color"] = "#EFB341"
			. = TRUE
		else if("setSE")
			tempcolor = "#EFB341"
			colorSE["color"] = "#EFB341"
			. = TRUE
	update_icon()

/obj/item/tile_painter/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!proximity || !check_allowed_items(target))
		return
	var/turf/open/floor/plasteel/T = target
	if(istype(T))
		var/list/comps = T.GetComponents(/datum/component/decal)
		for (var/datum/component/decal/D in comps)
			D.Destroy()
		new /obj/effect/turf_decal/tile(T, tempcolor, tempdir)
