## want to write a utility that allows us to generate our cover letters and our cold emails programmatically, so we minimize the chance of human error

def coldEmailWriter(email_text):
	print('\n\n')
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

email_text = piece1 + name + piece2 + quantity_of_roles_language + piece3 + company + piece4 + position_string + piece5 + company + piece6 + company + piece7

coldEmailWriter(email_text)