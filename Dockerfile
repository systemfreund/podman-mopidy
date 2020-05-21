FROM archlinux/base

# Update mirrorlist and packages

RUN pacman -Sy \
      && pacman -S --noconfirm reflector \
      && reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist \
      && pacman -Su --noconfirm

# Install yay

RUN pacman -S --noconfirm sudo git go fakeroot binutils make gcc gawk file \
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

RUN mkdir -p /var/lib/mopidy/.config \
      && chown -R nobody:nobody /var/lib/mopidy
COPY mopidy.conf /var/lib/mopidy/.config/mopidy/mopidy.conf

# Run

ENV HOME=/var/lib/mopidy
USER nobody

EXPOSE 6680

CMD ["/usr/bin/mopidy"]

