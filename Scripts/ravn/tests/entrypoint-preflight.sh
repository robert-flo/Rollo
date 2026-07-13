#!/usr/bin/env bash
set -euo pipefail

RAVN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
export RAVN_DIR

fixture_dir=$(mktemp -d)
trap 'rm -rf "$fixture_dir"' EXIT

bin_dir="$fixture_dir/bin"
os_release="$fixture_dir/os-release"
mkdir -p "$bin_dir"

for command_name in bash cat clear dirname env find grep mkdir realpath rm sed sort touch; do
  ln -s "/usr/bin/$command_name" "$bin_dir/$command_name"
done

cat > "$os_release" << 'EOF'
ID=arch
ID_LIKE=arch
EOF

for command_name in git curl gum; do
  printf "#!/usr/bin/env bash\nif [[ \$1 == choose ]]; then printf 'q  Exit\\n'; fi\n" > "$bin_dir/$command_name"
  chmod +x "$bin_dir/$command_name"
done

run_entrypoint() {
  local input="$1"
  printf '%b' "$input" | script -qefc \
    "env PATH='$bin_dir' RAVN_OS_RELEASE_FILE='$os_release' RAVN_UI=gum '$RAVN_DIR/setup.sh'" \
    /dev/null
}

supported_output=$(run_entrypoint 'q\n')
grep -q 'RaVN Task Runner' <<< "$supported_output"
grep -q 'Choose an action' <<< "$supported_output"

cat > "$os_release" << 'EOF'
ID=ubuntu
ID_LIKE=debian
EOF
unsupported_output=$(run_entrypoint 'q\n' || true)
grep -q 'Unsupported operating system' <<< "$unsupported_output"
if grep -q 'Choose an action' <<< "$unsupported_output"; then
  printf 'FAIL: unsupported systems opened the menu\n' >&2
  exit 1
fi

cat > "$os_release" << 'EOF'
ID=arch
ID_LIKE=arch
EOF
rm "$bin_dir/gum"
printf "#!/usr/bin/env bash\ntouch \"\$BIN_DIR/gum\"\n" > "$bin_dir/sudo"
chmod +x "$bin_dir/sudo"
install_output=$(BIN_DIR="$bin_dir" run_entrypoint 'q\n')
grep -q 'RaVN Task Runner' <<< "$install_output"

rm "$bin_dir/gum"
printf '#!/usr/bin/env bash\nexit 1\n' > "$bin_dir/sudo"
chmod +x "$bin_dir/sudo"
failure_output=$(run_entrypoint 'q\n' || true)
grep -q 'Unable to install interactive dependencies' <<< "$failure_output"
if grep -q 'Choose an action' <<< "$failure_output"; then
  printf 'FAIL: package-manager failure opened the menu\n' >&2
  exit 1
fi

printf 'PASS: executable interactive preflight\n'
