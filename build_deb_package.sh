#!/bin/bash

# build_deb_package.sh
# Script to build a .deb package for the dbusermgr-suite.
# This script should be placed in the root of the dbusermgr-suite project directory.

set -e

# --- Package Information (EDIT THESE) ---
PACKAGE_NAME="dbusermgr-suite"
PACKAGE_VERSION="1.0.0" # Update this for new releases
ARCHITECTURE="all" # 'all' for shell scripts, or 'amd64', 'arm64' etc. if arch-specific binaries
MAINTAINER_NAME="Your Name or Organization"
MAINTAINER_EMAIL="your-email@example.com"
DESCRIPTION_SHORT="Database User Management Suite CLI"
DESCRIPTION_LONG="A command-line tool for managing database users (e.g., PostgreSQL)
running in Docker containers. It provides a unified interface for common
user management tasks."
# Dependencies: bash, docker.io (or docker-ce/docker-ee), coreutils (for basic commands like cp, mkdir, chmod, tr, xargs)
# psql client is needed inside the target Docker containers, not directly by dbusermgr host script.
DEPENDENCIES="bash (>= 4.0), docker.io | docker-ce | docker-ee, coreutils"

# --- Script Configuration ---
# Source directory is the current directory where this script is located
SOURCE_PROJECT_ROOT="." 

# Staging directory for building the package
STAGING_DIR_BASE="${PACKAGE_NAME}_${PACKAGE_VERSION}_${ARCHITECTURE}"
STAGING_DIR_FULL_PATH="$(pwd)/${STAGING_DIR_BASE}" # Absolute path for safety

# Target installation paths within the package (and on the target system)
PREFIX="/usr/local"
SBIN_DIR_TARGET="${PREFIX}/sbin"
LIB_DIR_BASE_TARGET="${PREFIX}/lib"
LIB_DIR_APP_TARGET="${LIB_DIR_BASE_TARGET}/dbusermgr"
HANDLERS_DIR_TARGET="${LIB_DIR_APP_TARGET}/handlers"
ETC_DIR_BASE_TARGET="/etc"
ETC_DIR_APP_TARGET="${ETC_DIR_BASE_TARGET}/dbusermgr"
LOG_DIR_BASE_TARGET="/var/log"
LOG_DIR_APP_TARGET="${LOG_DIR_BASE_TARGET}/dbusermgr"
SYSTEMD_DIR_TARGET="/etc/systemd/system"

# Source file names from your project structure
MAIN_CLI_TOOL_NAME="dbusermgr"
UTILS_SCRIPT_NAME="utils.sh"
POSTGRES_HANDLER_NAME="postgres_handler.sh"
CONFIG_FILE_NAME_EXAMPLE="dbusermgr.conf.example"
SYSTEMD_SERVICE_NAME_EXAMPLE="dbusermgr-task@.service.example"

# --- Helper Functions ---
info() {
    echo "[INFO] $1"
}
error_exit() {
    echo "[ERROR] $1" >&2
    exit 1
}

# --- Main Build Logic ---
info "Starting Debian package build for ${PACKAGE_NAME} version ${PACKAGE_VERSION}..."

# 0. Check for dpkg-deb
if ! command -v dpkg-deb >/dev/null 2>&1; then
    error_exit "dpkg-deb command not found. Please install dpkg-dev package (e.g., sudo apt-get install dpkg-dev)."
fi

# 1. Clean up any previous staging directory and .deb file
info "Cleaning up previous build artifacts..."
rm -rf "${STAGING_DIR_FULL_PATH}"
rm -f "${PACKAGE_NAME}_${PACKAGE_VERSION}_${ARCHITECTURE}.deb"

# 2. Create staging directory structure
info "Creating staging directory: ${STAGING_DIR_FULL_PATH}"
mkdir -p "${STAGING_DIR_FULL_PATH}${SBIN_DIR_TARGET}"
mkdir -p "${STAGING_DIR_FULL_PATH}${HANDLERS_DIR_TARGET}" # Creates parent lib/dbusermgr too
mkdir -p "${STAGING_DIR_FULL_PATH}${ETC_DIR_APP_TARGET}"
mkdir -p "${STAGING_DIR_FULL_PATH}${SYSTEMD_DIR_TARGET}"
# Note: /var/log/dbusermgr will be created by postinst script

# 3. Copy project files into the staging directory
info "Copying project files to staging area..."
# Main CLI tool
cp "${SOURCE_PROJECT_ROOT}/bin/${MAIN_CLI_TOOL_NAME}" "${STAGING_DIR_FULL_PATH}${SBIN_DIR_TARGET}/"
# Lib files
cp "${SOURCE_PROJECT_ROOT}/lib/dbusermgr/${UTILS_SCRIPT_NAME}" "${STAGING_DIR_FULL_PATH}${LIB_DIR_APP_TARGET}/"
cp "${SOURCE_PROJECT_ROOT}/lib/dbusermgr/handlers/${POSTGRES_HANDLER_NAME}" "${STAGING_DIR_FULL_PATH}${HANDLERS_DIR_TARGET}/"
# Example config
cp "${SOURCE_PROJECT_ROOT}/config/${CONFIG_FILE_NAME_EXAMPLE}" "${STAGING_DIR_FULL_PATH}${ETC_DIR_APP_TARGET}/"
# Example systemd unit
cp "${SOURCE_PROJECT_ROOT}/systemd/${SYSTEMD_SERVICE_NAME_EXAMPLE}" "${STAGING_DIR_FULL_PATH}${SYSTEMD_DIR_TARGET}/"

# 4. Create DEBIAN directory and control files
DEBIAN_DIR="${STAGING_DIR_FULL_PATH}/DEBIAN"
info "Creating DEBIAN directory and control files..."
mkdir -p "${DEBIAN_DIR}"

# Create DEBIAN/control file
cat > "${DEBIAN_DIR}/control" << EOF
Package: ${PACKAGE_NAME}
Version: ${PACKAGE_VERSION}
Architecture: ${ARCHITECTURE}
Maintainer: ${MAINTAINER_NAME} <${MAINTAINER_EMAIL}>
Depends: ${DEPENDENCIES}
Description: ${DESCRIPTION_SHORT}
$(echo "${DESCRIPTION_LONG}" | sed 's/^/ /g')
EOF

# Create DEBIAN/postinst (post-installation script)
cat > "${DEBIAN_DIR}/postinst" << EOF
#!/bin/bash
set -e

case "\$1" in
    configure)
        echo "Configuring ${PACKAGE_NAME}..."
        # Create log directory if it doesn't exist
        LOG_DIR_APP="${LOG_DIR_APP_TARGET}" # Path embedded from build script
        if [ ! -d "\${LOG_DIR_APP}" ]; then
            mkdir -p "\${LOG_DIR_APP}"
            chown root:root "\${LOG_DIR_APP}"
            chmod 0755 "\${LOG_DIR_APP}"
            echo "Created log directory: \${LOG_DIR_APP}"
        fi

        # Create config directory if it doesn't exist
        ETC_DIR_APP="${ETC_DIR_APP_TARGET}" # Path embedded
        if [ ! -d "\${ETC_DIR_APP}" ]; then
            mkdir -p "\${ETC_DIR_APP}"
            chmod 0755 "\${ETC_DIR_APP}"
            echo "Created config directory: \${ETC_DIR_APP}"
        fi
        
        # Copy example config if actual config doesn't exist
        EXAMPLE_CONFIG_PATH="\${ETC_DIR_APP}/${CONFIG_FILE_NAME_EXAMPLE}"
        ACTUAL_CONFIG_PATH="\${ETC_DIR_APP}/dbusermgr.conf" # Actual name
        if [ -f "\${EXAMPLE_CONFIG_PATH}" ] && [ ! -f "\${ACTUAL_CONFIG_PATH}" ]; then
            cp "\${EXAMPLE_CONFIG_PATH}" "\${ACTUAL_CONFIG_PATH}"
            chmod 0644 "\${ACTUAL_CONFIG_PATH}"
            echo "Copied example configuration to \${ACTUAL_CONFIG_PATH}."
            echo "Please review and customize \${ACTUAL_CONFIG_PATH} as needed."
        fi

        # Copy example systemd unit if actual doesn't exist
        EXAMPLE_SYSTEMD_PATH="${SYSTEMD_DIR_TARGET}/${SYSTEMD_SERVICE_NAME_EXAMPLE}" # Path embedded
        ACTUAL_SYSTEMD_PATH="${SYSTEMD_DIR_TARGET}/dbusermgr-task@.service" # Actual name
         if [ -f "\${EXAMPLE_SYSTEMD_PATH}" ] && [ ! -f "\${ACTUAL_SYSTEMD_PATH}" ]; then
            cp "\${EXAMPLE_SYSTEMD_PATH}" "\${ACTUAL_SYSTEMD_PATH}"
            chmod 0644 "\${ACTUAL_SYSTEMD_PATH}"
            echo "Copied example systemd unit to \${ACTUAL_SYSTEMD_PATH}."
            echo "To use, enable specific instances: systemctl enable dbusermgr-task@myinstance.service"
        fi
        
        echo "Reloading systemd daemon..."
        systemctl daemon-reload || echo "Failed to reload systemd daemon. Run 'systemctl daemon-reload' manually."

        echo "${PACKAGE_NAME} configuration complete."
    ;;
    abort-upgrade|abort-remove|abort-deconfigure)
    ;;
    *)
        echo "postinst called with unknown argument \`\$1'" >&2
        exit 1
    ;;
esac
exit 0
EOF

# Create DEBIAN/prerm (pre-removal script)
cat > "${DEBIAN_DIR}/prerm" << EOF
#!/bin/bash
set -e
case "\$1" in
    remove|upgrade|deconfigure)
        echo "Preparing to remove ${PACKAGE_NAME}..."
    ;;
    failed-upgrade)
    ;;
    *)
        echo "prerm called with unknown argument \`\$1'" >&2
        exit 1
    ;;
esac
exit 0
EOF

# Create DEBIAN/postrm (post-removal script)
cat > "${DEBIAN_DIR}/postrm" << EOF
#!/bin/bash
set -e
case "\$1" in
    purge)
        echo "Purging configuration files for ${PACKAGE_NAME}..."
        rm -rf "${ETC_DIR_APP_TARGET}" || echo "Could not remove ${ETC_DIR_APP_TARGET}"
        echo "Log files in ${LOG_DIR_APP_TARGET} may need to be removed manually."
    ;;
    remove|upgrade|deconfigure)
        echo "Removing ${PACKAGE_NAME}..."
        ACTUAL_SYSTEMD_PATH="${SYSTEMD_DIR_TARGET}/dbusermgr-task@.service" 
        if [ -f "\${ACTUAL_SYSTEMD_PATH}" ]; then
            rm -f "\${ACTUAL_SYSTEMD_PATH}"
            echo "Removed systemd service file: \${ACTUAL_SYSTEMD_PATH}"
            systemctl daemon-reload || echo "Failed to reload systemd daemon. Run 'systemctl daemon-reload' manually."
        fi
        EXAMPLE_SYSTEMD_PATH="${SYSTEMD_DIR_TARGET}/${SYSTEMD_SERVICE_NAME_EXAMPLE}"
        if [ -f "\${EXAMPLE_SYSTEMD_PATH}" ]; then
             rm -f "\${EXAMPLE_SYSTEMD_PATH}"
             echo "Removed example systemd service file: \${EXAMPLE_SYSTEMD_PATH}"
        fi

        echo "Configuration files in ${ETC_DIR_APP_TARGET} and log files in ${LOG_DIR_APP_TARGET} were not removed."
        echo "Remove them manually if they are no longer needed."
    ;;
    failed-upgrade)
    ;;
    *)
        echo "postrm called with unknown argument \`\$1'" >&2
        exit 1
    ;;
esac
exit 0
EOF

# 5. Set permissions for control scripts and staged files
info "Setting permissions..."
chmod 0755 "${DEBIAN_DIR}/postinst" "${DEBIAN_DIR}/prerm" "${DEBIAN_DIR}/postrm"

chmod 0755 "${STAGING_DIR_FULL_PATH}${SBIN_DIR_TARGET}/${MAIN_CLI_TOOL_NAME}"
chmod 0755 "${STAGING_DIR_FULL_PATH}${LIB_DIR_APP_TARGET}/${UTILS_SCRIPT_NAME}"
chmod 0755 "${STAGING_DIR_FULL_PATH}${HANDLERS_DIR_TARGET}/${POSTGRES_HANDLER_NAME}"

# 6. Build the .deb package
info "Building the Debian package..."
dpkg-deb --build "${STAGING_DIR_BASE}" 

info "Package built: $(pwd)/${STAGING_DIR_BASE}.deb"
info "You can now install it using: sudo dpkg -i ${STAGING_DIR_BASE}.deb"
info "If dependencies are missing, run: sudo apt-get -f install"

info "Build process complete."
exit 0
