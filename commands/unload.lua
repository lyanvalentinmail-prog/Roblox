-- Restaurar y cerrar
return {
    usage = "unload",
    description = "Restaurar y cerrar",
    run = function(ctx, args)
        ctx.cleanup()
    end,
}
