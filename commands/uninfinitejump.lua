-- Desactivar salto infinito
return {
    usage = "uninfinitejump",
    description = "Desactivar salto infinito",
    run = function(ctx, args)
        ctx.setInfiniteJump(false)
    end,
}
