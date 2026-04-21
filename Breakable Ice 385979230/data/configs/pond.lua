pond = {
	formation = {
		delay = {
			hours = GetConfiguration("pond.formation.delay.hours", "Breakable Ice") or 2,
			minutes = GetConfiguration("pond.formation.delay.minutes", "Breakable Ice") or 0,
		},
	},
}

swamp = {
	formation = {
		delay = {
			hours = GetConfiguration("swamp.formation.delay.hours", "Breakable Ice") or 2,
			minutes = GetConfiguration("swamp.formation.delay.minutes", "Breakable Ice") or 0,
		},
	},
}