/*
GLOBAL_LIST_INIT(blacklisted_cargo_types, typecacheof(list(
		/mob/living,
		/obj/structure/blob,
		/obj/effect/rune,
		/obj/structure/spider/spiderling,
		/obj/item/disk/nuclear,
		/obj/machinery/nuclearbomb,
		/obj/item/beacon,
		/obj/singularity/narsie,
		/obj/singularity/wizard,
		/obj/machinery/teleport/station,
		/obj/machinery/teleport/hub,
		/obj/machinery/quantumpad,
		/obj/machinery/clonepod,
		/obj/effect/mob_spawn,
		/obj/effect/hierophant,
		/obj/structure/receiving_pad,
		/obj/item/warp_cube,
		/obj/machinery/rnd/production, //print tracking beacons, send shuttle
		/obj/machinery/autolathe, //same
		/obj/projectile/beam/wormhole,
		/obj/effect/portal,
		/obj/item/shared_storage,
		/obj/structure/extraction_point,
		/obj/machinery/syndicatebomb,
		/obj/item/hilbertshotel,
		/obj/item/swapper,
		/obj/docking_port,
		/obj/machinery/launchpad,
		/obj/machinery/disposal,
		/obj/structure/disposalpipe,
		/obj/item/hilbertshotel
	)))
*/
/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
#ifdef TESTSERVER
	callTime = 60
#else
	callTime = 300
#endif
	dir = NORTH
	port_direction = SOUTH
	width = 12
	dwidth = 5
	height = 7
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	var/budget = 0
	var/list/salese = list()

	//Export categories for this run, this is set by console sending the shuttle.
	var/export_categories = EXPORT_CARGO

/obj/docking_port/mobile/supply/register()
	. = ..()
	SSshuttle.supply = src
#ifdef MATURESERVER
	SSshuttle.moveShuttle("supply", "supply_home", TRUE)
#endif
/obj/docking_port/mobile/supply/canMove()
	//if(is_station_level(z))
		//return check_blacklist(shuttle_areas)
	return ..()
/*
/obj/docking_port/mobile/supply/proc/check_blacklist(areaInstances)
	for(var/place in areaInstances)
		var/area/shuttle/shuttle_area = place
		for(var/trf in shuttle_area)
			var/turf/T = trf
			for(var/a in T.GetAllContents())
				if(is_type_in_typecache(a, GLOB.blacklisted_cargo_types) && !istype(a, /obj/docking_port))
					return FALSE
	return TRUE

/obj/docking_port/mobile/supply/request(obj/docking_port/stationary/S)
	if(mode != SHUTTLE_IDLE)
		return 2
	return ..()

/obj/docking_port/mobile/supply/initiate_docking()
	. = ..() // Fly/enter transit.
	if(. != DOCKING_SUCCESS)
		return
	if(getDockedId() == "supply_away")

		sell()
		buy()
		addtimer(CALLBACK(SSshuttle, TYPE_PROC_REF(/datum/controller/subsystem/shuttle/, moveShuttle), "supply", "supply_home", TRUE), 100)

/obj/docking_port/mobile/supply/proc/buy()
	var/list/obj/cat_boxes = list()
	var/list/empty_turfs = list()
	var/list/general_turfs = list()
	for(var/area/shuttle/supply/buy/shuttle_area in shuttle_areas)
		for(var/turf/open/floor/T in shuttle_area)
			general_turfs += T
			if(is_blocked_turf(T))
				continue
			empty_turfs += T

	var/list/orderse = list()

	// Process orders
	if(SSshuttle.shoppinglist.len)
		for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
			var/turf/used_turf
			if(!empty_turfs.len)
				used_turf = pick(general_turfs)
			else
				used_turf = pick_n_take(empty_turfs)
			var/obj/structure/closet/crate/B = cat_boxes[SO.pack.group]
			if(!B)
				B = new SO.pack.crate_type(used_turf)
				cat_boxes[SO.pack.group] = B
			SO.generateCombo(B, SO.orderer, SO.pack.contains)
			orderse += "[SO.pack.name]"
			SSshuttle.shoppinglist -= SO
			qdel(SO)

	if(orderse.len || salese.len)
		var/turf/used_turf = pick(general_turfs)
		generateManifest(orderse, used_turf)
*/

/obj/docking_port/mobile/supply/proc/generateManifest(var/list/orders,loc) //generates-the-manifests.
	var/obj/item/paper/scroll/P = new(loc)

	P.name = "shipping manifest - [station_time_timestamp()]"
	P.info += "<h2>Shipping Manifest - [station_time_timestamp()]</h2>"
	P.info += "<hr/>"

	if(orders.len)
		P.info += "Trades: <br/>"
		P.info += "<ul>"
		for(var/A in orders)
			P.info += "<li>[A]</li>"
		P.info += "</ul>"

	P.info += "<br/>"

	if(salese.len)
		P.info += "Liquidation: <br/>"
		P.info += "<ul>"
		for(var/A in salese)
			P.info += "<li>[A]</li>"
		P.info += "</ul>"

	P.info += "<br/>"

	return P

/*
/obj/docking_port/mobile/supply/proc/remake_ledger()
	var/list/general_turfs = list()
	for(var/area/shuttle/supply/buy/shuttle_area in shuttle_areas)
		for(var/turf/open/floor/T in shuttle_area)
			general_turfs += T
			new /obj/item/book/rogue/ledger(pick(general_turfs))

/obj/docking_port/mobile/supply/proc/sell()
	var/msg = ""
	var/datum/export_report/ex = new
	var/newbudget = 0

	for(var/area/shuttle/supply/buy/place in shuttle_areas)
		for(var/atom/movable/AM in place)
			if(iscameramob(AM))
				continue
			if(QDELETED(AM))
				continue
			var/list/contents = AM.GetAllContents()
			for(var/i in reverseRange(contents))
				var/atom/movable/thing = i
				if(QDELETED(thing))
					continue
				thing.pre_sell()
			AM.pre_sell()

	// Process can shipments first
	var/list/processed_can_types = list()
	var/shipment_value = 0
	for(var/area/shuttle/supply/buy/place in shuttle_areas)
		for(var/obj/structure/closet/crate/cancrate/CC in place)
			shipment_value += CC.get_real_price()
			// Find the can type and price datum
			var/obj/item/first_can
			for(var/obj/item/I in CC.contents)
				first_can = I
				break

			if(first_can)
				for(var/datum/can_price/P in GLOB.can_price_datums)
					if(P.can_type == first_can.type)
						processed_can_types += P
						// Find gaffer console to distribute profits
						// Delete the crate and contents after processing
						qdel(CC)
						break
	if(shipment_value > 0)
		for(var/obj/structure/roguemachine/gafferconsole/G in SSroguemachine.allmachines)
			G.distribute_profits(shipment_value)
			break
		for(var/obj/structure/roguemachine/merchantvend/M in SSroguemachine.allmachines)
			if(istype(M, /obj/structure/roguemachine/merchantvend/publicboard))
				continue
			M.sale_log += list(list(
				"name" = "canned shipment",
				"value" = shipment_value,
				"time" = station_time_timestamp()
			))
			break
	// Adjust prices for processed can types
	for(var/datum/can_price/P in processed_can_types)
		P.adjust_price(-rand(1,3)) // Lower price of sold cans

		// Raise price of a random different can type
		var/list/other_cans = GLOB.can_price_datums - processed_can_types
		if(other_cans.len)
			var/datum/can_price/lucky_can = pick(other_cans)
			lucky_can.adjust_price(rand(1,3))

	// Process remaining items normally
	for(var/area/shuttle/supply/buy/place in shuttle_areas)
		for(var/atom/movable/AM in place)
			if(iscameramob(AM))
				continue
			if(QDELETED(AM))
				continue
			if(!AM.anchored || istype(AM, /obj/mecha))
				var/list/contents = AM.GetAllContents()
				for(var/i in reverseRange(contents))
					var/atom/movable/thing = i
					if(QDELETED(thing))
						continue
					if(thing.get_real_price() > 0)
						newbudget += thing.get_real_price()
						ex.total_value[thing] += thing.get_real_price()
						ex.total_amount[thing] += 1
						ex.exported_atoms += " [thing.name]"
						salese += "[thing.name] ([thing.get_real_price()])"
						for(var/obj/structure/roguemachine/merchantvend/M in SSroguemachine.allmachines)
							if(istype(M, /obj/structure/roguemachine/merchantvend/publicboard))
								continue
							M.sale_log += list(list(
								"name" = thing.name,
								"value" = thing.get_real_price(),
								"time" = station_time_timestamp()
							))
							break
						thing.on_sold()
						qdel(thing)

	for(var/obj/structure/roguemachine/merchantvend/M in SSroguemachine.allmachines)
		if(istype(M, /obj/structure/roguemachine/merchantvend/publicboard))
			continue
		M.budget += newbudget
		if(M.budget >= 1500)
			for(var/datum/mind/merchant_mind in SSticker.minds)
				if(merchant_mind.current && ishuman(merchant_mind.current))
					var/mob/living/carbon/human/H = merchant_mind.current
					if(H.job == "Merchant")
						for(var/datum/objective/roguequest/accumulatemammon/Q in merchant_mind.roguequests)
							if(!Q.completed)
								H.complete_objective(/datum/objective/roguequest/accumulatemammon, null)
		break

	return msg
*/
