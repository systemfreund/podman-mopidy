FROM archlinux/base

# Update mirrorlist and packages

RUN pacman -Sy \
      && pacman -S --noconfirm reflector \
      && reflector --verbose --latest 15 --sort rate --save /etc/pacman.d/mirrorlist \
      && pacman -Su --noconfirm

# Install yay

RUN pacman -Sy --noconfirm sudo git go fakeroot binutils make gcc gawk file \
      && useradd -m yay \
      && sudo -u yay git clone https://aur.archlinux.org/yay.git /tmp/yay \
      && cd /tmp/yay \
      && sudo -u yay makepkg \
      && pacman -U --noconfirm /tmp/yay/*.xz

# Install mopidy and extensions

RUN echo 'yay ALL=(ALL) NOPASSWD: ALL' >>/etc/sudoers \
      && sudo -u yay yay --answerclean --answerdiff --noconfirm -S mopidy mopidy-spotify mopidy-local mopidy-iris

# Cleanup

RUN pacman -Rsc --noconfirm sudo git go fakeroot binutils make gcc gawk file yay \
      && rm -rf /home/yay

# Configure

COPY mopidy.conf /etc/mopidy/mopidy.conf

RUN chmod -R o+rwx /var/lib/mopidy

# Run

ENV HOME=/var/lib/mopidy
USER mopidy

EXPOSE 6680

CMD ["/usr/bin/mopidy"]

