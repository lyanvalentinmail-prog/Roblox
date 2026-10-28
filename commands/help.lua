return {
    usage = "help [comando]",
    description = "Ayuda general o detallada de un comando",
    run = function(ctx, args) ctx.help(args[2]) end,
}
