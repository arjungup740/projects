## want to write a utility that allows us to generate our cover letters and our cold emails programmatically, so we minimize the chance of human error
# https://stackabuse.com/how-to-send-emails-with-gmail-using-python/ very helpful
from fpdf import FPDF
import smtplib

gmail_user = 'arjungup740@gmail.com'  
gmail_password =  # TODO there's gotta be a way you don't have to hardcode password here, so we can put this on github

sent_from = gmail_user  
to = 'arjungup740@gmail.com'
subject = 'Wharton Graduate with a Passion for Analytics'  
# body = 'Hey, what's up?\n\n- You'


def coldEmailWriter(email_text):
	print('\n')
	print(email_text)


def getPositionsString(positions_list):
	# right now this is restricted to two things
	# TODO: Can make it take 3 or more things and just list things out
	position_language = positions_list[0]
	if len(positions_list) > 1:
		for additional_position in positions_list[1:]:
			position_language += ' and ' + additional_position
	return position_language

name = 'Marina'
positions_list = ['two Business Analyst roles', 'Insights Manager', 'Journalist']
number_of_roles = len(positions_list)
if number_of_roles > 1:
	quantity_of_roles_language = 'a few interesting roles'
else:
	quantity_of_roles_language = 'an interesting role'
	
position_string = getPositionsString(positions_list) 

company = 'Capsule'

#email_text = "Hi %s, My name is Arjun, and I am a 2017 Wharton graduate with a keen interest in analytics.\nI came across a few data-focused positions at %s this morning (%s).\nI believe these positions at %s would provide me with an outstanding opportunity to learn and help %s succeed at the same time."
piece1 = 'Hi '
piece2 = ',\n\nMy name is Arjun, and I am a 2017 Wharton graduate with a keen interest in analytics.\n\nI came across '
piece3 = ' at '
piece4 = ' this morning ('
piece5 = "). These positions are very exciting to me, and I believe that my skills align with your requirements.\n\nFor some background, I've spent the last year and a half working as a data analyst focused on data quality at Coatue Asset Management, a long-short hedge fund. Despite the fact that I've gotten a lot out of this experience, I believe working at "
piece6 = ' would provide me with an outstanding opportunity to learn and help '
piece7 = ' succeed at the same time.\n\nI found your contact in Penn’s alumni database and was hoping that you could possibly direct me to a general recruiter or the recruiter specifically for this role. My resume is attached to this email. I would be extremely grateful for any help or contact regarding this opportunity!\nThank you in advance for your time!\n\nCheers,\n\nArjun\nhttps://www.linkedin.com/in/arjun-s-gupta-193a178a/' 

email_body = piece1 + name + piece2 + quantity_of_roles_language + piece3 + company + piece4 + position_string + piece5 + company + piece6 + company + piece7

coldEmailWriter(email_body)

# email_text = "From: %s \nTo: %s \nSubject: %s \n%s" % (sent_from, ", ".join(to), subject, email_body)

# try:  
#     server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
#     server.ehlo()
#     server.login(gmail_user, gmail_password)
#     server.sendmail(sent_from, to, email_text)
#     server.close()

#     print ('Email sent!')
# except Exception as e:  
#     print ('Something went wrong' + str(e))



## TODO figure out how to wring text to pdf
# pdf = FPDF()
# pdf.add_page()
# pdf.set_xy(0, 0)
# pdf.set_font('arial', 'B', 13.0)
# pdf.cell(ln=0, h=5.0, align='L', w=0, txt = email_text, border=0)
# pdf.output('/Users/arjungupta/projects/job_hunt_help/test.pdf', 'F')
