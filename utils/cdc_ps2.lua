project = {
	iconname = "ps2",
	{ name = "ps2/ila0",
	  bus = {
		"ps2data",
		{ name = "bitcount", bot=0, top=3 },
		"parity",
		{ name = "key", bot=0, top=7 },
		"fifo_wr_en",
		"ps2clk",
		{ name = "rd_data", bot=0, top=7 },
		{ name = "ps2__spami_data", bot=0, top=31 },
		"fifo_rd_en_1a",
		"fifo_rd_en_0a",
		"rd_decode_1a",
		"empty",
		"rd_decode_0a",
	  	{ name = "bullshit", bot=61, top=255 },
	  	}
	},
	{ name = "ps2/ila1",
	  bus = {
		"parity",
		{ name = "key", bot=0, top=7 },
		"fifo_wr_en",
		{ name = "bitcount", bot=0, top=3 },
		"ps2data",
		{ name = "bullshit", bot=15, top=255 },
	  	}
	},
	{ name = "mem/ila2",
	  bus = {
	  	{ name = "bullshit", bot=0, top=255 },
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
