#!/bin/bash

# create_full_dbusermgr_project.sh
# This script generates the dbusermgr-suite project structure and files
# within the CURRENT DIRECTORY. It avoids creating a new root project folder
# and will not overwrite existing README.md or .gitignore files.

set -e

# --- Configuration ---
# PROJECT_ROOT_DIR is now the current directory
PROJECT_ROOT_DIR="." # Files will be created relative to the current directory

# Subdirectories to be created within the current directory
BIN_SUBDIR="bin"
LIB_SUBDIR_BASE="lib"
LIB_SUBDIR_APP="dbusermgr" # lib/dbusermgr
HANDLERS_SUBDIR="handlers" # lib/dbusermgr/handlers
CONFIG_SUBDIR="config"
SYSTEMD_SUBDIR="systemd"

# File names
MAIN_CLI_TOOL_NAME="dbusermgr"
UTILS_SCRIPT_NAME="utils.sh"
POSTGRES_HANDLER_NAME="postgres_handler.sh"
CONFIG_FILE_NAME_EXAMPLE="dbusermgr.conf.example"
SYSTEMD_SERVICE_NAME_EXAMPLE="dbusermgr-task@.service.example"
INSTALL_SCRIPT_NAME="install.sh"
README_NAME="README.md"
GITIGNORE_NAME=".gitignore"

# Paths that will be embedded into scripts, referring to *installed* locations
INSTALLED_PREFIX="/usr/local"
INSTALLED_LIB_DIR="${INSTALLED_PREFIX}/lib/${LIB_SUBDIR_APP}"
ABSOLUTE_UTILS_SCRIPT_PATH_INSTALLED="${INSTALLED_LIB_DIR}/${UTILS_SCRIPT_NAME}"
ABSOLUTE_HANDLERS_DIR_INSTALLED="${INSTALLED_LIB_DIR}/${HANDLERS_SUBDIR}"

# --- Helper Functions ---
info() {
    echo "[INFO] $1"
}

error_exit() {
    echo "[ERROR] $1" >&2
    exit 1
}

# --- Main Logic ---
info "Generating project files and directories in the current location: $(pwd)"
# No longer creating or cd'ing into a new PROJECT_ROOT_DIR

info "Creating subdirectories if they don't exist..."
mkdir -p "${BIN_SUBDIR}"
mkdir -p "${LIB_SUBDIR_BASE}/${LIB_SUBDIR_APP}/${HANDLERS_SUBDIR}" 
mkdir -p "${CONFIG_SUBDIR}"
mkdir -p "${SYSTEMD_SUBDIR}"
info "Subdirectories created/verified."

# 1. Create .gitignore ONLY IF IT DOESN'T EXIST
if [ ! -f "${GITIGNORE_NAME}" ]; then
    info "Generating .gitignore..."
    cat > "${GITIGNORE_NAME}" << 'EOF'
# .gitignore

# Local user files
*.local
*.backup
*.swp
*~

# Log files (if generated locally during development)
*.log

# OS-generated files
.DS_Store
Thumbs.db

# IDE and editor specific files
.vscode/
.idea/
*.sublime-project
*.sublime-workspace

# Temporary files from scripts
tmp/
temp/

# Any build artifacts or packaging files if you add them later
dist/
build/
*.tar.gz
*.zip
EOF
    info ".gitignore generated."
else
    info ".gitignore already exists, skipping generation."
fi

# 2. Create README.md ONLY IF IT DOESN'T EXIST
if [ ! -f "${README_NAME}" ]; then
    info "Generating README.md..."
    cat > "${README_NAME}" << 'EOF'
# Database User Management Suite (dbusermgr)

A command-line tool for managing database users, designed with extensibility for multiple database types. Currently supports PostgreSQL via Docker container interaction.

## Overview

The `dbusermgr` tool provides a unified interface to perform common database user management tasks such as creating users, deleting users, listing users, altering users, and managing privileges. It operates by dispatching commands to database-specific handlers.

This suite is designed to interact with database instances running in Docker containers, identifying target containers by their base name.

## Project Structure

```
your-project-name/  (e.g., guepard-dbusermgr)
├── bin/
│   └── dbusermgr              # Main CLI executable script
├── lib/
│   └── dbusermgr/
│       ├── utils.sh           # Shared utility functions (logging, password prompt)
│       └── handlers/
│           └── postgres_handler.sh # Logic specific to PostgreSQL user management
├── config/
│   └── dbusermgr.conf.example # Example configuration file
├── systemd/
│   └── dbusermgr-task@.service.example # Example systemd template unit for running tasks
├── install.sh                 # Installation script to deploy the tool on a system
├── README.md                  # This file
└── .gitignore                 # Specifies intentionally untracked files for Git
```

## Features

* **Modular Design**: Easily extendable to support other database systems (e.g., MySQL, MongoDB) by adding new handler scripts.
* **Docker Integration**: Targets database instances running in Docker containers.
* **Command-Line Interface**: Clear and consistent CLI for all operations.
* **Password Management**: Secure password prompting and support for environment variable-based password provision.
* **Logging**: Operations are logged for auditing and debugging.
* **Systemd Integration (Optional)**: Includes an example systemd template unit for running `dbusermgr` commands as managed one-shot tasks.

## Prerequisites

* Bash (v4.0 or later recommended)
* Docker CLI installed and accessible by the user running `dbusermgr`.
* The target database client tools installed *within the Docker container* being managed (e.g., `psql` for PostgreSQL containers).

## Installation

1.  Clone your repository (or ensure files are present).
2.  Navigate to your project directory (e.g., `guepard-dbusermgr`).
3.  Make the installation script executable: `chmod +x install.sh`
4.  Run the installation script with root privileges: `sudo ./install.sh`

The script will install:
    * `dbusermgr` to `/usr/local/sbin/`
    * Helper scripts (`utils.sh`, handlers) to `/usr/local/lib/dbusermgr/`
    * Example configuration to `/etc/dbusermgr/dbusermgr.conf.example` (you'll need to copy and customize it to `dbusermgr.conf`).
    * Log directory `/var/log/dbusermgr/`.
    * Example systemd unit to `/etc/systemd/system/`.

## Configuration

After installation, copy the example configuration file:
```bash
sudo cp /etc/dbusermgr/dbusermgr.conf.example /etc/dbusermgr/dbusermgr.conf
```
Edit `/etc/dbusermgr/dbusermgr.conf` to set your desired `LOG_FILE` path and `LOG_LEVEL` (DEBUG, INFO, WARN, ERROR).

## Usage

The main command is `dbusermgr`. Run it with `sudo` if it requires Docker access that your current user doesn't have.

**Global Options:**
* `--db-type <type>`: Required. E.g., `postgres`.
* `--container-name <base_name>`: Required. Base name of the target Docker container. The script will find the full running container name.
* `--db-admin-user <user>`: Required. Admin user for database operations (e.g., `postgres`).
* `--db-admin-pass <pass>`: Optional. Password for the admin user.
* `--ask-admin-password`: Optional. Force prompt for the admin user's password.
* `--db-name <name>`: Optional. Database to connect to for operations (defaults vary by DB type, e.g., `postgres` for PostgreSQL).
* `--help, -h`: Show help.

**Environment Variable for Admin Password:**
You can set `DBMGR_ADMIN_PASS` to provide the admin password instead of using command-line options or interactive prompts.

**Example Commands (PostgreSQL):**

* **List Users:**
    ```bash
    sudo dbusermgr --db-type postgres --container-name my-pg-compute --db-admin-user postgres list-users
    ```

* **Create User (with password prompt for the new user):**
    ```bash
    sudo dbusermgr --db-type postgres --container-name my-pg-compute --db-admin-user postgres create-user --username newuser --ask-password
    ```

* **Create User (providing new user's password directly):**
    ```bash
    sudo dbusermgr --db-type postgres --container-name my-pg-compute --db-admin-user postgres create-user --username newuser --password "Str0ngP@ss!"
    ```

## Extending for Other Databases

1.  Create a new handler script in `lib/dbusermgr/handlers/` (e.g., `mysql_handler.sh`).
2.  Implement the required functions within this handler.
3.  Update the `case` statement in the main `dbusermgr` script (in `bin/`).
4.  Update the `install.sh` script to copy your new handler.

## Contributing

Contributions, issues, and feature requests are welcome.

## License

MIT
EOF
    info "README.md generated."
else
    info "README.md already exists, skipping generation."
fi

# 3. Create config/dbusermgr.conf.example
CONFIG_EXAMPLE_PATH="${CONFIG_SUBDIR}/${CONFIG_FILE_NAME_EXAMPLE}"
info "Generating ${CONFIG_EXAMPLE_PATH}..."
cat > "${CONFIG_EXAMPLE_PATH}" << 'EOF'
# config/dbusermgr.conf.example
# Example configuration for dbusermgr tool.
# When installed, this will be at /etc/dbusermgr/dbusermgr.conf.example
# Copy to /etc/dbusermgr/dbusermgr.conf and customize.

LOG_FILE="/var/log/dbusermgr/dbusermgr.log"
LOG_LEVEL="INFO" # DEBUG, INFO, WARN, ERROR
EOF
info "${CONFIG_EXAMPLE_PATH} generated."

# 4. Create systemd/dbusermgr-task@.service.example
SYSTEMD_EXAMPLE_PATH="${SYSTEMD_SUBDIR}/${SYSTEMD_SERVICE_NAME_EXAMPLE}"
info "Generating ${SYSTEMD_EXAMPLE_PATH}..."
cat > "${SYSTEMD_EXAMPLE_PATH}" << 'EOF'
# systemd/dbusermgr-task@.service.example
# Example systemd template unit for running dbusermgr commands as one-shot tasks.
[Unit]
Description=Database User Management Task (%I)
Documentation=man:dbusermgr(8) 
After=docker.service
Requires=docker.service 

[Service]
Type=oneshot
RemainAfterExit=no
ExecStart=/bin/bash -c "exec /usr/local/sbin/dbusermgr $(echo %I | tr '-' ' ')"
StandardOutput=journal
StandardError=journal
# EnvironmentFile=-/etc/dbusermgr/dbusermgr.conf
# User=dbmgruser 
# Group=dbmgrgroup

[Install]
# WantedBy=multi-user.target 
EOF
info "${SYSTEMD_EXAMPLE_PATH} generated."

# 5. Create lib/dbusermgr/utils.sh
UTILS_FILE_PATH="${LIB_SUBDIR_BASE}/${LIB_SUBDIR_APP}/${UTILS_SCRIPT_NAME}"
info "Generating ${UTILS_FILE_PATH}..."
cat > "${UTILS_FILE_PATH}" << 'EOF'
#!/bin/bash
# lib/dbusermgr/utils.sh
DBMGR_CONFIG_FILE="/etc/dbusermgr/dbusermgr.conf"; DEFAULT_LOG_FILE="/var/log/dbusermgr/dbusermgr.log"; DEFAULT_LOG_LEVEL="INFO"
if [ -z "$DBMGR_CONFIG_LOADED" ]; then if [ -f "$DBMGR_CONFIG_FILE" ]; then source "$DBMGR_CONFIG_FILE"; fi; LOG_FILE="${LOG_FILE:-$DEFAULT_LOG_FILE}"; LOG_LEVEL="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"; DBMGR_CONFIG_LOADED=true; fi
_log() { local l="$1" m="$2" t; t=$(date +"%Y-%m-%d %H:%M:%S"); echo "${t} [${l}] - ${m}" >> "${LOG_FILE}" 2>/dev/null||true; }
log_debug() { [ "$LOG_LEVEL" == "DEBUG" ] && _log "DEBUG" "$1"; }
log_info() { if [[ "$LOG_LEVEL" == "DEBUG" || "$LOG_LEVEL" == "INFO" ]]; then _log "INFO" "$1"; fi; echo "[INFO] $1"; }
log_warn() { if [[ "$LOG_LEVEL" == "DEBUG" || "$LOG_LEVEL" == "INFO" || "$LOG_LEVEL" == "WARN" ]]; then _log "WARN" "$1"; fi; echo "[WARN] $1" >&2; }
log_error() { _log "ERROR" "$1"; echo "[ERROR] $1" >&2; }
get_password() { local -n pvr="$1"; local pm="$2"; read -s -r -p "$pm: " tp; echo >&2; if [ -z "$tp" ]; then log_error "Password empty."; return 1; fi; pvr="$tp"; return 0; }
command_exists() { command -v "$1" >/dev/null 2>&1; }
export LOG_FILE LOG_LEVEL
EOF
chmod +x "${UTILS_FILE_PATH}"
info "${UTILS_FILE_PATH} generated."

# 6. Create lib/dbusermgr/handlers/postgres_handler.sh
POSTGRES_HANDLER_FILE_PATH="${LIB_SUBDIR_BASE}/${LIB_SUBDIR_APP}/${HANDLERS_SUBDIR}/${POSTGRES_HANDLER_NAME}"
info "Generating ${POSTGRES_HANDLER_FILE_PATH}..."
cat > "${POSTGRES_HANDLER_FILE_PATH}" << EOF
#!/bin/bash
# lib/dbusermgr/handlers/postgres_handler.sh
UTILS_SCRIPT_PATH="${ABSOLUTE_UTILS_SCRIPT_PATH_INSTALLED}" 
if [ -f "\$UTILS_SCRIPT_PATH" ]; then source "\$UTILS_SCRIPT_PATH"; else echo "[FATAL] PG Handler: utils.sh missing at \$UTILS_SCRIPT_PATH" >&2; exit 127; fi
pg_exec_psql(){ local s="\$1" c="\$2" au="\$3" ap="\$4" d="\$5" st; log_debug "pg_exec: C='\${c}' AU='\${au}' DBN='\${d}' SQL='\${s}'"; if ! command_exists docker; then log_error "Docker missing."; return 127; fi; local cmd=("docker" "exec" "-i"); if [ -n "\$ap" ]; then cmd+=("-e" "PGPASSWORD=\${ap}"); fi; cmd+=("\$c" "psql" "-U" "\$au" "-d" "\$d" "-v" ON_ERROR_STOP=1 -c "\$s"); log_info "Exec: \${cmd[*]}"; "\${cmd[@]}"; st=\$?; if [ \$st -ne 0 ]; then log_error "psql fail: \$st."; else log_info "psql ok."; fi; return \$st; }
pg_create_user(){ log_info "PG: Create"; local u="" p="" askp=false so=NOSUPERUSER co=NOCREATEDB cro=NOCREATEROLE lo=LOGIN; local c="\$1" au="\$2" apass="\$3" dc="\$4"; shift 4; while [[ \$# -gt 0 ]]; do case "\$1" in --username) u="\$2";shift 2;; --password) p="\$2";shift 2;; --ask-password) askp=true;shift;; --superuser) so=SUPERUSER;shift;; --no-superuser) so=NOSUPERUSER;shift;; --createdb) co=CREATEDB;shift;; --no-createdb) co=NOCREATEDB;shift;; --createrole) cro=CREATEROLE;shift;; --no-createrole) cro=NOCREATEROLE;shift;; --login) lo=LOGIN;shift;; --no-login) lo=NOLOGIN;shift;; *) log_error "pg_create: Unk: \$1"; return 1;; esac; done; if [ -z "\$u" ]; then log_error "--user req."; return 1; fi; if \$askp && [ -n "\$p" ]; then log_warn "Using --pass."; elif \$askp; then if ! get_password p "Pass for PG '\$u' (cont '\$c')"; then return 1; fi; elif [ -z "\$p" ]; then log_error "Pass req."; return 1; fi; local opts=("\$lo" "\$so" "\$co" "\$cro" "PASSWORD '\$p'"); local sql="CREATE USER \"\$u\" WITH \${opts[*]};"; pg_exec_psql "\$sql" "\$c" "\$au" "\$apass" "\$dc"; return \$?; }
pg_list_users(){ log_info "PG: List"; local c="\$1" au="\$2" apass="\$3" dc="\$4"; local sql="SELECT usename AS \"User Name\", CASE WHEN usesuper AND usecreatedb THEN 'Superuser, Create DB' WHEN usesuper THEN 'Superuser' WHEN usecreatedb THEN 'Create DB' ELSE 'Standard User' END AS \"User Type\", CASE WHEN valuntil IS NOT NULL THEN 'Expires: ' || valuntil ELSE 'No Expiry' END AS \"Password Validity\" FROM pg_user ORDER BY usename;"; pg_exec_psql "\$sql" "\$c" "\$au" "\$apass" "\$dc"; return \$?; }
pg_delete_user(){ log_info "PG: Delete"; local c="\$1" au="\$2" apass="\$3" dc="\$4"; shift 4; local u="" ife="" sc=false; while [[ \$# -gt 0 ]]; do case "\$1" in --username) u="\$2";shift 2;; --if-exists) ife="IF EXISTS";shift;; --yes) sc=true;shift;; *) log_error "pg_delete: Unk: \$1"; return 1;; esac; done; if [ -z "\$u" ]; then log_error "--user req."; return 1; fi; if ! \$sc && [ -t 0 ]; then read -r -p "Delete '\$u' in '\$c'? (yes/N): " conf; if [[ "\$conf" != "yes" ]]; then log_info "Cancelled."; return 0; fi; fi; local sql="DROP USER \$ife \"\$u\";"; pg_exec_psql "\$sql" "\$c" "\$au" "\$apass" "\$dc"; return \$?; }
pg_alter_user(){ log_info "PG: Alter"; local u="" np="" asknp=false rn="" ao=(); local c="\$1" au="\$2" apass="\$3" dc="\$4"; shift 4; while [[ \$# -gt 0 ]]; do case "\$1" in --username) u="\$2";shift 2;; --new-password) np="\$2";shift 2;; --ask-new-password) asknp=true;shift;; --rename-to) rn="\$2";shift 2;; --superuser) ao+=("SUPERUSER");shift;; --no-superuser) ao+=("NOSUPERUSER");shift;; --createdb) ao+=("CREATEDB");shift;; --no-createdb) ao+=("NOCREATEDB");shift;; --createrole) ao+=("CREATEROLE");shift;; --no-createrole) ao+=("NOCREATEROLE");shift;; --login) ao+=("LOGIN");shift;; --no-login) ao+=("NOLOGIN");shift;; *) log_error "pg_alter: Unk: \$1"; return 1;; esac; done; if [ -z "\$u" ]; then log_error "--user req."; return 1; fi; if \$asknp && [ -n "\$np" ]; then log_warn "Using --new-pass."; elif \$asknp; then if ! get_password np "New pass for PG '\$u' (cont '\$c')"; then return 1; fi; fi; if [ -n "\$np" ]; then ao+=("PASSWORD '\$np'"); fi; local os=0; if [ \${#ao[@]} -gt 0 ]; then local aos="\$(IFS=' '; echo "\${ao[*]}")"; local sql="ALTER USER \"\$u\" WITH \$aos;"; pg_exec_psql "\$sql" "\$c" "\$au" "\$apass" "\$dc"; if [ \$? -ne 0 ]; then os=1; fi; fi; if [ -n "\$rn" ]; then local sql="ALTER USER \"\$u\" RENAME TO \"\$rn\";"; pg_exec_psql "\$sql" "\$c" "\$au" "\$apass" "\$dc"; if [ \$? -ne 0 ]; then os=1; else u="\$rn"; fi; fi; if [ \${#ao[@]} -eq 0 ] && [ -z "\$rn" ]; then log_error "No alteration for '\$u'."; return 1; fi; if [ \$os -eq 0 ]; then log_info "User '\$u' altered."; else log_error "Fail alter '\$u'."; fi; return \$os; }
pg_grant_privs(){ log_info "PG: Grant"; local u="" odb="" privs="" ot="" oaa="" os="" oaas="" wgo=""; local c="\$1" au="\$2" apass="\$3" dca="\$4"; shift 4; while [[ \$# -gt 0 ]]; do case "\$1" in --username) u="\$2";shift 2;; --on-db) odb="\$2";shift 2;; --privileges) privs="\$2";shift 2;; --on-table) ot="\$2";shift 2;; --on-all-tables-in-schema) oaa="\$2";shift 2;; --on-schema) os="\$2";shift 2;; --on-all-sequences-in-schema) oaas="\$2";shift 2;; --with-grant-option) wgo="WITH GRANT OPTION";shift;; *) log_error "pg_grant: Unk: \$1";return 1;;esac;done; if [ -z "\$u" ]||[ -z "\$odb" ]||[ -z "\$privs" ]; then log_error "--user, --on-db, --privs req.";return 1;fi; local to=""; local tdb="\$odb"; if [ -n "\$ot" ];then to="TABLE \\"\$ot\\"";elif [ -n "\$oaa" ];then to="ALL TABLES IN SCHEMA \\"\$oaa\\"";elif [ -n "\$os" ];then to="SCHEMA \\"\$os\\"";elif [ -n "\$oaas" ];then to="ALL SEQUENCES IN SCHEMA \\"\$oaas\\"";else to="DATABASE \\"\$odb\\""; local vp="CREATE,CONNECT,TEMPORARY,TEMP"; if [[ "\${privs^^}" != "ALL PRIVILEGES" ]]; then local fp=""; IFS=',' read -ra pa <<< "\$privs"; for p in "\${pa[@]}"; do if [[ "\$vp" == *"\${p^^}"* ]]; then fp="\${fp}\${p},"; else log_warn "Priv '\$p' ? DB level.";fp="\${fp}\${p},"; fi; done; privs=\${fp%,}; if [ -z "\$privs" ]; then log_error "No valid DB privs."; return 1; fi; fi; fi; local sql="GRANT \${privs} ON \${to} TO \\"\$u\\" \${wgo};"; pg_exec_psql "\$sql" "\$c" "\$au" "\$apass" "\$tdb"; return \$?; }
pg_revoke_privs(){ log_info "PG: Revoke"; local u="" odb="" privs="" ot="" oaa="" os="" oaas="" casc=""; local c="\$1" au="\$2" apass="\$3" dca="\$4"; shift 4; while [[ \$# -gt 0 ]]; do case "\$1" in --username) u="\$2";shift 2;; --on-db) odb="\$2";shift 2;; --privileges) privs="\$2";shift 2;; --on-table) ot="\$2";shift 2;; --on-all-tables-in-schema) oaa="\$2";shift 2;; --on-schema) os="\$2";shift 2;; --on-all-sequences-in-schema) oaas="\$2";shift 2;; --cascade) casc="CASCADE";shift;; *) log_error "pg_revoke: Unk: \$1";return 1;;esac;done; if [ -z "\$u" ]||[ -z "\$odb" ]||[ -z "\$privs" ]; then log_error "--user, --on-db, --privs req.";return 1;fi; local to=""; local tdb="\$odb"; if [ -n "\$ot" ];then to="TABLE \\"\$ot\\"";elif [ -n "\$oaa" ];then to="ALL TABLES IN SCHEMA \\"\$oaa\\"";elif [ -n "\$os" ];then to="SCHEMA \\"\$os\\"";elif [ -n "\$oaas" ];then to="ALL SEQUENCES IN SCHEMA \\"\$oaas\\"";else to="DATABASE \\"\$odb\\"";fi; local sql="REVOKE \${privs} ON \${to} FROM \\"\$u\\" \${casc};"; pg_exec_psql "\$sql" "\$c" "\$au" "\$apass" "\$tdb"; return \$?; }
handle_postgres_command(){ local c="\$1" au="\$2" apass="\$3" dc="\$4" cmd="\$5"; shift 5; log_debug "PG Hdlr: C='\${c}', AU='\${au}', DBN='\${dc}', Cmd='\${cmd}'"; case "\$cmd" in create-user)pg_create_user "\$c" "\$au" "\$apass" "\$dc" "\$@";;list-users)pg_list_users "\$c" "\$au" "\$apass" "\$dc" "\$@";;delete-user)pg_delete_user "\$c" "\$au" "\$apass" "\$dc" "\$@";;alter-user)pg_alter_user "\$c" "\$au" "\$apass" "\$dc" "\$@";;grant-privs)pg_grant_privs "\$c" "\$au" "\$apass" "\$dc" "\$@";;revoke-privs)pg_revoke_privs "\$c" "\$au" "\$apass" "\$dc" "\$@";;*)log_error "PG Hdlr: Unk cmd '\$cmd'";return 127;;esac;return \$?; }
EOF
chmod +x "${POSTGRES_HANDLER_FILE_PATH}"
info "${POSTGRES_HANDLER_FILE_PATH} generated."

# 7. Create bin/dbusermgr
MAIN_CLI_FILE_PATH="${BIN_SUBDIR}/${MAIN_CLI_TOOL_NAME}"
info "Generating ${MAIN_CLI_FILE_PATH}..."
cat > "${MAIN_CLI_FILE_PATH}" << EOF
#!/bin/bash
# bin/dbusermgr - Database User Management CLI Tool

UTILS_SCRIPT_PATH="${ABSOLUTE_UTILS_SCRIPT_PATH_INSTALLED}"
HANDLERS_BASE_DIR="${ABSOLUTE_HANDLERS_DIR_INSTALLED}" 

if [ ! -f "\$UTILS_SCRIPT_PATH" ] && [ -f "\$(dirname "\$0")/../lib/dbusermgr/${UTILS_SCRIPT_NAME:-utils.sh}" ]; then
    UTILS_SCRIPT_PATH="\$(dirname "\$0")/../lib/dbusermgr/${UTILS_SCRIPT_NAME:-utils.sh}"
    HANDLERS_BASE_DIR="\$(dirname "\$0")/../lib/dbusermgr/handlers"
    echo "[DEV MODE] Using local utils.sh: \$UTILS_SCRIPT_PATH" >&2
fi
if [ -f "\$UTILS_SCRIPT_PATH" ]; then source "\$UTILS_SCRIPT_PATH"; else echo "[FATAL] dbusermgr: utils.sh missing. Tried: ${ABSOLUTE_UTILS_SCRIPT_PATH_INSTALLED} and local dev path." >&2; exit 127; fi

DB_TYPE="" DB_VERSION="" DB_CONTAINER_BASE_NAME="" DB_ADMIN_USER="" DB_ADMIN_PASS="" DB_NAME_CONN="" 
ASK_ADMIN_PASSWORD=false; COMMAND_ARGS=() 
usage(){ echo "Usage: \$0 [global_opts] <command> [cmd_opts]";echo "Global: --db-type <t> --container-name <base> --db-admin-user <u> [--db-admin-pass <p>] [--ask-admin-password] [--db-name <db>] [-h]";echo "Cmds (PG ex): create-user, delete-user, list-users, alter-user, grant-privs, revoke-privs"; }
if [ \$# -eq 0 ]; then usage; exit 0; fi
while [[ \$# -gt 0 ]]; do case "\$1" in --db-type) DB_TYPE="\$2";shift 2;;--container-name) DB_CONTAINER_BASE_NAME="\$2";shift 2;;--db-admin-user) DB_ADMIN_USER="\$2";shift 2;;--db-admin-pass) DB_ADMIN_PASS="\$2";shift 2;;--ask-admin-password) ASK_ADMIN_PASSWORD=true;shift;;--db-name) DB_NAME_CONN="\$2";shift 2;;-h|--help) usage;exit 0;;--) shift;COMMAND_ARGS=("\$@");break;;-*) log_error "Unk global: \$1";usage;exit 1;;*) COMMAND_ARGS=("\$@");break;;esac;done
DB_MANAGEMENT_COMMAND="\${COMMAND_ARGS[0]}"; if [ \${#COMMAND_ARGS[@]} -gt 0 ]; then COMMAND_SPECIFIC_ARGS=("\${COMMAND_ARGS[@]:1}"); else COMMAND_SPECIFIC_ARGS=(); fi
if [ -z "\$DB_TYPE" ]||[ -z "\$DB_CONTAINER_BASE_NAME" ]||[ -z "\$DB_ADMIN_USER" ]||[ -z "\$DB_MANAGEMENT_COMMAND" ]; then log_error "Required global options or command missing.";usage;exit 1;fi
if ! command_exists docker; then log_error "Docker missing.";exit 127;fi
log_info "Looking for container starting with: \${DB_CONTAINER_BASE_NAME}"; FOUND_CONTAINERS=\$(docker ps --filter "name=^/\${DB_CONTAINER_BASE_NAME}" --format "{{.Names}}" --no-trunc); NUM_FOUND=\$(echo "\$FOUND_CONTAINERS"|wc -l|xargs); FULL_CONTAINER_NAME=""
if [ -z "\$FOUND_CONTAINERS" ]; then log_error "No container found starting with '\$DB_CONTAINER_BASE_NAME'."; exit 1; elif [ "\$NUM_FOUND" -gt 1 ]; then log_error "Multiple containers found:\n\$FOUND_CONTAINERS"; exit 1; else FULL_CONTAINER_NAME="\$FOUND_CONTAINERS"; log_info "Found: \$FULL_CONTAINER_NAME"; fi
case "\$DB_TYPE" in postgres) DB_NAME_CONN="\${DB_NAME_CONN:-postgres}"; HANDLER_FUNCTION="handle_postgres_command";; *) log_error "DBType '\$DB_TYPE' unsupp."; exit 1;; esac
if \$ASK_ADMIN_PASSWORD && [ -n "\$DB_ADMIN_PASS" ]; then log_warn "Using --db-admin-pass."; elif \$ASK_ADMIN_PASSWORD; then if ! get_password DB_ADMIN_PASS "Pass for DB user '\$DB_ADMIN_USER' (cont '\$FULL_CONTAINER_NAME')"; then exit 1; fi; elif [ -z "\$DB_ADMIN_PASS" ]; then if [ -n "\$DBMGR_ADMIN_PASS" ]; then DB_ADMIN_PASS="\$DBMGR_ADMIN_PASS";log_debug "Using DBMGR_ADMIN_PASS."; elif [ "\$DB_ADMIN_USER" != "postgres" ] && [ -t 0 ]; then log_info "Pass not provided for non-default '\$DB_ADMIN_USER'."; if ! get_password DB_ADMIN_PASS "Pass for DB user '\$DB_ADMIN_USER' (cont '\$FULL_CONTAINER_NAME')"; then exit 1; fi; fi; fi
HANDLER_SCRIPT="\${HANDLERS_BASE_DIR}/\${DB_TYPE}_handler.sh"; log_debug "Loading handler: \$HANDLER_SCRIPT"; if [ ! -f "\$HANDLER_SCRIPT" ]; then log_error "Handler missing: \$HANDLER_SCRIPT"; exit 1; fi
source "\$HANDLER_SCRIPT"; if ! command_exists "\$HANDLER_FUNCTION"; then log_error "Handler func '\$HANDLER_FUNCTION' missing in '\$HANDLER_SCRIPT'."; exit 1; fi
log_info "Dispatching '\$DB_MANAGEMENT_COMMAND' to '\$DB_TYPE' for '\$FULL_CONTAINER_NAME'..."; "\$HANDLER_FUNCTION" "\$FULL_CONTAINER_NAME" "\$DB_ADMIN_USER" "\$DB_ADMIN_PASS" "\$DB_NAME_CONN" "\$DB_MANAGEMENT_COMMAND" "\${COMMAND_SPECIFIC_ARGS[@]}"; exit \$?
EOF
chmod +x "${MAIN_CLI_FILE_PATH}"
info "${MAIN_CLI_FILE_PATH} generated."

# 8. Create install.sh
INSTALL_SCRIPT_PATH="./${INSTALL_SCRIPT_NAME}"
info "Generating ${INSTALL_SCRIPT_PATH}..."
cat > "${INSTALL_SCRIPT_PATH}" << 'EOF'
#!/bin/bash
# install.sh
set -e; SOURCE_DIR="."; PREFIX="/usr/local"; SBIN_DIR="${PREFIX}/sbin"; LIB_BASE="${PREFIX}/lib"; LIB_APP="${LIB_BASE}/dbusermgr"; HDLRS_DIR="${LIB_APP}/handlers"; ETC_BASE="/etc"; ETC_APP="${ETC_BASE}/dbusermgr"; LOG_BASE="/var/log"; LOG_APP="${LOG_BASE}/dbusermgr"; SYSD_DIR="/etc/systemd/system"; CLI="dbusermgr"; UTILS="utils.sh"; PG_HDL="postgres_handler.sh"; CONF_EX="dbusermgr.conf.example"; CONF_TGT="dbusermgr.conf"; LOG_FNAME="dbusermgr.log"; SYSD_EX="dbusermgr-task@.service.example"; SYSD_TGT="dbusermgr-task@.service"
info(){ echo "[INFO] $1";}; error_exit(){ echo "[ERROR] $1" >&2; exit 1;}; info "Installing from ${SOURCE_DIR}"; if [ "$(id -u)" -ne 0 ]; then error_exit "Run as root."; fi
info "Checking sources..."; S_CLI="${SOURCE_DIR}/bin/${CLI}"; S_UTILS="${SOURCE_DIR}/lib/dbusermgr/${UTILS}"; S_PG_HDL="${SOURCE_DIR}/lib/dbusermgr/handlers/${PG_HDL}"; S_CONF_EX="${SOURCE_DIR}/config/${CONF_EX}"; S_SYSD_EX="${SOURCE_DIR}/systemd/${SYSD_EX}"
if [ ! -f "${S_CLI}" ]||[ ! -f "${S_UTILS}" ]||[ ! -f "${S_PG_HDL}" ]||[ ! -f "${S_CONF_EX}" ]||[ ! -f "${S_SYSD_EX}" ]; then error_exit "A source file is missing."; fi; info "Sources OK."
info "Creating dirs..."; mkdir -p "${SBIN_DIR}" "${HDLRS_DIR}" "${ETC_APP}" "${LOG_APP}"; chown root:root "${LOG_APP}"; chmod 0755 "${LOG_APP}"; info "Dirs OK."
info "Installing scripts..."; mkdir -p "${LIB_APP}"; cp "${S_CLI}" "${SBIN_DIR}/${CLI}"; cp "${S_UTILS}" "${LIB_APP}/${UTILS}"; cp "${S_PG_HDL}" "${HDLRS_DIR}/${PG_HDL}"
chmod 0755 "${SBIN_DIR}/${CLI}" "${LIB_APP}/${UTILS}" "${HDLRS_DIR}/${PG_HDL}"; info "Scripts OK."
TGT_CONF_EX="${ETC_APP}/${CONF_EX}"; TGT_CONF_ACTUAL="${ETC_APP}/${CONF_TGT}"; info "Installing example config to: ${TGT_CONF_EX}"; cp "${S_CONF_EX}" "${TGT_CONF_EX}"; chmod 0644 "${TGT_CONF_EX}"
if [ ! -f "${TGT_CONF_ACTUAL}" ]; then info "Actual config ${TGT_CONF_ACTUAL} missing. Consider: sudo cp ${TGT_CONF_EX} ${TGT_CONF_ACTUAL}"; else info "Actual config ${TGT_CONF_ACTUAL} exists."; fi
TGT_SYSD_EX="${SYSD_DIR}/${SYSD_EX}"; TGT_SYSD_ACTUAL="${SYSD_DIR}/${SYSD_TGT}"; info "Installing example systemd unit to: ${TGT_SYSD_EX}"; cp "${S_SYSD_EX}" "${TGT_SYSD_EX}"; chmod 0644 "${TGT_SYSD_EX}"
if [ ! -f "${TGT_SYSD_ACTUAL}" ]; then info "Actual systemd unit ${TGT_SYSD_ACTUAL} missing. Consider: sudo cp ${TGT_SYSD_EX} ${TGT_SYSD_ACTUAL}"; else info "Actual systemd unit ${TGT_SYSD_ACTUAL} exists."; fi
info "Reloading systemd..."; systemctl daemon-reload; info "Systemd reloaded."
echo ""; info "--- Install Complete! ---"; info "CLI: ${SBIN_DIR}/${CLI}"; info "Ex Config: ${TGT_CONF_EX}"; info "Ex Systemd: ${TGT_SYSD_EX}"; info "Log Dir: ${LOG_APP}/"; exit 0
EOF
chmod +x "${INSTALL_SCRIPT_PATH}"
info "${INSTALL_SCRIPT_PATH} generated."

# --- Final Instructions ---
# No longer cd .. because we are already in the project root
info "-------------------------------------------------"
info "Project files and subdirectories generated in the current directory: $(pwd)"
info "To install, ensure you are in this directory and run 'sudo ./install.sh'"
info "-------------------------------------------------"

exit 0
