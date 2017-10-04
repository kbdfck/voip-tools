%s/\(.\{-}\)\t\(.\{-}\)\t\(.\{-}\)\t\(.\{-}\)\t\(.\{-}\)\t\(.*\)\t.*/INSERT INTO acc_tmp(sipusername, sippassword, host, context, denyacl, permitacl) VALUES( '\1', '\2', '\3', '\4', '\5', '\6');
