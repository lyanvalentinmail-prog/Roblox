-- Gravedad local (0–1000)
return {
    usage = "gravity N",
    description = "Gravedad local (0–1000)",
    run = function(ctx, args)
        workspace.Gravity = ctx.number(args[2], 0, 1000)
    end,
}
