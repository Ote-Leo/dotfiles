import os
from pathlib import Path


try:
	HOME = Path(os.environ.get("HOME"))
except Exception:
	raise RuntimeError("Failed to located $HOME directory.")


XDG_VALUES: dict[str, Path] = {
	"XDG_CONFIG_HOME": HOME / ".config",
	"XDG_DATA_HOME": HOME / ".local" / "share",
	"XDG_CACHE_HOME": HOME / ".cache",
	"XDG_STATE_HOME": HOME / ".local" / "state",
}


for env_var, default_path in XDG_VALUES.items():
	path, user_path = default_path, os.environ.get(env_var)
	if user_path is not None:
		path = Path(user_path)
	XDG_VALUES[env_var] = path
