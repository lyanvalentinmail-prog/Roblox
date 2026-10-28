-- Detener vuelo
return {
    usage = "unfly",
    description = "Detener vuelo",
    run = function(ctx, args)
        ctx.stopFlight()
    end,
}
