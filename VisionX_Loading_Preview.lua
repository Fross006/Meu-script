-- VisionX V35 — prévia independente da tela de carregamento.
-- Executa somente animações. Não carrega, abre ou altera o script principal.
-- As seis etapas são simuladas por 1,4 s cada. Ao terminar, toque em Repetir.

local S = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	Workspace = game:GetService("Workspace"),
}
S.PlayerGui = S.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Standalone visual preview. All progress below is deliberately simulated.
local Loading = {
	Names = {"Interface", "Mira", "Corpo", "Jogadores", "ESP", "Configurações"},
	Cancelled = {},
	Colors = {
		Panel = Color3.fromRGB(17, 20, 25), Card = Color3.fromRGB(26, 29, 35),
		Border = Color3.fromRGB(59, 64, 74), Text = Color3.fromRGB(243, 245, 249),
		Sub = Color3.fromRGB(159, 165, 178), Muted = Color3.fromRGB(106, 113, 127),
		Red = Color3.fromRGB(246,  70, 89), DeepRed = Color3.fromRGB(116, 40,  50),
	},
}

function Loading.New(class, properties, parent)
	local object = Instance.new(class)
	if object:IsA("GuiObject") then object.BorderSizePixel = 0 end
	if object:IsA("TextLabel") or object:IsA("TextButton") then
		object.BackgroundTransparency = 1
		object.Font = Enum.Font.Gotham
		object.TextColor3 = Loading.Colors.Text
		object.TextSize = 18
	end
	for key, value in pairs(properties or {}) do object[key] = value end
	object.Parent = parent
	return object
end

function Loading.Round(object, radius)
	return Loading.New("UICorner", {CornerRadius = UDim.new(0, radius)}, object)
end

function Loading.Stroke(object, color, thickness, transparency)
	return Loading.New("UIStroke", {Color = color, Thickness = thickness or 1,
		Transparency = transparency or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, object)
end

function Loading.Text(parent, text, x, y, w, h, size, color, bold, centered)
	return Loading.New("TextLabel", {
		Text = text, Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h),
		TextSize = size, TextColor3 = color or Loading.Colors.Text,
		Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextXAlignment = centered and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
	}, parent)
end

function Loading.Line(parent, x1, y1, x2, y2, thickness, color)
	local dx, dy = x2 - x1, y2 - y1
	local line = Loading.New("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromOffset((x1+x2)/2, (y1+y2)/2),
		Size = UDim2.fromOffset(math.sqrt(dx*dx+dy*dy)+thickness, thickness),
		Rotation = math.deg(math.atan2(dy, dx)), BackgroundColor3 = color,
	}, parent)
	Loading.Round(line, 99)
	return line
end

function Loading.Arc(parent, diameter, first, last, color, thickness, segments)
	local arc = Loading.New("Frame", {BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
		Size = UDim2.fromOffset(diameter, diameter)}, parent)
	local radius = diameter/2
	for i = 0, segments - 1 do
		local a = math.rad(first + (last-first)*i/segments)
		local b = math.rad(first + (last-first)*(i+1)/segments)
		Loading.Line(arc, radius + math.cos(a)*radius, radius + math.sin(a)*radius,
			radius + math.cos(b)*radius, radius + math.sin(b)*radius, thickness, color)
	end
	return arc
end

function Loading.Icon(parent, index)
	local icon = Loading.New("Frame", {BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 15), Size = UDim2.fromOffset(32, 32)}, parent)
	local ink = {}
	local function line(x1, y1, x2, y2)
		ink[#ink+1] = {Loading.Line(icon, x1, y1, x2, y2, 2, Loading.Colors.Text), "BackgroundColor3"}
	end
	local function circle(x, y, diameter)
		local ring = Loading.New("Frame", {BackgroundTransparency = 1,
			Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(diameter, diameter)}, icon)
		Loading.Round(ring, 99)
		ink[#ink+1] = {Loading.Stroke(ring, Loading.Colors.Text, 2), "Color"}
	end
	if index == 1 then
		line(3,4,29,4); line(29,4,29,28); line(29,28,3,28); line(3,28,3,4)
		line(3,11,29,11); line(20,11,20,28); line(8,17,14,17); line(8,23,14,23)
	elseif index == 2 then
		circle(5,5,22); line(16,0,16,9); line(16,23,16,32); line(0,16,9,16); line(23,16,32,16)
	elseif index == 3 or index == 4 then
		circle(index == 4 and 5 or 10, 3, 12)
		line(4,29,4,24); line(4,24,8,21); line(8,21,22,21); line(22,21,26,24); line(26,24,26,29)
		if index == 4 then line(23,4,27,7); line(27,7,27,12); line(27,12,24,15); line(29,21,32,25); line(32,25,32,29) end
	elseif index == 5 then
		circle(11,11,10)
		line(1,16,8,8); line(8,8,16,5); line(16,5,24,8); line(24,8,31,16)
		line(31,16,24,24); line(24,24,16,27); line(16,27,8,24); line(8,24,1,16)
	else
		circle(6,6,20); circle(12,12,8)
		for i = 0, 7 do
			local angle = i*math.pi/4
			line(16+math.cos(angle)*10, 16+math.sin(angle)*10, 16+math.cos(angle)*15, 16+math.sin(angle)*15)
		end
	end
	return icon, ink
end

function Loading.Alpha(session, object, property, value)
	local base = session.OpacityMap[object]
	if base then base[property] = value end
	object[property] = 1 - (1-value)*session.Opacity
end

function Loading.PaintRow(session, index, status)
	local row, colors = session.Rows[index], Loading.Colors
	row.State = status
	local active, done, failed = status == "loading", status == "done", status == "failed"
	row.Status.Text = failed and "Falhou" or active and "Carregando" or "Aguardando"
	row.Status.Visible = not done
	row.Status.TextColor3 = failed and colors.Red or active and colors.Sub or colors.Muted
	row.Indicator.Position = UDim2.new(1, done and -44 or -150, .5, -12)
	row.Check.Visible = done
	row.Spinner.Visible = active
	row.Ring.Visible = not done
	row.RingStroke.Color = failed and colors.Red or colors.Border
	row.Stroke.Color = (active or failed) and colors.Red or colors.Border
	Loading.Alpha(session, row.Stroke, "Transparency", (active or failed) and .36 or .60)
	for _, entry in ipairs(row.Ink) do entry[1][entry[2]] = active and colors.Red or colors.Text end
end

function Loading.Layout(session)
	local viewport = session.Root.AbsoluteSize
	if viewport.X < 2 or viewport.Y < 2 then
		local camera = S.Workspace.CurrentCamera
		viewport = camera and camera.ViewportSize or Vector2.new(960, 540)
	end
	local portrait = viewport.X < viewport.Y*1.15
	local width, height = portrait and 520 or 1040, portrait and 844 or 554
	session.Panel.Size = UDim2.fromOffset(width, height)
	session.Scale.Scale = math.min((viewport.X-32)/width, (viewport.Y-32)/height, 1.12)
	session.Scale.Scale = math.max(.1, session.Scale.Scale)
	session.Left.Size = UDim2.fromOffset(portrait and 520 or 580, portrait and 392 or 554)
	session.Right.Position = UDim2.fromOffset(portrait and 24 or 614, portrait and 406 or 38)
	session.Right.Size = UDim2.fromOffset(portrait and 472 or 394, portrait and 420 or 478)
	session.Divider.Position = UDim2.fromOffset(portrait and 24 or 582, portrait and 391 or 24)
	session.Divider.Size = UDim2.fromOffset(portrait and 472 or 1, portrait and 1 or 506)
	session.Logo.Position = UDim2.new(.5, 0, 0, portrait and 90 or 130)
	session.LogoScale.Scale = portrait and .75 or 1
	session.Wordmark.Position = UDim2.new(.5, 0, 0, portrait and 157 or 224)
	session.Version.Position = UDim2.new(.5, 0, 0, portrait and 197 or 268)
	session.Welcome.Position = UDim2.fromOffset(28, portrait and 234 or 316)
	session.Welcome.Size = UDim2.new(1, -56, 0,  50)
	session.Welcome.TextSize = portrait and 32 or 36
	session.Subtitle.Position = UDim2.fromOffset(28, portrait and 282 or 370)
	session.Subtitle.Size = UDim2.new(1, -56, 0, 28)
	session.ProgressBox.Position = UDim2.new(0,  40, 0, portrait and 318 or 438)
	session.ProgressBox.Size = UDim2.new(1, -80, 0,  50)
	session.Footer.Position = UDim2.fromOffset(24, portrait and 371 or 500)
	session.Footer.Size = UDim2.new(1, -48, 0, 26)
	session.RightTitle.Size = UDim2.new(1, 0, 0, 36)
	session.RightTitle.TextSize = portrait and 24 or 25
	for i, row in ipairs(session.Rows) do
		local rowHeight = portrait and 56 or 62
		row.Card.Position = UDim2.fromOffset(0, (portrait and 44 or 58)+(i-1)*(portrait and 64 or  70))
		row.Card.Size = UDim2.new(1, 0, 0, rowHeight)
		row.Icon.Position = UDim2.new(0, 18, .5, -16)
	end
	session.Close.Position = UDim2.new(.5, -80, 1, -44)
	Loading.PaintOpacity(session)
end

function Loading.PaintOpacity(session)
	for object, properties in pairs(session.OpacityMap) do
		if object.Parent then
			for property, base in pairs(properties) do object[property] = 1-(1-base)*session.Opacity end
		end
	end
	session.Backdrop.BackgroundTransparency = 1-.48*session.Opacity
	session.Panel.Position = UDim2.new(.5, 0, .5, (1-session.Opacity)*10)
	if session.Blur then session.Blur.Size = 12*session.Opacity end
end

function Loading.Destroy()
	local session = Loading.Session
	if not session then return end
	Loading.Session = nil
	session.Destroyed = true
	for _, connection in ipairs(session.Connections) do connection:Disconnect() end
	session.Connections = {}
	if session.Blur then session.Blur:Destroy(); session.Blur = nil end
	if session.Root then session.Root:Destroy() end
	session.OnReady = nil
	local afterExit = session.AfterExit
	session.AfterExit = nil
	if session.Phase == "leaving" and afterExit then afterExit() end
end

function Loading.Cancel()
	Loading.Destroy()
	if Loading.OnCancel then Loading.OnCancel() end
end

function Loading.Tick(session, dt)
	if session ~= Loading.Session or session.Destroyed then return end
	dt = math.clamp(dt, 0, .1)
	session.Time += dt
	if session.Phase ~= "failed" then
		session.Arc.Rotation = math.sin(session.Time*math.pi/1.05)*86
		for _, row in ipairs(session.Rows) do
			if row.State == "loading" then row.Spinner.Rotation = (session.Time*240)%360 end
		end
	end
	session.ProgressTime = math.min(session.ProgressTime+dt, .18)
	local p = 1-(1-session.ProgressTime/.18)^3
	session.DisplayProgress = session.ProgressFrom+(session.Progress-session.ProgressFrom)*p
	session.Fill.Size = UDim2.fromScale(session.DisplayProgress, 1)
	if session.Phase == "leaving" then
		session.ExitTime += dt
		session.Opacity = (session.ExitOpacity or 1)*(1-math.sin(math.min(session.ExitTime/.26, 1)*math.pi/2))
		Loading.PaintOpacity(session)
		if session.ExitTime >= .26 then Loading.Destroy() end
		return
	end
	local opacity = 1-(1-math.min(session.Time/.28, 1))^4
	if opacity ~= session.Opacity then session.Opacity = opacity; Loading.PaintOpacity(session) end
	if session.Phase == "ready" and session.ProgressTime >= .18 and session.Time >= .28 then
		session.Phase, session.ExitTime = "leaving", 0
		local ready = session.OnReady
		session.OnReady = nil
		if ready then
			local ok, problem = pcall(ready)
			if not ok then Loading.HandleError(problem) end
		end
	end
end

function Loading.Create()
	Loading.Destroy()
	local c = Loading.Colors
	local session = {Rows = {}, Connections = {}, OpacityMap = {}, Opacity = 1, Time = 0,
		Phase = "loading", Completed = 0, Progress = 0, DisplayProgress = 0, ProgressFrom = 0, ProgressTime = .18}
	Loading.Session = session
	session.Root = Loading.New("ScreenGui", {Name = "VisionX_Loading_Preview", ResetOnSpawn = false,
		IgnoreGuiInset = true, DisplayOrder = 1000001, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, S.PlayerGui)
	local cleanup = Loading.New("BindableEvent", {Name = "AAP_Cleanup"}, session.Root)
	session.Connections[#session.Connections+1] = cleanup.Event:Connect(Loading.Cancel)
	session.Connections[#session.Connections+1] = session.Root.Destroying:Connect(Loading.Cancel)
	session.Backdrop = Loading.New("TextButton", {Name = "InputShield", Text = "", AutoButtonColor = false,
		Active = true, Selectable = false, Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1}, session.Root)
	session.Panel = Loading.New("Frame", {Name = "WelcomePanel", AnchorPoint = Vector2.new(.5,.5),
		Position = UDim2.fromScale(.5,.5), BackgroundColor3 = c.Panel, BackgroundTransparency = .035,
		Active = true, ZIndex = 2}, session.Root)
	Loading.Round(session.Panel, 30)
	Loading.Stroke(session.Panel, c.Red, 1.3, .60)
	Loading.New("UIGradient", {Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromRGB(175,185,205)), Rotation = 110}, session.Panel)
	session.Scale = Loading.New("UIScale", {}, session.Panel)
	session.Left = Loading.New("Frame", {BackgroundTransparency = 1}, session.Panel)
	session.Right = Loading.New("Frame", {BackgroundTransparency = 1}, session.Panel)
	session.Divider = Loading.New("Frame", {BackgroundColor3 = c.Border, BackgroundTransparency = .65}, session.Panel)
	session.Logo = Loading.New("Frame", {Name = "VisionXLogo", BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(.5,.5), Size = UDim2.fromOffset(180,180)}, session.Left)
	session.LogoScale = Loading.New("UIScale", {}, session.Logo)
	local track = Loading.New("Frame", {AnchorPoint = Vector2.new(.5,.5), Position = UDim2.fromScale(.5,.5),
		Size = UDim2.fromOffset(180,180), BackgroundTransparency = 1}, session.Logo)
	Loading.Round(track, 999); Loading.Stroke(track, c.Border, 4, .28)
	session.Arc = Loading.Arc(session.Logo, 180, -86, 10, c.Red, 4.5, 32)
	local mark = Loading.New("Frame", {Name = "Mark", AnchorPoint = Vector2.new(.5,.5),
		Position = UDim2.fromScale(.5,.5), Size = UDim2.fromOffset(108,108), BackgroundColor3 = c.Card}, session.Logo)
	Loading.Round(mark, 23); Loading.Stroke(mark, c.Sub, 1.5, .56)
	Loading.New("UIGradient", {Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromRGB(160,170,185)), Rotation = 90}, mark)
	local v = Loading.Text(mark, "V", 0, 0, 108, 108,  70, c.Red, true, true)
	v.Font = Enum.Font.GothamBlack
	Loading.New("UIGradient", {Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromRGB(158,62, 70)), Rotation = 90}, v)
	session.Wordmark = Loading.Text(session.Left, 'VISION<font color="#F64659">X</font>', 0, 0, 300,  40, 30, c.Text, true, true)
	session.Wordmark.RichText = true; session.Wordmark.Font = Enum.Font.GothamBlack; session.Wordmark.AnchorPoint = Vector2.new(.5,0)
	session.Version = Loading.New("Frame", {AnchorPoint = Vector2.new(.5,0), Size = UDim2.fromOffset( 70,30), BackgroundColor3 = c.Card}, session.Left)
	Loading.Round(session.Version, 99); Loading.Stroke(session.Version,c.Border,1,.45)
	Loading.Text(session.Version,"V35",0,0, 70,30,18,c.Red,true,true)
	session.Welcome = Loading.Text(session.Left,"Bem-vindo ao VisionX.",0,0,0,50,36,c.Text,true,true)
	session.Subtitle = Loading.Text(session.Left,"Estamos preparando seu menu.",0,0,0,28,20,c.Sub,false,true)
	session.ProgressBox = Loading.New("Frame", {BackgroundTransparency = 1}, session.Left)
	session.Current = Loading.Text(session.ProgressBox,"Preparando interface…",0,0,400,26,18)
	session.Current.Size = UDim2.new(1,-60,0,26)
	session.Percent = Loading.Text(session.ProgressBox,"0%",0,0,60,26,18,c.Text,false,false)
	session.Percent.Position = UDim2.new(1,-60,0,0); session.Percent.TextXAlignment = Enum.TextXAlignment.Right
	local bar = Loading.New("Frame", {Name = "ProgressTrack", Position = UDim2.fromOffset(0,32),
		Size = UDim2.new(1,0,0,18), BackgroundColor3 = c.Border, BackgroundTransparency = .22}, session.ProgressBox)
	Loading.Round(bar,99); Loading.Stroke(bar,c.Muted,1,.7)
	session.Fill = Loading.New("Frame", {Name = "ProgressFill", Size = UDim2.fromScale(0,1), BackgroundColor3 = Color3.new(1,1,1)}, bar)
	Loading.Round(session.Fill,99)
	Loading.New("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(255,101,110),c.Red), Rotation = 90}, session.Fill)
	session.Footer = Loading.New("TextButton", {
		Text = "Prévia visual · Toque aqui para fechar.", TextSize = 16, TextColor3 = c.Sub,
		BackgroundTransparency = 1, AutoButtonColor = false,
	}, session.Left)
	session.Connections[#session.Connections+1] = session.Footer.Activated:Connect(function()
		if Loading.OnClose then Loading.OnClose() else Loading.Cancel() end
	end)
	session.RightTitle = Loading.Text(session.Right,"Preparando componentes",0,0,0,36,25,c.Text,true)
	for index, name in ipairs(Loading.Names) do
		local row = {}
		row.Card = Loading.New("Frame", {Name = name, BackgroundColor3 = c.Card, BackgroundTransparency = .2}, session.Right)
		Loading.Round(row.Card,16); row.Stroke = Loading.Stroke(row.Card,c.Border,1.2,.6)
		row.Icon, row.Ink = Loading.Icon(row.Card,index)
		row.Label = Loading.Text(row.Card,name,68,0,0,62,18)
		row.Label.Size = UDim2.new(1,-226,1,0)
		row.Status = Loading.Text(row.Card,"Aguardando",0,0,100,62,14,c.Muted)
		row.Status.Position = UDim2.new(1,-116,0,0); row.Status.Size = UDim2.new(0,102,1,0)
		row.Indicator = Loading.New("Frame", {BackgroundTransparency = 1, Size = UDim2.fromOffset(24,24)}, row.Card)
		row.Ring = Loading.New("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1,1)}, row.Indicator)
		Loading.Round(row.Ring,99); row.RingStroke = Loading.Stroke(row.Ring,c.Border,2)
		row.Spinner = Loading.Arc(row.Indicator,24,-80,150,c.Red,2.2,18)
		row.Check = Loading.New("Frame", {Size = UDim2.fromScale(1,1), BackgroundColor3 = c.Text}, row.Indicator)
		Loading.Round(row.Check,99)
		Loading.Line(row.Check,6,12,10,16,2.2,c.Panel); Loading.Line(row.Check,10,16,18,8,2.2,c.Panel)
		session.Rows[index] = row
		Loading.PaintRow(session,index,"waiting")
	end
	session.Close = Loading.New("TextButton", {Text = "Fechar", Size = UDim2.fromOffset(160,32),
		BackgroundTransparency = 0, BackgroundColor3 = c.DeepRed, AutoButtonColor = false, TextSize = 18, Visible = false}, session.Left)
	Loading.Round(session.Close,12)
	session.Connections[#session.Connections+1] = session.Close.Activated:Connect(Loading.Cancel)
	-- One temporary blur, owned by this session. Existing game effects are untouched.
	pcall(function()
		session.Blur = Loading.New("BlurEffect", {Name = "VisionX_Loading_Preview_Blur", Size = 0}, game:GetService("Lighting"))
	end)
	for _, object in ipairs(session.Panel:GetDescendants()) do
		local properties = {}
		if object:IsA("GuiObject") then
			properties.BackgroundTransparency = object.BackgroundTransparency
			if object:IsA("TextLabel") or object:IsA("TextButton") then properties.TextTransparency = object.TextTransparency end
		elseif object:IsA("UIStroke") then properties.Transparency = object.Transparency end
		if next(properties) then session.OpacityMap[object] = properties end
	end
	session.OpacityMap[session.Panel] = {BackgroundTransparency = .035}
	session.Opacity = 0
	Loading.Layout(session)
	session.Connections[#session.Connections+1] = session.Root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() Loading.Layout(session) end)
	session.RenderConnection = S.RunService.RenderStepped:Connect(function(dt) Loading.Tick(session,dt) end)
	session.Connections[#session.Connections+1] = session.RenderConnection
	session.Built = true
	return session
end

function Loading.Yield()
	local session = Loading.Session
	S.RunService.Heartbeat:Wait() -- Give Roblox a frame to paint the actual current stage.
	if not session or session ~= Loading.Session or session.Destroyed then
		error(Loading.Cancelled,0)
	end
end

function Loading.Stage(index, work)
	local session = Loading.Session
	assert(session and index == session.Completed+1, "Etapa de inicialização fora de ordem")
	session.Active = index
	session.Current.Text = "Carregando " .. Loading.Names[index] .. "…"
	Loading.PaintRow(session,index,"loading")
	Loading.Yield()
	work()
	if session ~= Loading.Session then error(Loading.Cancelled,0) end
	session.Completed = index
	session.ProgressFrom, session.ProgressTime = session.DisplayProgress, 0
	session.Progress = index/#Loading.Names
	session.Percent.Text = string.format("%d%%", math.floor(session.Progress*100+.5))
	Loading.PaintRow(session,index,"done")
end

function Loading.Finish(onReady)
	local session = Loading.Session
	assert(session and session.Completed == #Loading.Names, "Inicialização incompleta")
	session.Current.Text = "Tudo pronto!"
	session.Subtitle.Text = "Animação concluída."
	session.Phase, session.OnReady = "ready", onReady
end

function Loading.HandleError(problem)
	local session = Loading.Session
	warn("[VisionX Prévia] Falha na animação: " .. tostring(problem))
	if not session or not session.Root or not session.Root.Parent or not session.Built then Loading.Destroy(); return end
	session.Phase, session.OnReady = "failed", nil
	session.Opacity, session.Time = 1, math.max(session.Time,.28)
	session.Welcome.Text = "Não foi possível abrir."
	session.Welcome.TextSize = 30
	session.Subtitle.Text = "Feche esta tela e execute o script novamente."
	session.Subtitle.TextSize = 16
	session.Current.Text = "Falha em " .. Loading.Names[session.Active or 1]
	session.Footer.Visible = false; session.Close.Visible = true
	session.Fill.Parent.Visible = false
	if session.RenderConnection then session.RenderConnection:Disconnect() end
	Loading.PaintRow(session,session.Active or 1,"failed")
	Loading.PaintOpacity(session)
end


local Preview = {Generation = 0, Closed = false, Connections = {}}

function Preview.Destroy()
	if Preview.Closed then return end
	Preview.Closed = true
	Preview.Generation += 1
	Loading.Destroy()
	for _, connection in ipairs(Preview.Connections) do connection:Disconnect() end
	Preview.Connections = {}
	if Preview.Root then Preview.Root:Destroy() end
end

function Preview.Close()
	if Preview.Closed then return end
	Preview.Generation += 1 -- Invalidate the simulated stages before the exit.
	local session = Loading.Session
	if not session then Preview.Destroy(); return end
	if session.Phase == "leaving" then
		session.AfterExit = Preview.Destroy
		return
	end
	if session.Phase == "failed" then Preview.Destroy(); return end
	session.OnReady = nil
	session.ExitTime, session.ExitOpacity = 0, session.Opacity
	session.Phase, session.AfterExit = "leaving", Preview.Destroy
end

function Preview.Wait(seconds, generation, session)
	local elapsed = 0
	repeat
		local delta = S.RunService.Heartbeat:Wait()
		if Preview.Closed or generation ~= Preview.Generation or session ~= Loading.Session then
			error(Loading.Cancelled, 0)
		end
		elapsed += delta
	until elapsed >= seconds
end

function Preview.Play()
	if Preview.Closed then return end
	Preview.Generation += 1
	local generation = Preview.Generation
	Preview.Card.Visible = false
	task.spawn(function()
		if Preview.Closed or generation ~= Preview.Generation then return end
		local ok, problem = xpcall(function()
			local session = Loading.Create()
			session.AfterExit = function()
				if not Preview.Closed and generation == Preview.Generation and Preview.Card.Parent then
					Preview.Card.Visible = true
				end
			end
			for index = 1, #Loading.Names do
				Loading.Stage(index, function()
					Preview.Wait(1.4, generation, session)
				end)
			end
			Loading.Finish() -- Only the splash exits. No menu callback exists.
		end, function(problem)
			if problem == Loading.Cancelled then return problem end
			return debug.traceback(tostring(problem), 2)
		end)
		if not ok and problem ~= Loading.Cancelled and not Preview.Closed and generation == Preview.Generation then
			Loading.HandleError(problem)
		end
	end)
end

function Preview.CreateControls()
	-- Only previous instances of this preview are replaced on re-execution.
	for _, name in ipairs({"VisionX_Loading_Preview_Controls", "VisionX_Loading_Preview"}) do
		while true do
			local old = S.PlayerGui:FindFirstChild(name)
			if not old then break end
			local cleanup = old:FindFirstChild("AAP_Cleanup")
			if cleanup and cleanup:IsA("BindableEvent") then pcall(function() cleanup:Fire() end) end
			old:Destroy()
		end
	end
	local c = Loading.Colors
	Preview.Root = Loading.New("ScreenGui", {Name = "VisionX_Loading_Preview_Controls",
		ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 1000002,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, S.PlayerGui)
	local cleanup = Loading.New("BindableEvent", {Name = "AAP_Cleanup"}, Preview.Root)
	Preview.Connections[#Preview.Connections+1] = cleanup.Event:Connect(Preview.Destroy)
	Preview.Connections[#Preview.Connections+1] = Preview.Root.Destroying:Connect(Preview.Destroy)
	Preview.Card = Loading.New("Frame", {Name = "Replay", AnchorPoint = Vector2.new(.5,1),
		Position = UDim2.new(.5,0,1,-16), Size = UDim2.fromOffset(296,92),
		BackgroundColor3 = c.Panel, Visible = false}, Preview.Root)
	Loading.Round(Preview.Card,16); Loading.Stroke(Preview.Card,c.Border,1,.25)
	Loading.Text(Preview.Card,"Prévia concluída",12,10,272,22,16,c.Text,true,true)
	Preview.Replay = Loading.New("TextButton", {Text = "Repetir", TextSize = 16,
		Position = UDim2.fromOffset(12,42), Size = UDim2.fromOffset(130,38),
		BackgroundTransparency = 0, BackgroundColor3 = c.DeepRed, AutoButtonColor = false}, Preview.Card)
	Preview.CloseButton = Loading.New("TextButton", {Text = "Fechar", TextSize = 16,
		Position = UDim2.fromOffset(154,42), Size = UDim2.fromOffset(130,38),
		BackgroundTransparency = 0, BackgroundColor3 = c.Card, AutoButtonColor = false}, Preview.Card)
	Loading.Round(Preview.Replay,10); Loading.Round(Preview.CloseButton,10)
	Preview.Connections[#Preview.Connections+1] = Preview.Replay.Activated:Connect(Preview.Play)
	Preview.Connections[#Preview.Connections+1] = Preview.CloseButton.Activated:Connect(Preview.Close)
end

Loading.OnCancel = Preview.Destroy
Loading.OnClose = Preview.Close
Preview.CreateControls()
Preview.Play()
