########################################################
# Sample customers blueprint of endpoints
# Remove this file if you are not using it in your project
########################################################
from flask import Blueprint, request, jsonify, make_response, current_app
import json
from src import db


Students = Blueprint('Students', __name__)

# Get all customers from the DB
@Students.route('/students', methods=['GET'])
def get_students():
    cursor = db.get_db().cursor()
    cursor.execute('select * from Students NATURAL JOIN StudentsEmails')
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get customer detail for customer with particular userID
@Students.route('/students/<ID>', methods=['GET'])
def get_customer(ID):
    cursor = db.get_db().cursor()
    cursor.execute('select * from Students NATURAL JOIN StudentsEmails where StudentID = {0}'.format(ID))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response


# get assignments that have not been graded yet AND count of how many submissions still need to be graded
@Students.route('/Assignments', methods=['GET'])
def get_assignments():
    cursor = db.get_db().cursor()
    cursor.execute('SELECT s.AssignmentID,COUNT(s.SubmissionID) AS SubmissionCount FROM Submissions s JOIN Assignments a ON s.AssignmentID = a.AssignmentID WHERE s.Grade IS NULL GROUP BY s.AssignmentID')
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# route 2; get oh schedule 
# changed endpoint to OfficeHours
@Students.route('/OfficeHours', methods=['GET'])
def get_schedule():
    cursor = db.get_db().cursor()
    cursor.execute('SELECT dtw.Day AS Day, dtw.Timeslot AS Timeslot, e.FirstName, e.LastName FROM Schedule s JOIN DayTimeWorked dtw ON dtw.ScheduleID = s.ScheduleID JOIN Employees e ON e.EmployeeID = s.EmployeeID')
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response


@Students.route('/Grades', methods=['GET'])
def get_grades():
    cursor = db.get_db().cursor()
    cursor.execute('SELECT * FROM Submissions')
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response



from datetime import datetime
import pytz

def parse_http_date(http_date):
    if http_date is None:
        # handle the case where no date is provided 
        return None 
    try:
        # Parse HTTP date format to datetime object
        dt = datetime.strptime(http_date, '%a, %d %b %Y %H:%M:%S GMT')
        # Convert to a timezone-aware datetime object in UTC
        dt = dt.replace(tzinfo=pytz.utc)
        # Format for MySQL
        return dt.strftime('%Y-%m-%d %H:%M:%S')
    except ValueError as e:
        raise ValueError(f"Invalid date format: {http_date}")

# route 4: update grade for submissions 
@Students.route('/Gradesupdate', methods=['PUT'])
def update_regradeRequests():
    the_data = request.json
    current_app.logger.info(the_data)

    #extracting the variable
    grade = the_data['Grade']
    graded_by = the_data['GradedBy']
    graded_on = parse_http_date(the_data['GradedOn'])
    submissionid = the_data['SubmissionID']
    query = 'UPDATE Submissions SET Grade = %s, GradedBy = %s, GradedOn = %s WHERE SubmissionID = %s '
    data = (grade, graded_by, graded_on, submissionid)

    # executing and committing the insert statement 
    cursor = db.get_db().cursor()
    r =cursor.execute(query, data)
    db.get_db().commit()
    return 'grade updated!'



