-- Vuelo del vehículo
return {
    usage = "vehiclefly [velocidad]",
    description = "Vuelo del vehículo",
    run = function(ctx, args)
        if args[2] then ctx.setFlySpeed(ctx.number(args[2], 1, 500)) end
        ctx.startFlight(true)
    end,
}
