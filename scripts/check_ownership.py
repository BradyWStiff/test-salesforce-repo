# scripts/check_ownership.py
import json
import subprocess
import sys

OWNERS_FILE = './OWNERS.json'

# Get changed files in the PR (against main branch)
result = subprocess.run(['git', 'diff', '--name-only', 'origin/main...'], capture_output=True, text=True)
changed_files = result.stdout.strip().split('\n')
changed_files = [f for f in changed_files if f]

# Load ownership list
try:
    with open(OWNERS_FILE, 'r') as f:
        owners = json.load(f)
except FileNotFoundError:
    print(f"❌ Error: {OWNERS_FILE} not found.")
    sys.exit(1)

# Convert ownership list to a set of paths
owned_paths = {entry['path'] for entry in owners}

# Check for missing ownership
missing = [f for f in changed_files if f.startswith('force-app/') and f not in owned_paths]

if missing:
    print("\n❌ The following Salesforce metadata files are missing ownership entries in OWNERS.json:")
    for f in missing:
        print(f" - {f}")
    print("\nPlease add ownership for the above files in ownership/OWNERS.json before merging.")
    sys.exit(1)
else:
    print("✅ All changed metadata files have ownership defined.")
