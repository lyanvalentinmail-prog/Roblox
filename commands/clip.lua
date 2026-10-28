-- Restaurar colisiones
return {
    usage = "clip",
    description = "Restaurar colisiones",
    run = function(ctx, args)
        ctx.setNoclip(false); ctx.restoreCollisions()
    end,
}
