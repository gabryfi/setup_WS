#!/usr/bin/env bash
set -Eeuo pipefail

LOG_DIR="$HOME/setup_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/01_setup_r_system_$(date +%F_%H-%M-%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "==> Controllo sistema"
if ! command -v lsb_release >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y lsb-release
fi

CODENAME="$(lsb_release -cs)"
if [[ "$CODENAME" != "noble" ]]; then
  echo "ERRORE: questo script è pensato per Ubuntu 24.04 (noble). Rilevato: $CODENAME"
  exit 1
fi

echo "==> Pacchetti base"
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  software-properties-common \
  dirmngr \
  ca-certificates \
  wget \
  curl \
  gnupg \
  lsb-release

echo "==> Chiave CRAN"
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | \
  sudo tee /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc >/dev/null

echo "==> Repository CRAN ufficiale"
if ! grep -Rqs "cloud.r-project.org/bin/linux/ubuntu" /etc/apt/sources.list /etc/apt/sources.list.d/; then
  sudo add-apt-repository -y "deb https://cloud.r-project.org/bin/linux/ubuntu ${CODENAME}-cran40/"
fi

echo "==> Update apt"
sudo apt-get update

echo "==> Installo R e dipendenze di sistema"
sudo apt-get install -y --no-install-recommends \
  r-base \
  r-base-dev \
  build-essential \
  gcc \
  g++ \
  gfortran \
  make \
  cmake \
  pkg-config \
  git \
  libcurl4-openssl-dev \
  libssl-dev \
  libxml2-dev \
  zlib1g-dev \
  libbz2-dev \
  liblzma-dev \
  libpcre2-dev \
  libreadline-dev \
  libopenblas-dev \
  liblapack-dev \
  libpng-dev \
  libjpeg-dev \
  libtiff5-dev \
  libcairo2-dev \
  libfontconfig1-dev \
  libfreetype6-dev \
  libharfbuzz-dev \
  libfribidi-dev \
  libgit2-dev \
  libglpk-dev \
  libgmp3-dev \
  libmpfr-dev \
  libudunits2-dev \
  libhdf5-dev \
  libfftw3-dev \
  libmagick++-dev

echo "==> Configuro libreria utente R"
R_MAJOR_MINOR="$(R -q -e 'cat(paste(R.version$major, strsplit(R.version$minor, "\\.")[[1]][1], sep="."))' | tail -n 1)"
USER_R_LIB="$HOME/R/x86_64-pc-linux-gnu-library/${R_MAJOR_MINOR}"

mkdir -p "$USER_R_LIB"

cat > "$HOME/.Renviron" <<EOF
R_LIBS_USER=$USER_R_LIB
EOF

echo "==> Verifica"
R -q -e '.libPaths(); cat("R_LIBS_USER=", Sys.getenv("R_LIBS_USER"), "\n", sep="")'

echo
echo "Setup sistema completato."
echo "Log: $LOG_FILE"
