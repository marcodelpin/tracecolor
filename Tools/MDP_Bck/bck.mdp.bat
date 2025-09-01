s:\MDPUtils\Utils\Shell\LogRotate\logrotate.exe s:\MDPUtils\Utils\Shell\LogRotate\logrotate.conf

set DST=\\192.168.71.9\Shared\Backup\Marco

MDP_Bck.exe s:\Users\Marco %DST% .mdpignore

MDP_Bck.exe s:\Commesse %DST% .mdpignore

set DST=\\192.168.71.9\Shared\Backup\MarcoC

MDP_Bck.exe c:\Users\marco %DST% .mdpignore


