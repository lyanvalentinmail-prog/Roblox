-- Atravesar paredes
return {
    usage = "noclip [on|off]",
    description = "Atravesar paredes",
    toggle = true,
    run = function(ctx, args)
        ctx.setNoclip(args[2] ~= "off")
        if args[2] == "off" then ctx.restoreCollisions() end
    end,
}
