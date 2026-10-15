/obj/structure/mineral_door/metaldoor
	name = "bulkhead"
	desc = ""
	icon_state = "metal"
	base_state = "metal"
	keylock = TRUE
	max_integrity = 9000
	kickthresh = 300
	locksound = 'sound/foley/doors/lockmetal.ogg'
	unlocksound = 'sound/foley/doors/lockmetal.ogg'
	rattlesound = 'sound/foley/doors/lockrattlemetal.ogg'
	attacked_sound = list("sound/combat/hits/onmetal/metalimpact (1).ogg", "sound/combat/hits/onmetal/metalimpact (2).ogg")
	openSound = 'modular_tidi/shuttle/sound/metal_op.ogg'
	closeSound = 'modular_tidi/shuttle/sound/metal_close.ogg'
	layer = ABOVE_MOB_LAYER
	icon = 'modular_tidi/shuttle/icons/doors.dmi'
	close_delay = -1
	close_delay = 10

/turf/closed/wall/mineral/rogue/metal
	name = "metal wall"
	icon = 'modular_tidi/shuttle/icons/metalwall.dmi'
	icon_state = "metalwall"
	smooth = SMOOTH_MORE
	max_integrity = 90000
	sheet_type = null
	break_sound = "pipewall"
	attacked_sound = "pipewall"
	above_floor = /turf/open/floor/rogue/concrete
	baseturfs = list(/turf/open/floor/rogue/concrete)
	damage_deflection = 20
	canSmoothWith = list(/turf/closed/wall/mineral/rogue/metal)
