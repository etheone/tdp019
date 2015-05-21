#!/usr/bin/env python
#-*- coding: utf-8 -*-

import os

from flask import Flask
from flask import render_template
from flask import request
from flask import url_for
from flask import redirect

# For att anropa ruby
from subprocess import Popen, PIPE, STDOUT



app = Flask(__name__)

@app.route('/')
def index_page():
    return render_template('index.html')

@app.route('/code', methods=['GET', 'POST'])
def code_page():
    if request.method == 'POST':
        input = request.form['input']
        #print 'det har hamtades ' + input
        #print repr(input)
        input2 = input.replace('\r\n', '\n')
        decoded_input = input2.encode('utf-8')
        decoded_input += "STOPNU"
        # print repr(decoded_input)
        result = call_ruby(decoded_input)
        #print "REsult = " + result
        temp = result.decode('utf-8')
        #print "Temp = " + temp
        return render_template('code.html', r=temp, t=input)
    else:
        content = ""
        temp = content.decode('utf-8')
        return render_template('code.html', r=temp)

@app.route('/presentation')
def presentation_page():
    """ Loads presentations page """
    return render_template('presentation.html')

@app.route('/about')
def contact_page():
    return render_template('about.html')

@app.route('/contact')
def contact_us_page():
    return render_template('contact.html')
    
# Test att anropa en ruby-modul
def call_ruby(string):
    print 'launching slave process...'
    #repopath = os.environ['OPENSHIFT_REPO_DIR']
    
    # slavepath = os.path.join(repopath, '/slave.rb')
    #slavepath = './slave.rb'
    #print slavepath + "THIS IS THE SLAVE PATH"
    slave = Popen(['ruby', 'slave.rb'], stdin=PIPE, stdout=PIPE, stderr=STDOUT)
    print "slave created"
    result = ""
    while True:
        # read user input, expression to be evaluated:
        #   line = raw_input('Enter expression or exit:')
        # write that line to slave's stdin
        #print string + " hehehehe "
        slave.stdin.write(string)
        # result will be a list of lines:
        
        # read slave output line by line, until we reach "[end]"
        while True:
            print "Vi kommer inte hit"
           
            # check if slave has terminated:
            # if slave.poll() is not None:
            #      print 'slave has terminated.'
            #exit()
            #     break
            # read one line, remove newline chars and trailing spaces:
           
            line = slave.stdout.readline().rstrip()
            #print "Vi kommer inte hit heller"
            #print line
            #print 'line:', line

            if line == '[end]':
                return result
                break
            #if line == "":
             #   return result
            #print "Nu ar vi har da" + result
            result += line + "\n"
        break
    
        
                    
if __name__ == '__main__':
    app.run(debug=True)
