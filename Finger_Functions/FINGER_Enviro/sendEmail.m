function sendEmail()

mail_address = 'slnorman@uci.edu';
user_name = 'slnorman@uci.edu'; 
smtp_server = 'smtp.gmail.com';


setpref('Internet', 'E_mail', mail_address);
setpref('Internet', 'SMTP_Username', user_name);
setpref('Internet', 'SMTP_Server', smtp_server);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth', 'true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port', '465');

sendmail('slnorman@uci.edu','MATLAB: Processing complete!', ...
    'Congratulations, your latest script completed successfuly!');

end