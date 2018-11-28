from fpdf import FPDF

company = 'Lime'
position = 'business process analyst'


cover_letter ="""
Dear %s:

IBM estimates that humanity creates 2.5 quintillion bytes of data per day, and that 90%% of all available data was created in the last two years. With this abundance of information, the value creators of the future are those who can interpret it. I want to pursue a career in making meaning out of the noise. And isn't that at the heart of any analysis? 

Over the last 3 years, I have fallen in love with analytics and have pursued experiences in that realm. Most recently I was a data analyst at Coatue Asset Management, a long-short hedge fund focused on tech stocks. My team buys alternative datasets and uses them to inform investment decisions. I spent my days working on our credit card data sets, cleaning the data and making it useful. It was important work -- if I did my job poorly, all the inputs that drive trades on millions of dollars are flawed. 

The summer prior I interned at Coatue, analyzing a satellite image data set and determining its usefulness to the firm. I collaborated with my teammates to come up with a plan of attack, discuss results, and ultimately arrive at the conclusion that it was not worth the six-figure contract that vendor wanted. It was difficult, interesting work, and I enjoyed every minute of it. More than anything, these experiences have taught me how to learn almost anything online and solve problems independently.

I made the most of my time at Coatue -- I learned a lot about interfacing between technical and non-technical stakeholders, as well as the business questions at hand dealing with alternative data. I've also learned how to work extremely hard while still maintaining a work-life balance and performing at a high level. However, I'm looking for a role where I can flex more skill sets and grow professionally.

I love using information to create value—which is what a %s does for %s. Working with the %s team in a analytical role would be a phenomenal experience.

I can be reached at 704-307-7983 or arjungup740@gmail.com. I look forward to talking further.

Thank you,

Arjun
""" % (company, position, company, company)

print(cover_letter)


pdf = FPDF()
pdf.add_page()
pdf.set_xy(0, 0)
pdf.add_font('DejaVu', '', 'DejaVuSansCondensed.ttf', uni=True)
pdf.set_font('DejaVu', '', 14)
pdf.cell(ln=0, h=5.0, align='L', w=0, txt = cover_letter, border=0)
pdf.output('/Users/arjungupta/projects/job_hunt_help/test.pdf', 'F')