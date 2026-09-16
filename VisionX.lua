-- V35.3.15 — Wi‑Fi clean refinado com animação dinâmica por qualidade de conexão.
-- Bootstrap do build completo V35.3.4 com patches visuais aplicados diretamente na interface original.

local BASE_URL = "https://raw.githubusercontent.com/Fross006/Meu-script/09152fc9f5e7791381e4b955856f5431b987c700/VisionX.lua"

local source = game:HttpGet(BASE_URL)
assert(type(source) == "string" and #source > 1000, "VisionX: falha ao carregar o build-base.")

local function replaceBetween(text, startMarker, endMarker, replacement, searchStart)
    local startAt = string.find(text, startMarker, searchStart or 1, true)
    assert(startAt, "VisionX: início do patch não encontrado: " .. tostring(startMarker))

    local endAt = string.find(text, endMarker, startAt + #startMarker, true)
    assert(endAt, "VisionX: fim do patch não encontrado: " .. tostring(endMarker))

    return string.sub(text, 1, startAt - 1) .. replacement .. string.sub(text, endAt)
end

local function replaceExact(text, oldText, newText, searchStart, errorName)
    local at = string.find(text, oldText, searchStart or 1, true)
    assert(at, "VisionX: patch não encontrado: " .. tostring(errorName or oldText))
    return string.sub(text, 1, at - 1) .. newText .. string.sub(text, at + #oldText)
end

source = source:gsub(
    "^%-%- V35%.3%.4[^\n]*",
    "-- V35.3.15 — Wi‑Fi clean refinado com animação dinâmica por qualidade de conexão.",
    1
)

--==============================================================
-- WI‑FI CLEAN
--==============================================================

local sharpStart = assert(
    string.find(source, "function UI.CreateSharpNavigationIcon", 1, true),
    "VisionX: CreateSharpNavigationIcon não encontrado."
)

local oldScaleLine =
    '    Util.New("UIScale", {Scale = size / 32}, glyph.Box)\n'

local newScaleLine =
    '    local navigationScale = Util.New("UIScale", {Scale = size / 32}, glyph.Box)\n'

source = replaceExact(
    source,
    oldScaleLine,
    newScaleLine,
    sharpStart,
    "UIScale do ícone de navegação"
)

local pingStartMarker =
    '    if kind == "PING" then\n'

local pingEndMarker =
    '    else\n        if kind == "JOGADORES" or kind == "ESP" then'

local newPingBranch = [=[    if kind == "PING" then
        navigationScale.Scale = 1

        -- Ícone Wi‑Fi limpo: três arcos largos + ponto, sem recorte nas bordas.
        local iconSize = math.max(18, math.floor((tonumber(size) or 18) + .5))
        glyph.Box.Size = UDim2.fromOffset(iconSize, iconSize)
        glyph.PingLayers = {}

        local function px(v)
            return math.floor(v + .5)
        end

        local centerX = iconSize * .50
        local arcCenterY = iconSize * .70
        local pointY = iconSize * .82

        local radii = {
            iconSize * .210,
            iconSize * .340,
            iconSize * .470,
        }

        local thickness = math.max(2, iconSize * .105)
        local pointSize = math.max(3.6, thickness * 1.55)
        local extentRatio = .82

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

            local function ink(object, colorProperty, alphaProperty)
                glyph.Ink[#glyph.Ink + 1] = {object, colorProperty}
                layer.Ink[#layer.Ink + 1] = {object, alphaProperty}
                object[alphaProperty] = .88
            end

            local function roundDot(x, y, diameter)
                local object = Util.New("Frame", {
                    AnchorPoint = Vector2.new(.5, .5),
                    Position = UDim2.fromOffset(px(x), px(y)),
                    Size = UDim2.fromOffset(px(diameter), px(diameter)),
                    BackgroundColor3 = Theme.Sub,
                    BorderSizePixel = 0,
                }, holder)

                Util.New("UICorner", {
                    CornerRadius = UDim.new(1, 0)
                }, object)

                ink(object, "BackgroundColor3", "BackgroundTransparency")
                return object
            end

            if index == 0 then
                roundDot(centerX, pointY, pointSize)
            else
                local radius = radii[index]
                local extent = radius * extentRatio
                local rise = math.sqrt(math.max(0, radius * radius - extent * extent))
                local endpointY = arcCenterY - rise
                local padding = math.ceil(thickness + 2)

                local clipX = centerX - radius - padding
                local clipY = arcCenterY - radius - padding
                local clipW = radius * 2 + padding * 2
                local clipH = radius - rise + padding + thickness + 1

                local clip = Util.New("Frame", {
                    Name = "SignalArcClip",
                    Position = UDim2.fromOffset(px(clipX), px(clipY)),
                    Size = UDim2.fromOffset(px(clipW), px(clipH)),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                }, holder)

                local ring = Util.New("Frame", {
                    Name = "SignalArc",
                    Position = UDim2.fromOffset(padding, padding),
                    Size = UDim2.fromOffset(px(radius * 2), px(radius * 2)),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                }, clip)

                Util.New("UICorner", {
                    CornerRadius = UDim.new(1, 0)
                }, ring)

                local stroke = Util.Stroke(ring, Theme.Sub, .88, thickness)

                pcall(function()
                    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                end)

                pcall(function()
                    stroke.LineJoinMode = Enum.LineJoinMode.Round
                end)

                ink(stroke, "Color", "Transparency")

                -- Pontas arredondadas para o mesmo acabamento da referência.
                roundDot(centerX - extent, endpointY, thickness)
                roundDot(centerX + extent, endpointY, thickness)
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

local updateStartMarker =
    "function UI.UpdatePingIcon(ping, instant)\n"

local updateEndMarker =
    "\nfunction UI.CreateNavigationIcon(parent, kind, size)"

local newUpdatePingIcon = [=[function UI.UpdatePingIcon(ping, instant)
    local glyph = State.UI.PingIcon
    if not glyph or not glyph.Box.Parent or not glyph.PingLayers then
        return
    end

    ping = Persistence.FiniteNumber(ping, nil)
    local known = ping ~= nil and ping >= 0
    State.UI.LastPingValue = known and ping or nil

    local previous = glyph.SignalLevel
    local wasKnown = glyph.SignalKnown == true
    local level = UI.PingSignalLevel(known and ping or nil, previous)

    -- Uma onda discreta mantém o Wi‑Fi "vivo". Quanto pior o ping,
    -- mais lenta fica a onda e menos arcos permanecem acesos.
    local pulseInterval = 1.05
    if known then
        if ping > 250 then
            pulseInterval = 2.20
        elseif ping > 150 then
            pulseInterval = 1.75
        elseif ping > 80 then
            pulseInterval = 1.35
        end
    end

    local now = os.clock()
    local sameState = previous == level and glyph.SignalKnown == known
    local shouldPulse = (
        known
        and sameState
        and not instant
        and (now - (glyph.LastSignalPulse or 0)) >= pulseInterval
    )

    if not instant and sameState and not shouldPulse then
        return
    end

    if shouldPulse then
        glyph.LastSignalPulse = now
    elseif not sameState then
        glyph.LastSignalPulse = now
    end

    glyph.SignalLevel = level
    glyph.SignalKnown = known
    glyph.SignalGeneration = (glyph.SignalGeneration or 0) + 1

    local generation = glyph.SignalGeneration
    local oldLevel = math.clamp(previous or 0, 0, 3)

    local activeAlpha = .04
    local inactiveAlpha = known and .84 or .92
    local pulseAlpha = 0
    local stepDelay = .055
    local tweenTime = .17

    local function stopLayer(layer)
        Util.StopTween(layer.Holder)
        for _, entry in ipairs(layer.Ink) do
            Util.StopTween(entry[1])
        end
    end

    local function setLayer(layer, active)
        stopLayer(layer)
        layer.Holder.Position = active and layer.BasePosition or layer.HiddenPosition

        for _, entry in ipairs(layer.Ink) do
            entry[1][entry[2]] = active and activeAlpha or inactiveAlpha
        end
    end

    local function transitionLayer(layer, active, delayTime)
        task.delay(math.max(0, delayTime or 0), function()
            if not Runtime.Alive or not glyph.Box.Parent or glyph.SignalGeneration ~= generation then
                return
            end

            stopLayer(layer)

            if active then
                layer.Holder.Position = layer.HiddenPosition
                for _, entry in ipairs(layer.Ink) do
                    entry[1][entry[2]] = inactiveAlpha
                end

                Util.Tween(layer.Holder, {
                    Position = layer.BasePosition
                }, tweenTime, Enum.EasingStyle.Quad)

                for _, entry in ipairs(layer.Ink) do
                    Util.Tween(entry[1], {
                        [entry[2]] = activeAlpha
                    }, tweenTime, Enum.EasingStyle.Quad)
                end
            else
                Util.Tween(layer.Holder, {
                    Position = layer.HiddenPosition
                }, tweenTime, Enum.EasingStyle.Quad)

                for _, entry in ipairs(layer.Ink) do
                    Util.Tween(entry[1], {
                        [entry[2]] = inactiveAlpha
                    }, tweenTime, Enum.EasingStyle.Quad)
                end
            end
        end)
    end

    local function pulseLayer(layer, delayTime)
        task.delay(delayTime, function()
            if not Runtime.Alive or not glyph.Box.Parent or glyph.SignalGeneration ~= generation then
                return
            end

            stopLayer(layer)
            layer.Holder.Position = layer.BasePosition

            Util.Tween(layer.Holder, {
                Position = layer.LiftPosition
            }, .10, Enum.EasingStyle.Quad)

            for _, entry in ipairs(layer.Ink) do
                Util.Tween(entry[1], {
                    [entry[2]] = pulseAlpha
                }, .10, Enum.EasingStyle.Quad)
            end

            task.delay(.11, function()
                if not Runtime.Alive or not glyph.Box.Parent or glyph.SignalGeneration ~= generation then
                    return
                end

                Util.Tween(layer.Holder, {
                    Position = layer.BasePosition
                }, .14, Enum.EasingStyle.Quad)

                for _, entry in ipairs(layer.Ink) do
                    Util.Tween(entry[1], {
                        [entry[2]] = activeAlpha
                    }, .14, Enum.EasingStyle.Quad)
                end
            end)
        end)
    end

    if shouldPulse then
        local rank = 0

        for index, layer in ipairs(glyph.PingLayers) do
            local arc = index - 1
            local active = known and (arc == 0 or arc <= level)

            if active then
                pulseLayer(layer, rank * stepDelay)
                rank += 1
            else
                setLayer(layer, false)
            end
        end

        return
    end

    for index, layer in ipairs(glyph.PingLayers) do
        local arc = index - 1
        local oldActive = wasKnown and (arc == 0 or arc <= oldLevel)
        local newActive = known and (arc == 0 or arc <= level)

        if instant then
            setLayer(layer, newActive)
        elseif oldActive == newActive then
            setLayer(layer, newActive)
        elseif newActive then
            local rank = wasKnown and math.max(0, arc - oldLevel - 1) or arc
            transitionLayer(layer, true, rank * stepDelay)
        else
            local rank = math.max(0, oldLevel - arc)
            transitionLayer(layer, false, rank * stepDelay)
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
-- PERFIL LOCAL + MÉTRICAS NA SIDEBAR ORIGINAL
--==============================================================

local metricsStartMarker =
    '\tlocal metrics = Util.New("Frame", {Name = "ConnectionMetrics"'

local metricsEndMarker =
    '\tlocal header = Util.New("Frame", {Name = "PageHeader"'

local newMetricsBlock = [=[\tlocal metrics = Util.New("Frame", {Name = "ConnectionMetrics", BackgroundTransparency = 1,
\t\tBorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), ClipsDescendants = true}, nav)

\tUtil.New("Frame", {Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.BorderSoft,
\t\tBackgroundTransparency = .15, BorderSizePixel = 0}, metrics)

\tlocal fpsIcon = UI.CreateNavigationIcon(metrics, "FPS", 13)
\tlocal pingIcon = UI.CreateNavigationIcon(metrics, "PING", 18)
\tState.UI.PingIcon = pingIcon

\tState.UI.FPSLabel.Parent = metrics
\tState.UI.PingLabel.Parent = metrics

\tfor _, label in ipairs({State.UI.FPSLabel, State.UI.PingLabel}) do
\t\tlabel.Font = Enum.Font.Gotham
\t\tlabel.TextXAlignment = Enum.TextXAlignment.Left
\tend

\tlocal avatarShell = Util.New("Frame", {
\t\tName = "LocalPlayerAvatarShell",
\t\tBackgroundColor3 = Theme.Surface3,
\t\tBorderSizePixel = 0,
\t\tClipsDescendants = true,
\t\tZIndex = 6,
\t}, metrics)
\tUtil.Corner(avatarShell, 999)
\tUtil.Stroke(avatarShell, Theme.Accent, .10, 2)

\tlocal localAvatar = Util.New("ImageLabel", {
\t\tName = "LocalPlayerAvatar",
\t\tSize = UDim2.fromScale(1, 1),
\t\tBackgroundTransparency = 1,
\t\tBorderSizePixel = 0,
\t\tImage = "",
\t\tScaleType = Enum.ScaleType.Crop,
\t\tZIndex = 7,
\t}, avatarShell)

\tUI.LoadPlayerThumbnail(localAvatar, S.LocalPlayer)
\tState.UI.LocalPlayerAvatar = localAvatar

\tlocal onlineDot = Util.New("Frame", {
\t\tName = "LocalPlayerOnlineDot",
\t\tAnchorPoint = Vector2.new(.5, .5),
\t\tSize = UDim2.fromOffset(8, 8),
\t\tBackgroundColor3 = Theme.Success,
\t\tBorderSizePixel = 0,
\t\tZIndex = 9,
\t}, metrics)
\tUtil.Corner(onlineDot, 999)
\tUtil.Stroke(onlineDot, Theme.BG, 0, 2)

\tlocal profileDivider = Util.New("Frame", {
\t\tName = "LocalProfileDivider",
\t\tBackgroundColor3 = Theme.BorderSoft,
\t\tBackgroundTransparency = .40,
\t\tBorderSizePixel = 0,
\t\tZIndex = 5,
\t}, metrics)

]=]

source = replaceBetween(
    source,
    metricsStartMarker,
    metricsEndMarker,
    newMetricsBlock,
    1
)

local metricsLayoutStart =
    '\t\tmetrics.Position = UDim2.new(0, compact and 4 or 12, 1, -4)\n'

local metricsLayoutEnd =
    '\t\tlocal contentWidth = w - navWidth - gap * 2\n'

local newMetricsLayout = [=[\t\tmetrics.Position = UDim2.new(0, compact and 4 or 12, 1, -4)
\t\tmetrics.Size = UDim2.new(1, compact and -8 or -24, 0, metricHeight)

\t\tlocal avatarSize = compact
\t\t\tand math.min(26, metricHeight - 10)
\t\t\tor math.min(math.max(28, math.floor(30 * math.min(scale, 1.10) + .5)), metricHeight - 10)
\t\tavatarSize = math.max(22, avatarSize)

\t\tavatarShell.Visible = true
\t\tavatarShell.AnchorPoint = Vector2.new(0, .5)
\t\tavatarShell.Position = UDim2.new(0, 1, .5, 0)
\t\tavatarShell.Size = UDim2.fromOffset(avatarSize, avatarSize)

\t\tonlineDot.Position = UDim2.new(
\t\t\t0,
\t\t\tavatarSize,
\t\t\t.5,
\t\t\tmath.floor(avatarSize * .5 - 4)
\t\t)
\t\tonlineDot.Size = UDim2.fromOffset(compact and 7 or 8, compact and 7 or 8)

\t\tprofileDivider.Position = UDim2.new(
\t\t\t0,
\t\t\tavatarSize + 9,
\t\t\t.5,
\t\t\t-math.floor(math.min(metricHeight - 10, 32) * .5)
\t\t)
\t\tprofileDivider.Size = UDim2.fromOffset(1, math.min(metricHeight - 10, 32))

\t\tlocal statusX = avatarSize + 16
\t\tlocal fpsIconSize = 16
\t\tlocal pingIconSize = 18

\t\tfor _, icon in ipairs({fpsIcon, pingIcon}) do
\t\t\ticon.Box.Visible = true
\t\t\ticon.Box.AnchorPoint = Vector2.new(0, .5)
\t\tend

\t\tpingIcon.Box.Position = UDim2.new(0, statusX, .29, 0)
\t\tlocal pingScale = pingIcon.Box:FindFirstChildOfClass("UIScale")
\t\tif pingScale then
\t\t\tpingScale.Scale = 1
\t\tend

\t\tfpsIcon.Box.Position = UDim2.new(0, statusX + 1, .72, 0)
\t\tlocal fpsScale = fpsIcon.Box:FindFirstChildOfClass("UIScale")
\t\tif fpsScale then
\t\t\tfpsScale.Scale = fpsIconSize / 32
\t\tend

\t\tState.UI.PingLabel.AnchorPoint = Vector2.new(0, .5)
\t\tState.UI.FPSLabel.AnchorPoint = Vector2.new(0, .5)

\t\tlocal pingTextX = statusX + pingIconSize + 5
\t\tlocal fpsTextX = statusX + fpsIconSize + 6

\t\tState.UI.PingLabel.Position = UDim2.new(0, pingTextX, .29, 0)
\t\tState.UI.FPSLabel.Position = UDim2.new(0, fpsTextX, .72, 0)

\t\tState.UI.PingLabel.Size = UDim2.new(1, -pingTextX, 0, 17)
\t\tState.UI.FPSLabel.Size = UDim2.new(1, -fpsTextX, 0, 17)

\t\tUI.SetReadableText(State.UI.PingLabel, compact and 7.5 or 8)
\t\tUI.SetReadableText(State.UI.FPSLabel, compact and 7.5 or 8)
]=]

source = replaceBetween(
    source,
    metricsLayoutStart,
    metricsLayoutEnd,
    newMetricsLayout,
    1
)

local compiled, compileError = loadstring(source, "VisionX.lua")
assert(compiled, "VisionX V35.3.15: " .. tostring(compileError))
return compiled()
