if command -v rustc >/dev/null 2>&1; then
	# shellcheck source=/dev/null
	source "$(rustc --print sysroot)"/etc/bash_completion.d/cargo
fi
