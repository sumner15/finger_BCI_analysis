function sendEmail(success)

mail_address = 'slnorman@uci.edu';
user_name = 'slnorman@uci.edu'; 
smtp_server = 'smtp.gmail.com';
psswd = 'fllnoocbhzqpmrce';


setpref('Internet', 'E_mail', mail_address);
setpref('Internet', 'SMTP_Username', user_name);
setpref('Internet', 'SMTP_Server', smtp_server);
setpref('Internet', 'SMTP_Password',psswd);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth', 'true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port', '465');

if success == false
    sendmail('slnorman@uci.edu','MATLAB: Processing failed :(', ...
        'Your last script encountered an error!');
else
    sendmail('slnorman@uci.edu','MATLAB: Processing complete!', ...
        'Congratulations, your latest script completed successfuly!');
end
disp('Email Sent.');

end