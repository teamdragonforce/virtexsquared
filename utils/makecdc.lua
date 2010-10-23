project = {
	iconname = "mem",
	{ name = "mem/ila0",
	  bus = {
	  	{ name = "fsabo_valid", bot=0, top=0 },
	  	{ name = "fsabo_credit", bot=0, top=0 },
	  	{ name = "fsabo_mask", bot=0, top=7 },
	  	{ name = "fsabo_data", bot=0, top=63 },
	  	{ name = "fsabo_len", bot=0, top=2 },
	  	{ name = "fsabo_addr", bot=0, top=30 },
	  	{ name = "fsabo_subdid", bot=0, top=3 },
	  	{ name = "fsabo_did", bot=0, top=3 },
	  	{ name = "fsabo_mode", bot=0, top=0 },
	  	{ name = "rst0_tb", bot=0, top=0 },
	  	{ name = "bullshit", bot=118, top=255 },
	  	}
	},
	{ name = "mem/ila1",
	  bus = {
	  	"fsabi_valid",
	  	{ name = "fsabi_data", bot=0, top=63 },
	  	{ name = "fsabi_subdid", bot=0, top=3 },
	  	{ name = "fsabi_did", bot=0, top=3 },
	  	"rst0_tb",
	  	{ name = "bullshit", bot=74, top=255 },
	  	}
	},
	{ name = "mem/ila2",
	  bus = {
	  	{ name = "bullshit", bot=0, top=255 },
	  	}
	},
	{ name = "mem/ila3",
	  bus = {
	  	{ name = "bullshit", bot=0, top=255 },
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
			print("Project.unit<"..k..">.triggerChannel<0><"..bit..">="..v1)
			bit = bit + 1
		elseif type(v1) == "table" then
			for idx = v1.bot, v1.top do
				print("Project.unit<"..k..">.triggerChannel<0><"..bit..">="..v1.name.."<"..idx..">")
				bit = bit + 1
			end
		end 
	end
end
