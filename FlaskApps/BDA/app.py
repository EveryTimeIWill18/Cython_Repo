"""
Business Intelligence and Analytics App
---------------------------------------
This is the development application for
viewing the hive table data.
"""
import json
from flask import (Flask, render_template, request,
                   Response, redirect, url_for,
                   make_response, jsonify)
from flask_bootstrap import Bootstrap
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired

# user defined modules
from LoadData import *
from LoadData import GenRandData

app = Flask(__name__)

#bootstrap = Bootstrap(app)

# Login form classes
class UsernameForm(FlaskForm):
    """
    Form for inputting username
    """
    name = StringField('Username', validators=[DataRequired()])
    submit = SubmitField()



@app.route('/')
def login_page():
   return '<h1>Page 1</h1>'

@app.route('/user/<name>')
def user(name):
    return render_template('index.html', name=name)

@app.route('/data')
def view_data():
    d = GenRandData(20, 20).df
    json_df = d.to_json(orient='columns')

@app.route('/d3')
def show_data():
    data = [{"United States": 336}, {"United Kingdom": 98},
            {"Germany": 79}, {"France": 60}, {"Sweden": 29},
            {"Switzerland": 23}, {"Japan": 21}, {"Russia": 19},
            {"Netherlands": 17}, {"Austria": 14}]
    return render_template("view_data.html")


def login_form():
    name = None
    form = UsernameForm()
    if form.validate_on_submit():
        name = form.name.data
        form.name.data = ''
    return render_template('LoginPage.html', form=form, name=name)


if __name__ == '__main__':
    app.run(debug=True)
