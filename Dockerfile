# FROM fedora:34
FROM fedora:34

# Adding a label to the environement
LABEL ImageVersion="4.0.0"
LABEL DISTTAG="f34container"
LABEL Maintainer="Henry Letellier"
LABEL Description="C Build environment"

# Setting the environment variables
ENV HOME /home/
ENV RUNNING_IN_DOCKER true
ENV DNF_CONFIG /etc/dnf/dnf.conf
ENV CRITERION_INSTALLER install_criterion.sh
# ENV FIX_VALGRIND_SCRIPT /bin/fix_valgrind
ENV FIX_VALGRIND_ON_LAUNCH /bin/fix_valgrind_on_launch

# Forcing dnf to use the fastest mirror
RUN echo "fastestmirror=true" >> ${DNF_CONFIG}

# Adding free and non-free rpm repositories
## Enabling free repositories
RUN dnf install -y \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

## Enabling non-free repositories
RUN dnf install -y \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

## doing a basic search to enable default keys
RUN dnf search -y sudo

#update dnf
RUN dnf makecache --refresh
RUN dnf update -y

# Install basic requirements

RUN dnf install -y \
    bc \
    bat \
    pip \
    tree \
    sudo \
    wget \
    curl \
    bzip2 \
    gcovr \
    valgrind    \
    python3 \
    python3-pip \
    python3-wheel \
    python3-devel \
    python3-setuptools

# Installing tui debuggers
RUN dnf install -y \
    gdb \
    lldb

# Installing text editors
RUN dnf install -y \
    nano    \
    emacs   \
    vim \
    vim-enhanced

# Installing the C/C++ tools
RUN dnf install -y \
    gcc \
    g++ \
    make    \
    cmake   \
    clang \
    clang-tools-extra

# Installing non-native C/C++ libs
RUN dnf install -y \
    ncurses \
    SFML-devel  \
    CSFML-devel \
    ncurses-devel \
    ncurses-c++-libs

# Installing different tui terminals to suit your needs
RUN dnf install -y \
    zsh \
    tmux \
    tcsh \
    byobu \
    screen \
    && dnf clean all

# Installing the criterion library
RUN echo '#!/usr/bin/env bash' > ${CRITERION_INSTALLER} && \
    echo "URL=\"https://github.com/Snaipe/Criterion/releases/download/v2.3.2\"" >> ${CRITERION_INSTALLER} && \
    echo "TARBALL=\"criterion-v2.3.2-linux-x86_64.tar.bz2\"" >> ${CRITERION_INSTALLER} && \
    echo "DIR=\"criterion-v2.3.2\"" >> ${CRITERION_INSTALLER} && \
    echo "DST=\"/usr/local/\"" >> ${CRITERION_INSTALLER} && \
    echo "SUDO=/usr/bin/sudo" >> ${CRITERION_INSTALLER} && \
    echo "if [ \$UID -eq \"0\" ]; then" >> ${CRITERION_INSTALLER} && \
    echo "    SUDO=\"\"" >> ${CRITERION_INSTALLER} && \
    echo "    echo \"[no sudo for root]\"" >> ${CRITERION_INSTALLER} && \
    echo "fi" >> ${CRITERION_INSTALLER} && \
    echo "cd /tmp" >> ${CRITERION_INSTALLER} && \
    echo "rm -f \$TARBALL" >> ${CRITERION_INSTALLER} && \
    echo "rm -fr \$DIR" >> ${CRITERION_INSTALLER} && \
    echo "wget \$URL/\$TARBALL" >> ${CRITERION_INSTALLER} && \
    echo "if [ \$? != 0 ]; then" >> ${CRITERION_INSTALLER} && \
    echo "    echo \"failled, exiting\"" >> ${CRITERION_INSTALLER} && \
    echo "    exit;" >> ${CRITERION_INSTALLER} && \
    echo "fi" >> ${CRITERION_INSTALLER} && \
    echo "echo" >> ${CRITERION_INSTALLER} && \
    echo "echo \"untaring \$TARBALL\"" >> ${CRITERION_INSTALLER} && \
    echo "tar xjf \$TARBALL" >> ${CRITERION_INSTALLER} && \
    echo "if [ \$? != 0 ]; then" >> ${CRITERION_INSTALLER} && \
    echo "    echo \"failled, exiting\"" >> ${CRITERION_INSTALLER} && \
    echo "    exit;" >> ${CRITERION_INSTALLER} && \
    echo "fi" >> ${CRITERION_INSTALLER} && \
    echo "echo \"creating custom ld.conf\"" >> ${CRITERION_INSTALLER} && \
    echo "\$SUDO sh -c \"echo \"/usr/local/lib\" > /etc/ld.so.conf.d/criterion.conf\"" >> ${CRITERION_INSTALLER} && \
    echo "echo \"cp headers to $DST/include...\"" >> ${CRITERION_INSTALLER} && \
    echo "\$SUDO cp -r \$DIR/include/* \$DST/include/" >> ${CRITERION_INSTALLER} && \
    echo "echo \"cp lib to \$DST/include...\"" >> ${CRITERION_INSTALLER} && \
    echo "\$SUDO cp -r \$DIR/lib/* \$DST/lib/" >> ${CRITERION_INSTALLER} && \
    echo "echo \"run ldconfig.\"" >> ${CRITERION_INSTALLER} && \
    echo "\$SUDO ldconfig" >> ${CRITERION_INSTALLER} && \
    echo "echo \"all good.\"" >> ${CRITERION_INSTALLER} && \
    chmod +x ${CRITERION_INSTALLER} && \
    ./${CRITERION_INSTALLER}

# Exposing ports
EXPOSE 21
EXPOSE 22
EXPOSE 80
EXPOSE 3000
EXPOSE 3300
EXPOSE 5000

# Removing the soft and hard limits:
RUN echo "soft nofile 65536" >> /etc/security/limits.conf &&\
    echo "hard nofile 65536" >> /etc/security/limits.conf &&\
    ulimit -n 4096

RUN FIX_VALGRIND_SCRIPT=/bin/fix_valgrind && \
    echo '#!/bin/bash' > ${FIX_VALGRIND_SCRIPT} && \
    echo 'echo "fixing valgrind..."' >> ${FIX_VALGRIND_SCRIPT} && \
    echo 'echo "soft nofile 65536"' >> ${FIX_VALGRIND_SCRIPT} && \
    echo 'echo "soft nofile 65536" >> /etc/security/limits.conf' >> ${FIX_VALGRIND_SCRIPT} && \
    echo 'echo "hard nofile 65536"' >> ${FIX_VALGRIND_SCRIPT} && \
    echo 'echo "hard nofile 65536" >> /etc/security/limits.conf' >> ${FIX_VALGRIND_SCRIPT} && \
    echo 'echo "ulimit -n 4096"' >> ${FIX_VALGRIND_SCRIPT} && \
    echo 'ulimit -n 4096' >> ${FIX_VALGRIND_SCRIPT} && \
    echo 'echo "(c) Created by Henry Letellier"' >> ${FIX_VALGRIND_SCRIPT}

# Creating patcher for launch
RUN echo '#!/bin/bash' > ${FIX_VALGRIND_ON_LAUNCH} && \
    echo 'echo "Applying fix for valgrind..." ' >> ${FIX_VALGRIND_ON_LAUNCH} && \
    echo 'echo "Setting limit to 4096"' >> ${FIX_VALGRIND_ON_LAUNCH} && \
    echo 'ulimit -n 4096' >> ${FIX_VALGRIND_ON_LAUNCH} && \
    echo 'echo "Done"' >> ${FIX_VALGRIND_ON_LAUNCH} && \
    echo 'echo "(c) Created by Henry Letellier"' >> ${FIX_VALGRIND_ON_LAUNCH} && \
    chmod +x ${FIX_VALGRIND_ON_LAUNCH}

# Applying fixes to the bash profiles
RUN CONTENT="alias fix_valgrind='echo 'Fixing Valgrind' && unlimit -n 4096'\necho 'Applying fix for valgrind...'\necho 'Setting limit to 4096'\nulimit -n 4096\necho 'Done'\necho '(c) Created by Henry Letellier'\nfix_valgrind\n" && \
    echo -e $CONTENT >> /root/.cshrc && \
    echo -e $CONTENT >> /root/.zshrc && \
    echo -e $CONTENT >> /etc/zshrc && \
    echo -e $CONTENT >> /root/.tcshrc && \
    echo -e $CONTENT >> /root/.bashrc && \
    echo -e $CONTENT >> /root/.zshprofile && \
    echo -e $CONTENT >> /root/.bash_profile

# Set the default entry point
WORKDIR ${HOME}
ENTRYPOINT [ "/bin/zsh" ]
