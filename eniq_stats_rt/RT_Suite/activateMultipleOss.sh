#!/usr/bin/sh
cd /eniq/sw/installer
chmod 777 /eniq/sw/installer/get_active_interfaces
./get_active_interfaces > oss2.txt
chmod 540 /eniq/sw/installer/get_active_interfaces
echo "Updating eniq_oss_2 details... ";
sed -i 's/eniq_oss_1/eniq_oss_2/' oss2.txt
echo "Executing activate_interfaces... ";
./activate_interface -f oss2.txt