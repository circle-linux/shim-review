FROM circlelinux/circlelinux-shim:8-15.4-4.1

ENV SHIM_VERSION 15.4-4.el8.1

RUN wget https://github.com/circle-linux/shim-review/blob/master/shim-unsigned-x64-$SHIM_VERSION.src.rpm
RUN rpm -ivh shim-unsigned-x64-$SHIM_VERSION.src.rpm
RUN sed -i 's/linux32 -B/linux32/g' /builddir/build/SPECS/shim-unsigned-x64.spec
RUN rpmbuild -bb /builddir/build/SPECS/shim-unsigned-x64.spec
COPY shimia32.efi /
COPY shimx64.efi /
RUN mkdir /built_shim/
RUN rpm2cpio /builddir/build/RPMS/x86_64/shim-unsigned-ia32-$SHIM_VERSION.x86_64.rpm | cpio -diu -D /built_shim
RUN rpm2cpio /builddir/build/RPMS/x86_64/shim-unsigned-x64-$SHIM_VERSION.x86_64.rpm | cpio -diu -D /built_shim
RUN ls -l /*.efi /built_shim/usr/share/shim/$SHIM_VERSION/*/shim*.efi
RUN sha256sum /built_shim/usr/share/shim/$SHIM_VERSION/x64/shimx64.efi /built_shim/usr/share/shim/$SHIM_VERSION/ia32/shimia32.efi /shimia32.efi /shimx64.efi
RUN hexdump -Cv /built_shim/usr/share/shim/$SHIM_VERSION/x64/shimx64.efi > built-x64.hex
RUN hexdump -Cv /built_shim/usr/share/shim/$SHIM_VERSION/ia32/shimia32.efi > built-ia32.hex
RUN hexdump -Cv /shimia32.efi > orig-ia32.hex
RUN hexdump -Cv /shimx64.efi > orig-x64.hex
RUN objdump -h /built_shim/usr/share/shim/$SHIM_VERSION/x64/shimx64.efi
RUN objdump -h /built_shim/usr/share/shim/$SHIM_VERSION/ia32/shimia32.efi
RUN diff -u orig-ia32.hex built-ia32.hex
RUN diff -u orig-x64.hex built-x64.hex
RUN cmp /built_shim/usr/share/shim/$SHIM_VERSION/x64/shimx64.efi /shimx64.efi
RUN cmp /built_shim/usr/share/shim/$SHIM_VERSION/ia32/shimia32.efi /shimia32.efi
RUN pesign -h -P -i /built_shim/usr/share/shim/$SHIM_VERSION/ia32/shimia32.efi
RUN pesign -h -P -i /shimia32.efi
RUN pesign -h -P -i /built_shim/usr/share/shim/$SHIM_VERSION/x64/shimx64.efi
RUN pesign -h -P -i /shimx64.efi
RUN sha256sum /built_shim/usr/share/shim/$SHIM_VERSION/x64/shimx64.efi /shimx64.efi /built_shim/usr/share/shim/$SHIM_VERSION/ia32/shimia32.efi /shimia32.efi
