#!/bin/bash

USB_MOUNT_POINT="/media/$USER"

# Search for .usb_vc.json starting from the current directory
find_usb_vc_json() {
    # Search upwards from the current directory to find .usb_vc.json
    DIR=$(pwd)
    while [[ "$DIR" != "/" ]]; do
        if [[ -f "$DIR/.usb_vc.json" ]]; then
            echo "$DIR/.usb_vc.json"
            return 0
        fi
        DIR=$(dirname "$DIR")
    done
    return 1  # If no .usb_vc.json is found
}

# Assign the project config file path dynamically
USB_VC_CONFIG=$(find_usb_vc_json)
if [[ -z "$USB_VC_CONFIG" ]]; then
    echo "Error: Could not find .usb_vc.json in the current directory or any parent directory."
    exit 1
fi
PROJECTS_DIR="$(dirname "$USB_VC_CONFIG")"
# Log for debugging
log() {
    echo "[DEBUG] $1"
}

# Load config from .usb_vc.json (located inside the project directory)
load_config() {
    log "Loading configuration from $PROJECTS_DIR/$USB_VC_CONFIG"

    if [[ ! -f "$PROJECTS_DIR/$USB_VC_CONFIG" ]]; then
        echo "Error: No $USB_VC_CONFIG file found in the current directory."
        exit 1
    fi

    # Print out the contents of the .usb_vc.json file for debugging
    echo "Contents of $USB_VC_CONFIG:"
    cat "$PROJECTS_DIR/$USB_VC_CONFIG"

    # Extract values from the .usb_vc.json
    PROJECT_NAME=$(jq -r '.project' "$PROJECTS_DIR/$USB_VC_CONFIG")
    if [[ -z "$PROJECT_NAME" ]]; then
        echo "Error: 'project' field is missing in .usb_vc.json"
        exit 1
    fi
    log "Project Name: $PROJECT_NAME"

    # Debugging jq content extraction
    echo "Attempting to parse banned-content"
    BANNED_CONTENT=$(jq -r '.banned-content | @sh' "$PROJECTS_DIR/$USB_VC_CONFIG")
    
    if [[ $? -ne 0 ]]; then
        echo "Error parsing 'banned-content' in .usb_vc.json: $BANNED_CONTENT"
        exit 1
    fi
    log "Banned content: $BANNED_CONTENT"

    ENCRYPTION_TYPE=$(jq -r '.encryption-type' "$PROJECTS_DIR/$USB_VC_CONFIG")
    if [[ -z "$ENCRYPTION_TYPE" ]]; then
        echo "Error: 'encryption-type' field is missing in .usb_vc.json"
        exit 1
    fi
    log "Encryption Type: $ENCRYPTION_TYPE"

    DECRYPTION_KEY=$(jq -r '.decryption-key' "$PROJECTS_DIR/$USB_VC_CONFIG")
    if [[ -z "$DECRYPTION_KEY" ]]; then
        echo "Error: 'decryption-key' field is missing in .usb_vc.json"
        exit 1
    fi
    log "Decryption Key Loaded"
    
    echo "Loaded config for project: $PROJECT_NAME"
}

# Ensure a USB is mounted
check_usb_mounted() {
    log "Checking for mounted USB"
    local usb_list=$(lsblk -o NAME,MOUNTPOINT | grep "$usb_name")

    if [[ -z "$usb_list" ]]; then
        echo "Error: No USB detected. Please insert a USB drive."
        exit 1
    fi
    
    if [[ $(echo "$usb_list" | wc -l) -gt 1 ]]; then
        echo "Multiple USBs detected: "
        echo "$usb_list"
        echo "Please specify the USB with --usb-name"
        exit 1
    fi
    log "USB detected: $usb_list"
}

# Filter files based on banned content rules
filter_files() {
    log "Filtering files based on banned content"
    local rsync_filter=""
    
    for rule in $(echo $BANNED_CONTENT | tr -d "'"); do
        log "Processing banned content rule: $rule"
        if [[ $rule == /* ]]; then
            rsync_filter+="--exclude=$rule "
        elif [[ $rule == .* ]]; then
            rsync_filter+="--exclude=*${rule} "
        else
            rsync_filter+="--exclude=**/$rule "
        fi
    done
    
    echo "$rsync_filter"
    log "File filtering rules applied: $rsync_filter"
}

# Initialize a repo on the USB
init_repo() {
    local usb_name="$1"
    local repo_dir="$USB_MOUNT_POINT/$usb_name/usb-vc/$PROJECT_NAME"
    
    if [[ -d "$repo_dir" ]]; then
        echo "Error: Repository $PROJECT_NAME already exists on the USB."
        exit 1
    fi
    
    mkdir -p "$repo_dir"
    log "Initialized USB repo for $PROJECT_NAME at $repo_dir."
}

# Push the project to USB, including .usb_vc.json
push_to_usb() {
    local usb_name="$1"
    local branch_name="$2"
    local destination="$USB_MOUNT_POINT/$usb_name/usb-vc/$PROJECT_NAME/$branch_name"
    
    if [[ ! -d "$destination" ]]; then
        mkdir -p "$destination"
    fi
    
    local filter=$(filter_files)
    rsync -av $filter "$PROJECTS_DIR/" "$destination/"
    
    echo "Project $PROJECT_NAME (branch: $branch_name) has been pushed to USB: $destination"
}

# Pull the project from USB
pull_from_usb() {
    local usb_name="$1"
    local branch_name="$2"
    local source="$USB_MOUNT_POINT/$usb_name/usb-vc/$PROJECT_NAME/$branch_name"
    
    if [[ ! -d "$source" ]]; then
        echo "Error: Branch $branch_name does not exist in repository $PROJECT_NAME on USB."
        exit 1
    fi

    if [[ -f "$source/.encrypted" ]]; then
        echo "Error: Branch $branch_name is encrypted. Use --decrypt to pull."
        exit 1
    fi

    rsync -av "$source/" "$PROJECTS_DIR/"
    echo "Pulled branch $branch_name from USB to $PROJECT_NAME."
}
BANNED_CONTENT=$(jq -r '.banned-content[]' "$PROJECTS_DIR/$USB_VC_CONFIG")

        exit 1
    fi
    
    # Archive and encrypt
    tar -czf - "$destination" | gpg --symmetric --cipher-algo "$ENCRYPTION_TYPE" --passphrase "$DECRYPTION_KEY" -o "$destination.tar.gpg"
    
    # Remove the unencrypted version and add encryption flag
    rm -rf "$destination"
    touch "$destination/.encrypted"
    
    echo "Branch $branch_name in $PROJECT_NAME has been encrypted and saved as $destination.tar.gpg."
}

# Decrypt a branch or repo
decrypt_repo_or_branch() {
    local usb_name="$1"
    local branch_name="$2"
    local destination="$USB_MOUNT_POINT/$usb_name/usb-vc/$PROJECT_NAME/$branch_name"
    
    if [[ ! -f "$destination.tar.gpg" ]]; then
        echo "Error: Encrypted archive for branch $branch_name not found."
        exit 1
    fi
    
    # Decrypt and extract
    gpg --decrypt --passphrase "$DECRYPTION_KEY" -o - "$destination.tar.gpg" | tar -xzf - -C "$USB_MOUNT_POINT/$usb_name/usb-vc/$PROJECT_NAME/"
    rm "$destination.tar.gpg"
    rm "$destination/.encrypted"
    
    echo "Branch $branch_name in $PROJECT_NAME has been decrypted."
}

# Clone a project (with decryption)
clone_repo() {
    local usb_name="$1"
    local branch_name="$2"
    local destination="$PWD/$PROJECT_NAME"
    local usb_source="$USB_MOUNT_POINT/$usb_name/usb-vc/$PROJECT_NAME/$branch_name"
    
    if [[ ! -d "$usb_source" && ! -f "$usb_source.tar.gpg" ]]; then
        echo "Error: Branch $branch_name does not exist or is encrypted on USB."
        exit 1
    fi
    
    # Check if encryption exists and request password
    if [[ -f "$usb_source.tar.gpg" ]]; then
        echo "This branch is encrypted. Please provide the decryption password."
        read -s input_password
        if [[ "$input_password" != "$DECRYPTION_KEY" ]]; then
            echo "Incorrect decryption password."
            exit 1
        fi
        decrypt_repo_or_branch "$usb_name" "$branch_name"
    fi

    # Clone project with identical .usb_vc.json
    rsync -av "$usb_source/" "$destination/"
    echo "Cloned project $PROJECT_NAME from branch $branch_name."

    # Create a copy of .usb_vc.json
    cp "$usb_source/.usb_vc.json" "$destination/.usb_vc.json"
    echo "Copied .usb_vc.json to the cloned project."
}

# Git-like status for checking branches
status() {
    local usb_name="$1"
    local repo_dir="$USB_MOUNT_POINT/$usb_name/usb-vc/$PROJECT_NAME"
    
    if [[ -d "$repo_dir" ]]; then
        echo "Repository $PROJECT_NAME has the following branches on USB:"
        ls "$repo_dir"
    else
        echo "Repository $PROJECT_NAME not found on USB."
    fi
}

# Main command execution

# Main command execution
case "$1" in
    --init)
        if [[ -z "$2" ]]; then
            echo "Please specify --usb-name <usb-name>"
            exit 1
        fi
        load_config
        check_usb_mounted
        init_repo "$2"
        ;;
    
    --push)
        if [[ -z "$2" || -z "$3" ]]; then
            echo "Usage: usb-vc --push --usb-name <usb-name> --branch <branch-name>"
            exit 1
        fi
        load_config
        check_usb_mounted
        push_to_usb "$2" "$3"
        ;;
    
    --pull)
        if [[ -z "$2" || -z "$3" ]]; then
            echo "Usage: usb-vc --pull --usb-name <usb-name> --branch <branch-name>"
            exit 1
        fi
        load_config
        check_usb_mounted
        pull_from_usb "$2" "$3"
        ;;
    
    --encrypt)
        if [[ -z "$2" || -z "$3" ]]; then
            echo "Usage: usb-vc --encrypt --usb-name <usb-name> --branch <branch-name>"
            exit 1
        fi
        load_config
        check_usb_mounted
        encrypt_repo_or_branch "$2" "$3"
        ;;
    
    --decrypt)
        if [[ -z "$2" || -z "$3" ]]; then
            echo "Usage: usb-vc --decrypt --usb-name <usb-name> --branch <branch-name>"
            exit 1
        fi
        load_config
        check_usb_mounted
        decrypt_repo_or_branch "$2" "$3"
        ;;
    
    --clone)
        if [[ -z "$2" || -z "$3" ]]; then
            echo "Usage: usb-vc --clone --usb-name <usb-name> --branch <branch-name> --decrypt"
            exit 1
        fi
        load_config
        check_usb_mounted
        clone_repo "$2" "$3"
        ;;
    
    --status)
        if [[ -z "$2" ]]; then
            echo "Please specify --usb-name <usb-name>"
            exit 1
        fi
        load_config
        check_usb_mounted
        status "$2"
        ;;
    
    *)
        echo "Usage: usb-vc --init --usb-name <usb-name>"
        echo "       usb-vc --push --usb-name <usb-name> --branch <branch-name>"
        echo "       usb-vc --pull --usb-name <usb-name> --branch <branch-name>"
        echo "       usb-vc --encrypt --usb-name <usb-name> --branch <branch-name>"
        echo "       usb-vc --decrypt --usb-name <usb-name> --branch <branch-name>"
        echo "       usb-vc --clone --usb-name <usb-name> --branch <branch-name> --decrypt"
        echo "       usb-vc --status --usb-name <usb-name>"
        ;;
esac
