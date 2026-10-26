local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Laptop screen on the left
hl.monitor({
  output = "eDP-1",
  mode = "1920x1080@120",
  position = "0x0",
  scale = omarchy_monitor_scale,
})

-- Dell external monitor on the right
hl.monitor({
  output = "HDMI-A-1",
  mode = "1600x900@60",
  position = "1920x0",
  scale = omarchy_monitor_scale,
}) -- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
