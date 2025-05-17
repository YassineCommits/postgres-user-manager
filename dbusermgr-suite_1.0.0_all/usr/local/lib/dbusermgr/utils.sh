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
