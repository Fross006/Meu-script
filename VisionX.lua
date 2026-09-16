-- V35.3.11 — perfil local integrado sem substituir FPS/ping; Wi-Fi crisp preservado.
-- Bootstrap do build completo V35.3.4 com patches visuais aplicados diretamente na interface original.

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
    "-- V35.3.11 — perfil local integrado, FPS/ping originais preservados e Wi-Fi crisp.",
    1
)

--==============================================================
-- WI-FI CRISP
--==============================================================

local sharpStart = assert(
    string.find(source, "function UI.CreateSharpNavigationIcon", 1, true),
    "VisionX: CreateSharpNavigationIcon não encontrado."
)

local oldScaleLine = '    Util.New("UIScale", {Scale = size / 32}, glyph.Box)\n'
local newScaleLine = '    local navigationScale = Util.New("UIScale", {Scale = size / 32}, glyph.Box)\n'
source = replaceExact(source, oldScaleLine, newScaleLine, sharpStart, "UIScale do ícone de navegação")

local pingStartMarker = '    if kind == "PING" then\n'
local pingEndMarker = '    else\n        if kind == "JOGADORES" or kind == "ESP" then'

local newPingBranch = [=[    if kind == "PING" then
        -- Wi-Fi nativo desenhado no tamanho final, sem reamostragem fracionada.
        navigationScale.Scale = 1

        local iconSize = math.max(16, math.floor((tonumber(size) or 32) + .5))
        glyph.Box.Size = UDim2.fromOffset(iconSize, iconSize)
        glyph.PingLayers = {}

        local function px(value)
            return math.floor(value + .5)
        end

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
                layer.Holder.Position = layer.HiddenPosition
                for _, entry in ipairs(layer.Ink) do
                    entry[1][entry[2]] = inactiveAlpha
                end
                Util.Tween(layer.Holder, {Position = layer.BasePosition}, tweenTime, Enum.EasingStyle.Quad)
                for _, entry in ipairs(layer.Ink) do
                    Util.Tween(entry[1], {[entry[2]] = activeAlpha}, tweenTime, Enum.EasingStyle.Quad)
                end
            else
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

--==============================================================
-- PERFIL LOCAL INTEGRADO À ÁREA ORIGINAL DE FPS/PING
--==============================================================

-- Em vez de cobrir ou substituir os indicadores existentes, recriamos apenas
-- o pequeno bloco ConnectionMetrics adicionando o avatar ao lado dos mesmos
-- fpsIcon/pingIcon e dos mesmos FPSLabel/PingLabel do build original.
local metricsStartMarker = '\tlocal metrics = Util.New("Frame", {Name = "ConnectionMetrics"'
local metricsEndMarker = '\tlocal header = Util.New("Frame", {Name = "PageHeader"'

local newMetricsBlock = [=[	local metrics = Util.New("Frame", {Name = "ConnectionMetrics", BackgroundTransparency = 1,
		BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), ClipsDescendants = true}, nav)
	Util.New("Frame", {Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.BorderSoft,
		BackgroundTransparency = .15, BorderSizePixel = 0}, metrics)

	-- Mantém os dois ícones originais. Só o PING usa o desenho crisp do patch.
	local fpsIcon = UI.CreateNavigationIcon(metrics, "FPS", 13)
	local pingIcon = UI.CreateNavigationIcon(metrics, "PING", 16)
	State.UI.PingIcon = pingIcon
	State.UI.FPSLabel.Parent = metrics
	State.UI.PingLabel.Parent = metrics
	for _, label in ipairs({State.UI.FPSLabel, State.UI.PingLabel}) do
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left
	end

	-- Avatar pequeno, integrado ao mesmo rodapé. Não substitui nem duplica métricas.
	local localAvatar = Util.New("ImageLabel", {
		Name = "LocalPlayerAvatar",
		BackgroundColor3 = Theme.Surface3,
		BorderSizePixel = 0,
		Image = "",
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 6,
	}, metrics)
	Util.Corner(localAvatar, 999)
	Util.Stroke(localAvatar, Theme.Accent, .12, 2)
	UI.LoadPlayerThumbnail(localAvatar, S.LocalPlayer)
	State.UI.LocalPlayerAvatar = localAvatar

	local onlineDot = Util.New("Frame", {
		Name = "LocalPlayerOnlineDot",
		AnchorPoint = Vector2.new(.5, .5),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = Theme.Success,
		BorderSizePixel = 0,
		ZIndex = 8,
	}, metrics)
	Util.Corner(onlineDot, 999)
	Util.Stroke(onlineDot, Theme.BG, 0, 2)

	local profileDivider = Util.New("Frame", {
		Name = "LocalProfileDivider",
		BackgroundColor3 = Theme.BorderSoft,
		BackgroundTransparency = .40,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, metrics)

]=]

source = replaceBetween(
    source,
    metricsStartMarker,
    metricsEndMarker,
    newMetricsBlock,
    1
)

-- O layout original colocava FPS e ping lado a lado. Com a foto, os dois ficam
-- em duas linhas compactas dentro da própria sidebar, sem invadir o centro.
local metricsLayoutStart = '\t\tmetrics.Position = UDim2.new(0, compact and 4 or 12, 1, -4)\n'
local metricsLayoutEnd = '\t\tlocal contentWidth = w - navWidth - gap * 2\n'

local newMetricsLayout = [=[		metrics.Position = UDim2.new(0, compact and 4 or 12, 1, -4)
		metrics.Size = UDim2.new(1, compact and -8 or -24, 0, metricHeight)

		local avatarSize = compact and 28 or math.max(30, math.floor(32 * math.min(scale, 1.15) + .5))
		localAvatar.Visible = true
		localAvatar.AnchorPoint = Vector2.new(0, .5)
		localAvatar.Position = UDim2.new(0, 0, .5, 0)
		localAvatar.Size = UDim2.fromOffset(avatarSize, avatarSize)

		onlineDot.Position = UDim2.new(
			0,
			avatarSize - 2,
			.5,
			math.floor(avatarSize * .5 - 3)
		)
		onlineDot.Size = UDim2.fromOffset(compact and 7 or 8, compact and 7 or 8)

		profileDivider.Position = UDim2.new(0, avatarSize + 7, .5, -math.floor(math.min(metricHeight - 8, 34) * .5))
		profileDivider.Size = UDim2.fromOffset(1, math.min(metricHeight - 8, 34))

		local statusX = avatarSize + 14
		local metricIconSize = 16

		for _, icon in ipairs({fpsIcon, pingIcon}) do
			icon.Box.Visible = true
			icon.Box.AnchorPoint = Vector2.new(0, .5)
		end

		-- FPS mantém o ícone original; PING mantém o Wi-Fi crisp em tamanho nativo.
		fpsIcon.Box.Position = UDim2.new(0, statusX, .30, 0)
		pingIcon.Box.Position = UDim2.new(0, statusX, .72, 0)

		local fpsScale = fpsIcon.Box:FindFirstChildOfClass("UIScale")
		if fpsScale then fpsScale.Scale = metricIconSize / 32 end
		local pingScale = pingIcon.Box:FindFirstChildOfClass("UIScale")
		if pingScale then pingScale.Scale = 1 end

		local textX = statusX + metricIconSize + 5
		State.UI.FPSLabel.AnchorPoint = Vector2.new(0, .5)
		State.UI.PingLabel.AnchorPoint = Vector2.new(0, .5)
		State.UI.FPSLabel.Position = UDim2.new(0, textX, .30, 0)
		State.UI.PingLabel.Position = UDim2.new(0, textX, .72, 0)
		State.UI.FPSLabel.Size = UDim2.new(1, -textX, 0, 17)
		State.UI.PingLabel.Size = UDim2.new(1, -textX, 0, 17)
		UI.SetReadableText(State.UI.FPSLabel, compact and 7.5 or 8)
		UI.SetReadableText(State.UI.PingLabel, compact and 7.5 or 8)
]=]

source = replaceBetween(
    source,
    metricsLayoutStart,
    metricsLayoutEnd,
    newMetricsLayout,
    1
)

local compiled, compileError = loadstring(source, "VisionX.lua")
assert(compiled, "VisionX V35.3.11: " .. tostring(compileError))
return compiled()
