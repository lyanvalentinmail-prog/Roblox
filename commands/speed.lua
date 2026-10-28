-- Velocidad al caminar (0–500)
return {
    aliases = {"ws"},
    parameter = { name = "valor", minimum = 0, maximum = 500, required = true },
    usage = "speed N",
    description = "Velocidad al caminar (0–500)",
    run = function(ctx, args)
        local n = ctx.number(args[2], 0, 500)
        local _, humanoid = ctx.characterParts()
        assert(humanoid, "No hay personaje")
        ctx.setSpeed(n)
        humanoid.WalkSpeed = n
    end,
}
