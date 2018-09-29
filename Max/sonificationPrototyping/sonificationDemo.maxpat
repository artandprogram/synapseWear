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
		"rect" : [ 307.0, 101.0, 1543.0, 1021.0 ],
		"bglocked" : 0,
		"openinpresentation" : 1,
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
					"id" : "obj-58",
					"maxclass" : "bpatcher",
					"name" : "autoVol.maxpat",
					"numinlets" : 2,
					"numoutlets" : 2,
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 1189.0, 747.0, 118.0, 37.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 821.0, 229.839935, 164.0, 37.0 ]
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-56",
					"maxclass" : "bpatcher",
					"name" : "chord.maxpat",
					"numinlets" : 2,
					"numoutlets" : 2,
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 1189.0, 540.0, 160.0, 191.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 821.0, 38.749016, 160.0, 191.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 7.0,
					"frgb" : 0.0,
					"id" : "obj-55",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 1293.0, 446.0, 29.0, 14.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 603.0, 501.939026, 29.0, 14.0 ],
					"text" : "STEP"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-53",
					"maxclass" : "bpatcher",
					"name" : "trsp.maxpat",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 1379.0, 592.0, 182.0, 84.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 641.0, 495.439026, 171.0, 61.0 ]
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-54",
					"maxclass" : "button",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"patching_rect" : [ 1273.0, 443.0, 20.0, 20.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 607.5, 515.939026, 20.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-50",
					"maxclass" : "bpatcher",
					"name" : "autoVol.maxpat",
					"numinlets" : 2,
					"numoutlets" : 2,
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 1538.0, 243.0, 118.0, 37.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 398.0, 515.939026, 165.0, 37.0 ]
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-48",
					"maxclass" : "bpatcher",
					"name" : "autoVol.maxpat",
					"numinlets" : 2,
					"numoutlets" : 2,
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 1340.0, 243.0, 118.0, 37.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 212.181824, 515.939026, 164.0, 37.0 ]
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-46",
					"maxclass" : "bpatcher",
					"name" : "autoVol.maxpat",
					"numinlets" : 2,
					"numoutlets" : 2,
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 1140.0, 243.0, 118.0, 37.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 18.181824, 515.939026, 164.0, 37.0 ]
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-44",
					"maxclass" : "bpatcher",
					"name" : "autoVol.maxpat",
					"numinlets" : 2,
					"numoutlets" : 2,
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 298.181824, 243.0, 118.0, 37.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 18.181824, 229.839935, 162.454544, 37.0 ]
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-41",
					"maxclass" : "bpatcher",
					"name" : "autoVol.maxpat",
					"numinlets" : 2,
					"numoutlets" : 2,
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 739.0, 243.0, 118.0, 37.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 398.0, 226.749023, 162.0, 37.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-37",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 700.0, 531.0, 85.0, 20.0 ],
					"text" : "s off_all_mute"
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-35",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 700.0, 493.0, 68.0, 18.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 605.5, 294.939026, 68.0, 18.0 ],
					"text" : "PLAY_ALL"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-25",
					"maxclass" : "bpatcher",
					"name" : "autoVol.maxpat",
					"numinlets" : 2,
					"numoutlets" : 2,
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 937.0, 243.0, 118.0, 37.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 598.0, 226.749023, 163.0, 37.0 ]
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-15",
					"maxclass" : "bpatcher",
					"name" : "autoVol.maxpat",
					"numinlets" : 2,
					"numoutlets" : 2,
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 530.0, 243.0, 118.0, 37.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 211.0, 229.839935, 161.0, 37.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 7.0,
					"frgb" : 0.0,
					"id" : "obj-39",
					"linecount" : 4,
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 989.5, 438.0, 26.0, 38.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 590.0, 475.190002, 51.0, 14.0 ],
					"text" : "PORT 57110"
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 7.0,
					"frgb" : 0.0,
					"id" : "obj-33",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 1153.0, 372.0, 26.0, 14.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 605.5, 434.190002, 24.0, 14.0 ],
					"text" : "OSC"
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-31",
					"maxclass" : "newobj",
					"numinlets" : 6,
					"numoutlets" : 6,
					"outlettype" : [ "", "", "", "", "", "" ],
					"patching_rect" : [ 1214.0, 349.0, 512.0, 20.0 ],
					"text" : "route /co2 /light /temp /hum /press"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-27",
					"maxclass" : "button",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"patching_rect" : [ 1153.0, 349.0, 20.0, 20.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 607.5, 448.190002, 20.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-23",
					"maxclass" : "newobj",
					"numinlets" : 0,
					"numoutlets" : 2,
					"outlettype" : [ "", "" ],
					"patching_rect" : [ 1214.0, 304.074402, 78.0, 20.0 ],
					"text" : "rcv_synapse"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-14",
					"maxclass" : "bpatcher",
					"name" : "glitch.maxpat",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 1538.0, 42.749016, 165.0, 188.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 398.0, 327.939026, 165.0, 188.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 7.0,
					"frgb" : 0.0,
					"id" : "obj-52",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 610.5, 330.749023, 107.0, 14.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 602.0, 380.939026, 34.0, 14.0 ],
					"text" : "SYNST"
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 7.0,
					"frgb" : 0.0,
					"id" : "obj-51",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 77.090897, 79.112625, 24.0, 14.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 605.5, 327.939026, 24.0, 14.0 ],
					"text" : "INIT"
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"frgb" : 0.0,
					"id" : "obj-49",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 975.0, 372.0, 80.0, 20.0 ],
					"text" : "MOVEMENT"
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"frgb" : 0.0,
					"id" : "obj-47",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 975.0, 334.0, 51.0, 20.0 ],
					"text" : "ANGLE"
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"frgb" : 0.0,
					"id" : "obj-45",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 1538.0, 9.0, 100.0, 20.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 404.049988, 305.939026, 100.0, 20.0 ],
					"text" : "TEMPERATURE",
					"textcolor" : [ 0.636458, 0.636458, 0.636458, 1.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"frgb" : 0.0,
					"id" : "obj-42",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 1340.0, 9.0, 100.0, 20.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 212.181824, 305.939026, 100.0, 20.0 ],
					"text" : "AIR PRESSURE",
					"textcolor" : [ 0.636458, 0.636458, 0.636458, 1.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"frgb" : 0.0,
					"id" : "obj-40",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 937.0, 9.0, 35.0, 20.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 598.0, 16.749016, 35.0, 20.0 ],
					"text" : "CO2",
					"textcolor" : [ 0.636458, 0.636458, 0.636458, 1.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"frgb" : 0.0,
					"id" : "obj-38",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 739.0, 9.0, 94.0, 20.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 398.0, 16.749016, 94.0, 20.0 ],
					"text" : "ILLUMINATION",
					"textcolor" : [ 0.636458, 0.636458, 0.636458, 1.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"frgb" : 0.0,
					"id" : "obj-36",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 1140.0, 9.0, 82.0, 20.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 18.181824, 305.939026, 82.0, 20.0 ],
					"text" : "ENV SOUND",
					"textcolor" : [ 0.636458, 0.636458, 0.636458, 1.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"frgb" : 0.0,
					"id" : "obj-34",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 530.0, 9.0, 68.0, 20.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 211.0, 16.749016, 68.0, 20.0 ],
					"text" : "HUMIDITY",
					"textcolor" : [ 0.636458, 0.636458, 0.636458, 1.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"frgb" : 0.0,
					"id" : "obj-32",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 298.181824, 9.0, 117.0, 20.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 18.181824, 16.749016, 117.0, 20.0 ],
					"text" : "MAGNETIC FIELD",
					"textcolor" : [ 0.636458, 0.636458, 0.636458, 1.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"frgb" : 0.0,
					"id" : "obj-30",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 555.0, 400.0, 164.0, 20.0 ],
					"text" : "reverb for click and tone_dist"
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"frgb" : 0.0,
					"id" : "obj-28",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 555.0, 363.0, 150.0, 20.0 ],
					"text" : "Tune curve for click etc"
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"frgb" : 0.0,
					"id" : "obj-26",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 555.0, 327.0, 153.0, 20.0 ],
					"text" : "Suitable focus and recover"
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"frgb" : 0.0,
					"id" : "obj-24",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 555.0, 291.0, 239.0, 20.0 ],
					"text" : "remote quantize (global click and quantize)"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-21",
					"maxclass" : "bpatcher",
					"name" : "kick.maxpat",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 1340.0, 42.749016, 165.0, 188.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 212.181824, 327.939026, 164.0, 188.0 ]
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-13",
					"maxclass" : "bpatcher",
					"name" : "hat.maxpat",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 1140.0, 42.749016, 164.0, 188.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 18.181824, 327.939026, 164.0, 188.0 ]
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-22",
					"maxclass" : "button",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"patching_rect" : [ 233.0, 443.0, 20.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-20",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 233.0, 479.0, 60.0, 20.0 ],
					"text" : "s recover"
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-17",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 233.0, 400.0, 61.0, 20.0 ],
					"text" : "s reduce"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-16",
					"maxclass" : "button",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"patching_rect" : [ 233.0, 363.0, 20.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-12",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 394.391357, 462.0, 35.0, 20.0 ],
					"text" : "s vol"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-11",
					"maxclass" : "live.gain~",
					"numinlets" : 2,
					"numoutlets" : 5,
					"outlettype" : [ "signal", "signal", "", "float", "list" ],
					"parameter_enable" : 1,
					"patching_rect" : [ 394.391357, 304.074402, 48.0, 136.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 684.0, 327.939026, 48.0, 162.0 ],
					"saved_attribute_attributes" : 					{
						"valueof" : 						{
							"parameter_longname" : "SUB",
							"parameter_shortname" : "SUB",
							"parameter_type" : 0,
							"parameter_mmin" : -70.0,
							"parameter_mmax" : 6.0,
							"parameter_initial_enable" : 1,
							"parameter_initial" : [ -9.0 ],
							"parameter_unitstyle" : 4
						}

					}
,
					"varname" : "SUB"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-9",
					"maxclass" : "bpatcher",
					"name" : "toneDist.maxpat",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 937.0, 42.749016, 163.0, 188.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 598.0, 38.749016, 163.0, 188.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-10",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 185.0, 73.0, 32.5, 18.0 ],
					"text" : "1"
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-8",
					"maxclass" : "newobj",
					"numinlets" : 0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 185.0, 42.749016, 27.0, 20.0 ],
					"text" : "r lb"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-1",
					"maxclass" : "bpatcher",
					"name" : "click.maxpat",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 739.0, 42.749016, 162.0, 188.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 398.0, 38.749016, 162.0, 188.0 ]
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-5",
					"maxclass" : "bpatcher",
					"name" : "toneMod.maxpat",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 530.0, 36.10437, 161.0, 192.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 211.0, 36.749016, 161.0, 192.0 ]
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-43",
					"maxclass" : "bpatcher",
					"name" : "pulse.maxpat",
					"numinlets" : 2,
					"numoutlets" : 2,
					"outlettype" : [ "signal", "signal" ],
					"patching_rect" : [ 298.181824, 36.10437, 162.454544, 193.090912 ],
					"presentation" : 1,
					"presentation_rect" : [ 18.181824, 36.749016, 162.454544, 193.090912 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-19",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 139.090897, 122.727272, 45.0, 20.0 ],
					"text" : "s sync"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-18",
					"maxclass" : "toggle",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "int" ],
					"parameter_enable" : 0,
					"patching_rect" : [ 139.090897, 42.749016, 20.0, 20.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 605.5, 394.939026, 20.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-7",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 50.891357, 114.649826, 29.0, 20.0 ],
					"text" : "s lb"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-6",
					"maxclass" : "button",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"patching_rect" : [ 50.891357, 79.112625, 20.0, 20.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 605.5, 344.302612, 20.0, 20.0 ]
				}

			}
, 			{
				"box" : 				{
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-4",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"patching_rect" : [ 50.891357, 42.749016, 60.0, 20.0 ],
					"text" : "loadbang"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-3",
					"maxclass" : "live.gain~",
					"numinlets" : 2,
					"numoutlets" : 5,
					"outlettype" : [ "signal", "signal", "", "float", "list" ],
					"parameter_enable" : 1,
					"patching_rect" : [ 41.391357, 182.074402, 48.0, 136.0 ],
					"presentation" : 1,
					"presentation_rect" : [ 636.0, 327.939026, 48.0, 162.0 ],
					"saved_attribute_attributes" : 					{
						"valueof" : 						{
							"parameter_longname" : "MAIN",
							"parameter_shortname" : "MAIN",
							"parameter_type" : 0,
							"parameter_mmin" : -70.0,
							"parameter_mmax" : 6.0,
							"parameter_initial_enable" : 1,
							"parameter_initial" : [ -9.0 ],
							"parameter_unitstyle" : 4
						}

					}
,
					"varname" : "MAIN"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-2",
					"maxclass" : "ezdac~",
					"numinlets" : 2,
					"numoutlets" : 0,
					"patching_rect" : [ 44.391357, 342.074402, 45.0, 45.0 ]
				}

			}
, 			{
				"box" : 				{
					"bgcolor" : [ 0.290623, 0.289219, 0.292027, 1.0 ],
					"id" : "obj-29",
					"maxclass" : "panel",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 555.0, 479.0, 128.0, 128.0 ],
					"presentation" : 1,
					"presentation_rect" : [ -4.818176, -5.0, 1395.0, 727.0 ]
				}

			}
 ],
		"lines" : [ 			{
				"patchline" : 				{
					"destination" : [ "obj-41", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-1", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-41", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-1", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-18", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-10", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-2", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-10", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-12", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-11", 2 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-46", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-13", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-46", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-13", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-50", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-14", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-50", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-14", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-15", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-15", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-17", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-16", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-19", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-18", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-48", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-21", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-48", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-21", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-20", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-22", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-27", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-23", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-31", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-23", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-54", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-23", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-25", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-25", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-2", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-3", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-2", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-3", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"color" : [ 0.616004, 0.0, 0.011558, 1.0 ],
					"destination" : [ "obj-1", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-31", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"color" : [ 0.616004, 0.0, 0.011558, 1.0 ],
					"destination" : [ "obj-14", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-31", 2 ]
				}

			}
, 			{
				"patchline" : 				{
					"color" : [ 0.616004, 0.0, 0.011558, 1.0 ],
					"destination" : [ "obj-21", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-31", 4 ]
				}

			}
, 			{
				"patchline" : 				{
					"color" : [ 0.616004, 0.0, 0.011558, 1.0 ],
					"destination" : [ "obj-5", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-31", 3 ]
				}

			}
, 			{
				"patchline" : 				{
					"color" : [ 0.616004, 0.0, 0.011558, 1.0 ],
					"destination" : [ "obj-9", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-31", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-37", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-35", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-6", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-4", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-41", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-41", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-44", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-43", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-44", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-44", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-46", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-46", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-48", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-48", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-15", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-5", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-15", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-5", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-50", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-50", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-56", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-54", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-58", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-56", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-58", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-56", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-58", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-58", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-7", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-6", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-10", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-8", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-25", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-9", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-25", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-9", 0 ]
				}

			}
 ],
		"parameters" : 		{
			"obj-21::obj-7::obj-40" : [ "live.text[13]", "live.text", 0 ],
			"obj-56::obj-66" : [ "CHORD_RATE", "CHORD_RATE", 0 ],
			"obj-5::obj-3::obj-34" : [ "VOL[1]", "VOL", 0 ],
			"obj-21::obj-7::obj-7" : [ "MIX[10]", "MIX", 0 ],
			"obj-9::obj-116::obj-40" : [ "live.text[10]", "live.text", 0 ],
			"obj-13::obj-7::obj-7" : [ "MIX[9]", "MIX", 0 ],
			"obj-56::obj-17::obj-11" : [ "live.text[20]", "live.text", 0 ],
			"obj-5::obj-116::obj-40" : [ "live.text[4]", "live.text", 0 ],
			"obj-56::obj-41::obj-7" : [ "MIX[13]", "MIX", 0 ],
			"obj-14::obj-17::obj-11" : [ "live.text[16]", "live.text", 0 ],
			"obj-1::obj-17::obj-100" : [ "live.tab[3]", "live.tab", 0 ],
			"obj-43::obj-17::obj-57" : [ "live.tab", "live.tab", 0 ],
			"obj-3" : [ "MAIN", "MAIN", 0 ],
			"obj-43::obj-17::obj-11" : [ "live.text", "live.text", 0 ],
			"obj-9::obj-114::obj-40" : [ "live.text[9]", "live.text", 0 ],
			"obj-9::obj-7::obj-7" : [ "MIX[5]", "MIX", 0 ],
			"obj-21::obj-3::obj-6" : [ "mute[5]", "mute", 0 ],
			"obj-14::obj-7::obj-7" : [ "MIX[11]", "MIX", 0 ],
			"obj-43::obj-8" : [ "PARAM", "PARAM", 0 ],
			"obj-14::obj-8" : [ "PARAM[6]", "PARAM", 0 ],
			"obj-56::obj-41::obj-40" : [ "live.text[21]", "live.text", 0 ],
			"obj-14::obj-3::obj-6" : [ "mute[6]", "mute", 0 ],
			"obj-56::obj-69::obj-7" : [ "MIX[14]", "MIX", 0 ],
			"obj-9::obj-87::obj-40" : [ "live.text[8]", "live.text", 0 ],
			"obj-56::obj-17::obj-57" : [ "live.tab[11]", "live.tab", 0 ],
			"obj-14::obj-17::obj-57" : [ "live.tab[8]", "live.tab", 0 ],
			"obj-56::obj-3::obj-34" : [ "VOL[7]", "VOL", 0 ],
			"obj-13::obj-3::obj-6" : [ "mute[4]", "mute", 0 ],
			"obj-21::obj-8" : [ "PARAM[5]", "PARAM", 0 ],
			"obj-1::obj-7::obj-40" : [ "live.text[5]", "live.text", 0 ],
			"obj-21::obj-3::obj-34" : [ "VOL[5]", "VOL", 0 ],
			"obj-5::obj-116::obj-7" : [ "MIX[3]", "MIX", 0 ],
			"obj-9::obj-3::obj-6" : [ "mute[3]", "mute", 0 ],
			"obj-9::obj-87::obj-7" : [ "MIX[6]", "MIX", 0 ],
			"obj-9::obj-116::obj-7" : [ "MIX[8]", "MIX", 0 ],
			"obj-14::obj-17::obj-100" : [ "live.tab[9]", "live.tab", 0 ],
			"obj-9::obj-8" : [ "PARAM[3]", "PARAM", 0 ],
			"obj-13::obj-7::obj-40" : [ "live.text[11]", "live.text", 0 ],
			"obj-56::obj-3::obj-6" : [ "mute[7]", "mute", 0 ],
			"obj-9::obj-114::obj-7" : [ "MIX[7]", "MIX", 0 ],
			"obj-53::obj-7" : [ "live.dial", "BPM", 0 ],
			"obj-21::obj-17::obj-57" : [ "live.tab[7]", "live.tab", 0 ],
			"obj-56::obj-69::obj-40" : [ "live.text[22]", "live.text", 0 ],
			"obj-13::obj-3::obj-34" : [ "VOL[4]", "VOL", 0 ],
			"obj-21::obj-17::obj-100" : [ "live.tab[6]", "live.tab", 0 ],
			"obj-1::obj-3::obj-6" : [ "mute[2]", "mute", 0 ],
			"obj-43::obj-17::obj-100" : [ "live.tab[1]", "live.tab", 0 ],
			"obj-5::obj-114::obj-40" : [ "live.text[3]", "live.text", 0 ],
			"obj-9::obj-3::obj-34" : [ "VOL[3]", "VOL", 0 ],
			"obj-5::obj-114::obj-7" : [ "MIX[2]", "MIX", 0 ],
			"obj-53::obj-5" : [ "live.text[18]", "live.text", 0 ],
			"obj-13::obj-17::obj-11" : [ "live.text[12]", "live.text", 0 ],
			"obj-56::obj-7::obj-40" : [ "live.text[19]", "live.text", 0 ],
			"obj-1::obj-8" : [ "PARAM[2]", "PARAM", 0 ],
			"obj-21::obj-17::obj-11" : [ "live.text[14]", "live.text", 0 ],
			"obj-14::obj-3::obj-34" : [ "VOL[6]", "VOL", 0 ],
			"obj-1::obj-7::obj-7" : [ "MIX[4]", "MIX", 0 ],
			"obj-56::obj-7::obj-7" : [ "MIX[12]", "MIX", 0 ],
			"obj-56::obj-17::obj-100" : [ "live.tab[10]", "live.tab", 0 ],
			"obj-13::obj-17::obj-100" : [ "live.tab[4]", "live.tab", 0 ],
			"obj-56::obj-8" : [ "PARAM[7]", "PARAM", 0 ],
			"obj-14::obj-7::obj-40" : [ "live.text[15]", "live.text", 0 ],
			"obj-1::obj-3::obj-34" : [ "VOL[2]", "VOL", 0 ],
			"obj-13::obj-17::obj-57" : [ "live.tab[5]", "live.tab", 0 ],
			"obj-43::obj-3::obj-6" : [ "mute", "mute", 0 ],
			"obj-5::obj-3::obj-6" : [ "mute[1]", "mute", 0 ],
			"obj-5::obj-7::obj-7" : [ "MIX", "MIX", 0 ],
			"obj-5::obj-87::obj-40" : [ "live.text[2]", "live.text", 0 ],
			"obj-5::obj-87::obj-7" : [ "MIX[1]", "MIX", 0 ],
			"obj-53::obj-43" : [ "live.text[17]", "live.text", 0 ],
			"obj-1::obj-17::obj-11" : [ "live.text[6]", "live.text", 0 ],
			"obj-11" : [ "SUB", "SUB", 0 ],
			"obj-43::obj-3::obj-34" : [ "VOL", "VOL", 0 ],
			"obj-5::obj-8" : [ "PARAM[1]", "PARAM", 0 ],
			"obj-9::obj-7::obj-40" : [ "live.text[7]", "live.text", 0 ],
			"obj-5::obj-7::obj-40" : [ "live.text[1]", "live.text", 0 ],
			"obj-1::obj-17::obj-57" : [ "live.tab[2]", "live.tab", 0 ],
			"obj-13::obj-8" : [ "PARAM[4]", "PARAM", 0 ]
		}
,
		"dependency_cache" : [ 			{
				"name" : "pulse.maxpat",
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
				"name" : "quantizer.maxpat",
				"bootpath" : "/Users/sonir/Documents/boxes/prj_box/1706_synp/2_dev/171119_sonification",
				"patcherrelativepath" : ".",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "toneMod.maxpat",
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
				"name" : "click.maxpat",
				"bootpath" : "/Users/sonir/Documents/boxes/prj_box/1706_synp/2_dev/171119_sonification",
				"patcherrelativepath" : ".",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "toneDist.maxpat",
				"bootpath" : "/Users/sonir/Documents/boxes/prj_box/1706_synp/2_dev/171119_sonification",
				"patcherrelativepath" : ".",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "hat.maxpat",
				"bootpath" : "/Users/sonir/Documents/boxes/prj_box/1706_synp/2_dev/171119_sonification",
				"patcherrelativepath" : ".",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "kick.maxpat",
				"bootpath" : "/Users/sonir/Documents/boxes/prj_box/1706_synp/2_dev/171119_sonification",
				"patcherrelativepath" : ".",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "glitch.maxpat",
				"bootpath" : "/Users/sonir/Documents/boxes/prj_box/1706_synp/2_dev/171119_sonification",
				"patcherrelativepath" : ".",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "rcv_synapse.maxpat",
				"bootpath" : "/Users/sonir/Documents/boxes/prj_box/1706_synp/2_dev/171119_sonification",
				"patcherrelativepath" : ".",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "autoVol.maxpat",
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
, 			{
				"name" : "chord.maxpat",
				"bootpath" : "/Users/sonir/Documents/boxes/prj_box/1706_synp/2_dev/171119_sonification",
				"patcherrelativepath" : ".",
				"type" : "JSON",
				"implicit" : 1
			}
 ]
	}

}
