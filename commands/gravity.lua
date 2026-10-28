-- Gravedad local (0–1000)
return {
    aliases = {"grav"},
    parameter = { name = "valor", minimum = 0, maximum = 1000, required = true },
    usage = "gravity N",
    description = "Gravedad local (0–1000)",
    run = function(ctx, args)
        workspace.Gravity = ctx.number(args[2], 0, 1000)
    end,
}
