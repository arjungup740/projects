### round 2 of auto-emailer
import smtplib
from datetime import date
import os 

def sendEmail(sent_from, to, email_text, gmail_user, gmail_password):
    
    server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
    server.ehlo()
    server.login(gmail_user, gmail_password)
    server.sendmail(sent_from, to, email_text)
    server.close()

    print ('Email sent!')

gmail_user = 'arjungup740@gmail.com'  
gmail_password = 

sent_from = gmail_user  
to = ['arjungup740@gmail.com']
subject = 'Daily Health Reminder %s' % date.today()
# subject = 'Welcome Back!'
# body = """
# reminder to do something healthy today! Love you!
# """

messages_folder = '/Users/arjungupta/projects/auto_emailer/messages/'
to_send_folder = messages_folder + 'to_send'
already_sent_folder = messages_folder + 'already_sent'
# messages_folder = os.path.dirname('/Users/arjungupta/projects/auto_emailer/messages')
## list messages
to_send_messages = os.listdir(to_send_folder)

try:
	indiv_message = to_send_messages[0]
except: ## if there aren't, then email a reminder to yourself to add some new ones
	print('got here')
	subject = 'Auto-emailer out of messages'	
	body = 'you know what to do'
	email_text = """From: %s  
	To: %s  
	Subject: %s
	%s
	""" % (sent_from, ", ".join(to), subject, body)

	sendEmail(sent_from, to, email_text, gmail_user, gmail_password)

	print('got here 2')
	sys.exit()

## if there is a message there we proceed
final_to_send_path = os.path.join(to_send_folder, indiv_message)
final_replacement_path = os.path.join(already_sent_folder, indiv_message)

with open(final_to_send_path, 'r') as file:
    body = file.read()#.replace('\n', '')


email_text = """From: %s  
To: %s  
Subject: %s
%s
""" % (sent_from, ", ".join(to), subject, body)

try:  

    sendEmail(sent_from, to, email_text, gmail_user, gmail_password)
    os.rename(final_to_send_path, final_replacement_path) # move file from to send to already sent
    print('moved file')
    jim

except Exception as e:
    print ('Something went wrong' + str(e))
