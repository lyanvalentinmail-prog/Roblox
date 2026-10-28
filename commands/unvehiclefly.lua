-- Detener vuelo del vehículo
return {
    usage = "unvehiclefly",
    description = "Detener vuelo del vehículo",
    run = function(ctx, args)
        ctx.stopFlight()
    end,
}
