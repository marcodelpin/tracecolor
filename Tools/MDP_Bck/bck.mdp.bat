set DST=\\192.168.71.9\Shared\Backup\Marco

s:\MDPUtils\Utils\Shell\LogRotate\logrotate.exe s:\MDPUtils\Utils\Shell\LogRotate\logrotate.conf

MDP_Bck.exe s:\Commesse %DST% .mdpignore

MDP_Bck.exe c:\Users\marco %DST% .mdpignore

MDP_Bck.exe s:\Users\Marco %DST% .mdpignore

