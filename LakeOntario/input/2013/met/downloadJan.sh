#! /bin/csh -f
#
# c-shell script to download selected files from rda.ucar.edu using Wget
# NOTE: if you want to run under a different shell, make sure you change
#       the 'set' commands according to your shell's syntax
# after you save the file, don't forget to make it executable
#   i.e. - "chmod 755 <name_of_script>"
#
# Experienced Wget Users: add additional command-line flags here
#   Use the -r (--recursive) option with care
set opts = "-N"
#
set cert_opt = ""
# If you get a certificate verification error (version 1.10 or higher),
# uncomment the following line:
#set cert_opt = "--no-check-certificate"
#
# download the file(s)

# at surface
wget $cert_opt $opts https://data.rda.ucar.edu/d094001/2013/dlwsfc.cdas1.201301.grb2
wget $cert_opt $opts https://data.rda.ucar.edu/d094001/2013/dswsfc.cdas1.201301.grb2
wget $cert_opt $opts https://data.rda.ucar.edu/d094001/2013/tmpsfc.cdas1.201301.grb2

# 2m from surface
wget $cert_opt $opts https://data.rda.ucar.edu/d094001/2013/q2m.cdas1.201301.grb2

# 10m from surface
wget $cert_opt $opts https://data.rda.ucar.edu/d094001/2013/wnd10m.cdas1.201301.grb2


# 0.5/0.5 resolution
wget $cert_opt $opts https://data.rda.ucar.edu/d094001/2013/prmsl.cdas1.201301.grb2
wget $cert_opt $opts https://data.rda.ucar.edu/d094001/2013/rh2m.cdas1.201301.grb2
