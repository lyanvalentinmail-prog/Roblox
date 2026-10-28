-- Velocidad de vuelo (1–500)
return {
    aliases = {"fs"},
    parameter = { name = "valor", minimum = 1, maximum = 500, required = true },
    usage = "flyspeed N",
    description = "Velocidad de vuelo (1–500)",
    run = function(ctx, args)
        ctx.setFlySpeed(ctx.number(args[2], 1, 500))
    end,
}
