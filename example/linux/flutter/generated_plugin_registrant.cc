//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <fastutils/fastutils_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) fastutils_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FastutilsPlugin");
  fastutils_plugin_register_with_registrar(fastutils_registrar);
}
