-- ADMIN
USE AIS
------------------------------------------------------------------------------------------------------------------------------------------------------
															--ADD, VIEW, UPDATE STUDENT--
------------------------------------------------------------------------------------------------------------------------------------------------------
-- a. Add student
EXEC dbo.sp_AddStudent
    @StudentLogin = 'S004',           -- Student ID
    @StudentPwd = 'Student123',		  -- Temporary password
    @StudentName = 'Student4',        -- Student's name
    @StudentPhone = '012-4256132';    -- Student's phone number
GO

-- b. View Student (except password)
EXEC SP_Admin_ViewStudent

-- b. update student details except password (option1)
EXEC dbo.SP_AdminUpdateStudent
    @StudentLogin = 'S003',            -- Student ID
    @NewStudentName = 'Student3',  -- New student name
    @NewStudentPhone = '012-5557777';  -- New student phone number
GO

-- update phone only (option2) 
EXEC SP_AdminUpdateStudent
    @StudentLogin = 'S003',            -- Student ID
    @NewStudentPhone = '012-5556236';  -- New student phone number
GO

------------------------------------------------------------------------------------------------------------------------------------------------------
															--ADD, VIEW, UPDATE LECTURER--
------------------------------------------------------------------------------------------------------------------------------------------------------
-- a. Add lecturer
EXEC sp_AddLecturer
    @LecturerLogin = 'L005',
    @LecturerPwd = 'Temp123',
    @LecturerName = 'Lecturer5',
    @LecturerPhone = '013-9909091',
    @LecturerDept = 'Marketing';
GO

-- b. View Lecturer
EXEC SP_Admin_ViewLecturer

-- b. Update Lecturer
EXEC SP_AdminUpdateLecturer
    @LecturerLogin = 'L001',            -- Lecturer's login ID
	@NewLecturerName = 'Lecturer1',
    @NewLecturerPhone = '011-5231230',  -- New lecturer phone number
    @NewLecturerDept = 'Marketing';       -- New lecturer department
GO


-- update Departure only (option2)
EXEC SP_AdminUpdateLecturer
    @LecturerLogin = 'L009',            -- Lecturer's login ID
    @NewLecturerDept = 'Economics';       -- New lecturer department
GO


------------------------------------------------------------------------------------------------------------------------------------------------------
															--ADD, VIEW, UPDATE, DELETE SUBJECT--
------------------------------------------------------------------------------------------------------------------------------------------------------
-- c. View subject
SELECT * FROM Subject;

-- c. Add Subject
EXEC SP_AddSubject 
    @Code = 'JAVA3', 
    @Title = 'Java Programming';
GO

-- c. Update Subject 
EXEC SP_AdminUpdateSubject
		@OldCode = 'CHI2',                    
        @NewCode = 'CHI1',
		@NewTitle = 'Chinese 1'
GO

-- c. Delete subject
EXEC SP_DeleteSubject
		@SubjectCode = 'JAVA3'              
GO

------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
															--VIEW, DELETE RESULT--
------------------------------------------------------------------------------------------------------------------------------------------------------
-- View result
OPEN SYMMETRIC KEY LecturerIDKey DECRYPTION BY PASSWORD = 'LecturerIDEncryptionKey@456';
GO
SELECT 
    ID,                             -- Result Table ID (Auto-generated)
    StudentID,                      -- Student ID (Foreign Key from Student Table)
    CONVERT(VARCHAR(100), DECRYPTBYKEY(LecturerID)) AS DecryptedLecturerID,   -- Decrypted Lecturer ID
    SubjectCode,                    -- Subject Code (Foreign Key from Subject Table)
    AssessmentDate,                 -- Date of Assessment
	Grade                           -- Masked Grade
FROM 
    Result;
GO
CLOSE SYMMETRIC KEY LecturerIDKey;
GO

-- d. Delete Result
EXEC SP_DeleteResult
	@ResultID = '7'
GO

-- e. admin track deleted data
-- admin track deleted / modified subject data
EXEC SP_TrackSubjectData
GO
 
-- admin track deleted / modified result record
EXEC SP_TrackResultData
GO

-- f. admin recover selected deleted any data 
-- admin recover deleted / modified subject data
EXEC SP_RecoverSubjectData 
	@Code = 'DBS4', 
	@ValidFrom = '2024-09-17 14:10:03.6308390';
GO
 
-- admin recover result record
EXEC SP_RecoverResultByID 
	@ID = 4,
	@ExpectedValidTo = '2024-09-17 14:06:05.1411781';
GO


------------------------------------------------------------------------------------------------------------------------------------------------------
															--Steps that are NOT Allowed--
------------------------------------------------------------------------------------------------------------------------------------------------------
-- g. Cannot read or update lecturer/student password
SELECT * FROM Student
SELECT * FROM Lecturer

SELECT ID, Name, Phone AS Unmasked_Phone                      
FROM Student;    

OPEN SYMMETRIC KEY LecturerIDKey DECRYPTION BY PASSWORD = 'LecturerIDEncryptionKey@456';
GO
SELECT 
    CONVERT(VARCHAR(100), DECRYPTBYKEY(ID)) AS DecryptedLecturerID,   
    Name,                    
    Phone AS Unmasked_Phone,                   
    Department              
FROM 
    Lecturer;
GO
CLOSE SYMMETRIC KEY LecturerIDKey;
GO

-- h. read, add or update student's result
-- Cannot View result
SELECT * FROM Result

-- Can View without result column 
OPEN SYMMETRIC KEY LecturerIDKey DECRYPTION BY PASSWORD = 'LecturerIDEncryptionKey@456';
SELECT 
    ID,                             -- Result Table ID (Auto-generated)
    StudentID,                      -- Student ID (Foreign Key from Student Table)

    CONVERT(VARCHAR(100), DECRYPTBYKEY(LecturerID)) AS DecryptedLecturerID,   -- Decrypted Lecturer ID
    SubjectCode,                    -- Subject Code (Foreign Key from Subject Table)
    AssessmentDate                  -- Date of Assessment
	-- Without Grade Column
FROM 
    Result;
CLOSE SYMMETRIC KEY LecturerIDKey;

GO

-- cannot update (Result Table is denied)
UPDATE Result
SET 
	Grade = 'B'
WHERE ID = 3;

-- cannot insert
OPEN SYMMETRIC KEY LecturerIDKey
DECRYPTION BY PASSWORD = 'LecturerIDEncryptionKey@456';  

DECLARE @EncryptedLecturerID VARBINARY(MAX);
SELECT @EncryptedLecturerID = ID
FROM Lecturer
WHERE CONVERT(VARCHAR(10), DECRYPTBYKEY(ID)) = 'L001';

INSERT INTO Result (StudentID, LecturerID, SubjectCode, AssessmentDate,Grade )
VALUES ('S001', @EncryptedLecturerID, 'ENG1', '2024-10-01','D');
CLOSE SYMMETRIC KEY LecturerIDKey;

-- i. drop any table
DROP TABLE Student;
DROP TABLE Result;
DROP TABLE Lecturer;
DROP TABLE Subject;

