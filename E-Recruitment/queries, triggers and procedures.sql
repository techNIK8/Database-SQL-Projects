3a)
SELECT First_Name, Surname, Name, ID, salary, count(username_of_candidate) 
FROM Recruiter INNER JOIN Job ON Recruiter.Username=Job.username_of_recruiter INNER JOIN applies ON applies.ID=Job.id INNER JOIN Company ON Company.afm=Recruiter.afm_of_company 
WHERE Job.Salary>1900 GROUP BY recruiter.username 


3b)
SELECT Username, Certifications_text, count(date_of_apoktisi), AVG(grade) 
FROM Candidate INNER JOIN has ON Candidate.username=Has.candid
WHERE count(date_of_apoktisi)>1 GROUP BY recruiter.username


3c)
SELECT Candidate.username, count(Job.ID), AVG(job.salary) 
FROM Candidate INNER JOIN applies ON applies.username_of_candidate=username.candidate INNER JOIN Job ON Job.ID=applies.ID
WHERE AVG(job.salary)>1800 
 


4a)
DELIMITER $
CREATE PROCEDURE JobRanker (IN JobId INT) 
BEGIN
DECLARE finishedFlag INT;
DECLARE candidate_username VARCHAR(12);
DECLARE overall_score INT;
DECLARE education_score INT;
DECLARE experience_score INT;
DECLARE personality_score INT;
DECLARE no_of_interviews_taken_per_candidate INT;
DECLARE CURSOR JobRanker FOR SELECT candidate.username SUM(evaluation.education,evaluation.experience,evaluation.personality), evaluation.education, evaluation.experience, evaluation.personality, count(Interview.job_Id) 
FROM candidate INNER JOIN Evaluation ON candidate.username=evaluation.candidate_username
ORDER BY SUM(evaluation.education,evaluation.experience,evaluation.personality) DESC
GROUP BY username 
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finishedFlag=1;
OPEN JobRanker;
SET finishedFlag=0;
REPEAT
FETCH JobRanker INTO candidate_username, overall_score, education_score, experience_score, personality_score, no_of_interviews_taken_per_candidate;
IF (finishedFlag=0) THEN 
SELECT candidate_username AS 'candidate username', overall_score AS 'overall score', education_score AS 'education score', experience_score AS 'experience score', personality_score AS 'personality score', no_of_interviews_taken_per_candidate AS 'no of interviews taken per candidate';
SELECT candidate_username AS 'candidate username FAIL', 'inadequate education' AS 'Reason of Failure1' WHERE education_score=0;
SELECT candidate_username AS 'candidate username FAIL', 'no prior experience' AS 'Reason of Failure2' WHERE experience_score=0;
SELECT candidate_username AS 'candidate username FAIL', 'failed the interview' AS 'Reason of Failure3' WHERE personality_score=0;
SELECT CONCAT_WS(" ", Reason of Failure1, Reason of Failure2, Reason of Failure3) AS 'Reason of Failure'
END IF;
UNTIL (finishedFlag=1)
END REPEAT;
CLOSE lectCursor;
END$
DELIMITER ;



4b)
DELIMITER $
CREATE TRIGGER insertion AFTER INSERT ON candidate
	FOR EACH ROW
	BEGIN
	  INSERT INTO log (action,username,date,table_name) VALUES
	  ('insert',NEW.username,DATETIME(),'candidate');
	END$
DELIMITER ;


CREATE TRIGGER insertion AFTER INSERT ON recruiter
	FOR EACH ROW
	BEGIN
	  INSERT INTO log (action,username,date,table_name) VALUES
	  ('insert',NEW.username,DATETIME(),'recruiter');
	END$
DELIMITER ;


CREATE TRIGGER insertion AFTER INSERT ON user
	FOR EACH ROW
	BEGIN
	  INSERT INTO log (action,username,date,table_name) VALUES
	  ('insert',NEW.username,DATETIME(),'user');
	END$
DELIMITER ;


CREATE TRIGGER insertion AFTER INSERT ON company
	FOR EACH ROW
	BEGIN
	  INSERT INTO log (action,username,date,table_name) VALUES
	  ('insert',NEW.username,DATETIME(),'company');
          INSERT INTO company(AFM, DOY, name) VALUES
	  (OLD.AFM,OLD.DOY,OLD.name,);	  			
	END$
DELIMITER ;


CREATE TRIGGER insertion AFTER INSERT ON job
	FOR EACH ROW
	BEGIN
	  INSERT INTO log (action,username,date,table_name) VALUES
	  ('insert',NEW.username,DATETIME(),'job');
	END$
DELIMITER ;



CREATE TRIGGER update AFTER UPDATE ON candidate
	FOR EACH ROW
	BEGIN
	  INSERT INTO log (action,username,date,table_name) VALUES
	  ('update',NEW.username,DATETIME(),'candidate');
	END$
DELIMITER ;


CREATE TRIGGER update AFTER UPDATE ON recruiter
	FOR EACH ROW
	BEGIN
	  INSERT INTO log (action,username,date,table_name) VALUES
	  ('update',NEW.username,DATETIME(),'recruiter');
	END$
DELIMITER ;


CREATE TRIGGER update AFTER UPDATE ON user
	FOR EACH ROW
	BEGIN
	  INSERT INTO log (action,username,date,table_name) VALUES
	  ('update',NEW.username,DATETIME(),'user');
	END$
DELIMITER ;


CREATE TRIGGER update AFTER UPDATE ON company
	FOR EACH ROW
	BEGIN
	  INSERT INTO log (action,username,date,table_name) VALUES
	  ('update',NEW.username,DATETIME(),'company');
          INSERT INTO company(AFM, DOY, name) VALUES
	  (OLD.AFM,OLD.DOY,OLD.name,);
	END$
DELIMITER ;


CREATE TRIGGER update AFTER UPDATE ON job
	FOR EACH ROW
	BEGIN
	  INSERT INTO log (action,username,date,table) VALUES
	  ('update',NEW.username,DATETIME(),'job');
	END$
DELIMITER ;



CREATE TRIGGER deletion AFTER DELETE ON candidate
	FOR EACH ROW
	BEGIN
	  INSERT INTO log (action,username,date,table_name) VALUES
	  ('deletion',OLD.username,DATETIME(),'candidate');
	END$
DELIMITER ;


CREATE TRIGGER deletion AFTER DELETE ON recruiter
	FOR EACH ROW
	BEGIN
	  INSERT INTO log (action,username,date,table_name) VALUES
	  ('deletion',OLD.username,DATETIME(),'recruiter');
	END$
DELIMITER ;

	
CREATE TRIGGER deletion AFTER DELETE ON user
	FOR EACH ROW
	BEGIN
	  INSERT INTO log (action,username,date,table_name) VALUES
	  ('deletion',OLD.username,DATETIME(),'user');
	END$
DELIMITER ;


CREATE TRIGGER deletion AFTER DELETE ON company
	FOR EACH ROW
	BEGIN
	  INSERT INTO log (action,username,date,table_name) VALUES
	  ('deletion',OLD.username,DATETIME(),'company');
	END$
DELIMITER ;


CREATE TRIGGER deletion AFTER DELETE ON job
	FOR EACH ROW
	BEGIN
	  INSERT INTO log (action,username,date,table_name) VALUES
	  ('deletion',OLD.username,DATETIME(),'job');
	END$
DELIMITER ;

4c)
CREATE TRIGGER expiration_check BEFORE DELETE ON Job
FOR EACH ROW
BEGIN
DECLARE currDate DATE;
DECLARE diff INT;
SET currDate=CURDATE();
SET diff=ABS(DATEDIFF(currDate,job.Date_of_expiration));
IF diff>=0 THEN
SIGNAL SQLSTATE VALUE '45000'
SET MESSAGE_TEXT = 'Job application expired';
END IF;
END$
DELIMITER ;

