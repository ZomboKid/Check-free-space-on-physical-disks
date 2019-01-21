#! /usr/bin/python

import sys
import re
import psutil
import collections

fs_patterns = ['xfs', 'ext.*']
fs_partitions_to_exclude = ['boot', 'swap', 'tmp']
trigger = int(sys.argv[1])  # set min GB free space in command line argument
# ----------------------------------------------------------------------------


def f_mounted_fs_info_list():
    diskinfo = collections.namedtuple('diskinfo',
                                      'device mountpoint fstype free_gb')
    fs_info_list = []
    # without arg 'All' psutil returns only phys dev
    for diskpart in psutil.disk_partitions():
        for fs_pattern in fs_patterns:
            if re.compile(fs_pattern).match(diskpart.fstype):
                for fs_partition in fs_partitions_to_exclude:
                    if fs_partition not in diskpart.mountpoint:
                        contains = False
                        continue
                    else:
                        contains = True
                        break
                if not contains:
                    fs_info_list.append(diskinfo(diskpart.device,
                                        diskpart.mountpoint, diskpart.fstype,
                                        int(round((psutil.disk_usage(
                                         diskpart.mountpoint).free) /
                                         1000000000))))
    return fs_info_list
# ----------------------------------------------------------------------------


def f_chkspace():

    mounted_fs_info_list = f_mounted_fs_info_list()

    for i in mounted_fs_info_list:
        if i.free_gb < trigger:
            sys.exit("ERROR. On device " + i.device + " that is mounted to " +
                     i.mountpoint+" is " + str(i.free_gb) +
                     " GB free. It is less than " + str(trigger) + " GB.")
# ----------------------------------------------------------------------------
if __name__ == "__main__":
    f_chkspace()
