local TARGET_GOLD = 15

local AchievementModel = {}
AchievementModel.__index = AchievementModel

function AchievementModel.new(bus)
  local self = setmetatable({ killGold = 0, unlocked = false }, AchievementModel)
  bus:on("enemy_killed", function(event)
    self.killGold = self.killGold + event.gold
    if not self.unlocked and self.killGold >= TARGET_GOLD then
      self.unlocked = true
      bus:emit("achievement_unlocked", { target = TARGET_GOLD })
    end
  end)
  return self
end

return AchievementModel
