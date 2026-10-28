-- Saltar en el aire
return {
    usage = "infinitejump [on|off]",
    description = "Saltar en el aire",
    toggle = true,
    run = function(ctx, args)
        ctx.setInfiniteJump(args[2] ~= "off")
    end,
}
