#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_audio;

main()
{
	replaceFunc( maps\mp\zm_prison::delete_perk_machine_clip, ::delete_perk_machine_clip );
}

init()
{
	precacheModel("collision_clip_32x32x128");
	precacheModel("zombie_vending_marathon");
	precacheModel("zombie_vending_marathon_on");
	precacheItem("zombie_perk_bottle_marathon");
	level thread spawn_staminup();
}

spawn_staminup()
{
	level waittill("game_started");
	wait 3;

	machine = spawn("script_model", (-10, -306, 120));
	machine setmodel("zombie_vending_marathon_on");
	machine.angles = (0, 180, 0);
	machine.script_noteworthy = "specialty_longersprint";

	machine thread staminup_buy();
}

staminup_buy()
{
	level endon("game_ended");
	while (1)
	{
		foreach (player in level.players)
		{
			if (isdefined(player) && isalive(player) && distance(self.origin, player.origin) < 75)
			{
				if (!player hasperk("specialty_longersprint") && !player maps\mp\zombies\_zm_laststand::player_is_in_laststand())
				{
					player thread show_hint(self.origin, "Hold ^3[{+activate}]^7 for Stamin-Up [3000]");

					if (player usebuttonpressed() && player.score >= 3000)
					{
						player.score -= 3000;
						player playsound("zmb_cha_ching");
						player maps\mp\zombies\_zm_perks::give_perk("specialty_longersprint", 1);
						player iprintln("^9Stamin-Up");
					}
					else if (player usebuttonpressed() && player.score < 3000)
					{
						player maps\mp\zombies\_zm_audio::create_and_play_dialog("general", "perk_deny", undefined, 0);
					}
				}
			}
		}
		wait 0.1;
	}
}

show_hint(origin, msg)
{
	hint = spawn("trigger_radius", origin, 1, 30, 30);
	hint setcursorhint("HINT_ACTIVATE");
	hint sethintstring(msg);
	wait 0.2;
	hint delete();
}

delete_perk_machine_clip()
{
	perk_machines = getentarray("zombie_vending", "targetname");

	foreach (perk_machine in perk_machines)
	{
		if (isdefined(perk_machine.clip))
		{
			perk_machine.clip delete();
		}

		if (isdefined(perk_machine.target) && perk_machine.target == "vending_divetonuke" || perk_machine.target == "vending_additionalprimaryweapon")
		{
			spawn_custom_perk_collision(perk_machine);
		}
	}
}

spawn_custom_perk_collision(perk_machine)
{
	collision = spawn("script_model", perk_machine.origin + (0, 0, 64), 1);
	collision.angles = perk_machine.angles;

	collision setmodel("collision_clip_32x32x128");
	collision disconnectpaths();
}