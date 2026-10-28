-- Panel local de movimiento. Usar solo en experiencias propias o con permiso.
-- No requiere descargas, HTTP ni scripts externos.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
assert(player, "Este script debe ejecutarse en el cliente")
local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("MovementCommands")
if old then
    local shutdown = old:FindFirstChild("Shutdown")
    if shutdown then shutdown:Fire() end
    old:Destroy()
end

local connections, pressed, collisions = {}, {}, {}
local flying, vehicleMode, noclip, infiniteJump = false, false, false, false
local flySpeed = 60
local flightPart, attachment, velocity, orientation, flightHumanoid, previousPlatformStand
local defaults, speedOverride, jumpOverride = nil, nil, nil
local originalGravity = workspace.Gravity
local closed = false
local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end
local function characterParts()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return character, humanoid, root
end
local function restoreCollisions()
    for part, canCollide in pairs(collisions) do
        if part.Parent then part.CanCollide = canCollide end
    end
    table.clear(collisions)
end
local function stopFlight()
    if velocity then velocity:Destroy() end
    if orientation then orientation:Destroy() end
    if attachment then attachment:Destroy() end
    if flightHumanoid and flightHumanoid.Parent then
        flightHumanoid.PlatformStand = previousPlatformStand
    end
    flightPart, attachment, velocity, orientation, flightHumanoid = nil, nil, nil, nil, nil
    flying, vehicleMode = false, false
end
local function startFlight(vehicle)
    stopFlight()
    local _, humanoid, root = characterParts()
    assert(humanoid and root and humanoid.Health > 0, "No hay personaje disponible")
    local seat = humanoid.SeatPart
    assert(not vehicle or seat, "Siéntate en un vehículo primero")
    flightPart = vehicle and seat.AssemblyRootPart or root
    assert(flightPart and not flightPart.Anchored, "La pieza está anclada")
    attachment = Instance.new("Attachment")
    attachment.Name = "MovementFlightAttachment"
    attachment.Parent = flightPart
    velocity = Instance.new("LinearVelocity")
    velocity.Attachment0 = attachment
    velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    velocity.MaxForce = math.huge
    velocity.VectorVelocity = Vector3.zero
    velocity.Parent = flightPart
    orientation = Instance.new("AlignOrientation")
    orientation.Attachment0 = attachment
    orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    orientation.MaxTorque = math.huge
    orientation.Responsiveness = 25
    orientation.CFrame = flightPart.CFrame.Rotation
    orientation.Parent = flightPart
    flightHumanoid, previousPlatformStand = humanoid, humanoid.PlatformStand
    if not vehicle then humanoid.PlatformStand = true end
    flying, vehicleMode = true, vehicle
end

local gui = Instance.new("ScreenGui")
gui.Name = "MovementCommands"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui
local shutdown = Instance.new("BindableEvent")
shutdown.Name = "Shutdown"
shutdown.Parent = gui
-- Consola compacta inspirada en el diseño clásico de Infinite Yield.
local panel = Instance.new("Frame")
panel.Name = "Console"
panel.Size = UDim2.fromOffset(300, 380)
panel.AnchorPoint = Vector2.new(1, 1)
panel.Position = UDim2.new(1, -16, 1, -16)
panel.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
panel.BorderSizePixel = 0
panel.Parent = gui
local function text(class, value, parent, position, size)
    local item = Instance.new(class)
    item.Text = value
    item.Position = position
    item.Size = size
    item.BackgroundColor3 = Color3.fromRGB(48, 48, 49)
    item.BorderSizePixel = 0
    item.TextColor3 = Color3.fromRGB(235, 235, 235)
    item.Font = Enum.Font.SourceSans
    item.TextSize = 16
    item.Parent = parent
    return item
end
local header = text("TextLabel", "  @  MOVEMENT YIELD", panel, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 30))
header.TextXAlignment = Enum.TextXAlignment.Left
header.Active = true
local minimize = text("TextButton", "−", header, UDim2.new(1, -60, 0, 0), UDim2.fromOffset(30, 30))
local close = text("TextButton", "×", header, UDim2.new(1, -30, 0, 0), UDim2.fromOffset(30, 30))
local input = text("TextBox", "", panel, UDim2.fromOffset(8, 38), UDim2.new(1, -50, 0, 30))
input.PlaceholderText = "; command / buscar"
input.PlaceholderColor3 = Color3.fromRGB(160, 160, 160)
input.TextXAlignment = Enum.TextXAlignment.Left
input.ClearTextOnFocus = false
local run = text("TextButton", ">", panel, UDim2.new(1, -36, 0, 38), UDim2.fromOffset(28, 30))
local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromOffset(8, 76)
list.Size = UDim2.new(1, -16, 1, -142)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.ScrollBarImageColor3 = Color3.fromRGB(140, 140, 140)
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.Parent = panel
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 2)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list
local status = text("TextLabel", "Listo. Escribe help para ver los controles.", panel, UDim2.new(0, 8, 1, -60), UDim2.new(1, -16, 0, 34))
status.BackgroundTransparency = 1
status.TextSize = 13
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
local footer = text("TextLabel", "COMANDOS LOCALES  •  ; / RightShift", panel, UDim2.new(0, 0, 1, -22), UDim2.new(1, 0, 0, 22))
footer.TextSize = 12
footer.TextColor3 = Color3.fromRGB(170, 170, 170)
local toggle = text("TextButton", "@", gui, UDim2.new(1, -48, 0, 12), UDim2.fromOffset(36, 36))
local function togglePanel() panel.Visible = not panel.Visible end
connect(toggle.Activated, togglePanel)
connect(close.Activated, togglePanel)
local collapsed = false
connect(minimize.Activated, function()
    collapsed = not collapsed
    panel.Size = UDim2.fromOffset(300, collapsed and 30 or 380)
    for _, child in ipairs(panel:GetChildren()) do
        if child:IsA("GuiObject") and child ~= header then child.Visible = not collapsed end
    end
    minimize.Text = collapsed and "+" or "−"
end)
-- Arrastre de cabecera con ratón o un único dedo.
local dragInput, dragStart, dragPosition
connect(header.InputBegan, function(event)
    if event.UserInputType == Enum.UserInputType.MouseButton1 or event.UserInputType == Enum.UserInputType.Touch then
        dragInput, dragStart, dragPosition = event, event.Position, panel.Position
    end
end)
connect(UserInputService.InputChanged, function(event)
    if dragInput and (event == dragInput or event.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = event.Position - dragStart
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
        local right = dragPosition.X.Scale * viewport.X + dragPosition.X.Offset + delta.X
        local bottom = dragPosition.Y.Scale * viewport.Y + dragPosition.Y.Offset + delta.Y
        panel.Position = UDim2.fromOffset(math.clamp(right, 300, math.max(300, viewport.X)), math.clamp(bottom, panel.AbsoluteSize.Y, math.max(panel.AbsoluteSize.Y, viewport.Y)))
    end
end)
connect(UserInputService.InputEnded, function(event) if event == dragInput then dragInput = nil end end)

local function captureDefaults(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if closed or not humanoid or character ~= player.Character then return end
    defaults = { humanoid = humanoid, speed = humanoid.WalkSpeed, jump = humanoid.JumpPower, useJumpPower = humanoid.UseJumpPower }
    if speedOverride then humanoid.WalkSpeed = speedOverride end
    if jumpOverride then humanoid.UseJumpPower = true; humanoid.JumpPower = jumpOverride end
end
local function reset()
    stopFlight()
    noclip, infiniteJump = false, false
    restoreCollisions()
    speedOverride, jumpOverride = nil, nil
    if defaults and defaults.humanoid.Parent then
        defaults.humanoid.WalkSpeed = defaults.speed
        defaults.humanoid.JumpPower = defaults.jump
        defaults.humanoid.UseJumpPower = defaults.useJumpPower
    end
    workspace.Gravity = originalGravity
end
local function cleanup()
    if closed then return end
    closed = true
    reset()
    for _, connection in ipairs(connections) do connection:Disconnect() end
    gui:Destroy()
end
connect(shutdown.Event, cleanup)
local function number(value, minimum, maximum)
    local n = tonumber(value)
    assert(n and n == n and n >= minimum and n <= maximum, "Valor requerido: " .. minimum .. " a " .. maximum)
    return n
end
local context = {
    number = number, startFlight = startFlight, stopFlight = stopFlight,
    characterParts = characterParts, restoreCollisions = restoreCollisions,
    reset = reset, togglePanel = togglePanel, cleanup = cleanup, status = status,
    setFlySpeed = function(value) flySpeed = value end,
    setSpeed = function(value) speedOverride = value end,
    setJump = function(value) jumpOverride = value end,
    setNoclip = function(value) noclip = value end,
    setInfiniteJump = function(value) infiniteJump = value end,
}
local commands = {}
-- COMMAND_MODULES_BEGIN
local folder = script.Parent:WaitForChild("commands")
for _, module in ipairs(folder:GetChildren()) do
    if module:IsA("ModuleScript") then commands[module.Name] = require(module) end
end
-- COMMAND_MODULES_END
local rows, names = {}, {}
for name in pairs(commands) do table.insert(names, name) end
table.sort(names)
for index, name in ipairs(names) do
    local command = commands[name]
    local row = text("TextButton", "  " .. command.usage, list, UDim2.new(), UDim2.new(1, -6, 0, 32))
    row.LayoutOrder = index
    row.TextXAlignment = Enum.TextXAlignment.Left
    rows[name] = row
    connect(row.Activated, function()
        input.Text = name .. " "
        status.Text = command.description
        input:CaptureFocus()
        input.CursorPosition = #input.Text + 1
    end)
end
connect(input:GetPropertyChangedSignal("Text"), function()
    local query = input.Text:lower():match("^%s*[;!]?(%S*)") or ""
    for name, row in pairs(rows) do row.Visible = name:find(query, 1, true) ~= nil end
    list.CanvasPosition = Vector2.zero
end)

local function execute()
    local args = string.split(string.lower(input.Text:match("^%s*(.-)%s*$")), " ")
    local filtered = {}
    for _, arg in ipairs(args) do if arg ~= "" then table.insert(filtered, arg) end end
    args = filtered
    if not args[1] then return end
    args[1] = args[1]:gsub("^[;!]", "")
    local command = commands[args[1]]
    if not command then status.Text = "Comando desconocido. Escribe help."; return end
    local ok, err = pcall(command.run, context, args)
    if not closed and args[1] ~= "help" then status.Text = ok and ("OK: " .. table.concat(args, " ")) or tostring(err) end
end
connect(run.Activated, execute)
connect(input.FocusLost, function(enter) if enter then execute() end end)
connect(UserInputService.InputBegan, function(key, processed)
    if processed or UserInputService:GetFocusedTextBox() then return end
    pressed[key.KeyCode] = true
    if key.KeyCode == Enum.KeyCode.RightShift then togglePanel() end
    if key.KeyCode == Enum.KeyCode.Semicolon then
        panel.Visible = true
        task.defer(function() if not closed then input:CaptureFocus() end end)
    end
end)
connect(UserInputService.InputEnded, function(key) pressed[key.KeyCode] = nil end)
connect(UserInputService.WindowFocusReleased, function() table.clear(pressed) end)
connect(UserInputService.JumpRequest, function()
    local _, humanoid = characterParts()
    if infiniteJump and humanoid and humanoid.Health > 0 then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
connect(RunService.Stepped, function()
    if not noclip then return end
    local character = player.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if collisions[part] == nil then collisions[part] = part.CanCollide end
                part.CanCollide = false
            end
        end
    end
end)
connect(RunService.RenderStepped, function()
    if not flying then return end
    local _, humanoid = characterParts()
    local camera = workspace.CurrentCamera
    if not flightPart or not flightPart.Parent or not humanoid or humanoid.Health <= 0
        or (vehicleMode and (not humanoid.SeatPart or humanoid.SeatPart.AssemblyRootPart ~= flightPart)) then
        stopFlight()
        return
    end
    if not camera then return end
    local direction = Vector3.zero
    if not UserInputService:GetFocusedTextBox() then
        local function down(key) return pressed[key] and 1 or 0 end
        direction = camera.CFrame.LookVector * (down(Enum.KeyCode.W) - down(Enum.KeyCode.S))
            + camera.CFrame.RightVector * (down(Enum.KeyCode.D) - down(Enum.KeyCode.A))
            + Vector3.yAxis * (down(Enum.KeyCode.Space) - down(Enum.KeyCode.LeftControl))
        if UserInputService.TouchEnabled and direction.Magnitude == 0 then
            direction = humanoid.MoveDirection + (humanoid.Jump and Vector3.yAxis or Vector3.zero)
        end
    end
    velocity.VectorVelocity = direction.Magnitude > 0 and direction.Unit * flySpeed or Vector3.zero
    orientation.CFrame = camera.CFrame.Rotation
end)
connect(player.CharacterRemoving, function()
    stopFlight()
    restoreCollisions()
    defaults = nil
    table.clear(pressed)
end)
connect(player.CharacterAdded, function(character) task.spawn(captureDefaults, character) end)
if player.Character then task.spawn(captureDefaults, player.Character) end
