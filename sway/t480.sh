#!/usr/bin/sh

export QT_ENABLE_HIGHDPI_SCALING=1
export MOZ_ENABLE_WAYLAND=1
export MOZ_WAYLAND_USE_VAAPI=1
export WLR_DRM_NO_MODIFIERS=1

# Log cleanup
mv ~/log/sway.log ~/log/sway-prev.log

