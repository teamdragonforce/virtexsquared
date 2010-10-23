project = {
	iconname = "mem",
	{ name = "mem/ila0",
	  bus = {
	  	"fsabo_valid",
	  	"fsabo_credit",
	  	{ name = "fsabo_mask", bot=0, top=7 },
	  	{ name = "fsabo_data", bot=0, top=63 },
	  	{ name = "fsabo_len", bot=0, top=3 },
	  	{ name = "fsabo_addr", bot=0, top=30 },
	  	{ name = "fsabo_subdid", bot=0, top=3 },
	  	{ name = "fsabo_did", bot=0, top=3 },
	  	"fsabo_mode",
	  	"rst0_tb",
	  	"idfif_rd_0a",
	  	"idfif_wr_0a",
	  	"irfif_rd_0a",
	  	"irfif_wr_0a",
	  	"reading_req_1a",
	  	"reading_req_0a",
	  	"ifif_have_req",
	  	{ name = "irfif_ddr_len_1a", bot=0, top=3 },
	  	{ name = "mem_cur_req_ddr_len_rem_0a", bot=0, top=3 },
	  	{ name = "ifif_reqs_queued_0a", bot=0, top=2 },
	  	"mem_cur_req_active_0a",
	  	"app_wdf_afull",
	  	"app_af_afull",
	  	"app_wdf_wren",
	  	"app_af_wren",
	  	{ name = "bullshit", bot=142, top=255 },
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
