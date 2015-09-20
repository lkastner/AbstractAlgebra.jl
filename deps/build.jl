on_windows = @windows ? true : false

oldwdir = pwd()

pkgdir = Pkg.dir("Nemo") 
wdir = Pkg.dir("Nemo", "deps")
vdir = Pkg.dir("Nemo", "local")

cd(pkgdir)
mkdir("local")
mkdir("lib")

cd(wdir)

# install M4

if !on_windows
   run(`wget http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.bz2`)
   run(`tar -xvf m4-1.4.17.tar.bz2`)
   run(`rm m4-1.4.17.tar.bz2`)
   cd("$wdir/m4-1.4.17")
   run(`./configure --prefix=$vdir`)
   run(`make`)
   run(`make install`)
end

cd(wdir)

# install GMP/MPIR

if on_windows
   download("https://gmplib.org/download/gmp/gmp-6.0.0a.tar.bz2", joinpath(wdir, "gmp-6.0.0a.tar.bz2"))
   run(`tar -xvf gmp-6.0.0a.tar.bz2`)
   run(`rm gmp-6.0.0a.tar.bz2`)
else
   run(`wget http://mpir.org/mpir-2.7.0.tar.bz2`)
   run(`tar -xvf mpir-2.7.0.tar.bz2`)
   run(`rm mpir-2.7.0.tar.bz2`)
   cd("$wdir/mpir-2.7.0")
end

if on_windows
   download("http://nemocas.org/binaries/w64-libgmp-10.dll", joinpath(vdir, "lib", "libgmp-10.dll"))
else
   run(`./configure --prefix=$vdir M4=$vdir/bin/m4 --enable-gmpcompat --disable-static --enable-shared`)
   run(`make -j4`)
   run(`make install`)
   cd(wdir)
   run(`rm -rf mpir-2.7.0`)
   run(`rm -rf bin`)
end

cd(wdir)

# install MPFR

if on_windows
   download("http://www.mpfr.org/mpfr-current/mpfr-3.1.3.tar.bz2", joinpath(wdir, "mpfr-3.1.3.tar.bz2"))
   run(`tar -xvf mpfr-3.1.3.tar.bz2`)
   run(`rm mpfr-3.1.3.tar.bz2`)
else
   run(`wget http://www.mpfr.org/mpfr-current/mpfr-3.1.3.tar.bz2`)
   run(`tar -xvf mpfr-3.1.3.tar.bz2`)
   run(`rm mpfr-3.1.3.tar.bz2`)
   cd("$wdir/mpfr-3.1.3")
end

if on_windows
   download("http://nemocas.org/binaries/w64-libmpfr-4.dll", joinpath(vdir, "lib", "libmpfr-4.dll"))
else
   run(`./configure --prefix=$vdir --with-gmp=$vdir --disable-static --enable-shared`)
   run(`make -j4`)
   run(`make install`)
   cd(wdir)
   run(`rm -rf mpfr-3.1.3`)
end

cd(wdir)

# install ANTIC

try
  run(`git clone https://github.com/wbhart/antic.git`)
except
  run(`cd antic ; git pull`)
end          

# install FLINT
try
  run(`git clone https://github.com/wbhart/flint2.git`)
except
  run(`cd flint2 ; git pull`)
end          

if on_windows
   download("http://nemocas.org/binaries/w64-libflint-13.dll", joinpath(vdir, "lib", "libflint-13.dll"))
else
   cd("$wdir/flint2")
   run(`./configure --prefix=$vdir --extensions="$wdir/antic" --disable-static --enable-shared --with-mpir=$vdir --with-mpfr=$vdir`)
   run(`make -j4`)
   run(`make install`)
end

cd(wdir)

# INSTALL ARB 

try
  run(`git clone -b julia https://github.com/thofma/arb.git`)
except
  run(`cd arb ; git pull`)
end          
 
if on_windows
else
   cd("$wdir/arb")
   run(`./configure --prefix=$vdir --disable-static --enable-shared --with-mpir=$vdir --with-mpfr=$vdir --with-flint=$vdir`)
   run(`make -j4`)
   run(`make install`)
   cd(wdir)
end

# install PARI

try
  run(`git clone http://pari.math.u-bordeaux.fr/git/pari.git`)
except
  run(`cd pari ; git pull`)
end  

if on_windows
   download("http://nemocas.org/binaries/w64-libpari.dll", joinpath(vdir, "lib", "libpari.dll"))
else
   cd("$wdir/pari")
   env_copy = copy(ENV)
   env_copy["LD_LIBRARY_PATH"] = "$vdir/lib"
   env_copy["CFLAGS"] = "-Wl,-rpath,$vdir/lib"
   config_str = `./Configure --prefix=$vdir --with-gmp=$vdir --mt=pthread`
   config_str = setenv(config_str, env_copy)
   run(config_str)
   run(`make -j4 gp`)
   run(`make doc`)
   run(`make install`)
end

cd(wdir)

push!(Libdl.DL_LOAD_PATH, Pkg.dir("Nemo", "local", "lib"))

cd(oldwdir)

