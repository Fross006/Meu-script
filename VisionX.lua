-- V35.3.17 — status limpo: somente ping em ms e FPS, sem ícones.
-- Mantém o restante da interface e das funções sem alterações.

local PREVIOUS_BUILD = "https://raw.githubusercontent.com/Fross006/Meu-script/2eec94fb61368f8b12ab0ae4a953c5c9aa492ed5/VisionX.lua"

local source = game:HttpGet(PREVIOUS_BUILD)
assert(type(source) == "string" and #source > 1000, "VisionX: falha ao carregar o build-base.")

local function replaceExact(text, oldText, newText, errorName)
    local at = string.find(text, oldText, 1, true)
    assert(at, "VisionX V35.3.17: patch não encontrado: " .. tostring(errorName))
    return string.sub(text, 1, at - 1) .. newText .. string.sub(text, at + #oldText)
end

source = source:gsub(
    "^%-%- V35%.3%.15[^\n]*",
    "-- V35.3.17 — status limpo: somente ping em ms e FPS, sem ícones.",
    1
)

-- Remove somente a criação dos ícones de ping/FPS.
source = replaceExact(
    source,
    [[    local fpsIcon = UI.CreateNavigationIcon(metrics, "FPS", 13)
    local pingIcon = UI.CreateNavigationIcon(metrics, "PING", 18)
    State.UI.PingIcon = pingIcon]],
    [[    State.UI.PingIcon = nil]],
    "criação dos ícones de status"
)

-- Mantém os dois textos no mesmo local, agora sem espaço reservado para ícones.
source = replaceExact(
    source,
    [[        local statusX = avatarSize + 16
        local fpsIconSize = 16
        local pingIconSize = 18

        for _, icon in ipairs({fpsIcon, pingIcon}) do
            icon.Box.Visible = true
            icon.Box.AnchorPoint = Vector2.new(0, .5)
        end

        pingIcon.Box.Position = UDim2.new(0, statusX, .29, 0)
        local pingScale = pingIcon.Box:FindFirstChildOfClass("UIScale")
        if pingScale then
            pingScale.Scale = 1
        end

        fpsIcon.Box.Position = UDim2.new(0, statusX + 1, .72, 0)
        local fpsScale = fpsIcon.Box:FindFirstChildOfClass("UIScale")
        if fpsScale then
            fpsScale.Scale = fpsIconSize / 32
        end

        State.UI.PingLabel.AnchorPoint = Vector2.new(0, .5)
        State.UI.FPSLabel.AnchorPoint = Vector2.new(0, .5)

        local pingTextX = statusX + pingIconSize + 5
        local fpsTextX = statusX + fpsIconSize + 6

        State.UI.PingLabel.Position = UDim2.new(0, pingTextX, .29, 0)
        State.UI.FPSLabel.Position = UDim2.new(0, fpsTextX, .72, 0)

        State.UI.PingLabel.Size = UDim2.new(1, -pingTextX, 0, 17)
        State.UI.FPSLabel.Size = UDim2.new(1, -fpsTextX, 0, 17)]],
    [[        local statusX = avatarSize + 16

        State.UI.PingLabel.AnchorPoint = Vector2.new(0, .5)
        State.UI.FPSLabel.AnchorPoint = Vector2.new(0, .5)

        State.UI.PingLabel.Position = UDim2.new(0, statusX, .29, 0)
        State.UI.FPSLabel.Position = UDim2.new(0, statusX, .72, 0)

        State.UI.PingLabel.Size = UDim2.new(1, -statusX, 0, 17)
        State.UI.FPSLabel.Size = UDim2.new(1, -statusX, 0, 17)]],
    "layout dos ícones de status"
)

local compiled, compileError = loadstring(source, "VisionX.lua")
assert(compiled, "VisionX V35.3.17: " .. tostring(compileError))
return compiled()
