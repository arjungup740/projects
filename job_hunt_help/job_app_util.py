## want to write a utility that allows us to generate our cover letters and our cold emails programmatically, so we minimize the chance of human error
def coldEmailWriter(email_text):
	final_email_text = email_text % (name, company, position, company, company)
	print(final_email_text)

def coldEmailWriterAlt(email_text_2):
	print(email_text_2)


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


email_text_2 = 'Hi ' + name + ',\nMy name is Arjun, and I am a 2017 Wharton graduate with a keen interest in analytics.\nI came across ' + quantity_of_roles_language + ' at '  + company + ' this morning (' + position_string + ').\nI believe working at ' + company + ' would provide me with an outstanding opportunity to learn and help ' + company + ' succeed at the same time.' 



#coldEmailWriter(email_text)
print('\n\n')
coldEmailWriterAlt(email_text_2)