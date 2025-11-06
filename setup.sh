#!/bin/bash
# Official installation script.

mcsmanager_install_path="/opt/mcsmanager"
mcsmanager_download_addr="https://github.com/thororen1234/MCSManager/releases/latest/download/mcsmanager_linux_release.tar.gz"
package_name="mcsmanager_linux_release.tar.gz"
arch=$(uname -m)

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Please use \"sudo bash\" instead."
  exit 1
fi

printf "\033c"

echo_cyan() {
  printf '\033[1;36m%b\033[0m\n' "$@"
}
echo_red() {
  printf '\033[1;31m%b\033[0m\n' "$@"
}
echo_green() {
  printf '\033[1;32m%b\033[0m\n' "$@"
}
echo_cyan_n() {
  printf '\033[1;36m%b\033[0m' "$@"
}
echo_yellow() {
  printf '\033[1;33m%b\033[0m\n' "$@"
}

# script info
echo_cyan "+----------------------------------------------------------------------
| MCSManager Installer
+----------------------------------------------------------------------
"

Red_Error() {
  echo '================================================='
  printf '\033[1;31;40m%b\033[0m\n' "$@"
  echo '================================================='
  exit 1
}

Install_MCSManager() {
  echo_cyan "[+] Install MCSManager..."

  # stop service
  systemctl disable --now mcsm-{web,daemon}

  # delete service
  rm -rf /etc/systemd/system/mcsm-{daemon,web}.service
  systemctl daemon-reload

  mkdir -p "${mcsmanager_install_path}" || Red_Error "[x] Failed to create ${mcsmanager_install_path}"

  # cd /opt/mcsmanager
  cd "${mcsmanager_install_path}" || Red_Error "[x] Failed to enter ${mcsmanager_install_path}"

  # download MCSManager release
  wget "${mcsmanager_download_addr}" -O "${package_name}" || Red_Error "[x] Failed to download MCSManager"
  tar -zxf ${package_name} -o || Red_Error "[x] Failed to untar ${package_name}"
  rm -rf "${mcsmanager_install_path}/${package_name}"

  # compatible with tar.gz packages of different formats
  if [ -d "/opt/mcsmanager/mcsmanager" ]; then
    cp -rf /opt/mcsmanager/mcsmanager/* /opt/mcsmanager/
    rm -rf /opt/mcsmanager/mcsmanager
  fi

  # echo "[→] cd daemon"
  cd "${mcsmanager_install_path}/daemon" || Red_Error "[x] Failed to enter ${mcsmanager_install_path}/daemon"

  echo_cyan "[+] Install MCSManager-Daemon dependencies..."
  env "npm install --production --no-fund --no-audit &>/dev/null || Red_Error "[x] Failed to npm install in ${mcsmanager_install_path}/daemon"

  # echo "[←] cd .."
  cd "${mcsmanager_install_path}/web" || Red_Error "[x] Failed to enter ${mcsmanager_install_path}/web"

  echo_cyan "[+] Install MCSManager-Web dependencies..."
  env "npm install --production --no-fund --no-audit &>/dev/null || Red_Error "[x] Failed to npm install in ${mcsmanager_install_path}/web"

  echo
  echo_yellow "=============== MCSManager ==============="
  echo_green "Daemon: ${mcsmanager_install_path}/daemon"
  echo_green "Web: ${mcsmanager_install_path}/web"
  echo_yellow "=============== MCSManager ==============="
  echo
  echo_green "[+] MCSManager installation success!"

  chmod -R 755 "$mcsmanager_install_path"

  sleep 3
}

# Install MCSManager
Install_MCSManager