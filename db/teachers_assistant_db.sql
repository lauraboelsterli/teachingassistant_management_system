-- This file is to bootstrap a database for the CS3200 project. 

-- Create a new database.  You can change the name later.  You'll
-- need this name in the FLASK API file(s),  the AppSmith 
-- data source creation.
create database teachers_assistant_db;

-- Via the Docker Compose file, a special user called webapp will 
-- be created in MySQL. We are going to grant that user 
-- all privilages to the new database we just created. 
-- TODO: If you changed the name of the database above, you need 
-- to change it here too.
grant all privileges on teachers_assistant_db.* to 'webapp'@'%';
flush privileges;

-- Move into the database we just created.
-- TODO: If you changed the name of the database above, you need to
-- change it here too. 
use teachers_assistant_db;

-- Put your DDL 
-- Creates Employees Table
CREATE TABLE IF NOT EXISTS Employees(
    EmployeeID int AUTO_INCREMENT PRIMARY KEY,
    FirstName varchar(50) NOT NULL,
    LastName varchar(50) NOT NULL,
    EmployeeTitle varchar(50) NOT NULL
);

-- Creates EmployeesEmails Table
CREATE TABLE IF NOT EXISTS EmployeesEmails(
    EmployeeID int AUTO_INCREMENT NOT NULL,
    Email varchar(100) NOT NULL,
    CONSTRAINT EE_fk_01
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID) ON UPDATE CASCADE,
    CONSTRAINT EE_PK
        PRIMARY KEY (EmployeeID,Email)
);

-- Creates Schedule Table
CREATE TABLE IF NOT EXISTS Schedule(
    ScheduleID int AUTO_INCREMENT PRIMARY KEY,
    EmployeeID int NOT NULL,
    CONSTRAINT S_fk_01
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID) ON UPDATE CASCADE,
    HoursWorked int DEFAULT 0
);

-- Creates DayTimeWorked Table
CREATE TABLE IF NOT EXISTS DayTimeWorked(
    Day varchar(10),
    Timeslot varchar(40),
    ScheduleID int NOT NULL,
    CONSTRAINT DTW_pk
        PRIMARY KEY (Day,Timeslot,ScheduleID),
    CONSTRAINT  DTW_pk_01
        FOREIGN KEY (ScheduleID) REFERENCES Schedule(ScheduleID) ON UPDATE CASCADE
);

-- Creates Students Table
CREATE TABLE IF NOT EXISTS Students(
    StudentID int auto_increment PRIMARY KEY,
    FirstName varchar(50) NOT NULL,
    LastName varchar(50) NOT NULL
);

-- Creates StudentsEmails Table
CREATE TABLE IF NOT EXISTS StudentsEmails(
    StudentID int AUTO_INCREMENT NOT NULL,
    Email varchar(100) NOT NULL,
    CONSTRAINT SE_fk_01
        FOREIGN KEY (StudentID) REFERENCES Students(StudentID) ON UPDATE CASCADE,
     CONSTRAINT SE_PK
        PRIMARY KEY (StudentID,Email)
);

-- Creates AcademicAdvisors Table
CREATE TABLE IF NOT EXISTS AcademicCoordinators(
    CoordinatorID int AUTO_INCREMENT PRIMARY KEY,
    FirstName varchar(50) NOT NULL,
    LastName varchar(50) NOT NULL,
    Phone char(20) NOT NULL,
    Department varchar(100) NOT NULL,
    Supervisor int NOT NULL
);

-- Create AcademicAdvisorsEmails Table
CREATE TABLE IF NOT EXISTS AcademicCoordinatorEmails(
    CoordinatorID int AUTO_INCREMENT NOT NULL,
    Email varchar(100) NOT NULL,
    CONSTRAINT AAE_fk_01
        FOREIGN KEY (CoordinatorID) REFERENCES AcademicCoordinators(CoordinatorID) ON UPDATE CASCADE,
     CONSTRAINT AAE_PK
        PRIMARY KEY (CoordinatorID,Email)
);


-- Creates Courses Table
CREATE TABLE IF NOT EXISTS Courses(
    CourseID int AUTO_INCREMENT PRIMARY KEY,
    Department varchar(100)
);

-- Create CourseSections Table
CREATE TABLE IF NOT EXISTS CourseSections(
    CRN int AUTO_INCREMENT PRIMARY KEY,
    CourseID int not null,
    CONSTRAINT CS_fk_01
        FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON UPDATE CASCADE,
    Year int not null,
    Semester varchar(10) not null
);

-- Create Instructors Table
CREATE TABLE IF NOT EXISTS Instructors(
    CRN int NOT NULL,
    CONSTRAINT I_fk_01
        FOREIGN KEY (CRN) REFERENCES CourseSections(CRN) ON UPDATE CASCADE,
    EmployeeID int NOT NULL,
    CONSTRAINT I_fk_02
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID) ON UPDATE CASCADE,
    CONSTRAINT I_pk
        PRIMARY KEY (CRN, EmployeeID)
);

-- Create Assignments Table
CREATE TABLE IF NOT EXISTS Assignments(
    AssignmentID int AUTO_INCREMENT PRIMARY KEY,
    DueDate datetime,
    DateAssigned datetime not null,
    CourseCRN int NOT NULL,
    CONSTRAINT Assignments_fk_01
        FOREIGN KEY (CourseCRN) REFERENCES CourseSections(CRN) ON UPDATE CASCADE
);

-- Create Submissions Table
CREATE TABLE IF NOT EXISTS Submissions(
    SubmissionID int auto_increment PRIMARY KEY,
    AssignmentID int NOT NULL,
    CONSTRAINT Sub_fk_01
        FOREIGN KEY (AssignmentID) REFERENCES Assignments(AssignmentID) ON UPDATE CASCADE,
    Grade int,
    GradedOn DATETIME,
    TurnedIn DATETIME,
    RegradeRequestStatus boolean default False,
    GradedBy int,
    CONSTRAINT Sub_fk_02
        FOREIGN KEY (GradedBy) REFERENCES Employees(EmployeeID) ON UPDATE CASCADE
);

-- Create SubmissionsComments Table
CREATE TABLE IF NOT EXISTS SubmissionsComments(
    SubmissionCommentID int auto_increment primary key,
    CommentText text NOT NULL,
    SubmissionID int NOT NULL,
    CONSTRAINT SubCom_fk_01
        FOREIGN KEY (SubmissionID) REFERENCES Submissions(SubmissionID) ON UPDATE CASCADE
);

-- Create Enrollements Table
CREATE TABLE IF NOT EXISTS Enrollements(
    EnrollmentID int auto_increment primary key,
    EnrollDate DATETIME,
    Status boolean default FALSE,
    FinalGrade int,
    StudentID int NOT NULL,
    CONSTRAINT Enrolle_fk_01
        FOREIGN KEY (StudentID) REFERENCES Students(StudentID) ON UPDATE CASCADE,
    CoordinatorID int NOT NULL,
    CONSTRAINT Enrolle_fk_02
        FOREIGN KEY (CoordinatorID) REFERENCES AcademicCoordinators(CoordinatorID) ON UPDATE CASCADE,
    CRN int NOT NULL,
    CONSTRAINT Enrolle_fk_03
        FOREIGN KEY (CRN) REFERENCES CourseSections(CRN) ON UPDATE CASCADE
);

-- Create FeedbackSurveys Table
CREATE TABLE IF NOT EXISTS FeedbackSurveys(
    SurveyID int auto_increment primary key,
    Feedback text not null,
    Date DATETIME not null,
    ReviewerID int not null,
    CONSTRAINT feedback_fk_01
        FOREIGN KEY (ReviewerID) REFERENCES Students(StudentID) ON UPDATE CASCADE,
    Status boolean,
    ReceivedBy int Not null,
    CONSTRAINT feedback_fk_02
        FOREIGN KEY (ReceivedBy) REFERENCES Employees(EmployeeID) ON UPDATE CASCADE,
    CRN int Not NULL,
      CONSTRAINT feedback_fk_03
        FOREIGN KEY (CRN) REFERENCES CourseSections(CRN) ON UPDATE CASCADE
);

-- Create Chats Table
CREATE TABLE IF NOT EXISTS Chats(
    ChatID int auto_increment primary key,
    Message text not null,
    SenderID int NOT NULL,
     CONSTRAINT Chats_fk_01
        FOREIGN KEY (SenderID) REFERENCES Students(StudentID) ON UPDATE CASCADE,
    RecipientID int NOT NULL,
    CONSTRAINT Chats_fk_02
        FOREIGN KEY (RecipientID) REFERENCES Employees(EmployeeID) ON UPDATE CASCADE,
    TimeSent DATETIME not null
);

-- Create ChatReplies Table
CREATE TABLE IF NOT EXISTS ChatReplies(
    ReplyID int auto_increment primary key,
    ChatID int NOT NULL,
    CONSTRAINT ChatsReply_fk_01
        FOREIGN KEY (ChatID) REFERENCES Chats(ChatID) ON UPDATE CASCADE,
    SenderID int NOT NULL,
    CONSTRAINT ChatsReply_fk_02
        FOREIGN KEY (SenderID) REFERENCES Chats(RecipientID) ON UPDATE CASCADE,
    RecipientID int NOT NULL,
    CONSTRAINT ChatsReply_fk_03
        FOREIGN KEY (RecipientID) REFERENCES Chats(SenderID) ON UPDATE CASCADE,
    TimeSent DATETIME not null,
    ChatReplyText TEXT NOT NULL
);

-- Create DiscussionPost Table
CREATE TABLE IF NOT EXISTS DiscussionPosts(
    PostID int auto_increment primary key,
    CRN INT NOT NULL,
    CONSTRAINT DiscussionPost_fk_01
        FOREIGN KEY (CRN) REFERENCES CourseSections(CRN) ON UPDATE CASCADE,
    StudentID INT NOT NULL,
    CONSTRAINT DiscussionPost_fk_02
        FOREIGN KEY (StudentID) REFERENCES Students(StudentID) ON UPDATE CASCADE,
    PostTitle text NOT NULL,
    PostContent text NOT NULL
);

-- Create DiscussionPostComments Table
CREATE TABLE IF NOT EXISTS DiscussionPostComments(
    DPCommentID int auto_increment PRIMARY KEY,
    PostID int NOT NULL,
     CONSTRAINT DiscussionPostComment_fk_01
        FOREIGN KEY (PostID) REFERENCES DiscussionPosts(PostID) ON UPDATE CASCADE,
    StudentID int NOT NULL,
    CONSTRAINT DiscussionPostComment_fk_02
        FOREIGN KEY (StudentID) REFERENCES Students(StudentID) ON UPDATE CASCADE,
    TimePosted DATETIME not null,
    CommentText text not null
);

-- Create DiscussionPostAnswers Table
CREATE TABLE IF NOT EXISTS DiscussionPostAnswers(
    DPAnsswerID int auto_increment PRIMARY KEY,
    PostID int NOT NULL,
    CONSTRAINT DiscussionPostAnswer_fk_01
        FOREIGN KEY (PostID) REFERENCES DiscussionPosts(PostID) ON UPDATE CASCADE,
    EmployeeID int NOT NULL,
    CONSTRAINT DiscussionPostAnswer_fk_02
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID) ON UPDATE CASCADE,
    TimePosted DATETIME not null,
    DiscussionPostAnswer TEXT not null
);


-- Add sample data. 
-- Insert dummy data into Employees table
INSERT INTO Employees (FirstName, LastName, EmployeeTitle)
VALUES
    ('John', 'Doe', 'Professor'),
    ('Jane', 'Smith', 'Assistant Professor'),
    ('Michael', 'Johnson', 'Teaching Assistant'),
    ('Rachel', 'Davis', 'Teaching Assistant');

-- Insert dummy data into EmployeesEmails table
INSERT INTO EmployeesEmails (EmployeeID, Email)
VALUES
    (1, 'john.doe@example.com'),
    (1, 'j.doe@university.edu'),
    (2, 'jane.smith@example.com'),
    (3, 'michael.johnson@example.com'),
    (4, 'rachel.davis@example.com');

-- Insert dummy data into Schedule table
INSERT INTO Schedule (EmployeeID, HoursWorked)
VALUES
    (1, 40),
    (2, 35),
    (3, 20),
    (4, 20);

-- Insert dummy data into DayTimeWorked table
INSERT INTO DayTimeWorked (Day, Timeslot, ScheduleID)
VALUES
    ('Monday', '9:00 AM - 1:00 PM', 1),
    ('Tuesday', '10:00 AM - 2:00 PM', 2),
    ('Wednesday', '1:00 PM - 5:00 PM', 3),
    ('Thursday', '2:00 PM - 6:00 PM', 4);

-- Insert dummy data into Students table
INSERT INTO Students (FirstName, LastName)
VALUES
    ('Emily', 'Davis'),
    ('Matthew', 'Brown'),
    ('Emma', 'Wilson'),
    ('Oliver', 'Taylor'),
    ('Sophia', 'Martinez'),
    ('Jacob', 'Anderson'),
    ('Ava', 'Garcia'),
    ('William', 'Thomas'),
    ('Isabella', 'Hernandez'),
    ('Ethan', 'Lopez'),
    ('Mia', 'Young'),
    ('Alexander', 'Scott'),
    ('Charlotte', 'Nguyen'),
    ('James', 'Lewis'),
    ('Amelia', 'Adams'),
    ('Benjamin', 'Robinson'),
    ('Sophie', 'Walker'),
    ('Daniel', 'Wright'),
    ('Olivia', 'Lee'),
    ('Lucas', 'Allen');

-- Insert dummy data into StudentsEmails table
INSERT INTO StudentsEmails (StudentID, Email)
VALUES
    (1, 'emily.davis@example.com'),
    (1, 'e.davis@university.edu'),
    (2, 'matthew.brown@example.com'),
    (3, 'emma.wilson@example.com'),
    (4, 'oliver.taylor@example.com'),
    (5, 'sophia.martinez@example.com'),
    (6, 'jacob.anderson@example.com'),
    (7, 'ava.garcia@example.com'),
    (8, 'william.thomas@example.com'),
    (9, 'isabella.hernandez@example.com'),
    (10, 'ethan.lopez@example.com'),
    (11, 'mia.young@example.com'),
    (12, 'alexander.scott@example.com'),
    (13, 'charlotte.nguyen@example.com'),
    (14, 'james.lewis@example.com'),
    (15, 'amelia.adams@example.com'),
    (16, 'benjamin.robinson@example.com'),
    (17, 'sophie.walker@example.com'),
    (18, 'daniel.wright@example.com'),
    (19, 'olivia.lee@example.com'),
    (20, 'lucas.allen@example.com');

-- Insert dummy data into AcademicAdvisors table
INSERT INTO AcademicCoordinators (FirstName, LastName, Phone, Department, Supervisor)
VALUES
    ('Sarah', 'Johnson', '123-456-7890', 'Computer Science', 1),
    ('David', 'Clark', '987-654-3210', 'Mathematics', 2),
    ('Jennifer', 'Lee', '111-222-3333', 'Physics', 1);

-- Insert dummy data into AcademicAdvisorsEmails table
INSERT INTO AcademicCoordinatorEmails (CoordinatorID, Email)
VALUES
    (1, 'sarah.johnson@example.com'),
    (2, 'david.clark@example.com'),
    (3, 'jennifer.lee@example.com');

-- Insert dummy data into Courses table
INSERT INTO Courses (Department)
VALUES
    ('Computer Science'),
    ('Mathematics'),
    ('Physics');

-- Insert dummy data into CourseSections table
INSERT INTO CourseSections (CourseID, Year, Semester)
VALUES
    (1, 2024, 'Spring'),
    (2, 2024, 'Spring'),
    (3, 2024, 'Spring');

-- Insert dummy data into Instructors table
INSERT INTO Instructors (CRN, EmployeeID)
VALUES
    (1, 1),
    (2, 2),
    (3, 3);

-- Insert dummy data into Assignments table
INSERT INTO Assignments (DueDate, DateAssigned, CourseCRN)
VALUES
    ('2024-04-30', '2024-04-15', 1),
    ('2024-04-30', '2024-04-15', 2),
    ('2024-04-30', '2024-04-15', 3);

-- Insert dummy data into Submissions table
INSERT INTO Submissions (AssignmentID, Grade, GradedOn, TurnedIn, RegradeRequestStatus, GradedBy)
VALUES
    (1, 95, '2024-04-30', '2024-04-28', FALSE, 1),
    (2, NULL, NULL, '2024-04-28', FALSE, 2),
    (3, 85, '2024-04-30', '2024-04-28', FALSE, 3);

-- Insert dummy data into SubmissionsComments table
INSERT INTO SubmissionsComments (CommentText, SubmissionID)
VALUES
    ('Great work!', 1),
    ('Well done!', 2),
    ('Needs improvement.', 3);

-- Insert dummy data into Enrollments table
INSERT INTO Enrollements (EnrollDate, Status, FinalGrade, StudentID, CoordinatorID, CRN)
VALUES
    ('2024-01-15', TRUE, 90, 1, 1, 1),
    ('2024-01-20', TRUE, 85, 2, 2, 2),
    ('2024-01-25', FALSE, NULL, 3, 3, 3),
    ('2024-01-25', TRUE, 95, 4, 1, 1),
    ('2024-01-25', TRUE, 80, 5, 1, 2),
    ('2024-01-25', FALSE, NULL, 6, 2, 3),
    ('2024-01-25', TRUE, 85, 7, 2, 1),
    ('2024-01-25', TRUE, 92, 8, 3, 2),
    ('2024-01-25', FALSE, NULL, 9, 1, 3),
    ('2024-01-25', TRUE, 88, 10, 3, 1),
    ('2024-01-25', TRUE, 90, 11, 2, 2),
    ('2024-01-25', FALSE, NULL, 12, 1, 3),
    ('2024-01-25', TRUE, 82, 13, 1, 1),
    ('2024-01-25', TRUE, 85, 14, 2, 2),
    ('2024-01-25', FALSE, NULL, 15, 3, 3),
    ('2024-01-25', TRUE, 90, 16, 1, 1),
    ('2024-01-25', TRUE, 88, 17, 2, 2),
    ('2024-01-25', FALSE, NULL, 18, 3, 3),
    ('2024-01-25', TRUE, 95, 19, 1, 1),
    ('2024-01-25', TRUE, 85, 20, 2, 2);

-- Insert dummy data into FeedbackSurveys table
INSERT INTO FeedbackSurveys (Feedback, Date, ReviewerID, Status, ReceivedBy, CRN)
VALUES
    ('Great course!', '2024-04-30', 1, TRUE, 1, 1),
    ('Excellent instructor!', '2024-04-30', 2, TRUE, 2, 2),
    ('Could use improvement.', '2024-04-30', 3, FALSE, 3, 3);

-- Insert dummy data into Chats table
INSERT INTO Chats (Message, SenderID, RecipientID, TimeSent)
VALUES
    ('Hi, can you help me with this assignment?', 1, 3, '2024-04-01 10:00:00'),
    ('Sure, what do you need?', 3, 1, '2024-04-01 10:05:00'),
    ('I need clarification on question 2', 1, 3, '2024-04-01 10:10:00');

-- Insert dummy data into ChatReplies table
INSERT INTO ChatReplies (ChatID, SenderID, RecipientID, TimeSent, ChatReplyText)
VALUES
    (1, 3, 1, '2024-04-01 10:15:00', 'Sure, I can help you with that.'),
    (2, 1, 3, '2024-04-01 10:20:00', 'I need clarification on the second part of question 2.'),
    (3, 3, 1, '2024-04-01 10:25:00', 'Sure, I''ll explain it to you');

-- Insert dummy data into DiscussionPosts table
INSERT INTO DiscussionPosts (CRN, StudentID, PostTitle, PostContent)
VALUES
    (1, 1, 'Question about Lecture 3', 'I have a question about the material covered in lecture 3.'),
    (2, 2, 'Assignment 2 Discussion', 'Let''s discuss assignment 2 and any challenges we are facing.'),
    (3, 3, 'Upcoming Exam', 'Does anyone have any tips for preparing for the upcoming exam?');

-- Insert dummy data into DiscussionPostComments table
INSERT INTO DiscussionPostComments (PostID, StudentID, TimePosted, CommentText)
VALUES
    (1, 2, '2024-04-02 09:00:00', 'I can help clarify the concepts from lecture 3.'),
    (1, 3, '2024-04-02 09:15:00', 'I also have some questions regarding the lecture.'),
    (2, 1, '2024-04-03 10:00:00', 'I''m struggling with question 2 on assignment 2.'),
    (3, 2, '2024-04-03 10:15:00', 'I recommend reviewing the practice quizzes for the exam.');

-- Insert dummy data into DiscussionPostAnswers table
INSERT INTO DiscussionPostAnswers (PostID, EmployeeID, TimePosted, DiscussionPostAnswer)
VALUES
    (1, 1, '2024-04-02 10:00:00', 'Feel free to ask your questions here and I''ll do my best to help.'),
    (2, 3, '2024-04-03 11:00:00', 'Let''s break down the problem step by step.'),
    (3, 2, '2024-04-03 12:00:00', 'I suggest creating a study schedule and focusing on the key concepts.');
