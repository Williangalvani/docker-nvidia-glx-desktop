# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Ubuntu release versions 22.04, and 20.04 are supported
ARG UBUNTU_RELEASE=22.04
FROM ubuntu:${UBUNTU_RELEASE}

LABEL maintainer "https://github.com/ehfd,https://github.com/danisla"

ARG UBUNTU_RELEASE
# Use noninteractive mode to skip confirmation when installing packages
ARG DEBIAN_FRONTEND=noninteractive
# System defaults that should not be changed
ENV DISPLAY :0
ENV XDG_RUNTIME_DIR /tmp/runtime-user
ENV PULSE_SERVER unix:/run/pulse/native

# Expose NVIDIA libraries and paths
ENV PATH /usr/local/nvidia/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}}:/usr/local/nvidia/lib:/usr/local/nvidia/lib64
# Make all NVIDIA GPUs visible by default
ENV NVIDIA_VISIBLE_DEVICES all
# All NVIDIA driver capabilities should preferably be used, check `NVIDIA_DRIVER_CAPABILITIES` inside the container if things do not work
ENV NVIDIA_DRIVER_CAPABILITIES all
# Disable VSYNC for NVIDIA GPUs
ENV __GL_SYNC_TO_VBLANK 0

# Default environment variables (password is "mypasswd")
ENV TZ UTC
ENV SIZEW 1920
ENV SIZEH 1080
ENV REFRESH 60
ENV DPI 96
ENV CDEPTH 24
ENV VIDEO_PORT DFP
ENV PASSWD mypasswd
ENV NOVNC_ENABLE false
ENV WEBRTC_ENCODER nvh264enc
ENV WEBRTC_ENABLE_RESIZE false
ENV ENABLE_BASIC_AUTH true


# Install KDE and other GUI packages
ENV XDG_CURRENT_DESKTOP LXDE
ENV XDG_SESSION_DESKTOP LXDE
ENV XDG_SESSION_TYPE x11
ENV DESKTOP_SESSION plasma
ENV KDE_FULL_SESSION true
ENV KWIN_COMPOSE N
ENV KWIN_X11_NO_SYNC_TO_VBLANK 1
# Use sudoedit to change protected files instead of using sudo on kate
ENV SUDO_EDITOR kate
# Set input to fcitx
ENV GTK_IM_MODULE fcitx
ENV QT_IM_MODULE fcitx
ENV XIM fcitx
ENV XMODIFIERS "@im=fcitx"
# Enable AppImage execution in containers
ENV APPIMAGE_EXTRACT_AND_RUN 1


# Install fundamental packages
RUN apt-get clean && apt-get update && apt-get install --no-install-recommends -y \
        apt-transport-https \
        apt-utils \
        ca-certificates \
        curl \
#        locales \
        wget && \
    rm -rf /var/lib/apt/lists/*
#    locale-gen en_US.UTF-8
# Set locales
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY forced_cleanup.sh /forced_cleanup.sh
# Install operating system libraries or packages
RUN apt-get update && apt-get install -y --no-install-recommends gcc make && apt-get install --no-install-recommends -y \
        alsa-base \
        #alsa-utils \
        file \
        xz-utils \
        # unar \
        unzip \
        zstd \
        jq \
        python3 \
        ssl-cert \
        nano \
        #vim \
        htop \
        fakeroot \
        less \
        #libavcodec-extra \
        libpulse0 \
        pulseaudio \
        supervisor \
        net-tools \
        packagekit-tools \
        pkg-config \
        #mesa-utils \
        #va-driver-all \
 #       i965-va-driver-shaders \
 #       intel-media-va-driver-non-free \
        #libva2 \
        #vainfo \
        #vdpau-driver-all \
        #vdpauinfo \
        #mesa-vulkan-drivers \ #coul be required for non nvidia gpus
        libvulkan-dev \
        vulkan-tools \
        ocl-icd-libopencl1 \
        clinfo \
        dbus-user-session \
        dbus-x11 \
        libdbus-c++-1-0v5 \
        xkb-data \
        xauth \
        xbitmaps \
        xdg-user-dirs \
        xdg-utils \
        xfonts-base \
#        xfonts-scalable \
        xinit \
        xsettingsd \
        libxrandr-dev \
        x11-xkb-utils \
        x11-xserver-utils \
        x11-utils \
        xserver-xorg-input-all \
        xserver-xorg-video-all \
#        xserver-xorg-video-intel \
        xserver-xorg-video-qxl \
        # Install OpenGL libraries
        libxau6 \
        libxdmcp6 \
        libxcb1 \
        libxext6 \
        libx11-6 \
        libxv1 \
        libxtst6 \
        libglvnd0 \
        libgl1 \
        libglx0 \
        libegl1 \
        libgles2 \
        libglu1 \
        libsm6 \
        # Install Xorg and NVIDIA driver installer dependencies \
        kmod \
        libc6-dev \
        libpci3 \
        libelf-dev \
        pkg-config \
        xorg \
        lxde \
        # GStreamer dependencies
        python3-pip \
        python3-dev \
        python3-gi \
        python3-setuptools \
        python3-wheel \
        wmctrl \
        gdebi-core \
        libglvnd-dev \
        xclip \
        x11-utils \
        xdotool \
        x11-xserver-utils \
        xserver-xorg-core \
        libx11-xcb1 \
        libxkbcommon0 \
        libxdamage1 \
        libsoup2.4-1 \
        libsoup-gnome2.4-1 \
        libsrtp2-1 \
        libwebrtc-audio-processing1 \
        pulseaudio \
        libpulse0 \
        libgirepository-1.0-1 \
        libopenjp2-7 \
        xcvt \
        sudo \
        libgstreamer-plugins-bad1.0-0 \
        gstreamer1.0-rtsp \
        gstreamer1.0 \
        tzdata && \
    rm -rf /var/lib/apt/lists/* && \
    echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf && \
    # Configure OpenCL manually
    mkdir -pm755 /etc/OpenCL/vendors && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd && \
    # Configure Vulkan manually
    VULKAN_API_VERSION=$(dpkg -s libvulkan1 | grep -oP 'Version: [0-9|\.]+' | grep -oP '[0-9]+(\.[0-9]+)(\.[0-9]+)') && \
    mkdir -pm755 /etc/vulkan/icd.d/ && echo "{\n\
    \"file_format_version\" : \"1.0.0\",\n\
    \"ICD\": {\n\
        \"library_path\": \"libGLX_nvidia.so.0\",\n\
        \"api_version\" : \"${VULKAN_API_VERSION}\"\n\
    }\n\
}" > /etc/vulkan/icd.d/nvidia_icd.json && \
    # Configure EGL manually
    mkdir -pm755 /usr/share/glvnd/egl_vendor.d/ && echo "{\n\
    \"file_format_version\" : \"1.0.0\",\n\
    \"ICD\": {\n\
        \"library_path\": \"libEGL_nvidia.so.0\"\n\
    }\n\
}" > /usr/share/glvnd/egl_vendor.d/10_nvidia.json && \
    # Automatically fetch the latest selkies-gstreamer version and install the components
    SELKIES_VERSION="$(curl -fsSL "https://api.github.com/repos/selkies-project/selkies-gstreamer/releases/latest" | jq -r '.tag_name' | sed 's/[^0-9\.\-]*//g')" && \
    cd /opt && curl -fsSL "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/selkies-gstreamer-v${SELKIES_VERSION}-ubuntu$(grep VERSION_ID= /etc/os-release | cut -d= -f2 | tr -d '\"').tgz" | tar -zxf - && \
    # Extract NVRTC dependency, https://developer.download.nvidia.com/compute/cuda/redist/cuda_nvrtc/LICENSE.txt
    cd /tmp && curl -fsSL -o nvidia_cuda_nvrtc_linux_x86_64.whl "https://developer.download.nvidia.com/compute/redist/nvidia-cuda-nvrtc/nvidia_cuda_nvrtc-11.0.221-cp36-cp36m-linux_x86_64.whl" && unzip -joq -d ./nvrtc nvidia_cuda_nvrtc_linux_x86_64.whl && cd nvrtc && chmod 755 libnvrtc* && find . -maxdepth 1 -type f -name "*libnvrtc.so.*" -exec sh -c 'ln -snf $(basename {}) libnvrtc.so' \; && mv -f libnvrtc* /opt/gstreamer/lib/x86_64-linux-gnu/ && cd /tmp && rm -rf /tmp/* && \
    cd /tmp && curl -fsSL -O "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/selkies_gstreamer-${SELKIES_VERSION}-py3-none-any.whl" && pip3 install "selkies_gstreamer-${SELKIES_VERSION}-py3-none-any.whl" && rm -f "selkies_gstreamer-${SELKIES_VERSION}-py3-none-any.whl" && \
    cd /opt && curl -fsSL "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/selkies-gstreamer-web-v${SELKIES_VERSION}.tgz" | tar -zxf - && \
    cd /tmp && curl -fsSL -o selkies-js-interposer.deb "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/selkies-js-interposer-v${SELKIES_VERSION}-ubuntu$(grep VERSION_ID= /etc/os-release | cut -d= -f2 | tr -d '\"').deb" && apt-get update && apt-get install --no-install-recommends -y ./selkies-js-interposer.deb && rm -f ./selkies-js-interposer.deb && \ 
    apt autoremove -y \
    gstreamer1.0-adapter-pulseeffects \
    gstreamer1.0-autogain-pulseeffects \
    gstreamer1.0-convolver-pulseeffects \
    gstreamer1.0-crystalizer-pulseeffects \
    gstreamer1.0-espeak \
    gstreamer1.0-fdkaac \
    gstreamer1.0-gtk3 \
    gstreamer1.0-omx-bellagio-config \
    gstreamer1.0-omx-generic-config \
    gstreamer1.0-omx-generic \
    gstreamer1.0-opencv \
    gstreamer1.0-pocketsphinx \
    gstreamer1.0-qt5 gstreamer1.0-wpe \
    gcc \
    make \
    && apt autoremove -y && rm -rf /var/lib/apt/lists/* && rm -rf /var/lib/apt/lists/* /tmp/* && /forced_cleanup.sh
# Add configuration for Selkies-GStreamer Joystick interposer
ENV LD_PRELOAD /usr/local/lib/selkies-js-interposer/joystick_interposer.so${LD_PRELOAD:+:${LD_PRELOAD}}
ENV SDL_JOYSTICK_DEVICE /dev/input/js0



# Create user with password ${PASSWD} and assign adequate groups
RUN groupadd -g 1000 user && \
    useradd -ms /bin/bash user -u 1000 -g 1000 && \
    usermod -a -G adm,audio,cdrom,dialout,dip,fax,floppy,input,lp,plugdev,pulse-access,ssl-cert,sudo,tape,tty,video,voice user && \
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    chown user:user /home/user && \
    echo "user:${PASSWD}" | chpasswd && \
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone

# Copy scripts and configurations used to start the container
COPY entrypoint.sh /etc/entrypoint.sh
RUN chmod 755 /etc/entrypoint.sh
COPY selkies-gstreamer-entrypoint.sh /etc/selkies-gstreamer-entrypoint.sh
RUN chmod 755 /etc/selkies-gstreamer-entrypoint.sh
COPY supervisord.conf /etc/supervisord.conf
RUN chmod 755 /etc/supervisord.conf

COPY bluesim-x86 /home/user/bluesim-x86
RUN chmod +x /home/user/bluesim-x86

EXPOSE 8080

USER 1000
ENV SHELL /bin/bash
ENV USER user
WORKDIR /home/user

ENTRYPOINT ["/usr/bin/supervisord"]
