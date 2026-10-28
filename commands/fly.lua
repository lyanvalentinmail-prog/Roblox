-- Vuelo del personaje
return {
    aliases = {"v"},
    parameter = { name = "velocidad", minimum = 1, maximum = 500, required = false },
    usage = "fly [velocidad]",
    description = "Vuelo del personaje",
    run = function(ctx, args)
        if args[2] then ctx.setFlySpeed(ctx.number(args[2], 1, 500)) end
        ctx.startFlight(false)
    end,
}
