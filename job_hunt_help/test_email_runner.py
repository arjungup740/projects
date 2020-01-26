### round 2 of auto-emailer
import smtplib
from datetime import date
import os 

gmail_user = 'arjungup740@gmail.com'  
gmail_password = 

sent_from = gmail_user  
to = ['arjungup740@gmail.com']
subject = 'Daily Health Reminder %s' % date.today()
# body = """
# reminder to do something healthy today! Love you!
# """

messages_folder = '/Users/arjungupta/projects/auto_emailer/messages/'
to_send_folder = messages_folder + 'to_send'
already_sent_folder = messages_folder + 'already_sent'
# messages_folder = os.path.dirname('/Users/arjungupta/projects/auto_emailer/messages')
## list messages
to_send_messages = os.listdir(to_send_folder)

## check to see if there any messages available, otherwise make some new ones
try:
	indiv_message = to_send_messages[0]
except Exception as e: ## if there aren't, then email a reminder to yourself to add some new ones
	

final_to_send_path = os.path.join(to_send_folder, indiv_message)
final_replacement_path = os.path.join(already_sent_folder, indiv_message)

with open(final_to_send_path, 'r') as file:
    body = file.read()#.replace('\n', '')

# print(body)

email_text = """From: %s  
To: %s  
Subject: %s
%s
""" % (sent_from, ", ".join(to), subject, body)

try:  
    server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
    server.ehlo()
    server.login(gmail_user, gmail_password)
    server.sendmail(sent_from, to, email_text)
    server.close()

    print ('Email sent!')
    # print('moving this message to already sent folder')
    os.rename(final_to_send_path, final_replacement_path)
    # print(final_to_send_path)
    # print(final_replacement_path)
    print('moved file')


except Exception as e:
    print ('Something went wrong' + str(e))
