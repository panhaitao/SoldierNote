#!/bin/bash
> book.md
cat src/think_about_distribution.md >> book.md || ture
cat src/start_from_here.md >> book.md || true      
cat src/version-release-workflow.md >> book.md || true
cat src/toolchains.md >> book.md || true
cat src/cc.md >> book.md || true
cat src/ld.md >> book.md || true
cat src/libc.md >> book.md || true
cat src/kerner.md >> book.md || true
cat src/packages_manager.md >> book.md || true
cat src/rpm_and_yum.md >> book.md || true
cat src/deb_and_apt.md >> book.md || true
cat src/make_install_media.md >> book.md || true
cat src/base_on_debian.md >> book.md || true
cat src/base_on_centos.md >> book.md || true
cat src/base_on_debian_live.md >> book.md || true
