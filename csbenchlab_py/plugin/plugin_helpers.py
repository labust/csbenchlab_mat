
def parse_plugin_type(plugin_class):
    """
    Parses the type of a plugin class to determine if it is a 'Controller', 'System', or else.

    Args:
        plugin_class (type): The class of the plugin to parse.
    """
    if any([base for base in plugin_class.__bases__ \
            if str(base) ==  "<class 'csbenchlab_py.plugin.DynSystem.DynSystem'>"]):
        return 1
    if any([base for base in plugin_class.__bases__ \
            if str(base) ==  "<class 'csbenchlab_py.plugin.Controller.Controller'>"]):
        return 2
    if any([base for base in plugin_class.__bases__ \
            if str(base) ==  "<class 'csbenchlab_py.plugin.Estimator.Estimator'>"]):
        return 3
    if any([base for base in plugin_class.__bases__ \
            if str(base) ==  "<class 'csbenchlab_py.plugin.DisturbanceGenerator.DisturbanceGenerator'>"]):
        return 4
    return 0


def get_plugin_class(plugin_path: str) -> dict:
    """
    Retrieves information about a plugin by its name.

    Args:
        plugin_path (str): The name of the plugin to retrieve information for.

    Returns:
        dict: A dictionary containing the plugin's information, including its name,
              description, and parameters.

    Raises:
        ValueError: If the plugin does not exist or if the plugin name is invalid.
    """
    import importlib.util
    import os
    if not os.path.exists(plugin_path):
        raise ValueError(f"Plugin path '{plugin_path}' does not exist.")
    plugin_name = os.path.splitext(os.path.basename(plugin_path))[0]
    spec = importlib.util.spec_from_file_location(plugin_name, plugin_path)
    if spec is None:
        raise ValueError(f"Could not find plugin '{plugin_name}' at path '{plugin_path}'.")
    plugin_module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(plugin_module)
    if not hasattr(plugin_module, plugin_name):
        raise ValueError(f"Plugin '{plugin_name}' does not have a 'Plugin' class.")
    return getattr(plugin_module, plugin_name)