set -e
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $script_dir/helper.sh

# Trap the ERR signal
trap 'if [[ $? -ne 0 ]]; then error_handler; fi' EXIT

$script_dir/install.sh && $script_dir/setup.sh