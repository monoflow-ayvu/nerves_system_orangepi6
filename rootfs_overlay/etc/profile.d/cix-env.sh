# CIX userspace runtime paths (mirrors the vendor cix-env).
export LD_LIBRARY_PATH="/usr/share/cix/lib:/opt/cixgpu-pro/lib/aarch64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export GST_PLUGIN_PATH_1_0="/usr/share/cix/lib/gstreamer-1.0:/usr/lib/gstreamer-1.0"
# Prefer GLES on the Mali stack for GTK/GDK/GStreamer GL consumers.
export GDK_GL=gles
export GST_GL_API=gles2
