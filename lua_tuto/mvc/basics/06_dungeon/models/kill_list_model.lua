local KillListModel = {}
KillListModel.__index = KillListModel

function KillListModel.new(bus)
  local self = setmetatable({ names = {} }, KillListModel)
  bus:on("enemy_killed", function(event)
    self.names[#self.names + 1] = event.name
  end)
  return self
end

return KillListModel
