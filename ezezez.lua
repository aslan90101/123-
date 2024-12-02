-- GUI Script with Rainbow Border and Star Particles

-- Create ScreenGui with TopbarInset
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999 -- Make it appear above other GUIs

-- Create main frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.25, 0, 0.3, 0) -- Smaller size
MainFrame.Position = UDim2.new(0.5, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 3
MainFrame.Active = true -- Required for dragging
MainFrame.Draggable = true -- Make frame draggable
MainFrame.Parent = ScreenGui

-- Create rainbow border effect
local function updateBorder()
    local hue = 0
    while wait() do
        hue = (hue + 1) % 360
        MainFrame.BorderColor3 = Color3.fromHSV(hue/360, 1, 1)
    end
end
coroutine.wrap(updateBorder)()

-- Create spawn button
local SpawnButton = Instance.new("TextButton")
SpawnButton.Size = UDim2.new(0.7, 0, 0.2, 0)
SpawnButton.Position = UDim2.new(0.15, 0, 0.4, 0)
SpawnButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnButton.Text = "Spawn Magic Sphere"
SpawnButton.Parent = MainFrame

-- Variable to store the magic sphere
local magicSphere = nil

-- Function to create permanent star particle effect
local function createPermanentStarEffect(position)
    if magicSphere then
        magicSphere:Destroy()
    end
    
    magicSphere = Instance.new("Part")
    magicSphere.Size = Vector3.new(2, 2, 2)
    magicSphere.Position = position
    magicSphere.Anchored = false -- No anchor
    magicSphere.CanCollide = true -- Enable collisions
    magicSphere.Material = Enum.Material.Neon
    magicSphere.BrickColor = BrickColor.new("White")
    magicSphere.Shape = Enum.PartType.Ball -- Make it spherical
    
    -- Add physical properties with extremely low density
    magicSphere.CustomPhysicalProperties = PhysicalProperties.new(
        0.1,  -- Ultra-light density for feather-like weight
        0.5,  -- Keep same friction
        0.3,  -- Keep same elasticity
        1,    -- Friction Weight
        1     -- Elasticity Weight
    )
    
    -- Remove BodyPosition to allow gravity
    -- Add only BodyGyro for rotation stability
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.D = 100 -- Damping
    bodyGyro.P = 10000 -- Power/Strength
    bodyGyro.Parent = magicSphere
    
    -- Create particle effect
    local particle = Instance.new("ParticleEmitter")
    particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particle.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
    })
    particle.Rate = 50
    particle.Speed = NumberRange.new(5, 10)
    particle.Lifetime = NumberRange.new(0.5, 1)
    particle.SpreadAngle = Vector2.new(-180, 180)
    particle.Parent = magicSphere
    
    magicSphere.Parent = workspace

    -- Add F key functionality
    local UserInputService = game:GetService("UserInputService")
    local holdingPlayer = nil
    local throwForce = 50

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.F then
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                if not holdingPlayer then
                    -- Pick up the sphere
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart and (humanoidRootPart.Position - magicSphere.Position).Magnitude < 10 then
                        holdingPlayer = player
                        -- Create weld when picked up
                        local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
                        if rightHand then
                            local weld = Instance.new("Weld")
                            weld.Part0 = rightHand
                            weld.Part1 = magicSphere
                            weld.C0 = CFrame.new(0, 1, 0)
                            weld.Parent = magicSphere
                            
                            -- Remove BodyGyro while held
                            if magicSphere:FindFirstChild("BodyGyro") then
                                magicSphere:FindFirstChild("BodyGyro"):Destroy()
                            end
                        end
                    end
                else
                    -- Throw the sphere
                    if holdingPlayer == player then
                        -- Remove weld
                        for _, weld in pairs(magicSphere:GetChildren()) do
                            if weld:IsA("Weld") then
                                weld:Destroy()
                            end
                        end
                        
                        -- Apply throwing force
                        local lookVector = character.HumanoidRootPart.CFrame.LookVector
                        magicSphere.Velocity = lookVector * throwForce
                        
                        -- Reset holding state
                        holdingPlayer = nil
                        
                        -- Recreate BodyGyro
                        local bodyGyro = Instance.new("BodyGyro")
                        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                        bodyGyro.D = 100
                        bodyGyro.P = 10000
                        bodyGyro.Parent = magicSphere
                    end
                end
            end
        end
    end)
end

-- Button click handler
SpawnButton.MouseButton1Click:Connect(function()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        local position = character.HumanoidRootPart.Position + 
                        character.HumanoidRootPart.CFrame.LookVector * 5 +
                        Vector3.new(0, 5, 0) -- Spawn slightly above to let it fall
        createPermanentStarEffect(position)
    end
end)

-- Create title label
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0.2, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "Magic Sphere Control (Press F to Pick Up/Throw)"
TitleLabel.Parent = MainFrame
