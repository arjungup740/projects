import smtplib

gmail_user = 'arjungup740@gmail.com'  
gmail_password = 'Pantherfan16' # TODO there's gotta be a way you don't have to hardcode password here, so we can put this on github

sent_from = gmail_user  
to = ['joejmaher@gmail.com', 'gautham.venkatesan@pwc.com', 'halla@wharton.upenn.edu']
subject = 'Care to propose ideas for the Arjun listserv?'  
body = """
Hello! If you are reading this, you have made history as having received the first email sent from Arjun's computer completely programmatically (I.e. I did not open gmail or even google chrome to send this, but rather ran one line on the terminal).

Don't be too impressed though, if you google "send emails through gmail python" there's some extremely easy-to-follow templates.

At any rate, this is part of the syllabus of personal projects I'm going to be working on while I have a break from Coatue. So, I'd love to hear from you if you have any ideas of things that might be fun or useful (e.g. maybe Joe would like a weekly email summarizing key stats from the Vikings and Timberwolves games or maybe it'd be interesting to get an email telling you how many snaps you received). 

Obviously it's gonna be pretty rough and nowhere near as polished as if a professional did it, but we'll have some fun and I'll learn something in the process.

Rise and grind boys,

Arjun
"""

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
except Exception as e:  
    print ('Something went wrong' + str(e))