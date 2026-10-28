-- Potencia de salto (0–500)
return {
    usage = "jumppower N",
    description = "Potencia de salto (0–500)",
    run = function(ctx, args)
        local n = ctx.number(args[2], 0, 500)
        local _, humanoid = ctx.characterParts()
        assert(humanoid, "No hay personaje")
        ctx.setJump(n)
        humanoid.UseJumpPower = true
        humanoid.JumpPower = n
    end,
}
