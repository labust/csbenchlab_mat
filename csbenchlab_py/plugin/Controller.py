from abc import abstractmethod
from . import PluginBase
import numpy as np

class Controller(PluginBase):


    def __init__(self, *args, **kwargs):

        self._is_configured = False
        self.params = args[0] if len(args) > 0 else {}
        parsed = self.parse_positional_args(args)
        self.is_simulink = parsed.get('is_simulink', False)
        self.params = self.parse_dict(parsed.get('Params', self.params))
        self.data = self.parse_dict(parsed.get('Data', None))
        dims = parsed.get('Dims', None)
        if self.data is None and dims is not None:
            self.data = self.create_data_model(self.params, dims)
        elif self.data is None:
            raise ValueError("Data model must be provided or created with 'dims'.")
        self.initialize(**kwargs)

    def parse_dict(self, d):
        from types import SimpleNamespace
        # recursively convert dictionary to SimpleNamespace
        if d is None:
            return None
        if isinstance(d, dict):
            return SimpleNamespace(**{k: self.parse_dict(v) for k, v in d.items()})
        elif isinstance(d, list):
            return [self.parse_dict(item) for item in d]
        else:
            return np.array(d)

    @classmethod
    @abstractmethod
    def create_data_model(cls):
        """Create and return a data model for the controller."""
        return None

    @abstractmethod
    def on_configure(self):
        """Called when the controller is configured with parameters."""
        pass

    @abstractmethod
    def on_step(self):
        """Called on each step with the current parameters."""
        pass

    @abstractmethod
    def on_reset(self):
        """Called to reset the controller state."""
        pass

    @property
    def is_configured(self):
        """Check if the controller is configured."""
        return self._is_configured

    def configure(self, *args, **kwargs):
        self._is_configured = True
        self.on_configure()

    def step(self, y_ref, y, dt, *args, **kwargs):

        result = self.on_step(np.array(y_ref), np.array(y), np.double(dt), *args)
        return result

    def reset(self):
        pass