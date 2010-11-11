project = {
	iconname = "mem",
	{ name = "mem/ila0",
	  bus = {
	  	"fifo_empty",
	  	"data_ready",
	  	{ name = "data", bot=0, top=63 },
	  	"request",
	  	"secondhalf",
	  	"ac97_out_slot4_valid",
	  	{ name = "ac97_out_slot4", bot=0, top=19 },
	  	"ac97_out_slot3_valid",
	  	{ name = "ac97_out_slot3", bot=0, top=19 },
	  	"ac97_out_slot2_valid",
	  	{ name = "ac97_out_slot2", bot=0, top=19 },
	  	"ac97_out_slot1_valid",
	  	{ name = "ac97_out_slot1", bot=0, top=19 },
	  	"ac97_sdata_in",
	  	"ac97_strobe",
	  	"ac97_reset_b",
	  	"ac97_sync",
	  	"ac97_sdata_out",
	  	{ name = "bullshit", bot=157, top=255 },
	  	}
	},
	{ name = "mem/ila1",
	  bus = {
	  	"spamo_valid",
	  	"spamo_r_nw",
	  	{ name = "spamo_did", bot=0, top=3 },
	  	{ name = "spamo_data", bot=0, top=31 },
	  	{ name = "spamo_addr", bot=0, top=23 },
	  	"spam_wr",
	  	{ name = "bullshit", bot=63, top=255 },
	  	}
	},
	{ name = "mem/ila2",
	  bus = {
	  	{ name = "rd_data_fifo_out", bot=0, top=31 },
	  	"rd_data_valid",
	  	"app_wdf_afull",
	  	{ name = "app_wdf_mask_data", bot=0, top=15 },
	  	{ name = "app_wdf_data", bot=0, top=127 },
	  	"app_wdf_wren",
	  	"app_af_afull",
	  	{ name = "app_af_addr", bot=0, top=30 },
	  	{ name = "app_af_cmd", bot=0, top=2 },
	  	"app_af_wren",
	  	"phy_init_done",
	  	"rst0_tb",
	  	{ name = "bullshit", bot=217, top=255 },
	  	}
	},
	{ name = "mem/ila3",
	  bus = {
	        { name = "data", bot=0, top=7 },
	        "drdy",
	  	{ name = "bullshit", bot=9, top=255 },
	  	}
	}
}

print("#FPGA Editor Signal Export Version 1.0")
print("#bull shit bull shit")
print("")

print("Project.unit.dimension="..(#project))
print("Project.icon.name="..project.iconname)

for k,unit in ipairs(project) do
	k = k - 1         -- B| lua
	print("Project.unit<"..k..">.name="..unit.name)
	print("Project.unit<"..k..">.type=ilapro")
	print("Project.unit<"..k..">.clockChannel=fsabi_clk")
	print("Project.unit<"..k..">.dataPortWidth=0")
	print("Project.unit<"..k..">.dataEqualsTrigger=true")
	print("Project.unit<"..k..">.triggerPortCount=1")
	local bit = 0
	for k1,v1 in ipairs(unit.bus) do
		if type(v1) == "string" then
			bit = bit + 1
		elseif type(v1) == "table" then
			for idx = v1.bot, v1.top do
				bit = bit + 1
			end
		end 
	end
	print("Project.unit<"..k..">.triggerPortWidth<0>="..bit)
	print("Project.unit<"..k..">.triggerPortIsData<0>=true")
	bit = 0
	for k1,v1 in ipairs(unit.bus) do
		if type(v1) == "string" then
			print("Project.unit<"..k..">.triggerChannel<0><"..bit..">="..v1.."<0>")
			bit = bit + 1
		elseif type(v1) == "table" then
			for idx = v1.bot, v1.top do
				print("Project.unit<"..k..">.triggerChannel<0><"..bit..">="..v1.name.."<"..idx..">")
				bit = bit + 1
			end
		end 
	end
end
