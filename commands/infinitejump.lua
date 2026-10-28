-- Saltar en el aire
return {
    usage = "infinitejump",
    description = "Saltar en el aire",
    run = function(ctx, args)
        ctx.setInfiniteJump(true)
    end,
}
