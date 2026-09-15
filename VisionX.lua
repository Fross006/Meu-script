-- V35.3.8 — Wi-Fi crisp: geometria em pixels inteiros, sem escala fracionada e com curvas mais limpas.
-- Bootstrap do build completo V35.3.4 com o patch visual V35.3.8 aplicado em memória.

local BASE_URL = "https://raw.githubusercontent.com/Fross006/Meu-script/09152fc9f5e7791381e4b955856f5431b987c700/VisionX.lua"

local source = game:HttpGet(BASE_URL)
assert(type(source) == "string" and #source > 1000, "VisionX: falha ao carregar o build-base.")

local function replaceBetween(text, startMarker, endMarker, replacement, searchStart)
    local startAt = string.find(text, startMarker, searchStart or 1, true)
    assert(startAt, "VisionX: início do patch não encontrado: " .. startMarker)

    local endAt = string.find(text, endMarker, startAt + #startMarker, true)
    assert(endAt, "VisionX: fim do patch não encontrado: " .. endMarker)

    return string.sub(text, 1, startAt - 1) .. replacement .. string.sub(text, endAt)
end

local function replaceExact(text, oldText, newText, searchStart, errorName)
    local at = string.find(text, oldText, searchStart or 1, true)
    assert(at, "VisionX: patch não encontrado: " .. tostring(errorName or oldText))
    return string.sub(text, 1, at - 1) .. newText .. string.sub(text, at + #oldText)
end

source = source:gsub(
    "^%-%- V35%.3%.4[^\n]*",
    "-- V35.3.8 — Wi-Fi crisp com pixels inteiros e sem escala fracionada; demais funções preservadas.",
    1
)

local sharpStart = assert(
    string.find(source, "function UI.CreateSharpNavigationIcon", 1, true),
    "VisionX: CreateSharpNavigationIcon não encontrado."
)

-- O blur principal vinha do ícone de 32 px inteiro ser rasterizado por um UIScale fracionário.
-- Guardamos o UIScale para desativá-lo somente no PING e desenhar já no tamanho final em pixels.
local oldScaleLine = '    Util.New("UIScale", {Scale = size / 32}, glyph.Box)\n'
local newScaleLine = '    local navigationScale = Util.New("UIScale", {Scale = size / 32}, glyph.Box)\n'
source = replaceExact(source, oldScaleLine, newScaleLine, sharpStart, "UIScale do ícone de navegação")

local pingStartMarker = '    if kind == "PING" then\n'
local pingEndMarker = '    else\n        if kind == "JOGADORES" or kind == "ESP" then'

local newPingBranch = [=[    if kind == "PING" then
        -- PING é desenhado diretamente no tamanho final para não sofrer reamostragem.
        navigationScale.Scale = 1

        local iconSize = math.max(16, math.floor((tonumber(size) or 32) + .5))
        glyph.Box.Size = UDim2.fromOffset(iconSize, iconSize)
        glyph.PingLayers = {}

        local function px(value)
            return math.floor(value + .5)
        end

        -- Todas as medidas abaixo terminam em pixels inteiros.
        local centerX = px(iconSize * .50)
        local arcCenterY = px(iconSize * .75)
        local pointY = px(iconSize * .91)
        local radii = {
            math.max(4, px(iconSize * .19)),
            math.max(7, px(iconSize * .35)),
            math.max(10, px(iconSize * .50)),
        }
        local thickness = math.max(2, px(iconSize * .065))
        local pointSize = math.max(3, thickness + 1)
        local extentRatio = .78

        for index = 0, 3 do
            local holder = Util.New("Frame", {
                Name = ("SignalLayer_%d"):format(index),
                Position = UDim2.fromOffset(0, 2),
                Size = UDim2.fromOffset(iconSize, iconSize),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
            }, glyph.Box)
            fallback[#fallback + 1] = holder

            local layer = {
                Ink = {},
                Holder = holder,
                BasePosition = UDim2.fromOffset(0, 0),
                HiddenPosition = UDim2.fromOffset(0, 2),
            }
            glyph.PingLayers[index + 1] = layer

            local function ink(object, colorProperty, alphaProperty)
                glyph.Ink[#glyph.Ink + 1] = {object, colorProperty}
                layer.Ink[#layer.Ink + 1] = {object, alphaProperty}
                object[alphaProperty] = .86
            end

            local function dot(x, y, diameter)
                diameter = math.max(2, px(diameter))
                local object = Util.New("Frame", {
                    AnchorPoint = Vector2.new(.5, .5),
                    Position = UDim2.fromOffset(px(x), px(y)),
                    Size = UDim2.fromOffset(diameter, diameter),
                    BackgroundColor3 = Theme.Sub,
                    BorderSizePixel = 0,
                }, holder)
                Util.New("UICorner", {CornerRadius = UDim.new(1, 0)}, object)
                ink(object, "BackgroundColor3", "BackgroundTransparency")
                return object
            end

            if index == 0 then
                -- Ponto central pequeno, perfeitamente alinhado e separado da primeira onda.
                dot(centerX, pointY, pointSize)
            else
                local radius = radii[index]
                local weight = thickness
                local extent = px(radius * extentRatio)
                local rise = px(math.sqrt(math.max(0, radius * radius - extent * extent)))
                local endpointY = arcCenterY - rise
                local padding = math.max(4, thickness + 2)

                local clip = Util.New("Frame", {
                    Name = "CircularArcClip",
                    Position = UDim2.fromOffset(
                        centerX - radius - padding,
                        arcCenterY - radius - padding
                    ),
                    Size = UDim2.fromOffset(
                        radius * 2 + padding * 2,
                        radius - rise + padding + thickness
                    ),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                }, holder)

                local ring = Util.New("Frame", {
                    Name = "SignalArc",
                    Position = UDim2.fromOffset(padding, padding),
                    Size = UDim2.fromOffset(radius * 2, radius * 2),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                }, clip)

                Util.New("UICorner", {CornerRadius = UDim.new(1, 0)}, ring)
                local stroke = Util.Stroke(ring, Theme.Sub, .86, weight)

                pcall(function()
                    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                end)
                pcall(function()
                    stroke.LineJoinMode = Enum.LineJoinMode.Round
                end)
                pcall(function()
                    stroke.BorderStrokePosition = Enum.BorderStrokePosition.Center
                end)

                ink(stroke, "Color", "Transparency")

                -- Caps inteiros evitam pontas quadradas e mantêm ambos os lados idênticos.
                dot(centerX - extent, endpointY, weight)
                dot(centerX + extent, endpointY, weight)
            end
        end
]=]

source = replaceBetween(
    source,
    pingStartMarker,
    pingEndMarker,
    newPingBranch,
    sharpStart
)

local updateStartMarker = "function UI.UpdatePingIcon(ping, instant)\n"
local updateEndMarker = "\nfunction UI.CreateNavigationIcon(parent, kind, size)"

local newUpdatePingIcon = [=[function UI.UpdatePingIcon(ping, instant)
    local glyph = State.UI.PingIcon
    if not glyph or not glyph.Box.Parent or not glyph.PingLayers then return end

    ping = Persistence.FiniteNumber(ping, nil)
    local known = ping ~= nil and ping >= 0
    State.UI.LastPingValue = known and ping or nil

    local previous = glyph.SignalLevel
    local wasKnown = glyph.SignalKnown == true
    local level = UI.PingSignalLevel(known and ping or nil, previous)
    if not instant and previous == level and glyph.SignalKnown == known then return end

    glyph.SignalLevel, glyph.SignalKnown = level, known
    glyph.SignalGeneration = (glyph.SignalGeneration or 0) + 1
    local generation = glyph.SignalGeneration
    local oldLevel = math.clamp(previous or 0, 0, 3)
    local activeAlpha = .02
    local inactiveAlpha = known and .86 or .93
    local stepDelay = .05
    local tweenTime = .16

    local function stable(layer, active)
        Util.StopTween(layer.Holder)
        layer.Holder.Position = active and layer.BasePosition or layer.HiddenPosition
        for _, entry in ipairs(layer.Ink) do
            Util.StopTween(entry[1])
            entry[1][entry[2]] = active and activeAlpha or inactiveAlpha
        end
    end

    local function animate(layer, active, delayTime)
        local function paint()
            if not Runtime.Alive or not glyph.Box.Parent or glyph.SignalGeneration ~= generation then return end

            Util.StopTween(layer.Holder)
            for _, entry in ipairs(layer.Ink) do
                Util.StopTween(entry[1])
            end

            if active then
                -- Melhorou: ondas entram de baixo para cima, do centro para fora.
                layer.Holder.Position = layer.HiddenPosition
                for _, entry in ipairs(layer.Ink) do
                    entry[1][entry[2]] = inactiveAlpha
                end
                Util.Tween(layer.Holder, {Position = layer.BasePosition}, tweenTime, Enum.EasingStyle.Quad)
                for _, entry in ipairs(layer.Ink) do
                    Util.Tween(entry[1], {[entry[2]] = activeAlpha}, tweenTime, Enum.EasingStyle.Quad)
                end
            else
                -- Piorou: ondas descem e apagam de fora para dentro.
                Util.Tween(layer.Holder, {Position = layer.HiddenPosition}, tweenTime, Enum.EasingStyle.Quad)
                for _, entry in ipairs(layer.Ink) do
                    Util.Tween(entry[1], {[entry[2]] = inactiveAlpha}, tweenTime, Enum.EasingStyle.Quad)
                end
            end
        end

        if delayTime <= 0 then
            paint()
        else
            task.delay(delayTime, paint)
        end
    end

    for index, layer in ipairs(glyph.PingLayers) do
        local arc = index - 1
        local oldActive = wasKnown and (arc == 0 or arc <= oldLevel)
        local newActive = known and (arc == 0 or arc <= level)

        if instant then
            stable(layer, newActive)
        elseif oldActive == newActive then
            stable(layer, newActive)
        elseif newActive then
            local rank
            if wasKnown then
                rank = math.max(0, arc - oldLevel - 1)
            else
                rank = arc
            end
            animate(layer, true, rank * stepDelay)
        else
            local rank = math.max(0, oldLevel - arc)
            animate(layer, false, rank * stepDelay)
        end
    end
end
]=]

source = replaceBetween(
    source,
    updateStartMarker,
    updateEndMarker,
    newUpdatePingIcon,
    1
)

local compiled, compileError = loadstring(source, "VisionX.lua")
assert(compiled, "VisionX V35.3.8: " .. tostring(compileError))
return compiled()
