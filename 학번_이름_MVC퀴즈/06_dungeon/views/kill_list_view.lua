local KillListView = { title = "처치한 적" }
KillListView.__index = KillListView

function KillListView.new()
  return setmetatable({}, KillListView)
end

function KillListView:lines(game)
  local names = game.killList.names
  if #names == 0 then
    return { "처치한 적이 없습니다." }
  end
  return names
end

return KillListView
