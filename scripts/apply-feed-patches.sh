#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root"

for patch_dir in "$root"/patches/feeds/*; do
	[ -d "$patch_dir" ] || continue
	feed=${patch_dir##*/}
	feed_dir="$root/feeds/$feed"
	if [ ! -d "$feed_dir" ]; then
		echo "Feed '$feed' is missing; run ./scripts/feeds update -a first." >&2
		exit 1
	fi

	changed=0
	for patch_file in "$patch_dir"/*.patch; do
		[ -f "$patch_file" ] || continue
		if git -C "$feed_dir" apply --check "$patch_file" >/dev/null 2>&1; then
			git -C "$feed_dir" apply "$patch_file"
			echo "Applied $feed/${patch_file##*/}"
			changed=1
		elif git -C "$feed_dir" apply --reverse --check "$patch_file" >/dev/null 2>&1; then
			echo "Already applied $feed/${patch_file##*/}"
		else
			echo "Cannot apply $feed/${patch_file##*/}; check the feed's upstream changes." >&2
			exit 1
		fi
	done

	if [ "$changed" = 1 ]; then
		./scripts/feeds update -i "$feed"
	fi
done
