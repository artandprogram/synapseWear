{
	"patcher" : 	{
		"fileversion" : 1,
		"appversion" : 		{
			"major" : 6,
			"minor" : 1,
			"revision" : 10,
			"architecture" : "x86"
		}
,
		"rect" : [ 775.0, 100.0, 640.0, 480.0 ],
		"bglocked" : 0,
		"openinpresentation" : 0,
		"default_fontsize" : 12.0,
		"default_fontface" : 0,
		"default_fontname" : "Arial",
		"gridonopen" : 0,
		"gridsize" : [ 15.0, 15.0 ],
		"gridsnaponopen" : 0,
		"statusbarvisible" : 2,
		"toolbarvisible" : 1,
		"boxanimatetime" : 200,
		"imprint" : 0,
		"enablehscroll" : 1,
		"enablevscroll" : 1,
		"devicewidth" : 0.0,
		"description" : "",
		"digest" : "",
		"tags" : "",
		"boxes" : [ 			{
				"box" : 				{
					"id" : "obj-9",
					"maxclass" : "bpatcher",
					"name" : "trsp.maxpat",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 384.0, 332.0, 164.0, 86.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-8",
					"maxclass" : "flonum",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "float", "bang" ],
					"parameter_enable" : 0,
					"patching_rect" : [ 96.0, 44.0, 50.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-6",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 323.0, 161.0, 29.0, 20.0 ],
					"text" : "s lb"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-5",
					"maxclass" : "button",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"patching_rect" : [ 323.0, 118.5, 20.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-3",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"patching_rect" : [ 323.0, 89.0, 60.0, 20.0 ],
					"text" : "loadbang"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-2",
					"maxclass" : "ezdac~",
					"numinlets" : 2,
					"numoutlets" : 0,
					"patching_rect" : [ 96.0, 312.0, 45.0, 45.0 ]
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-1",
					"maxclass" : "bpatcher",
					"name" : "toneMod.maxpat",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 96.0, 89.0, 166.0, 193.0 ]
				}

			}
 ],
		"lines" : [ 			{
				"patchline" : 				{
					"destination" : [ "obj-2", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-1", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-2", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-1", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-5", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-3", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-6", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-5", 0 ]
				}

			}
 ],
		"parameters" : 		{
			"obj-1::obj-3::obj-34" : [ "VOL", "VOL", 0 ],
			"obj-1::obj-87::obj-40" : [ "live.text[4]", "live.text", 0 ],
			"obj-1::obj-7::obj-7" : [ "MIX[3]", "MIX", 0 ],
			"obj-1::obj-7::obj-40" : [ "live.text[5]", "live.text", 0 ],
			"obj-1::obj-8" : [ "PARAM", "PARAM", 0 ],
			"obj-1::obj-116::obj-7" : [ "MIX", "MIX", 0 ],
			"obj-1::obj-116::obj-40" : [ "live.text[2]", "live.text", 0 ],
			"obj-1::obj-114::obj-40" : [ "live.text[3]", "live.text", 0 ],
			"obj-1::obj-87::obj-7" : [ "MIX[2]", "MIX", 0 ],
			"obj-9::obj-5" : [ "live.text", "live.text", 0 ],
			"obj-1::obj-114::obj-7" : [ "MIX[1]", "MIX", 0 ],
			"obj-1::obj-3::obj-6" : [ "mute", "mute", 0 ],
			"obj-9::obj-7" : [ "live.dial", "BPM", 0 ],
			"obj-9::obj-43" : [ "live.text[1]", "live.text", 0 ]
		}
,
		"dependency_cache" : [ 			{
				"name" : "toneMod.maxpat",
				"bootpath" : "/Users/sonir/Documents/boxes/prj_box/1706_synp/2_dev/171119_sonification",
				"patcherrelativepath" : ".",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "mixing.maxpat",
				"bootpath" : "/Users/sonir/Documents/boxes/prj_box/1706_synp/2_dev/171119_sonification",
				"patcherrelativepath" : ".",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "sampler.maxpat",
				"bootpath" : "/Users/sonir/Documents/boxes/prj_box/1706_synp/2_dev/171119_sonification",
				"patcherrelativepath" : ".",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "trsp.maxpat",
				"bootpath" : "/Users/sonir/Documents/boxes/prj_box/1706_synp/2_dev/171119_sonification",
				"patcherrelativepath" : ".",
				"type" : "JSON",
				"implicit" : 1
			}
 ]
	}

}
