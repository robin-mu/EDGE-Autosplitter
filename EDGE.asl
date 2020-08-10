state("edge") {
	int  time          : 0x01F9064, 0x10C;      // level time in 1/22-seconds
	int  edgetime      : 0x01F9064, 0x110;      // final time with EDGE-Time subtracted
	byte edging        : 0x01F9064, 0x6C;       // 1 if currently gaining EDGE-Time, 0 if not
	int  totalEdgetime : 0x01F9064, 0x108;      // total EDGE-Time in the current level
	int  id            : 0x01F9040, 0x78;       // ID of the current level, -1 for menu or loading
	byte clear         : 0x01F9064, 0xB5;       // 1 if in level clear screen, 0 if not
	byte goNormal      : 0x01F91B4, 0x64, 0x10;
	byte goExtended    : 0x01F91B4, 0x74, 0x10;
	byte goBonus       : 0x01F91B4, 0x6C, 0x10; // 2 if the "go"-button is selected in the respective level menu
}

startup {
	settings.Add("igt", false, "In-Game Timer");
	settings.Add("edgetime", false, "Subtract EDGE-Time", "igt");
	settings.SetToolTip("igt", "Adds all In-Game level times together (remember to compare against Game Time)");
	settings.SetToolTip("edgetime", "Pauses when gaining EDGE-Time");
}

init{
	vars.igt = 0;
}

start {
	if(settings["igt"]){
		if(current.id > old.id && old.id == -1) {
			vars.igt = 0;
			return true;
		}
	} else {
		return current.goNormal == 2 && current.goNormal != old.goNormal ||
			   current.goExtended == 2 && current.goExtended != old.goExtended ||
			   current.goBonus == 2 && current.goBonus != old.goBonus;
	}
}

split {
	if(settings["igt"]){
		return current.edgetime < old.edgetime && vars.igt > 0;
	} else {
		return current.clear > old.clear;
	}
}

reset {
	return current.goNormal == 0 && current.goNormal != old.goNormal ||
		   current.goExtended == 0 && current.goExtended != old.goExtended ||
		   current.goBonus == 0 && current.goBonus != old.goBonus;
}

isLoading{
	return settings["igt"];
}

gameTime{
	if(settings["igt"] && !settings["edgetime"]){
		if(current.edgetime == 0) {
			return TimeSpan.FromSeconds(Convert.ToDouble(vars.igt + current.time)/22);
		}
		if(current.edgetime > old.edgetime) {
			vars.igt += current.time;
			return TimeSpan.FromSeconds(Convert.ToDouble(vars.igt)/22);
		}
	}
	if(settings["edgetime"]){
		if(current.edgetime == 0 && current.edging == 0){
			return TimeSpan.FromSeconds(Convert.ToDouble(vars.igt + current.time - current.totalEdgetime)/22);
		}
		if(current.edgetime > old.edgetime) {
			vars.igt += current.edgetime;
			return TimeSpan.FromSeconds(Convert.ToDouble(vars.igt)/22);
		}
	}
}