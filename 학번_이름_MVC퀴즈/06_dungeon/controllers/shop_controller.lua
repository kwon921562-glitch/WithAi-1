local ShopController = {}
ShopController.__index = ShopController

function ShopController.new()
  return setmetatable({}, ShopController)
end

function ShopController:handle(game, input)
  if input == "b" then
    return game:buyPotion()
  elseif input == "l" then
    return game:leaveShop()
  end
  return false, "상점에서는 b / l 을 입력하세요"
end

return ShopController
