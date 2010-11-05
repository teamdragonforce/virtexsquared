project = {
	iconname = "framebuffer",
	{ name = "framebuffer/ila0",
	  bus = {
		hs,
		vs,
	  	{ name = "y", bot=0, top=11 },
		{ name = "x", bot=0, top=11 },
		{ name = "blue", bot=0, top=7 },
		{ name = "green", bot=0, top=7 },
		{ name = "red", bot=0, top=7 },
		{ name = "data", bot=0, top=63 },
		data_ready,
		border,
		next_offset,
		fbclk_rst_b,
		offset,
		request,
	  	{ name = "bullshit", bot=120, top=255 },
	  	}
	},
	{ name = "framebuffer/ila1",
	  bus = {
		{ name = "bullshit", bot=0, top=255 },
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
