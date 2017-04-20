from conans import ConanFile, CMake, tools
from conans.util import files
from conans.tools import download, unzip
import os


class LibresslConan(ConanFile):
    description = "An open-source implementation of the Secure Sockets Layer and Transport Layer Security protocols"
    name = "libressl"
    version = "2.5.3"
    src_dir = name + "-" + version
    license = "https://raw.githubusercontent.com/libressl-portable/openbsd/master/src/lib/libssl/LICENSE"
    url = "https://github.com/pbtrung/conan-libressl"
    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False]}
    default_options = "shared=False"
    generators = "cmake"
    exports = ("FindLibreSSL.cmake")

    def source(self):
        if self.settings.os == "Windows":
            zip_name = "libressl-%s-windows.zip" % self.version
        else:
            zip_name = "libressl-%s.tar.gz" % self.version
        url = "https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/%s"
        download(url % zip_name, zip_name, verify=False)
        unzip(zip_name)
        os.unlink(zip_name)

    def build(self):
        with tools.chdir(self.src_dir):
            cmake = CMake(self)
            shared = "-DBUILD_SHARED_LIBS=ON" if self.options.shared else ""
            self.run("cmake . %s %s" % (cmake.command_line, shared))
            self.run("cmake --build . %s" % cmake.build_config)

    def package(self):
        self.copy("*.cmake", dst="include", src=self.src_dir + "/include", keep_path=True)
        self.copy("*.marks", dst="include", src=self.src_dir + "/include", keep_path=True)
        self.copy("*.h", dst="include/openssl", src=self.src_dir + "/include/openssl", keep_path=False)
        self.copy("tls.h", dst="include", src=self.src_dir + "/include", keep_path=False)
        self.copy("pqueue.h", dst="include", src=self.src_dir + "/include", keep_path=False)
        if self.settings.os != "Windows":
            self.copy("*.pc", dst="lib/pkgconfig", src=self.src_dir, keep_path=False)
            if self.options.shared:
                self.copy("*.so*", dst="lib", src=self.src_dir, keep_path=False)
                self.copy("*.dylib", dst="lib", src=self.src_dir, keep_path=False)
            else:
                self.copy("*.a", dst="lib", src=self.src_dir, keep_path=False)
        else:
            if self.options.shared:
                self.copy("*.dll", dst="bin", src=self.src_dir, keep_path=False)
            else:
                self.copy("*.lib", dst="lib", src=self.src_dir, keep_path=False)

    def package_info(self):
        if self.settings.compiler == "Visual Studio":
            suffix = str(self.settings.compiler.runtime)
            self.cpp_info.libs = ["ssleay32" + suffix, "libeay32" + suffix, "crypt32", "msi"]
        elif self.settings.os != "Windows":
            self.cpp_info.libs = ["ssl", "crypto", "tls"]