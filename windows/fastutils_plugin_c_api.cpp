#include "include/fastutils/fastutils_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "fastutils_plugin.h"

void FastutilsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  fastutils::FastutilsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
