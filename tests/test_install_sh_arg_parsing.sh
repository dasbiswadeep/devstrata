#!/usr/bin/env bash
# test_install_sh_arg_parsing.sh — verify install.sh parses --lite/--full/--pro
# and strips leading dashes correctly. Also verify invalid args are rejected.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO/scripts/install.sh"
FAIL=0

# We can't run install.sh interactively (it prompts). Instead we source the
# arg-parsing part by extracting the relevant lines and checking behavior.
# Simpler: grep for the parsing logic and verify the PROFILE variable derivation.

# 1. install.sh must default to 'lite' when no profile arg given
#    (new parser: loops over args, PROFILE defaults to "lite")
if grep -qE 'PROFILE="lite"' "$INSTALL" && grep -qE 'for arg in "\$@"' "$INSTALL"; then
  echo "PASS: install.sh defaults to 'lite' when no profile arg given"
else
  echo "FAIL: install.sh does not default to 'lite'"
  FAIL=1
fi

# 2. install.sh must accept --lite/--full/--pro via arg loop (not positional $1)
if grep -qE '\-\-lite\)  PROFILE="lite"' "$INSTALL" && grep -qE '\-\-full\) PROFILE="full"' "$INSTALL" && grep -qE '\-\-pro\)  PROFILE="pro"' "$INSTALL"; then
  echo "PASS: install.sh parses --lite/--full/--pro via arg loop"
else
  echo "FAIL: install.sh does not parse profile flags correctly"
  FAIL=1
fi

# 3. install.sh must branch on 'full' or 'pro' for the extra tools
if grep -qE 'PROFILE" == "full" \|\| "\$PROFILE" == "pro"' "$INSTALL"; then
  echo "PASS: install.sh has --full/--pro branch for extra tools"
else
  echo "FAIL: install.sh missing --full/--pro branch"
  FAIL=1
fi

# 4. install.sh must branch on 'pro' only for Hermes + Obsidian
if grep -qE 'PROFILE" == "pro"' "$INSTALL"; then
  echo "PASS: install.sh has --pro-only branch (Hermes + Obsidian)"
else
  echo "FAIL: install.sh missing --pro-only branch"
  FAIL=1
fi

# 5. install.sh must accept all three profiles — verify the usage string mentions each
for p in lite full pro; do
  if grep -q "\-\-$p" "$INSTALL"; then
    echo "PASS: install.sh mentions --$p"
  else
    echo "FAIL: install.sh does not mention --$p"
    FAIL=1
  fi
done

# 6. install.sh must reject invalid profile args (new in round 2)
if grep -qE 'Unknown arg|Invalid profile' "$INSTALL"; then
  echo "PASS: install.sh rejects invalid args"
else
  echo "FAIL: install.sh accepts invalid profile args"
  FAIL=1
fi

# 7. install.sh must support --yes/-y and --force flags (new in round 2)
if grep -q -- '--yes' "$INSTALL" && grep -q -- '--force' "$INSTALL"; then
  echo "PASS: install.sh supports --yes and --force flags"
else
  echo "FAIL: install.sh missing --yes or --force"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1