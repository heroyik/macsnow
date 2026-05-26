#if MACSNOW_FORBID_DEBUG_BUILD
#error("Debug builds are forbidden for MacSnow. Use `swift build -c release`, `swift run -c release MacSnow`, or `bash Scripts/build_app_bundle.sh`.")
#endif
