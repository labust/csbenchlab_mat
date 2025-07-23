import sys, os
file_name = sys.argv[0]
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(file_name)))))

from argparse import ArgumentParser

from csbenchlab_py.plugin.plugin_helpers import get_plugin_class

def instantiate_plugin(plugin_path: str) -> dict:
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
    instance = parse_plugin(plugin_class('is_simulink', 1, 'Params', {'param1': 1, 'param2': 2}, 'Data', {}))

    # check if plugin has abstract class 'Plugin' implemented
    return instance


def parse_plugin(obj):
    from types import SimpleNamespace
    ret = SimpleNamespace()
    for attr in dir(obj):
        if attr.startswith('_'):
            continue
        setattr(ret, attr, getattr(obj, attr))

    return ret

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
        instance = instantiate_plugin(plugin_path)
        a = 5
    except ValueError as e:
        print(e)


