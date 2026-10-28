"""Tests of the actual dispatcher and modules with mocked Roblox state.
Run with Python + lupa installed. Does not simulate Roblox UI or networking.
"""
from pathlib import Path
from lupa import LuaRuntime

root = Path(__file__).resolve().parent.parent
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute('''
commands = {}; aliases = {}; closed = false; status = {Text = ""}
workspace = {Gravity = 196.2}
humanoid = {WalkSpeed = 16, JumpPower = 50}
context = {
 status = status,
 number = function(v, lo, hi)
  local n = tonumber(v)
  assert(n and n == n and n >= lo and n <= hi, "invalid number")
  return n
 end,
 characterParts = function() return {}, humanoid end,
 setSpeed = function(n) speed = n end,
 setJump = function(n) jump = n end,
 setFlySpeed = function(n) flyspeed = n end,
 startFlight = function(v) vehicle = v; flying = true end,
 stopFlight = function() flying = false end,
 setNoclip = function(v) noclip = v end,
 restoreCollisions = function() restored = true end,
 setInfiniteJump = function(v) infinitejump = v end,
 help = function(v) status.Text = "help " .. (v or "general") end,
}
''')
for path in sorted((root / 'commands').glob('*.lua')):
    lua.globals().commands[path.stem] = lua.execute(path.read_text())
lua.execute('''
for name, cmd in pairs(commands) do
 aliases[name] = name
 for _, alias in ipairs(cmd.aliases or {}) do aliases[alias] = name end
end
''')
source = (root / 'Main.client.lua').read_text()
start = source.index('local history, historyIndex, draft')
end = source.index('connect(run.Activated', start)
lua.execute(source[start:end] + '\nrunCommand = execute')
cases = [
    ('speed 32', 'humanoid.WalkSpeed == 32'),
    ('/WS --valor=45', 'humanoid.WalkSpeed == 45'),
    ('speed --valor 50', 'humanoid.WalkSpeed == 50'),
    ('speed -1', 'humanoid.WalkSpeed == 50 and status.Text:find("Error:")'),
    ('speed 1 2', 'humanoid.WalkSpeed == 50 and status.Text:find("Error:")'),
    ('speed --wrong=9', 'humanoid.WalkSpeed == 50 and status.Text:find("Error:")'),
    ('speed --valor', 'status.Text:find("Error:")'),
    ('speed', 'status.Text:find("Error:")'),
    ('speed nan', 'status.Text:find("Error:")'),
    ('fly 80', 'flying and flyspeed == 80 and not vehicle'),
    ('/vfly --velocidad=90', 'flying and flyspeed == 90 and vehicle'),
    ('fly 501', 'flyspeed == 90 and status.Text:find("Error:")'),
    ('noclip OFF', 'noclip == false and restored'),
    (';noclip on', 'noclip == true'),
    ('noclip maybe', 'noclip == true and status.Text:find("Error:")'),
    ('infinitejump off', 'infinitejump == false'),
    ('!jp 100', 'humanoid.JumpPower == 100 and humanoid.UseJumpPower'),
    ('gravity 0', 'workspace.Gravity == 0'),
    ('speed --help', 'status.Text == "help speed" and humanoid.WalkSpeed == 50'),
    ('help fly', 'status.Text == "help fly"'),
    ('unknown', 'status.Text:find("desconocido")'),
]
for command, assertion in cases:
    lua.globals().runCommand(command)
    assert lua.eval(assertion), (command, lua.globals().status.Text)
print(f'{len(cases)} dispatcher/module tests passed.')
