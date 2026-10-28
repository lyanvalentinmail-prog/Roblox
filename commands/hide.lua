-- Ocultar consola
return {
    usage = "hide",
    description = "Ocultar consola",
    run = function(ctx, args)
        ctx.togglePanel()
    end,
}
