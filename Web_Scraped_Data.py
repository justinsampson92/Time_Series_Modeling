from bs4 import BeautifulSoup
import webbrowser
from urllib import urlopen
import nltk 
import string
from string import digits
import numpy as np
import csv
import socket
from nltk.corpus import stopwords

socket.setdefaulttimeout(None)

dump = '/Users/justinsampson/testing/statdata.csv'
url_file = '/Users/justinsampson/testing/Sampson.csv'


bp_words = ('bp', 'bps', 'one', 'two','three', 'four', 'five', 'six', 'seven', 'eight', 'nine','ten', 'eor', 'per', 'cent', 'pls', 'plc', 'of', 'are', 'both', 'a')
common_words = stopwords.words("english")
other_words = ['a','able','about','across','after','all','almost','also','am','among','an','and','any','are','as','at','be','because','been','but','by','can','cannot','could','dear','did','do','does','either','else','ever','every','for','from','get','got','had','has','have','he','her','hers','him','his','how','however','i','if','in','into','is','it','its','just','least','let','like','likely','may','me','might','most','must','my','neither','no','nor','not','of','off','often','on','only','or','other','our','own','rather','said','say','says','she','should','since','so','some','than','that','the','their','them','then','there','these','they','this','tis','to','too','twas','us','wants','was','we','were','what','when','where','which','while','who','whom','why','will','with','would','yet']


def get_words(url):
	response = urlopen(url)
	html = response.read()
	get_words.soup = BeautifulSoup(html)

	text = get_words.soup.find('div',{'class':'nvc-press-summary'}).text
	text = text.split(' ')
	text = [line.rsplit('\n') for line in text]
	data = []
	for i in range(0,len(text)):
		data = data + text[i]


	data = [word.encode('ascii', 'ignore') for word in data]
	data = [s.translate(None, string.punctuation) for s in data]
	data = [x.lower() for x in data]

	clean = [w for w in data if not w in common_words]
	clean = [w for w in clean if not w in bp_words]
	clean = [w for w in clean if not w in other_words]
	clean = [w for w in clean if len(w) > 2]
	clean = [w for w in clean if not w.isdigit()]

	return clean

def get_date():
	date = get_words.soup.strong.string
	date = [date.encode('ascii', 'ignore')]
	date = str(date).replace('[','').replace(']','').replace("'", '')

	return date


## get sentiment

pos = open('positive-words.txt', 'r')
pos_words = [line.rstrip('\n') for line in pos.readlines()]

neg = open('negative-words.txt', 'r')
neg_words = [line.rstrip('\n') for line in neg.readlines()]

def get_sentiment(words):

	sent = []
	final = []
	for word in words:
		if word in pos_words:
			sent.append(1)
		if word in neg_words:
			sent.append(-1)
		else:
			sent.append(0)
		
	return np.mean(sent)
#################################

temp= open(url_file, 'rU')
urls = csv.reader(temp)

df = []
for row in urls:
	df.append([get_sentiment(get_words(row[0])),get_date()])





myfile = open(dump, 'wb')
wr = csv.writer(myfile, quoting=csv.QUOTE_ALL)
for i in range(0,len(df)):
	wr.writerow(df[i])







