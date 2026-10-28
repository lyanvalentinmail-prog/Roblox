-- Vuelo del vehículo
return {
    aliases = {"vfly"},
    parameter = { name = "velocidad", minimum = 1, maximum = 500, required = false },
    usage = "vehiclefly [velocidad]",
    description = "Vuelo del vehículo",
    run = function(ctx, args)
        if args[2] then ctx.setFlySpeed(ctx.number(args[2], 1, 500)) end
        ctx.startFlight(true)
    end,
}
