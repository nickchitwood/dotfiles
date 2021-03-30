#!/usr/bin/sh

# Disable Mozilla with Wayland until Sway 1.6
# export MOZ_ENABLE_WAYLAND=1
# export MOZ_WAYLAND_USE_VAAPI=1

# Fix intdel gpu issues
export WLR_DRM_NO_MODIFIERS=1

# Log cleanup
mv ~/log/sway.log ~/log/sway-prev.log

