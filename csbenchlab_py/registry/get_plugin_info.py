import sys, os
file_name = sys.argv[0]
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(file_name)))))

from argparse import ArgumentParser
from csbenchlab_py.plugin.plugin_helpers import parse_plugin_type, get_plugin_class


def get_plugin_info(plugin_path: str) -> dict:
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
    plugin_class = get_plugin_class(plugin_path)
    plugin_name = plugin_class.__name__
    plugin_bases = [base for base in plugin_class.__mro__ \
            if str(base) == "<class 'csbenchlab_py.plugin.PluginBase.PluginBase'>"]
    if not plugin_bases:
        raise ValueError(f"Plugin '{plugin_name}' does not implement the abstract class 'Plugin'.")
    plugin_info = {
        'Name': plugin_name,
        'T': parse_plugin_type(plugin_class),
        'HasParameters': hasattr(plugin_class, 'param_description') and plugin_class.param_description is not None,
        'Description': getattr(plugin_class, 'description', 'No description provided.'),
        'Parameters': getattr(plugin_class, 'param_description', None),
    }

    # check if plugin has abstract class 'Plugin' implemented
    return plugin_info

if __name__ == "__main__":


    parser = ArgumentParser(description="Get information about a specific plugin.")
    parser.add_argument("--plugin_path", type=str, default="", help="Path to the plugin directory or module.")
    args = parser.parse_args()
    plugin_path = args.plugin_path
    if not plugin_path.endswith('.py'):
        plugin_path = plugin_path + '.py'

    # Check if the plugin path is valid
    if not os.path.exists(plugin_path):
        raise ValueError(f"Plugin path '{plugin_path}' does not exist.")

    try:
        plugin_info = get_plugin_info(plugin_path)
    except ValueError as e:
        print(e)


