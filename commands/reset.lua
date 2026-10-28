-- Restaurar valores originales
return {
    usage = "reset",
    description = "Restaurar valores originales",
    run = function(ctx, args)
        ctx.reset()
    end,
}
