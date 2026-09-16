-- V35.3.16 — Wi‑Fi redesenhado sem máscara: arcos limpos, sem blocos ou recortes.
-- Mantém integralmente a V35.3.15 e troca somente o desenho do ícone de conexão.

local PREVIOUS_BUILD = "https://raw.githubusercontent.com/Fross006/Meu-script/2eec94fb61368f8b12ab0ae4a953c5c9aa492ed5/VisionX.lua"

local source = game:HttpGet(PREVIOUS_BUILD)
assert(type(source) == "string" and #source > 1000, "VisionX: falha ao carregar a V35.3.15.")

local startMarker = 'local newPingBranch = [=[    if kind == "PING" then\n'
local endMarker = '\n]=]\n\nsource = replaceBetween(\n    source,\n    pingStartMarker,'

local startAt = assert(
    string.find(source, startMarker, 1, true),
    "VisionX V35.3.16: início do bloco Wi-Fi não encontrado."
)

local endAt = assert(
    string.find(source, endMarker, startAt + #startMarker, true),
    "VisionX V35.3.16: fim do bloco Wi-Fi não encontrado."
)

local replacement = [=[local newPingBranch = [=[    if kind == "PING" then
        navigationScale.Scale = 1

        -- Wi-Fi desenhado sem UIStroke circular/máscara.
        -- Cada arco usa pequenos pontos sobrepostos, evitando o bloco semicircular
        -- que aparecia em alguns executores/dispositivos.
        local iconSize = math.max(18, math.floor((tonumber(size) or 18) + .5))
        glyph.Box.Size = UDim2.fromOffset(iconSize, iconSize)
        glyph.PingLayers = {}

        local centerX = iconSize * .50
        local centerY = iconSize * .76
        local pointY = iconSize * .88
        local thickness = math.max(1.7, iconSize * .095)
        local pointSize = math.max(3.2, thickness * 1.65)

        local radii = {
            iconSize * .205,
            iconSize * .330,
            iconSize * .455,
        }

        local samples = {7, 10, 13}
        local startAngle = math.rad(210)
        local endAngle = math.rad(330)

        for index = 0, 3 do
            local holder = Util.New("Frame", {
                Name = ("SignalLayer_%d"):format(index),
                Position = UDim2.fromOffset(0, 3),
                Size = UDim2.fromOffset(iconSize, iconSize),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
            }, glyph.Box)

            fallback[#fallback + 1] = holder

            local layer = {
                Ink = {},
                Holder = holder,
                BasePosition = UDim2.fromOffset(0, 0),
                LiftPosition = UDim2.fromOffset(0, -1),
                HiddenPosition = UDim2.fromOffset(0, 3),
            }

            glyph.PingLayers[index + 1] = layer

            local function addDot(x, y, diameter)
                local dot = Util.New("Frame", {
                    AnchorPoint = Vector2.new(.5, .5),
                    Position = UDim2.fromOffset(
                        math.floor(x + .5),
                        math.floor(y + .5)
                    ),
                    Size = UDim2.fromOffset(
                        math.max(2, math.floor(diameter + .5)),
                        math.max(2, math.floor(diameter + .5))
                    ),
                    BackgroundColor3 = Theme.Sub,
                    BackgroundTransparency = .88,
                    BorderSizePixel = 0,
                }, holder)

                Util.New("UICorner", {
                    CornerRadius = UDim.new(1, 0)
                }, dot)

                glyph.Ink[#glyph.Ink + 1] = {dot, "BackgroundColor3"}
                layer.Ink[#layer.Ink + 1] = {dot, "BackgroundTransparency"}
            end

            if index == 0 then
                addDot(centerX, pointY, pointSize)
            else
                local radius = radii[index]
                local count = samples[index]

                for sample = 0, count - 1 do
                    local t = sample / (count - 1)
                    local angle = startAngle + (endAngle - startAngle) * t
                    local x = centerX + math.cos(angle) * radius
                    local y = centerY + math.sin(angle) * radius
                    addDot(x, y, thickness)
                end
            end
        end
]=]

source = string.sub(source, 1, startAt - 1)
    .. replacement
    .. string.sub(source, endAt)

source = source:gsub("V35%.3%.15", "V35.3.16")

local compiled, compileError = loadstring(source, "VisionX_V35.3.16.lua")
assert(compiled, "VisionX V35.3.16: " .. tostring(compileError))
return compiled()
