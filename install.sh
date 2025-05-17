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
