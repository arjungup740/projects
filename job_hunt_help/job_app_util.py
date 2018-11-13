## want to write a utility that allows us to generate our cover letters and our cold emails programmatically, so we minimize the change of human error
name = 'Marina'
position = 'Business Analyst'
number_of_roles = 2
company = 'Capsule'

email_text = "Hi %s, My name is Arjun, and I am a 2017 Wharton graduate with a keen interest in analytics.\nI came across a few data-focused positions at %s this morning (%s).\nI believe these positions at %s would provide me with an outstanding opportunity to learn and help %s succeed at the same time."

email_text_2 = 'Hi ' + name + ',\nMy name is Arjun, and I am a 2017 Wharton graduate with a keen interest in analytics.\nI came across a few data-focused positions at ' + company + ' this morning (' + position + ').\nI believe these positions at ' + company + ' would provide me with an outstanding opportunity to learn and help ' + company + ' succeed at the same time.' 

def coldEmailWriter(email_text):
	final_email_text = email_text % (name, company, position, company, company)
	print(final_email_text)

def coldEmailWriterAlt(email_text_2):
	print(email_text_2)

coldEmailWriter(email_text)
print('\n\n')
coldEmailWriterAlt(email_text_2)