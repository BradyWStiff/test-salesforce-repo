# scripts/check_ownership.py
import json
import subprocess
import sys
import os

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

    print("\n🔧 Suggested entries to add to OWNERS.json:")
    suggestions = []
    for f in missing:
        parts = f.split('/')
        metadata_type = parts[3] if len(parts) > 3 else "unknown"
        name = os.path.splitext(parts[-1])[0] if "." in parts[-1] else parts[-1]
        suggestion = {
            "metadata_type": metadata_type,
            "metadata_name": name,
            "owner": "team-???",
            "path": f
        }
        suggestions.append(suggestion)
    print(json.dumps(suggestions, indent=2))
    print("\n💡 Copy the above entries into ownership/OWNERS.json and replace \"team-???\" with the appropriate team.")
    sys.exit(1)
else:
    print("✅ All changed metadata files have ownership defined.")
