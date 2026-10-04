local folder = script.Parent.GGH
local core = require(folder.Core)
local GGH = core.new()
local modules = {
	Themes = require(folder.Themes),
	ConnectionBag = require(folder.Systems.ConnectionBag),
	Viewport = require(folder.Systems.Viewport),
	ElementRegistry = require(folder.Elements.Registry),
}

modules.Icons = require(folder.Icons)(GGH)
modules.Utils = require(folder.Utils)(GGH)
require(folder.Window)(GGH, modules)
require(folder.Systems.KeySystem)(GGH, modules)

return GGH