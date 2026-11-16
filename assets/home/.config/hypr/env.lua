-- NVIDIA VA-API/GLX. Remove both lines on systems without an NVIDIA GPU.
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
