-- Velocidad de vuelo (1–500)
return {
    usage = "flyspeed N",
    description = "Velocidad de vuelo (1–500)",
    run = function(ctx, args)
        ctx.setFlySpeed(ctx.number(args[2], 1, 500))
    end,
}
