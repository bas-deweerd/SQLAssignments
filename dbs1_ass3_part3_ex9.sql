-- 1 write a procedure which increments the number of years
-- served for a given president. If further incrementing
-- would result in a value of more than eight years, a 
-- warning is given and the increment is not carried through.
CREATE OR REPLACE FUNCTION incrementYearsServed(presidentSearched varchar)
   RETURNS void AS $$
 DECLARE
   oldYearsServed int = (SELECT years_served FROM president WHERE name = presidentSearched);
 BEGIN
   IF oldYearsServed + 1 > 8
	THEN  RAISE EXCEPTION 'Warning, years served more than 8.';
   ELSE  UPDATE President
	SET years_served = oldYearsServed + 1
	WHERE name = presidentSearched;
 END IF;
 END;
$$ LANGUAGE plpgsql;

	-- procedure test
	SELECT incrementYearsServed ('WASHINGTON G'); --should give an error

	SELECT	years_served
	FROM	president
	WHERE	name = 'WASHINGTON G';

-- 2 write a procedure to add a marriage to the pres_marriage
-- table.If the president's marriage year lies before his
-- birth year + 21, a warning is given and the marriage 
-- is not stored.
CREATE OR REPLACE FUNCTION addMarriage(pres_id int, spouse_name varchar, spouse_age int, nr_children int, marriage_year int)
   RETURNS void AS $$
BEGIN
   IF marriage_year < (select birth_year from president where id = pres_id)+ 21
	THEN RAISE EXCEPTION 'Warning, president age at least 21 before marrying.';
   ELSE 
	INSERT INTO pres_marriage (pres_id, spouse_name, spouse_age, nr_children, marriage_year)
	VALUES (pres_id, spouse_name, spouse_age, nr_children, marriage_year);
END IF;
END;
$$ LANGUAGE plpgsql;

	-- procedure test
	SELECT addMarriage (1, 'FirstName LastName', 25, 2, 1753); -- should not give error

	SELECT addMarriage (1, 'FirstName LastName', 25, 2, 1750); -- should give error




-- 3 write a procedure which adds one more hobbies to a given
-- president's data. If the hobby in the table does not 
-- exist in the database yet, a warning is output and the 
-- hobby is not entered.
CREATE OR REPLACE FUNCTION addHobby(pres_id int, hobbyName varchar)
   RETURNS void AS $$
BEGIN
   IF hobbyName NOT IN (select distinct hobby from pres_hobby)
	THEN RAISE EXCEPTION 'Warning, hobby does not exist in database.';
   ELSE 
	INSERT INTO pres_hobby (pres_id, hobby)
	VALUES (pres_id, hobbyName);
END IF;
END;
$$ LANGUAGE plpgsql;

	-- procedure test
	SELECT addHobby (1, 'BILLIARDS'); -- should not give error
	SELECT addHobby (1, 'NON EXISTENT HOBBY'); -- should give error


-- 4 write a procedure which enters a new state. ADMIN_ENTERED 
-- and PRESNAME_ENTERED will be filled automatically
-- by the procedure.							
CREATE OR REPLACE FUNCTION addNewState(stateId int, stateName varchar,stateYearEntered int)
   RETURNS void AS $$
DECLARE 
  admin_entered int = (select admin_nr from administration 
			where id in(select id from administration where year_inaugurated <= stateYearEntered 
									and year_inaugurated + 4 > stateYearEntered ));
BEGIN
   INSERT INTO state (id, name, admin_id, year_entered)
   VALUES (stateID, stateName, admin_entered, stateYearEntered);
END;
$$ LANGUAGE plpgsql;

	-- procedure test
	SELECT addNewState (51, 'NEWSTATE', 2000);



-- 5 write a procedure which enters a new tenure in the
-- administration table. The administration number has to be
-- equal to the existing maximum number +1. If this is not the
-- case, a warning is given and the new administration is not stored.
CREATE OR REPLACE FUNCTION addNewTenure(newId int, adminNr int, presId int, yearInaugurated int)
   RETURNS void AS $$
DECLARE 
   correctId int = (select max(id) from administration) + 1;
BEGIN
   IF newId !=correctId
	THEN RAISE EXCEPTION 'Warning, administration number is incorrect.';
   ELSE 
	INSERT INTO administration (id, admin_nr, pres_id, year_inaugurated)
	VALUES (newId, adminNr, presId, yearInaugurated);
END IF;
END;
$$ LANGUAGE plpgsql;

	--procedure test
	SELECT addNewTenure (67, 57, 39, 2017); -- should not give errors
	SELECT addNewTenure (68, 57, 39, 2017); -- should give error



-- 6 write a procedure to enter a new vice-president to an 
-- existing tenure. If the vice-president's name is equal to
-- the president's name, a warning is given and the 
-- vice-president is not entered.					
CREATE OR REPLACE FUNCTION addVicePresident(vicePresidentName varchar, administrationId int)
   RETURNS void AS $$
DECLARE 
   presidentName varchar = (select name from president where id IN 
								(select pres_id from administration where id = administrationId));
BEGIN
   IF vicePresidentName = presidentName
	THEN RAISE EXCEPTION 'Warning, vice president name is equal to president name';
   ELSE 
	INSERT INTO admin_vpres (admin_id, vice_pres_name)
	VALUES (administrationId, vicePresidentName) ;
END IF;
END;
$$ LANGUAGE plpgsql;

	--procedure test
	SELECT addVicePresident ('VICE PRESIDENT NAME', 66); -- should not give error
	SELECT addVicePresident ('OBAMA B', 66); --should give error