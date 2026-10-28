-- Mostrar controles
return {
    usage = "help",
    description = "Mostrar controles",
    run = function(ctx, args)
        ctx.status.Text = "Fly: WASD, Espacio sube, Ctrl baja. Móvil: joystick + salto. reset restaura los valores iniciales."
    end,
}
